import 'package:clinikx_dashboardd/staff%20manage/staffpopup.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'addstaff.dart';


class StaffTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 50,),
          Container(
            width: MediaQuery.of(context).size.width * 0.95,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2), // Shadow color
                  spreadRadius: 2, // Spread radius
                  blurRadius: 3, // Blur radius
                  offset: Offset(0, 3 ), // Changes position of shadow
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Staff',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(width: 15,),
                    Icon(Icons.person_rounded, color: Colors.blue.shade900, size: 35),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Show the add staff form as a popup dialog when button is clicked
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: StaffDetailsForm(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  icon: Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Add Staff',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    // For desktop/tablet view
                    return _buildDataTable();
                  } else {
                    // For mobile view
                    return _buildMobileDataTable();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('staffs').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        List<QueryDocumentSnapshot> staffDocs = snapshot.data!.docs;

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('designation').get(),
          builder: (context, designationSnapshot) {
            if (designationSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (designationSnapshot.hasError) {
              return Center(child: Text('Error: ${designationSnapshot.error}'));
            }

            // Map designation IDs to their corresponding data
            Map<String, dynamic> designationData = {};
            designationSnapshot.data!.docs.forEach((doc) {
              designationData[doc.id] = doc.data();
            });

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
                dividerThickness: 1.0,
                columnSpacing: 60,
                dataRowHeight: 60,
                columns: [
                  DataColumn(label: Text('Image', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                  DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                  DataColumn(label: Text('Designation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                  DataColumn(label: Text('Assigned Designation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                  DataColumn(label: Text('Specialization', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                  DataColumn(label: Text('Experience', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                  DataColumn(label: Text('Mobile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                  DataColumn(label: Text('About', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                ],
                rows: staffDocs.map((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>; // Cast document data to Map<String, dynamic>

                  String assignedDesignation = '';

                  if (data.containsKey('designation')) {
                    String designationId = data['designation']; // Get designation ID from staff data
                    if (designationData.containsKey(designationId)) {
                      // Check if designation data exists for this ID
                      var designation = designationData[designationId];
                      assignedDesignation = designation['designation  '] ?? 'Unknown Designation'; // Assuming 'name' is the field for designation
                    }
                  }

                  return DataRow(
                    cells: [
                      DataCell(
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => StaffPopup(
                                image: data['image'] ?? '',
                                name: data['name'] ?? '',
                                designation: data['designation'] ?? '',
                                specialization: data['specialization'] ?? '',
                                experience: data['experience'] ?? '',
                                mobile: data['mobile'] ?? '',
                                about: data['about'] ?? '',
                                status: data['status'] ?? '',
                              ),
                            );
                          },
                          child: data['image'] != null
                              ? Image.network(
                            data['image'],
                            width: 80,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                              : SizedBox(),
                        ),
                      ),
                      DataCell(Text(data['name'] ?? '')),
                      DataCell(Text(data.containsKey('designation') ? data['designation'] : '')),
                      DataCell(Text(assignedDesignation)), // Display assigned designation
                      DataCell(Text(data['specialization'] ?? '')),
                      DataCell(Text(data['experience'] ?? '')),
                      DataCell(Text(data['mobile'] ?? '')),
                      DataCell(Text(data['about'] ?? '')),
                      DataCell(Text(data['status'] ?? '')),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }



  Widget _buildMobileDataTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('staffs').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        List<QueryDocumentSnapshot> staffDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: staffDocs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> data = staffDocs[index].data() as Map<String, dynamic>;

            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                leading: data['image'] != null
                    ? Image.network(
                  data['image'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
                    : SizedBox(),
                title: Text(data['name'] ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.containsKey('designation') ? data['designation'] : ''),
                    Text(data['specialization'] ?? ''),
                    Text(data['experience'] ?? ''),
                    Text(data['mobile'] ?? ''),
                    Text(data['about'] ?? ''),
                  ],
                ),
                onTap: () {
                  // Show the details popup when the row is clicked
                  showDialog(
                    context: context,
                    builder: (context) => StaffPopup(
                      image: data['image'] ?? '',
                      name: data['name'] ?? '',
                      designation: data['designation'] ?? '',
                      specialization: data['specialization'] ?? '',
                      experience: data['experience'] ?? '',
                      mobile: data['mobile'] ?? '',
                      about: data['about'] ?? '',
                      status: data['status'] ?? '',
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Staff Table Example',
    home: StaffTable(),
  ));
}
