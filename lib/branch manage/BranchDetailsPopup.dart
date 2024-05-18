import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'DocumentViewer.dart';
import 'messages/error_message.dart';
import 'messages/users_message.dart';

class BranchDetailsPopup extends StatefulWidget {
  final String branchName;
  final String city;
  final String area;
  final String state;
  final String mobileNumber;
  final String branchId;
  final String status;

  BranchDetailsPopup({
    required this.branchName,
    required this.city,
    required this.area,
    required this.state,
    required this.mobileNumber,
    required this.branchId,
    required this.status,
  });

  @override
  _BranchDetailsPopupState createState() => _BranchDetailsPopupState();
}

class _BranchDetailsPopupState extends State<BranchDetailsPopup> {
  late TextEditingController nameController;
  late TextEditingController areaController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController mobileController;
  late TextEditingController govIdController;
  late TextEditingController fromTimeController;
  late TextEditingController toTimeController;

  final _formKey = GlobalKey<FormState>();

  bool isEditing = false;
  File? selectedFile;
  Uint8List? selectedFileBytes;
  String? selectedFileName;
  String? govDocumentUrl;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.branchName);
    areaController = TextEditingController(text: widget.area);
    cityController = TextEditingController(text: widget.city);
    stateController = TextEditingController(text: widget.state);
    mobileController = TextEditingController(text: widget.mobileNumber);
    govIdController = TextEditingController();
    fromTimeController = TextEditingController();
    toTimeController = TextEditingController();

    if (widget.status == 'PA' || widget.status == 'AA') {
      FirebaseFirestore.instance
          .collection('branches')
          .doc(widget.branchId)
          .get()
          .then((doc) {
        if (doc.exists) {
          setState(() {
            govIdController.text = doc['govIdNumber'] ?? '';
            govDocumentUrl = doc['governmentDocument'] ?? '';
            fromTimeController.text = doc['timingFrom'] ?? '';
            toTimeController.text = doc['timingTo'] ?? '';
          });
        }
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    areaController.dispose();
    cityController.dispose();
    stateController.dispose();
    mobileController.dispose();
    govIdController.dispose();
    fromTimeController.dispose();
    toTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'pdf'],
    );

    if (result != null) {
      if (kIsWeb) {
        setState(() {
          selectedFileBytes = result.files.first.bytes;
          selectedFileName = result.files.first.name;
        });
      } else {
        setState(() {
          selectedFile = File(result.files.single.path!);
        });
      }
    }
  }

  Future<String> _uploadFile() async {
    if (selectedFile == null && selectedFileBytes == null) {
      throw Exception("No file selected");
    }

    String fileName = selectedFileName ?? selectedFile!.path.split('/').last;
    Reference storageReference =
    FirebaseStorage.instance.ref().child('governmentDocuments/$fileName');

    UploadTask uploadTask;
    if (kIsWeb) {
      uploadTask = storageReference.putData(selectedFileBytes!);
    } else {
      uploadTask = storageReference.putFile(selectedFile!);
    }

    await uploadTask;
    return await storageReference.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    String buttonText = '';

    // Determine button text based on branch status and editing state
    if (isEditing) {
      buttonText = UserMessages.editBranchDetails();
    } else {
      switch (widget.status) {
        case 'BP':
          buttonText = UserMessages.branchProfileIncomplete();
          break;
        case 'PA':
          buttonText = UserMessages.branchProfileCompleted();
          break;
        case 'AA':
          buttonText = UserMessages.viewBranchDetails();
          break;
        default:
          buttonText = UserMessages.viewBranchDetails();
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.grey[200],
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.purple, width: 2),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          isEditing = true;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                buildTextFormField(nameController, 'Branch Name'),
                SizedBox(height: 16),
                buildTextFormField(areaController, 'Area'),
                SizedBox(height: 16),
                buildTextFormField(cityController, 'City'),
                SizedBox(height: 16),
                buildTextFormField(stateController, 'State'),
                SizedBox(height: 16),
                buildTextFormField(mobileController, 'Mobile Number'),
                SizedBox(height: 16),
                buildTextFormField(govIdController, 'Government ID Number'),
                SizedBox(height: 16),
                buildFilePicker(context),
                if (govDocumentUrl != null)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DocumentViewer(
                            documentUrl: govDocumentUrl!,
                          ),
                        ),
                      );
                    },
                    child: Text('View Document'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.purple,
                      onPrimary: Colors.white,
                    ),
                  ),
                SizedBox(height: 16),
                buildTextFormField(fromTimeController, 'Timings From'),
                SizedBox(height: 16),
                buildTextFormField(toTimeController, 'Timings To'),
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
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          String? fileUrl;
                          if (selectedFile != null ||
                              selectedFileBytes != null) {
                            fileUrl = await _uploadFile();
                          }

                          Map<String, dynamic> updateData = {
                            'clinicName': nameController.text,
                            'area': areaController.text,
                            'city': cityController.text,
                            'state': stateController.text,
                            'mobileNumber': mobileController.text,
                            if (fileUrl != null) 'governmentDocument': fileUrl,
                            if (widget.status == 'PA' || widget.status == 'BP')
                              'govIdNumber': govIdController.text,
                            if (widget.status == 'PA' || widget.status == 'BP')
                              'timingFrom': fromTimeController.text,
                            if (widget.status == 'PA' || widget.status == 'BP')
                              'timingTo': toTimeController.text,
                          };

                          // Include status update only if the status is not 'AA'
                          if (widget.status != 'AA') {
                            updateData['status'] = 'PA';
                          }

                          FirebaseFirestore.instance
                              .collection('branches')
                              .doc(widget.branchId)
                              .update(updateData)
                              .then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(UserMessages.dataUpdatedSuccessfully()),
                              ),
                            );
                            Navigator.of(context).pop();

                            // Show the message if the status is 'PA'
                            if (widget.status == 'PA') {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(UserMessages.branchProfileEditedTitle()),
                                    content: Text(UserMessages.branchProfileEditedContent()),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }).catchError((error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(UserMessages.branchDetailsSaved)),                            );
                          });
                        }
                      },
                      child: Text(
                        widget.status == 'PA' ? 'Edit' : 'SAVE',
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
  }

  TextFormField buildTextFormField(TextEditingController controller, String labelText) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.black),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.purple),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.purple),
        ),
      ),
      style: TextStyle(color: Colors.black),
      enabled: isEditing,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '${ErrorMessages.pleaseEnterValue} $labelText';
        }
        return null;
      },
    );
  }

  Widget buildFilePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Government Document',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ElevatedButton(
          onPressed: isEditing ? _pickFile : null,
          child: Text('Select Document'),
          style: ElevatedButton.styleFrom(
            primary: Colors.purple,
            onPrimary: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        if (selectedFileName != null)
          Text(
            selectedFileName!,
            style: TextStyle(color: Colors.black),
          ),
      ],
    );
  }
}
