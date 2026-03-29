import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../../services/api_service.dart';
import '../../models/chat_message.dart';

class SupportChatScreen extends StatefulWidget {
  final String ticketId;

  const SupportChatScreen({Key? key, required this.ticketId}) : super(key: key);

  @override
  _SupportChatScreenState createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  String? _ticketSubject;
  String? _ticketStatus;

  WebSocketChannel? _channel;
  bool _isConnected = false;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
    _connectWebSocket();
    _startFallbackPolling();
  }

  void _startFallbackPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isConnected && mounted) {
        _loadInitialMessages();
      }
    });
  }

  void _connectWebSocket() async {
    try {
      final token = await ApiService.getAccessToken();
      if (token == null) return;

      final wsUrl =
          '${ApiService.BASE_URL.replaceFirst('http', 'ws')}/ws/chat/${widget.ticketId}/?token=$token';

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          _handleIncomingMessage(data);
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _error = 'Connection error. Reconnecting...';
              _isConnected = false;
            });
            _reconnect();
          }
        },
        onDone: () {
          if (mounted) {
            setState(() {
              _isConnected = false;
            });
            _reconnect();
          }
        },
      );

      if (mounted) {
        setState(() {
          _isConnected = true;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to connect. Retrying...';
          _isConnected = false;
        });
        _reconnect();
      }
    }
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _connectWebSocket();
    });
  }

  void _handleIncomingMessage(Map<String, dynamic> data) {
    if (!mounted) return;

    setState(() {
      _messages.removeWhere(
        (m) => m.isOptimistic == true && m.text == data['message'],
      );
      _messages.add(ChatMessage.fromJson(data));
    });
    _scrollToBottom();
  }

  Future<void> _loadInitialMessages() async {
    try {
      final response = await ApiService().getAuth(
        '/api/support/tickets/${widget.ticketId}/',
      );

      if (mounted) {
        setState(() {
          final rawMessages = response['ticket'] != null
              ? (response['ticket']['messages'] ?? response['messages'] ?? [])
              : (response['message_list'] ?? response['messages'] ?? []);

          _ticketSubject =
              response['ticket']?['subject'] ?? response['subject'];
          _ticketStatus = response['ticket']?['status'] ?? response['status'];

          _messages = (rawMessages as List)
              .map((msg) => ChatMessage.fromJson(msg))
              .toList();
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      print('Error loading messages: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    final tempMessage = ChatMessage(
      id: tempId,
      text: messageText,
      isFromUser: true,
      isFromAdmin: false,
      timestamp: DateTime.now(),
      isRead: false,
      isOptimistic: true,
    );

    setState(() {
      _messages.add(tempMessage);
    });
    _scrollToBottom();
    FocusScope.of(context).unfocus();

    try {
      if (_channel != null && _isConnected) {
        _channel!.sink.add(
          jsonEncode({'action': 'send_message', 'message': messageText}),
        );
      } else {
        // Fallback to HTTP
        final response = await ApiService().postAuth(
          '/api/support/tickets/${widget.ticketId}/messages/',
          body: {'message': messageText},
        );
        if (mounted) {
          setState(() {
            _messages.removeWhere((m) => m.id == tempId);
            if (response['message'] != null) {
              _messages.add(ChatMessage.fromJson(response['message']));
            }
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.removeWhere((m) => m.id == tempId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send message'),
            backgroundColor: Colors.red,
          ),
        );
        _messageController.text = messageText;
      }
    }
  }

  String _formatTime(DateTime time) {
    final localTime = time.toLocal();
    final hour = localTime.hour > 12
        ? localTime.hour - 12
        : (localTime.hour == 0 ? 12 : localTime.hour);
    final amPm = localTime.hour >= 12 ? 'PM' : 'AM';
    final minute = localTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $amPm';
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isFromUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF1DB954),
              child: Icon(Icons.support_agent, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Sender name (only for admin)
                  if (!isUser && message.senderName != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 2),
                      child: Text(
                        message.senderName!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1DB954),
                        ),
                      ),
                    ),

                  // Message bubble
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(
                              0xFF1DB954,
                            ).withOpacity(message.isOptimistic ? 0.7 : 1.0)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser
                            ? const Radius.circular(16)
                            : const Radius.circular(4),
                        bottomRight: isUser
                            ? const Radius.circular(4)
                            : const Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(message.timestamp),
                              style: TextStyle(
                                fontSize: 10,
                                color: isUser
                                    ? Colors.white70
                                    : Colors.grey[600],
                              ),
                            ),
                            if (isUser &&
                                message.isRead &&
                                !message.isOptimistic) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.done_all,
                                size: 12,
                                color: isUser
                                    ? Colors.white70
                                    : Colors.grey[600],
                              ),
                            ] else if (isUser &&
                                !message.isRead &&
                                !message.isOptimistic) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.check,
                                size: 12,
                                color: isUser
                                    ? Colors.white70
                                    : Colors.grey[600],
                              ),
                            ] else if (isUser && message.isOptimistic) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.access_time,
                                size: 10,
                                color: isUser
                                    ? Colors.white70
                                    : Colors.grey[600],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    final isClosed = _ticketStatus?.toLowerCase() == 'closed';

    if (isClosed) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Center(
            child: Text(
              'This ticket is closed.',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: 4,
                minLines: 1,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              onPressed: _sendMessage,
              mini: true,
              backgroundColor: const Color(0xFF1DB954),
              elevation: 2,
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _ticketSubject ?? 'Support Chat',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (!_isConnected && !_isLoading)
              Text(
                'Connecting...',
                style: TextStyle(fontSize: 11, color: Colors.green[100]),
              )
            else if (_ticketStatus != null)
              Text(
                _ticketStatus!.toUpperCase().replaceAll('_', ' '),
                style: TextStyle(fontSize: 11, color: Colors.green[100]),
              ),
          ],
        ),
        backgroundColor: const Color(0xFF1DB954),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadInitialMessages();
              if (!_isConnected) _connectWebSocket();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1DB954)),
            )
          : Column(
              children: [
                if (_error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 16,
                    ),
                    color: Colors.red[100],
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red[800], fontSize: 12),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
                ),
                _buildInputBar(),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _channel?.sink.close(status.goingAway);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
