import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'config.dart';
import 'firebase_options.dart'; // Import your configuration file for Firebase options



class FirestoreDropdownService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> getDesignations() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('designation').get();
      List<String> designations =
      querySnapshot.docs.map((doc) => doc.get('designation') as String).toList(); // Cast to String
      return designations;
    } catch (e) {
      print('Error fetching designations: $e');
      return []; // Return an empty list in case of an error
    }
  }

  Future<List<String>> getSpecializations() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('Specialisation').get();
      List<String> specializations =
      querySnapshot.docs.map((doc) => doc.get('Specialisation') as String).toList(); // Cast to String
      return specializations;
    } catch (e) {
      print('Error fetching specializations: $e');
      return []; // Return an empty list in case of an error
    }
  }
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> fetchBranchAndClinicData(String branchId, String clinicId) async {
    try {
      DocumentSnapshot branchSnapshot = await _firestore.collection('branches').doc(branchId).get();
      DocumentSnapshot clinicSnapshot = await _firestore.collection('clinics').doc(clinicId).get();

      if (branchSnapshot.exists && clinicSnapshot.exists) {
        Map<String, dynamic> data = {
          'branchId': branchSnapshot.id,
          'branchName': branchSnapshot.get('name'),
          'clinicId': clinicSnapshot.id,
          'clinicName': clinicSnapshot.get('name'),
        };
        return data;
      } else {
        throw Exception('Branch or clinic data not found.');
      }
    } catch (e) {
      print('Error fetching branch and clinic data: $e');
      throw Exception('Error fetching branch and clinic data.');
    }
  }

  Future<void> addStaffDetails({
    required String name,
    required String designation,
    required String specialization,
    required String experience,
    required String mobile,
    required String qualification,
    required String about,
    required dynamic image, // Use dynamic type for image
    required String createdBy,
  }) async {
    try {
      // Get the current timestamp
      DateTime createdAt = DateTime.now();

      // You can add more fields as needed
      await _firestore.collection('staffs').add({
        'name': name,
        'designation': designation,
        'specialization': specialization,
        'experience': experience,
        'mobile': mobile,
        'qualification': qualification,
        'about': about,
        'createdAt': createdAt,
        'createdBy': createdBy,
        'image': image, // Save the image as a dynamic type
        // Add other fields here
      });
    } catch (e) {
      // Handle errors if any
      print('Error adding staff details: $e');
    }
  }
}

class StaffDetailsForm extends StatefulWidget {
  @override
  _StaffDetailsFormState createState() => _StaffDetailsFormState();
}

class _StaffDetailsFormState extends State<StaffDetailsForm> {
  TextEditingController nameController = TextEditingController();
  String? designationValue;
  String? specializationValue;
  TextEditingController experienceController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController qualificationController = TextEditingController();
  TextEditingController aboutController = TextEditingController();

  dynamic _image; // Use dynamic type for image
  final picker = ImagePicker();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late FirestoreService _firestoreService;
  late FirestoreDropdownService _dropdownService;
  List<String> designations = [];
  List<String> specializations = [];
  bool specializationEnabled = true;
  bool specializationEditable = true;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _dropdownService = FirestoreDropdownService();
    fetchDataForDropdowns();
  }

  Future<void> fetchDataForDropdowns() async {
    designations = await _dropdownService.getDesignations();
    specializations = await _dropdownService.getSpecializations();
    setState(() {}); // Update the UI after fetching data
  }

  Widget _buildDropdownField(
      String? value,
      String label,
      List<String> options, {
        String? Function(String?)? validator,
        bool isEnabled = true,
        bool isEditable = true,
        void Function(String?)? onChanged, // Add readonly parameter with default false
      }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: isEditable? (newValue) {
          onChanged?.call(newValue); // Call the provided onChanged function
        }:null,
        items: options.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        ),
        validator: validator,
        onTap: () {},// Disable onTap if not enabled
      ),
    );
  }
  bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width > 600;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Padding(
              padding: EdgeInsets.all(25.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isDesktop(context))
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.purple),
                                borderRadius: BorderRadius.circular(20.0),
                              ),

                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 20),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.add_circle_sharp,
                                            color: Colors.purple,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            'Adding New Staff',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w200,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: getImage,
                                        child: Container(
                                          width: 300,
                                          height: 400,
                                          padding: EdgeInsets.all(20.0),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.purple),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: _image == null
                                                    ? Icon(Icons.add_photo_alternate_outlined,
                                                  color: Colors.purple,
                                                  size: 100,)
                                                    : Image.network(
                                                  _image,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  Expanded(
                                    flex: 1,
                                    child: SingleChildScrollView(
                                      child: Container(
                                        width: 200,
                                        height: 550,
                                        padding: EdgeInsets.all(30.0),
                                        child: buildFormFields(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: buildFormFields(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildFormFields() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      //crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTextField(
          nameController,
          'Enter Name',
          validator: validateName,
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                experienceController,
                'Enter Experience',
                validator: validateExperience,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                mobileController,
                'Enter Mobile Number',
                validator: validateMobile,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                designationValue,
                'Designation',
                designations,
                onChanged: (newValue) {
                  setState(() {
                    designationValue = newValue;
                    if (newValue == 'Doctor') {
                      specializationEnabled = true;
                      specializationEditable = true;
                    } else {
                      specializationEnabled = false;
                      specializationValue = null;
                      specializationEditable = false;
                    }
                  });
                },
                validator: validateDesignation,
              ),
            ),
            SizedBox(width: 10),
            if (specializationEnabled)
              Expanded(
                child: _buildDropdownField(
                  specializationValue,
                  'Specialization',
                  specializations,
                  onChanged: (newValue) {
                    setState(() {
                      specializationValue = newValue;
                    });
                  },
                  validator: validateSpecialization,
                ),
              ),
          ],
        ),
        SizedBox(height: 10),
        _buildTextField(
          qualificationController,
          'Enter Qualification',
          validator: validateQualification,
        ),
        SizedBox(height: 10),
        _buildTextField(
          aboutController,
          'About Doctor',
          maxLines: 3,
        ),
        SizedBox(height: 20),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _firestoreService.addStaffDetails(
                    name: nameController.text,
                    designation: designationValue ?? '',
                    specialization: specializationValue ?? '',
                    experience: experienceController.text,
                    mobile: mobileController.text,
                    qualification: qualificationController.text,
                    about: aboutController.text,
                    image: _image,
                    createdBy: 'UserXYZ',
                  ).then((_) {
                    // Show snackbar and clear form
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Data stored successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    _formKey.currentState?.reset();
                    nameController.clear();
                    experienceController.clear();
                    mobileController.clear();
                    qualificationController.clear();
                    aboutController.clear();
                    setState(() {
                      designationValue = null;
                      specializationValue = null;
                      _image = null;
                    });
                  }).catchError((error) {
                    // Handle error if data storage fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to store data: $error'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              child: Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                // Clear form fields
                _formKey.currentState?.reset();
                nameController.clear();
                experienceController.clear();
                mobileController.clear();
                qualificationController.clear();
                aboutController.clear();
                setState(() {
                  designationValue = null;
                  specializationValue = null;
                  _image = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        int maxLines = 1,
        String? Function(String?)? validator,
      }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          errorStyle: TextStyle(fontSize: 12),
        ),
        maxLines: maxLines,
        validator: validator,
        onChanged: (_) {
          // Reset error state when user modifies the text field
          _formKey.currentState?.validate();
        },
      ),
    );
  }


  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppMessages.nameerror;
    }
    return null;
  }
  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return AppMessages.mobilenumbererror;
    }
    return null;
  }
  String? validateExperience(String? value) {
    if (value == null || value.isEmpty) {
      return AppMessages.experienceerror;
    }
    return null;
  }
  String? validateQualification(String? value) {
    if (value == null || value.isEmpty) {
      return AppMessages.qualificationerror;
    }
    return null;
  }
  String? validateDesignation(String? value) {
    if (value == null || value.isEmpty) {
      return AppMessages.Designstionerror;
    }
    return null;
  }
  String? validateSpecialization(String? value) {
    if (value == null || value.isEmpty) {
      return AppMessages.Specializationerror;
    }
    return null;
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = pickedFile.path; // Store image path for mobile, URL for web
      } else {
        print('No image selected.');
      }
    });
  }
}
