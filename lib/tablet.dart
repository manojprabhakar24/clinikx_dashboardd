

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'Addstaff.dart';
import 'config.dart';


class TabletDashboard extends StatefulWidget {
  @override
  _TabletDashboardState createState() => _TabletDashboardState();
}

class _TabletDashboardState extends State<TabletDashboard> {
  String selectedItem = '';
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
              child: Text('No data available'),
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

                    SizedBox(width: 16),
                    Text("Powered by",
                        style: TextStyle(color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14
                        )),// Add some spacing between Admin text and logo
                    Image.asset(
                      AppConfig.matrical,
                      height: 150,
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
                    AppConfig.contact, // Replace 'your_image.png' with your image path
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
            MaterialPageRoute(builder: (context) => StaffDetailsForm()),
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
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
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
                              child: Text(
                                branchName,
                                style: TextStyle(
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              onTap: () {
                                _showBranchDetailsPopup(
                                  context,
                                  branchName,
                                  branch['city'],
                                  branch['area'],
                                  branch['state'],
                                  branch['mobileNumber'],
                                  branch['branchId'],
                                  branch['status'],
                                );
                              },
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
      String status) {
    TextEditingController nameController =
    TextEditingController(text: branchName);
    TextEditingController areaController = TextEditingController(text: area);
    TextEditingController cityController = TextEditingController(text: city);
    TextEditingController stateController = TextEditingController(text: state);
    TextEditingController mobileController =
    TextEditingController(text: mobileNumber);
    TextEditingController govIdController = TextEditingController();
    TextEditingController fromTimeController = TextEditingController();
    TextEditingController toTimeController = TextEditingController();

    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    // Fetch all branch details from Firestore
    FirebaseFirestore.instance
        .collection('branches')
        .doc(branchId)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          nameController.text = doc['clinicName'] ?? '';
          areaController.text = doc['area'] ?? '';
          cityController.text = doc['city'] ?? '';
          stateController.text = doc['state'] ?? '';
          mobileController.text = doc['mobileNumber'] ?? '';
          govIdController.text = doc['govIdNumber'] ?? '';
          fromTimeController.text = doc['timingFrom'] ?? '';
          toTimeController.text = doc['timingTo'] ?? '';
        });
      }
    });


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.grey[200],
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.purple, width: 2), // Purple outline
              borderRadius: BorderRadius.circular(16.0),
            ),
            constraints: BoxConstraints(maxWidth: 550, maxHeight: 500),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      status == 'PA' ? 'Edit Branch Details' : 'View Branch Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Branch Name',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple), // Purple outline
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple), // Purple outline
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                      enabled: status == 'PA',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the branch name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: areaController,
                      decoration: InputDecoration(
                        labelText: 'Area',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple), // Purple outline
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple), // Purple outline
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                      enabled: status == 'PA',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the area';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: cityController,
                      decoration: InputDecoration(
                        labelText: 'City',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                      enabled: status == 'PA',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the city';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: stateController,
                      decoration: InputDecoration(
                        labelText: 'State',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                      enabled: status == 'PA',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the state';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: mobileController,
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.purple),
                        ),
                      ),
                      style: TextStyle(color: Colors.black),
                      enabled: status == 'PA',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the mobile number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Visibility(
                      visible: status == 'BP',
                      child: Column(
                        children: [
                          TextFormField(
                            controller: govIdController,
                            decoration: InputDecoration(
                              labelText: 'Government ID Number',
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.purple),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.purple),
                              ),
                            ),
                            style: TextStyle(color: Colors.black),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the government ID number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: fromTimeController,
                            decoration: InputDecoration(
                              labelText: 'Timings From',
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.purple),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.purple),
                              ),
                            ),
                            style: TextStyle(color: Colors.black),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the timings from';
                              }
                              String pattern =
                                  r'^(1[0-2]|0?[1-9]):([0-5][0-9]) ([APap][mM])$';
                              RegExp regex = RegExp(pattern);
                              if (!regex.hasMatch(value)) {
                                return 'Invalid timings format. Please use hh:mm AM/PM';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: toTimeController,
                            decoration: InputDecoration(
                              labelText: 'Timings To',
                              labelStyle: TextStyle(color: Colors.black),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.purple),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.purple),
                              ),
                            ),
                            style: TextStyle(color: Colors.black),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the timings to';
                              }
                              String pattern =
                                  r'^(1[0-2]|0?[1-9]):([0-5][0-9]) ([APap][mM])$';
                              RegExp regex = RegExp(pattern);
                              if (!regex.hasMatch(value)) {
                                return 'Invalid timings format. Please use hh:mm AM/PM';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Close',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Update branch details in Firestore
                              FirebaseFirestore.instance
                                  .collection('branches')
                                  .doc(branchId)
                                  .update({
                                'clinicName': nameController.text,
                                'area': areaController.text,
                                'city': cityController.text,
                                'state': stateController.text,
                                'mobileNumber': mobileController.text,
                                'govIdNumber': govIdController.text,
                                'timingFrom': fromTimeController.text,
                                'timingTo': toTimeController.text,
                              }).then((_) {
                                // Update status from 'BP' to 'PA'
                                return FirebaseFirestore.instance
                                    .collection('branches')
                                    .doc(branchId)
                                    .update({
                                  'status': 'PA',
                                });
                              }).then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                      Text('Data updated successfully')),
                                );
                                Navigator.of(context).pop();
                              }).catchError((error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Failed to update data: $error')),
                                );
                              });
                            }
                          },
                          child: Text(
                            status == 'PA' ? 'edit' : 'SAVE',
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.purple,
                            onPrimary: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
