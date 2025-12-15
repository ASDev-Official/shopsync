// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String returnClearedCountCompletedItems(int count) {
    return 'Cleared \$$count completed items';
  }

  @override
  String returnErrorDeletingListError(String error) {
    return 'Error deleting list: \$$error';
  }

  @override
  String returnErrorFetchingMaintenanceStatusError(String error) {
    return 'Error fetching maintenance status: \$$error';
  }

  @override
  String returnErrorSharingListError(String error) {
    return 'Error sharing list: \$$error';
  }

  @override
  String get returnHigh => 'high';

  @override
  String get returnLow => 'low';

  @override
  String get returnMedium => 'medium';

  @override
  String get returnNameMustBeAtLeast2Characters =>
      'Name must be at least 2 characters';

  @override
  String get returnNetworkErrorCheckYourConnectionAndTryAgain =>
      'Network error. Check your connection and try again';

  @override
  String get returnNetworkErrorPleaseCheckYourInternetConnectionAndTryAgain =>
      'Network error. Please check your internet connection and try again';

  @override
  String get returnNoAccountFoundWithThisEmail =>
      'No account found with this email';

  @override
  String get returnNoUserFoundForThatEmailPleaseCheckYourEmailAndTryAgain =>
      'No user found for that email. Please check your email and try again';

  @override
  String get returnPasswordMustBeAtLeast6Characters =>
      'Password must be at least 6 characters';

  @override
  String get returnPleaseEnterADisplayName => 'Please enter a display name';

  @override
  String get returnPleaseEnterAPassword => 'Please enter a password';

  @override
  String get returnPleaseEnterAValidEmailAddress =>
      'Please enter a valid email address';

  @override
  String get returnPleaseEnterYourEmail => 'Please enter your email';

  @override
  String get returnPleaseEnterYourName => 'Please enter your name';

  @override
  String get returnPleaseEnterYourPassword => 'Please enter your password';

  @override
  String get returnTheEmailAddressIsAlreadyInUseByAnotherAccount =>
      'The email address is already in use by another account';

  @override
  String get returnTheOperationIsNotAllowedPleaseTryAgainLaterIfItDoesn =>
      'The operation is not allowed. Please try again later. If it doesn\'t';

  @override
  String get returnThePasswordIsInvalidOrTheUserDoesNotHaveAPassword =>
      'The password is invalid or the user does not have a password';

  @override
  String get returnTheProvidedCredentialsAreIncorrectPleaseCheckYourEmailAndPassword =>
      'The provided credentials are incorrect. Please check your email and password';

  @override
  String get returnThisEmailIsAlreadyRegisteredPleaseSignInInstead =>
      'This email is already registered. Please sign in instead';

  @override
  String get returnThisPasswordIsTooWeakPleaseChooseAStrongerOne =>
      'This password is too weak. Please choose a stronger one';

  @override
  String get returnThisUserHasBeenDisabledPleaseContact =>
      'This user has been disabled. Please contact asdev.feedback@gmail.com';

  @override
  String get returnTooManyRequestsPleaseTryAgainLater =>
      'Too many requests. Please try again later';

  @override
  String returnVersionPackageinfoversionPackageinfobuildnumber(
      String packageInfoVersion, String packageInfoBuildNumber) {
    return 'Version \$$packageInfoVersion (\$$packageInfoBuildNumber)';
  }

  @override
  String get textappLanguage => 'App Language';

  @override
  String get textareYouSureYouWantToSignOut =>
      'Are you sure you want to sign out?';

  @override
  String get textcancel => 'Cancel';

  @override
  String get textclearCompletedItems => 'Clear Completed Items';

  @override
  String get textclearCompleted => 'Clear Completed';

  @override
  String get textclearItems => 'Clear Items';

  @override
  String textclearedCompleteditemsdocslengthCompletedItems(
      int completedItemsLength) {
    return 'Cleared \$$completedItemsLength completed items';
  }

  @override
  String get textcouldNotOpenPlayStore => 'Could not open Play Store';

  @override
  String get textcreate => 'Create';

  @override
  String get textdarkMode => 'Dark Mode';

  @override
  String get textdeleteList => 'Delete List';

  @override
  String get textdelete => 'Delete';

  @override
  String get textenableNotifications => 'Enable Notifications';

  @override
  String get textenglish => 'English';

  @override
  String texterrorFetchingMaintenanceStatusE(String e) {
    return 'Error fetching maintenance status: \$$e';
  }

  @override
  String texterrorLoadingListsSnapshoterror(String snapshotError) {
    return 'Error loading lists: \$$snapshotError';
  }

  @override
  String texterrorSharingListEtostring(String eToString) {
    return 'Error sharing list: \$$eToString';
  }

  @override
  String texterrorSigningOutEtostring(String eToString) {
    return 'Error signing out: \$$eToString';
  }

  @override
  String get textexportList => 'Export List';

  @override
  String get textfailedToCreateListPleaseTryAgain =>
      'Failed to create list. Please try again.';

  @override
  String get textfailedToDeleteItem => 'Failed to delete item';

  @override
  String get textfailedToDeleteList => 'Failed to delete list';

  @override
  String get textfailedToDeleteTask => 'Failed to delete task';

  @override
  String get textfailedToRestoreItem => 'Failed to restore item';

  @override
  String get textfailedToSignInWithGoogle => 'Failed to sign in with Google';

  @override
  String get textfailedToSignOutPleaseTryAgain =>
      'Failed to sign out. Please try again.';

  @override
  String get textfailedToUpdateTaskStatus => 'Failed to update task status';

  @override
  String get textlistDeletedSuccessfully => 'List deleted successfully';

  @override
  String get textloading => 'Loading...';

  @override
  String get textowner => 'Owner';

  @override
  String get textpleaseEnterATaskTitle => 'Please enter a task title';

  @override
  String get textprivacyPolicy => 'Privacy Policy';

  @override
  String get textprofileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get textrenameList => 'Rename List';

  @override
  String get textsaveChanges => 'Save Changes';

  @override
  String get textsave => 'Save';

  @override
  String get textselectLanguage => 'Select Language';

  @override
  String get textsettings => 'Settings';

  @override
  String get textsignOut => 'Sign Out';

  @override
  String get texttoggleDarklightTheme => 'Toggle dark/light theme';

  @override
  String get textuserAddedSuccessfully => 'User added successfully';

  @override
  String get textuserAlreadyHasAccessToThisList =>
      'User already has access to this list';

  @override
  String get textuserRemoved => 'User removed';

  @override
  String get textversion => 'Version';

  @override
  String get textviewRecycleBin => 'View Recycle Bin';

  @override
  String get titleAbout => 'About';

  @override
  String get titleAccessYourListsAndSettings =>
      'Access your lists and settings';

  @override
  String get titleAddItemsToYourList => 'Add items to your list';

  @override
  String get titleAppInformation => 'App Information';

  @override
  String get titleAppearance => 'Appearance';

  @override
  String get titleCreateNewList => 'Create New List';

  @override
  String get titleWeblate => 'Weblate';

  @override
  String get titleDeadline => 'Deadline';

  @override
  String get titleDescription => 'Description';

  @override
  String get titleGithub => 'GitHub';

  @override
  String get titleLanguage => 'Language';

  @override
  String get titleLocation => 'Location';

  @override
  String get titleMyProfile => 'My Profile';

  @override
  String get titleNotifications => 'Notifications';

  @override
  String get titleOpenTheDrawerFromTheLeft => 'Open the drawer from the left';

  @override
  String get titleReleaseNotes => 'Release Notes';

  @override
  String get titleSelectAShoppingListToView => 'Select a shopping list to view';

  @override
  String get titleShareCollaborate => 'Share & Collaborate';

  @override
  String get titleShopsync => 'ShopSync';

  @override
  String get titleSignOut => 'Sign Out';

  @override
  String get titleSmartLists => 'Smart Lists';

  @override
  String get titleTaskName => 'Task Name';

  @override
  String get titleWelcomeToShopsync => 'Welcome to ShopSync';
}
