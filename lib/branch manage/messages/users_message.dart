class UserMessages {

  static String branchDetailsSavedSuccessfully() {
  return 'Branch details updated successfully';
  }
  static String dataUpdatedSuccessfully() {
    return 'Data updated successfully';
  }

  static String branchApprovalPendingTitle() {
    return 'Branch Approval Pending';
  }
  static String branchApprovalPendingContent() {
    return 'Your branch profile is completed. Please wait until your branch gets approval';
  }

  static String branchProfileEditedTitle() {
    return 'Branch Profile Edited';
  }
  static String branchProfileEditedContent() {
    return 'Your branch profile is edited successfully.\nPlease wait until you get approval for your branch.';
  }

  static String editBranchDetails() {
    return 'Edit Branch Details';
  }

  static String branchProfileIncomplete() {
    return 'Please click on edit icon and complete your branch profile to get approval';
  }

  static String branchProfileCompleted() {
    return 'Your branch profile is completed.\nPlease wait until your branch gets approval';
  }

  static String viewBranchDetails() {
    return 'View Branch Details';
  }
  static const String profileUpdatedSuccessfully = 'Profile updated successfully';
  static const Map<String, String> statusFullForms = {
    'BP': 'Branch Pending',
    'PA': 'Pending Approval',
  };
  static const String selectItemFromDrawerMessage =
      'Please select an item from the drawer to view details.';
  static const String branchDetailsSaved = 'Branch details saved successfully.';
  static const String branchProfileEdited = 'Your branch profile is edited successfully.';
  static const String branchApprovalPending = 'Your branch profile is completed. Please wait until your branch gets approval.';
}
