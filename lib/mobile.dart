import 'dart:typed_data';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import 'Addstaff.dart';
import 'config.dart';

class MobileDashboard extends StatefulWidget {
  @override
  _MobileDashboardState createState() => _MobileDashboardState();
}

class _MobileDashboardState extends State<MobileDashboard> {
  String selectedItem = ''; // Track the selected item in the drawer
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController govIdController = TextEditingController();
  TextEditingController fromTimeController = TextEditingController();
  TextEditingController toTimeController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  double appBarElevation = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      appBarElevation = _scrollController.offset > 0 ? 4.0 : 0.0;
    });
  }
  Future<Uint8List?> pickImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: source, imageQuality: 50);
    if (_file != null) {
      return await _file.readAsBytes();
    }
    print('No Images Selected');
    return null;
  }


  // RegExp pattern to match the 12-hour time format
  final RegExp timeRegex = RegExp(
    r'^((0?[1-9]|1[0-2]):([0-5][0-9]) ([AaPp][Mm]))$',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purpleAccent, Colors.deepPurple],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: appBarElevation,
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                );
              },
            ),

            title: AnimatedOpacity(
              opacity: appBarElevation > 0 ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Text(
                'Welcome Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.person),
                onPressed: () {
                  // Navigate to profile page
                },
              ),
            ],
          ),
        ),
      ),
      body: _buildBody(),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  AppConfig.imagelogo,
                  height: 60,
                ),
                SizedBox(height: 8),
              ],
            ),
          ),
          _buildDrawerItem('Branch Manage'),
          _buildDrawerItem('Staff Manage'),
          _buildDrawerItem('Appointments'),
          _buildDrawerItem('Patients'),
          _buildDrawerItem('Subscription'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String title) {
    return ListTile(
      title: Text(title),
      selected: selectedItem == title,
      onTap: () => _selectDrawerItem(title),
    );
  }

  Widget _buildBody() {
    if (selectedItem == 'Branch Manage') {
      return _buildBranchDataTable();
    } else if (selectedItem == 'Staff Manage') {
      return StaffDetailsForm(); // Display Staff Details Form
    } else {
      return Center(
        child: Image.asset(
          AppConfig.imagelogo, // Replace 'assets/company_logo.png' with your actual image path
          width: 200, // Adjust the width as needed
          height: 200, // Adjust the height as needed
        ),
      );
    }
  }


  Widget _buildBranchDataTable() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('branches').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No branches available.'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            String branchName = snapshot.data!.docs[index]['clinicName'];
            String mobileNumber = snapshot.data!.docs[index]['mobileNumber'];
            String branchId = snapshot.data!.docs[index]['branchId'];
            Map<String, dynamic>? data =
            snapshot.data!.docs[index].data() as Map<String, dynamic>?;
            String? govIdNumber = data != null && data.containsKey('govIdNumber')
                ? data['govIdNumber']
                : null;
            String? timingFrom =
            data != null && data.containsKey('timingFrom') ? data['timingFrom'] : null;

            String? timingTo =
            data != null && data.containsKey('timingTo') ? data['timingTo'] : null;
            String? status =
            data != null && data.containsKey('status') ? data['status'] : null; // Fetch status

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ExpansionTile(
                  title: Text(branchName),
                  children: [
                    _buildDetailText('Area: ${snapshot.data!.docs[index]['area']}'),
                    _buildDetailText('City: ${snapshot.data!.docs[index]['city']}'),
                    _buildDetailText('State: ${snapshot.data!.docs[index]['state']}'),
                    _buildDetailText('Mobile Number: $mobileNumber'),
                    if (govIdNumber != null) _buildDetailText('Government ID: $govIdNumber'),
                    if (timingFrom != null) _buildDetailText('Timings From: $timingFrom'),
                    if (timingTo != null) _buildDetailText('Timings To: $timingTo'),
                    if (status != null) _buildDetailText('Status: $status'), // Display status if available
                    if (status == 'BP' &&
                        (govIdNumber == null || timingFrom == null || timingTo == null))
                      TextButton(
                        onPressed: () => _openCompleteProfilePopup(
                          context,
                          branchId,
                          branchName,
                          snapshot.data!.docs[index]['area'],
                          snapshot.data!.docs[index]['city'],
                          snapshot.data!.docs[index]['state'],
                          mobileNumber,
                          govIdNumber,
                          timingFrom,
                          timingTo,
                        ),
                        child: Text('Click here to complete profile'),
                      ),
                    if (status == 'PA' &&
                        govIdNumber != null &&
                        timingFrom!= null &&
                        timingTo != null)
                      ElevatedButton(
                        onPressed: () => _openEditProfilePopup(
                          context,
                          branchId,
                          branchName,
                          snapshot.data!.docs[index]['area'],
                          snapshot.data!.docs[index]['city'],
                          snapshot.data!.docs[index]['state'],
                          mobileNumber,
                          govIdNumber,
                          timingFrom,
                          timingTo,
                          status, // Pass status to edit profile popup
                        ),
                        child: Text('Edit'),
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openEditProfilePopup(
      BuildContext context,
      String branchId,
      String branchName,
      String area,
      String city,
      String state,
      String mobileNumber,
      String? govIdNumber,
      String? timingFrom,
      String? timingTo,
      String? status,
      ) {
    final _formKey = GlobalKey<FormState>();

    TextEditingController branchNameController = TextEditingController(text: branchName);
    TextEditingController areaController = TextEditingController(text: area);
    TextEditingController cityController = TextEditingController(text: city);
    TextEditingController stateController = TextEditingController(text: state);
    TextEditingController mobileNumberController = TextEditingController(text: mobileNumber);

    govIdController.text = govIdNumber ?? '';
    fromTimeController.text = timingFrom ?? '';
    toTimeController.text = timingTo ?? '';
    Uint8List? _image;

    // Create _ImagePick widget inside the dialog
    Widget imagePickerWidget = ImagePick(onImagePicked: (image) => _image = image);

    showDialog(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: AlertDialog(
          title: Text('Edit Branch Details'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: branchNameController,
                  decoration: InputDecoration(
                    labelText: 'Branch Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the branch name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: areaController,
                  decoration: InputDecoration(
                    labelText: 'Area',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the area';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: 'City',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the city';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: stateController,
                  decoration: InputDecoration(
                    labelText: 'State',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the state';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: mobileNumberController,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the mobile number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: govIdController,
                  decoration: InputDecoration(
                    labelText: 'Government ID Number',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the government ID number';
                    }
                    return null;
                  },
                ),

                ImagePick(onImagePicked: (image) => _image = image), // Add ImagePick widget here


                TextFormField(
                  controller: fromTimeController,
                  decoration: InputDecoration(
                    labelText: 'Timing From',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the timings from';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: toTimeController,
                  decoration: InputDecoration(
                    labelText: 'Timings To (hh:mm AM/PM)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the timings to';
                    }
                    if (!timeRegex.hasMatch(value)) {
                      return 'Please enter the timings in "hh:mm AM/PM" format';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  String updatedBranchName = branchNameController.text;
                  String updatedArea = areaController.text;
                  String updatedCity = cityController.text;
                  String updatedState = stateController.text;
                  String updatedMobileNumber = mobileNumberController.text;
                  String updatedGovIdNumber = govIdController.text;
                  String updatedTimingsFrom = fromTimeController.text;
                  String updatedTimingsTo = toTimeController.text;
                  // If a new image is selected, upload it and get the URL
                  String imageUrl = '';
                  if (_image != null) {
                    imageUrl = await _uploadImageToFirebase(branchId, _image!);
                  }

                  // Update the branch details in Firestore
                  await FirebaseFirestore.instance.collection('branches').doc(branchId).update({
                    'clinicName': updatedBranchName,
                    'area': updatedArea,
                    'city': updatedCity,
                    'state': updatedState,
                    'mobileNumber': updatedMobileNumber,
                    'govIdNumber': updatedGovIdNumber,
                    'timingFrom': updatedTimingsFrom,
                    'timingTo': updatedTimingsTo,
                    if (imageUrl.isNotEmpty) 'imageUrl': imageUrl, // Add the new image URL if available

                  });



                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Branch details updated successfully')));
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _openCompleteProfilePopup(
      BuildContext context,
      String branchId,
      String branchName,
      String area,
      String city,
      String state,
      String mobileNumber,
      String? govIdNumber,
      String? timingFrom,
      String? timingTo,
      ) {
    final _formKey = GlobalKey<FormState>();

    govIdController.text = govIdNumber ?? '';
    fromTimeController.text = timingFrom ?? '';
    toTimeController.text = timingTo ?? '';
    Uint8List? _image;
    showDialog(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: AlertDialog(
          title: Text('Complete Profile'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: govIdController,
                  decoration: InputDecoration(
                    labelText: 'Government ID Number',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the government ID number';
                    }
                    return null;
                  },
                ),
                ImagePick(onImagePicked: (image) => _image = image), // Add ImagePick widget here

                TextFormField(
                  controller: fromTimeController,
                  decoration: InputDecoration(
                    labelText: 'Timings From',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the timings to';
                    }
                    if (!timeRegex.hasMatch(value)) {
                      return 'Please enter the timings in "hh:mm AM/PM" format';
                    }
                    return null;
                  },
                ),

                TextFormField(
                  controller: toTimeController,
                  decoration: InputDecoration(
                    labelText: 'Timings To (hh:mm AM/PM)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the timings to';
                    }
                    if (!timeRegex.hasMatch(value)) {
                      return 'Please enter the timings in "hh:mm AM/PM" format';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  String imageUrl = await _uploadImageToFirebase(branchId, _image!);

                  // Update status to 'PA' in Firestore
                  await FirebaseFirestore.instance.collection('branches').doc(branchId).update({
                    'status': 'PA',
                    'govIdNumber': govIdController.text,
                    'timingFrom': fromTimeController.text,
                    'timingTo': toTimeController.text,
                    'imageUrl': imageUrl, // Add image URL to Firestore
                  });

                  // Show a snackbar to indicate successful update
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Profile updated successfully')));

                  // Update the UI immediately to reflect the new status
                  setState(() {
                    selectedItem = 'Branch Manage'; // Select Branch Manage item to reload the StreamBuilder
                  });

                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),

          ],
        ),
      ),
    );
  }
  Future<String> _uploadImageToFirebase(String branchId, Uint8List image) async {
    // Reference to a location in Firebase Storage
    Reference storageReference = FirebaseStorage.instance.ref().child('branches/$branchId/image.jpg');

    // Upload the file to Firebase Storage
    UploadTask uploadTask = storageReference.putData(image);

    // Get the download URL
    TaskSnapshot taskSnapshot = await uploadTask;
    String imageUrl = await taskSnapshot.ref.getDownloadURL();

    // Return the download URL
    return imageUrl;
  }



  Widget _buildDetailText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  void _selectDrawerItem(String item) {
    setState(() {
      selectedItem = item;
    });
    Navigator.pop(context); // Close the drawer after selecting an item
  }
}

class ImagePick extends StatefulWidget {
  final Function(Uint8List?) onImagePicked;

  ImagePick({required this.onImagePicked});

  @override
  _ImagePickState createState() => _ImagePickState(onImagePicked);
}

class _ImagePickState extends State<ImagePick> {
  final Function(Uint8List?) onImagePicked;

  _ImagePickState(this.onImagePicked);

  Uint8List? _image;

  void selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      setState(() {
        _image = img;
      });
      onImagePicked(_image); // Call the callback function here
    }
  }

  Future<Uint8List?> pickImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();
    XFile? _file = await _imagePicker.pickImage(source: source, imageQuality: 50);
    if (_file != null) {
      return await _file.readAsBytes();
    }
    print('No Images Selected');
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        _image != null
            ? Image.memory(
          _image!,
          height: 100,
        )
            : Column(
          children: [
            ElevatedButton(
              onPressed: selectImage,
              child: Text('Upload Document'),///
            ),
            Text(
              'Please select a document',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ],
    );
  }
}
