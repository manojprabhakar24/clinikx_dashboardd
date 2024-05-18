class ErrorMessages {
  static String failedToUpdateData(String error) {
  return 'Failed to update data: $error';
  }

  static String pleaseEnter(String field) {
  return 'Please enter $field';
  }

  static String pleaseEnterValidFormat(String field) {
  return 'Please enter $field in valid format';
  }

  static String noImagesSelected() {
  return 'No images selected';
  }

  static const String noBranchesAvailable='No branches available.';

  static const String noFileSelected = 'No file selected';
  static const String pleaseEnterValue = 'Please enter';
  static const Map<String, String> statusFullForms = {
    'BP': 'Branch Pending',
    'PA': 'Pending Approval',
  };
  static const String failedToUploadFile = 'Failed to upload file';
  static const String failedToDownloadFile = 'Failed to download file';
  static const String pleaseSelectDocument = 'Please select a document';
  static const String enterBranchName = 'Please enter the branch name';
  static const String enterArea = 'Please enter the area';
  static const String enterCity = 'Please enter the city';
  static const String enterState = 'Please enter the state';
  static const String enterMobileNumber = 'Please enter the mobile number';
  static const String enterGovIdNumber = 'Please enter the government ID number';
  static const String enterTimingFrom = 'Please enter the timings from';
  static const String enterTimingTo = 'Please enter the timings to';
  static const String invalidTimingFormat = 'Please enter the timings in "hh:mm AM/PM" format';
}
