import 'package:clinikx_dashboardd/branch%20manage/messages/error_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../config.dart';
import '../staff manage/addstaff.dart';
import '../staff manage/manage_staff.dart';
import 'BranchDetailsPopup.dart';

class TabletDashboard extends StatefulWidget {
  @override
  _TabletDashboardState createState() => _TabletDashboardState();
}

class _TabletDashboardState extends State<TabletDashboard> {
  String selectedItem = 'Branch Manage'; // Set default selected item
  String selectedBranchName = '';
  Map<String, String> statusFullForms = {
    'BP': 'Branch Pending',
    'PA': 'Pending Approval',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('branches').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(ErrorMessages.noBranchesAvailable),
            );
          }
          var branchData =
              (snapshot.data!.docs.first.data() as Map<String, dynamic>);
          String branchName = branchData['clinicName'] ?? '';
          String area = branchData['area'] ?? '';
          String city = branchData['city'] ?? '';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Image.asset(
                        AppConfig.imagelogo,
                        height: 60,
                      ),
                    ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Branch Name: ${branchName ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Area: ${area ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'City: ${city ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                // Add a divider for separation
                height: 1,
                color: Colors.grey,
              ),
              AppBar(
                backgroundColor: Colors.grey.shade50,
                elevation: 0,
                title: Row(
                  children: [
                    _buildMenuItem('Branch Manage'),
                    _buildMenuItem('Staff Manage'),
                    _buildMenuItem('Appointments'),
                    _buildMenuItem('Patients'),
                    _buildMenuItem('Subscription'),
                    Spacer(),
                    Expanded(
                      // Wrap the Row with Expanded
                      child: Row(
                        // New Row containing "Powered by" text and logo
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "Powered by",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(width: 7.1),
                          // Add some spacing between "Powered by" and logo
                          Flexible(
                            child: Container(
                              constraints:
                                  BoxConstraints(maxHeight: 160, maxWidth: 200),
                              // Adjust size as needed
                              child: Image.asset(
                                AppConfig.matrical,
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: selectedItem == 'Branch Manage'
                    ? _buildBranchDataTable()
                    : SizedBox(),
              ),
              SizedBox(height: 16),
              // Add some spacing between the table and the image
              // Add your image here
              Container(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Image.asset(
                    AppConfig.contact,
                    // Replace 'your_image.png' with your image path
                    height: 80, // Adjust the height as needed
                    width: 250, // Adjust the width as needed
                    // Adjust the fit as needed
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(String title) {
    return TextButton(
      onPressed: () {
        setState(() {
          selectedItem = title;
        });
        if (selectedItem == 'Staff Manage') {
          // Open the StaffDetailsForm
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StaffTable()),
          );
        }
      },
      child: Text(
        title,
        style: TextStyle(
          color: selectedItem == title ? Colors.purple : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBranchDataTable() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('branches').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                ),
                child: DataTable(
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  dataTextStyle: TextStyle(
                    color: Colors.black,
                  ),
                  columns: [
                    DataColumn(
                      label: Text(
                        'Branch Name',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Area',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'City',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'State',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Mobile Number',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                  rows: snapshot.data!.docs.map((DocumentSnapshot branch) {
                    String branchName = branch['clinicName'];
                    String branchId = branch.id; // Fetching the branchId
                    return DataRow(
                      cells: [
                        DataCell(
                          Tooltip(
                            message: statusFullForms[branch['status']] ?? '',
                            child: InkWell(
                              onTap: () {
                                _showBranchDetailsPopup(
                                  context,
                                  branch['clinicName'],
                                  branch['city'],
                                  branch['area'],
                                  branch['state'],
                                  branch['mobileNumber'],
                                  branch.id,
                                  branch['status'],
                                );
                              },
                              child: Text(
                                branchName,
                                style: TextStyle(
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            branch['area'],
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        DataCell(
                          Text(
                            branch['city'],
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        DataCell(
                          Text(
                            branch['state'],
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        DataCell(
                          Text(
                            branch['mobileNumber'],
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        DataCell(
                          Text(
                            branch['status'],
                            style: TextStyle(
                              color: branch['status'] == 'Active'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  void _showBranchDetailsPopup(
    BuildContext context,
    String branchName,
    String city,
    String area,
    String state,
    String mobileNumber,
    String branchId,
    String status,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BranchDetailsPopup(
          branchName: branchName,
          city: city,
          area: area,
          state: state,
          mobileNumber: mobileNumber,
          branchId: branchId,
          status: status,
        );
      },
    );
  }
}
