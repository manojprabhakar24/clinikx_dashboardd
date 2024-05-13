import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Define a list of colors for each row
    List<Color> rowColors = [
      Colors.blue.shade100,
      Colors.blue.shade50,
      Colors.blue.shade100,
      Colors.blue.shade50,
      Colors.blue.shade100,
      Colors.blue.shade50,
      Colors.blue.shade100,
      Colors.blue.shade50,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Table'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('staffs').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  List<QueryDocumentSnapshot> staffDocs = snapshot.data!.docs;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.black), // Vertical line color
                        ),
                      ),
                      child: DataTable(
                        dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
                        headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue),
                        dividerThickness: 3.0,
                        columns: [
                          DataColumn(label: Text('Image')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Designation')),
                          DataColumn(label: Text('Specialization')),
                          DataColumn(label: Text('Experience')),
                          DataColumn(label: Text('Mobile')),
                          DataColumn(label: Text('Qualification')),
                          DataColumn(label: Text('About')),
                        ],
                        rows: staffDocs.asMap().entries.map((entry) {
                          // Get a map representation of the document data
                          Map<String, dynamic> data = entry.value.data() as Map<String, dynamic>;

                          // Determine the color for this row based on its index
                          Color rowColor = rowColors[entry.key % rowColors.length];

                          return DataRow(
                            color: MaterialStateColor.resolveWith((states) => rowColor),
                            cells: [
                              DataCell(
                                // Check if 'image' exists and is not null
                                data['image'] != null
                                    ? Image.network(
                                  data['image'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                                    : SizedBox(), // Placeholder if image URL is null
                              ),
                              DataCell(Text(data['name'] ?? '')),
                              DataCell(
                                  Text(data.containsKey('designation') ? data['designation'] : '')),
                              DataCell(Text(data['specialization'] ?? '')),
                              DataCell(Text(data['experience'] ?? '')),
                              DataCell(Text(data['mobile'] ?? '')),
                              DataCell(Text(data['qualification'] ?? '')),
                              DataCell(Text(data['about'] ?? '')),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


