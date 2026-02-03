// reports_screen.dart
import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String? _selectedTurf;
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedReportType = 'monthly';
  
  List<String> turfNames = [
    'Green Field Arena',
    'City Sports Turf',
    'Elite Football Ground',
    'Victory Sports Park',
  ];

  List<String> reportTypes = ['daily', 'weekly', 'monthly', 'quarterly', 'yearly'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Reports & Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF00C853),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generate Report',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Turf Selection
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Turf',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedTurf,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: null,
                              child: Text('All Turfs'),
                            ),
                            ...turfNames.map((turf) => DropdownMenuItem(
                              value: turf,
                              child: Text(turf),
                            )).toList(),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedTurf = value;
                            });
                          },
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Report Type
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report Type',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: reportTypes.map((type) {
                            return FilterChip(
                              label: Text(type.toUpperCase()),
                              selected: _selectedReportType == type,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedReportType = type;
                                });
                              },
                              selectedColor: Color(0xFF00C853),
                              labelStyle: TextStyle(
                                color: _selectedReportType == type 
                                    ? Colors.white 
                                    : Colors.grey[700],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Date Range
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'From Date',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _selectStartDate(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 20, color: Colors.grey[600]),
                                      SizedBox(width: 8),
                                      Text(
                                        _startDate != null
                                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                            : 'Select date',
                                        style: TextStyle(
                                          color: _startDate != null
                                              ? Colors.black
                                              : Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'To Date',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _selectEndDate(context),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today,
                                          size: 20, color: Colors.grey[600]),
                                      SizedBox(width: 8),
                                      Text(
                                        _endDate != null
                                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                            : 'Select date',
                                        style: TextStyle(
                                          color: _endDate != null
                                              ? Colors.black
                                              : Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 24),
                    
                    // Generate Report Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _generateReport,
                        icon: Icon(Icons.insert_chart_outlined),
                        label: Text('Generate Report'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00C853),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Report Preview
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Summary Stats
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) => _buildReportStat(index),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _downloadPDF,
                            icon: Icon(Icons.picture_as_pdf, size: 18),
                            label: Text('Download PDF'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: BorderSide(color: Colors.red),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _downloadExcel,
                            icon: Icon(Icons.table_chart, size: 18),
                            label: Text('Download Excel'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: BorderSide(color: Colors.green),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Recent Reports
            Text(
              'Recent Reports',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) => _buildReportItem(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportStat(int index) {
    List<Map<String, dynamic>> stats = [
      {
        'title': 'Total Bookings',
        'value': '142',
        'icon': Icons.event_available,
        'color': Color(0xFF2196F3),
      },
      {
        'title': 'Gross Revenue',
        'value': '₹1,42,580',
        'icon': Icons.currency_rupee,
        'color': Color(0xFF4CAF50),
      },
      {
        'title': 'Avg Rating',
        'value': '4.7★',
        'icon': Icons.star,
        'color': Color(0xFFFF9800),
      },
      {
        'title': 'Cancellations',
        'value': '8',
        'icon': Icons.cancel,
        'color': Color(0xFFF44336),
      },
    ];
    
    final stat = stats[index];
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: stat['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  stat['icon'],
                  size: 18,
                  color: stat['color'],
                ),
              ),
              Spacer(),
              Text(
                '+12%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            stat['value'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            stat['title'],
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportItem(int index) {
    List<Map<String, dynamic>> reports = [
      {
        'title': 'January 2025 Report',
        'date': 'Generated on 01 Feb 2025',
        'type': 'Monthly',
        'downloads': 'PDF, Excel',
      },
      {
        'title': 'Weekly Report (22-28 Jan)',
        'date': 'Generated on 29 Jan 2025',
        'type': 'Weekly',
        'downloads': 'PDF',
      },
      {
        'title': 'Q4 2024 Report',
        'date': 'Generated on 05 Jan 2025',
        'type': 'Quarterly',
        'downloads': 'PDF, Excel',
      },
    ];
    
    final report = reports[index];
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report['title'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        report['date'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(0xFF00C853).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report['type'],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00C853),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.download, size: 16, color: Colors.grey[600]),
                SizedBox(width: 6),
                Text(
                  'Available in: ${report['downloads']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.download_outlined, size: 20),
                  onPressed: () {},
                  color: Color(0xFF00C853),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _generateReport() {
    // Generate report logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report generated successfully!'),
        backgroundColor: Color(0xFF00C853),
      ),
    );
  }

  void _downloadPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF report downloading...'),
        backgroundColor: Color(0xFF00C853),
      ),
    );
  }

  void _downloadExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Excel report downloading...'),
        backgroundColor: Color(0xFF00C853),
      ),
    );
  }
}