// operations_center_screen.dart
import 'package:flutter/material.dart';

class OperationsCenterScreen extends StatefulWidget {
  const OperationsCenterScreen({super.key});

  @override
  State<OperationsCenterScreen> createState() => _OperationsCenterScreenState();
}

class _OperationsCenterScreenState extends State<OperationsCenterScreen> {
  bool _isOpenToday = true;
  List<bool> _weeklySchedule = [true, true, true, true, true, false, false];
  List<Map<String, dynamic>> timeSlots = [
    {'time': '6:00 AM - 7:00 AM', 'visible': true},
    {'time': '7:00 AM - 8:00 AM', 'visible': true},
    {'time': '8:00 AM - 9:00 AM', 'visible': true},
    {'time': '9:00 AM - 10:00 AM', 'visible': true},
    {'time': '10:00 AM - 11:00 AM', 'visible': true},
    {'time': '12:00 PM - 1:00 PM', 'visible': true},
    {'time': '1:00 PM - 2:00 PM', 'visible': true},
    {'time': '2:00 PM - 3:00 PM', 'visible': true},
    {'time': '3:00 PM - 4:00 PM', 'visible': true},
    {'time': '4:00 PM - 5:00 PM', 'visible': true},
    {'time': '5:00 PM - 6:00 PM', 'visible': true},
    {'time': '6:00 PM - 7:00 PM', 'visible': true},
  ];
  TextEditingController reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Operations Center',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF00C853),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Today's Status Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF00C853).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.access_time, size: 24, color: Color(0xFF00C853)),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Today\'s Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manage availability and status for final',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Status Switch
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Status',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Quickly open or close for the remaining day',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _isOpenToday,
                          onChanged: (value) {
                            setState(() {
                              _isOpenToday = value;
                            });
                          },
                          activeColor: Color(0xFF00C853),
                          activeTrackColor: Color(0xFF00C853).withOpacity(0.3),
                        ),
                      ],
                    ),
                  ),

                  if (!_isOpenToday) ...[
                    SizedBox(height: 16),
                    Text(
                      'Reason for closing (optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                        color: Colors.white,
                      ),
                      child: TextField(
                        controller: reasonController,
                        maxLines: 3,
                        style: TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Enter reason for closing...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isOpenToday = !_isOpenToday;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isOpenToday ? Colors.red : Color(0xFF00C853),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _isOpenToday ? 'Close Facility for Today' : 'Open Facility for Today',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Weekly Schedule
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF00C853).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.calendar_today, size: 24, color: Color(0xFF00C853)),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Weekly Schedule',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ...['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                      .asMap()
                      .entries
                      .map((entry) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month, size: 20, color: Colors.grey[600]),
                          SizedBox(width: 12),
                          Text(
                            entry.value,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                          Switch(
                            value: _weeklySchedule[entry.key],
                            onChanged: (value) {
                              setState(() {
                                _weeklySchedule[entry.key] = value;
                              });
                            },
                            activeColor: Color(0xFF00C853),
                            activeTrackColor: Color(0xFF00C853).withOpacity(0.3),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Manage Individual Slots
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF00C853).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.schedule, size: 24, color: Color(0xFF00C853)),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Manage Individual Slots',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Disable specific hours for private coaching or maintenance',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: timeSlots.length,
                    itemBuilder: (context, index) {
                      final slot = timeSlots[index];
                      return Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: slot['visible'] ? Colors.grey[200]! : Colors.red[100]!,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              slot['time'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: slot['visible'] ? Colors.grey[800] : Colors.grey[600],
                              ),
                            ),
                            Switch(
                              value: slot['visible'],
                              onChanged: (value) {
                                setState(() {
                                  slot['visible'] = value;
                                });
                              },
                              activeColor: Color(0xFF00C853),
                              activeTrackColor: Color(0xFF00C853).withOpacity(0.3),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Emergency Kill-Switch
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red[100]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.05),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.warning, size: 24, color: Colors.red),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Emergency Kill-Switch',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Instantly block all new bookings for immediate operational stops.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[800],
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  // Event Selection
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[100]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Event Type',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[800],
                          ),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ['Heavy Rain', 'Power Failure', 'Maintenance', 'Other']
                              .map((event) => Chip(
                                    label: Text(event),
                                    backgroundColor: Colors.red[100],
                                    labelStyle: TextStyle(color: Colors.red[800]),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Confirm Emergency Stop'),
                            content: Text('This will block all new bookings immediately. Are you sure?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Emergency stop activated'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text('Activate'),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'Activate Emergency Stop',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}