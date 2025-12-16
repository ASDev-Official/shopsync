import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('ru'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @accessYourListsAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Access your lists and settings'**
  String get accessYourListsAndSettings;

  /// No description provided for @addCustomGroup.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Group'**
  String get addCustomGroup;

  /// No description provided for @addDescription.
  ///
  /// In en, this message translates to:
  /// **'Add description...'**
  String get addDescription;

  /// No description provided for @addDescription1.
  ///
  /// In en, this message translates to:
  /// **'Add description...'**
  String get addDescription1;

  /// No description provided for @addDescription2.
  ///
  /// In en, this message translates to:
  /// **'Add description...'**
  String get addDescription2;

  /// No description provided for @addFromTemplate.
  ///
  /// In en, this message translates to:
  /// **'Add From Template'**
  String get addFromTemplate;

  /// No description provided for @addGroup.
  ///
  /// In en, this message translates to:
  /// **'Add Group'**
  String get addGroup;

  /// No description provided for @addItemManually.
  ///
  /// In en, this message translates to:
  /// **'Add Item Manually'**
  String get addItemManually;

  /// No description provided for @addItemsToYourLists.
  ///
  /// In en, this message translates to:
  /// **'Add items to your lists'**
  String get addItemsToYourLists;

  /// No description provided for @addNewLocation.
  ///
  /// In en, this message translates to:
  /// **'Add new location'**
  String get addNewLocation;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get added;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @areYouSureYouWantToRemoveAllCompletedItems.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all completed items?'**
  String get areYouSureYouWantToRemoveAllCompletedItems;

  /// No description provided for @areYouSureYouWantToRemoveAllCompletedItems1.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all completed items?'**
  String get areYouSureYouWantToRemoveAllCompletedItems1;

  /// No description provided for @areYouSureYouWantToSignOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get areYouSureYouWantToSignOut;

  /// No description provided for @areYouSureYouWantToSignOut1.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get areYouSureYouWantToSignOut1;

  /// No description provided for @areYouSureYouWantToSignOut2.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get areYouSureYouWantToSignOut2;

  /// No description provided for @areYouSureYouWantToSignOut3.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get areYouSureYouWantToSignOut3;

  /// No description provided for @assetsbadgesgoogleandroidpng4xdarkandroiddarkrdctn4xpng.
  ///
  /// In en, this message translates to:
  /// **'assets/badges/google/android/png@4x/dark/android_dark_rd_ctn@4x.png'**
  String get assetsbadgesgoogleandroidpng4xdarkandroiddarkrdctn4xpng;

  /// No description provided for @assetsbadgesgoogleandroidpng4xdarkandroiddarksqctn4xpng.
  ///
  /// In en, this message translates to:
  /// **'assets/badges/google/android/png@4x/dark/android_dark_sq_ctn@4x.png'**
  String get assetsbadgesgoogleandroidpng4xdarkandroiddarksqctn4xpng;

  /// No description provided for @assetsbadgesgoogleandroidpng4xlightandroidlightrdctn4xpng.
  ///
  /// In en, this message translates to:
  /// **'assets/badges/google/android/png@4x/light/android_light_rd_ctn@4x.png'**
  String get assetsbadgesgoogleandroidpng4xlightandroidlightrdctn4xpng;

  /// No description provided for @assetsbadgesgoogleandroidpng4xlightandroidlightsqctn4xpng.
  ///
  /// In en, this message translates to:
  /// **'assets/badges/google/android/png@4x/light/android_light_sq_ctn@4x.png'**
  String get assetsbadgesgoogleandroidpng4xlightandroidlightsqctn4xpng;

  /// No description provided for @avgCompletion.
  ///
  /// In en, this message translates to:
  /// **'Avg Completion'**
  String get avgCompletion;

  /// No description provided for @canAddEditAndDeleteItems.
  ///
  /// In en, this message translates to:
  /// **'Can add, edit, and delete items'**
  String get canAddEditAndDeleteItems;

  /// No description provided for @canOnlyViewItems.
  ///
  /// In en, this message translates to:
  /// **'Can only view items'**
  String get canOnlyViewItems;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cancel1.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel1;

  /// No description provided for @cancel10.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel10;

  /// No description provided for @cancel11.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel11;

  /// No description provided for @cancel12.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel12;

  /// No description provided for @cancel2.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel2;

  /// No description provided for @cancel3.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel3;

  /// No description provided for @cancel4.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel4;

  /// No description provided for @cancel5.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel5;

  /// No description provided for @cancel6.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel6;

  /// No description provided for @cancel7.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel7;

  /// No description provided for @cancel8.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel8;

  /// No description provided for @cancel9.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel9;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @category1.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category1;

  /// No description provided for @categoryCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category created successfully'**
  String get categoryCreatedSuccessfully;

  /// No description provided for @categoryCreatedSuccessfully1.
  ///
  /// In en, this message translates to:
  /// **'Category created successfully'**
  String get categoryCreatedSuccessfully1;

  /// No description provided for @categoryDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category deleted successfully'**
  String get categoryDeletedSuccessfully;

  /// No description provided for @categoryDeletedSuccessfully1.
  ///
  /// In en, this message translates to:
  /// **'Category deleted successfully'**
  String get categoryDeletedSuccessfully1;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @categoryName1.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName1;

  /// No description provided for @categoryUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category updated successfully'**
  String get categoryUpdatedSuccessfully;

  /// No description provided for @categoryUpdatedSuccessfully1.
  ///
  /// In en, this message translates to:
  /// **'Category updated successfully'**
  String get categoryUpdatedSuccessfully1;

  /// No description provided for @changeTheNameOfThisList.
  ///
  /// In en, this message translates to:
  /// **'Change the name of this list'**
  String get changeTheNameOfThisList;

  /// No description provided for @clearCompleted.
  ///
  /// In en, this message translates to:
  /// **'Clear Completed'**
  String get clearCompleted;

  /// No description provided for @clearCompletedItems.
  ///
  /// In en, this message translates to:
  /// **'Clear Completed Items'**
  String get clearCompletedItems;

  /// No description provided for @clearItems.
  ///
  /// In en, this message translates to:
  /// **'Clear Items'**
  String get clearItems;

  /// From: lib/screens/lists/list_options.dart
  ///
  /// In en, this message translates to:
  /// **'Cleared {completedItems} completed items'**
  String clearedCompleteditemsdocslengthCompletedItems(String completedItems);

  /// From: lib/screens/lists/list_options.dart
  ///
  /// In en, this message translates to:
  /// **'Cleared {completedItems} completed items'**
  String clearedCompleteditemsdocslengthCompletedItems1(String completedItems);

  /// From: lib/screens/lists/list_options.dart
  ///
  /// In en, this message translates to:
  /// **'Cleared {completedItems} completed items'**
  String clearedCompleteditemsdocslengthCompletedItems2(String completedItems);

  /// From: lib/screens/lists/list_options.dart
  ///
  /// In en, this message translates to:
  /// **'Cleared {completedItems} completed items'**
  String clearedCompleteditemsdocslengthCompletedItems3(String completedItems);

  /// No description provided for @collaborators.
  ///
  /// In en, this message translates to:
  /// **'Collaborators'**
  String get collaborators;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @completionRate.
  ///
  /// In en, this message translates to:
  /// **'completion rate'**
  String get completionRate;

  /// No description provided for @completionRate1.
  ///
  /// In en, this message translates to:
  /// **'completion rate'**
  String get completionRate1;

  /// No description provided for @configureHomeScreenWidgetDebugOnly.
  ///
  /// In en, this message translates to:
  /// **'Configure home screen widget (Debug Only)'**
  String get configureHomeScreenWidgetDebugOnly;

  /// No description provided for @contributeOnWeblate.
  ///
  /// In en, this message translates to:
  /// **'Contribute on Weblate'**
  String get contributeOnWeblate;

  /// From: lib/screens/settings/settings.dart
  ///
  /// In en, this message translates to:
  /// **'Could not launch {url}'**
  String couldNotLaunchUrl(String url);

  /// From: lib/screens/settings/settings.dart
  ///
  /// In en, this message translates to:
  /// **'Could not launch {url}'**
  String couldNotLaunchUrl1(String url);

  /// From: lib/screens/settings/settings.dart
  ///
  /// In en, this message translates to:
  /// **'Could not launch {url}'**
  String couldNotLaunchUrl2(String url);

  /// From: lib/screens/settings/settings.dart
  ///
  /// In en, this message translates to:
  /// **'Could not launch {url}'**
  String couldNotLaunchUrl3(String url);

  /// No description provided for @couldNotOpenPlayStore.
  ///
  /// In en, this message translates to:
  /// **'Could not open Play Store'**
  String get couldNotOpenPlayStore;

  /// No description provided for @couldNotOpenPlayStore1.
  ///
  /// In en, this message translates to:
  /// **'Could not open Play Store'**
  String get couldNotOpenPlayStore1;

  /// No description provided for @couldNotOpenReleaseNotes.
  ///
  /// In en, this message translates to:
  /// **'Could not open release notes'**
  String get couldNotOpenReleaseNotes;

  /// No description provided for @couldNotOpenReleaseNotes1.
  ///
  /// In en, this message translates to:
  /// **'Could not open release notes'**
  String get couldNotOpenReleaseNotes1;

  /// No description provided for @counter.
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get counter;

  /// No description provided for @counter1.
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get counter1;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @createCategory.
  ///
  /// In en, this message translates to:
  /// **'Create Category'**
  String get createCategory;

  /// No description provided for @createItemsFromSavedTemplates.
  ///
  /// In en, this message translates to:
  /// **'Create items from saved templates'**
  String get createItemsFromSavedTemplates;

  /// No description provided for @createList.
  ///
  /// In en, this message translates to:
  /// **'Create List'**
  String get createList;

  /// No description provided for @createListGroup.
  ///
  /// In en, this message translates to:
  /// **'Create List Group'**
  String get createListGroup;

  /// No description provided for @createListGroups.
  ///
  /// In en, this message translates to:
  /// **'Create list groups'**
  String get createListGroups;

  /// No description provided for @dailyAvg.
  ///
  /// In en, this message translates to:
  /// **'Daily Avg'**
  String get dailyAvg;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadline;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @delete1.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete1;

  /// No description provided for @delete2.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete2;

  /// No description provided for @delete3.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete3;

  /// No description provided for @delete4.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete4;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @deleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete Group'**
  String get deleteGroup;

  /// No description provided for @deleteList.
  ///
  /// In en, this message translates to:
  /// **'Delete List'**
  String get deleteList;

  /// No description provided for @deleteList1.
  ///
  /// In en, this message translates to:
  /// **'Delete List'**
  String get deleteList1;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @description1.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description1;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @editGroupName.
  ///
  /// In en, this message translates to:
  /// **'Edit Group Name'**
  String get editGroupName;

  /// No description provided for @editListName.
  ///
  /// In en, this message translates to:
  /// **'Edit List Name'**
  String get editListName;

  /// No description provided for @editor.
  ///
  /// In en, this message translates to:
  /// **'Editor'**
  String get editor;

  /// No description provided for @egGroceryListsWorkProjects.
  ///
  /// In en, this message translates to:
  /// **'e.g., Grocery Lists, Work Projects'**
  String get egGroceryListsWorkProjects;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @email1.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email1;

  /// No description provided for @email2.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email2;

  /// No description provided for @email3.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email3;

  /// No description provided for @enterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get enterEmailAddress;

  /// No description provided for @enterGroupName.
  ///
  /// In en, this message translates to:
  /// **'Enter group name'**
  String get enterGroupName;

  /// No description provided for @enterGroupName1.
  ///
  /// In en, this message translates to:
  /// **'Enter group name'**
  String get enterGroupName1;

  /// No description provided for @enterGroupName2.
  ///
  /// In en, this message translates to:
  /// **'Enter group name'**
  String get enterGroupName2;

  /// No description provided for @enterItemName.
  ///
  /// In en, this message translates to:
  /// **'Enter item name...'**
  String get enterItemName;

  /// No description provided for @enterItemName1.
  ///
  /// In en, this message translates to:
  /// **'Enter item name...'**
  String get enterItemName1;

  /// No description provided for @enterListName.
  ///
  /// In en, this message translates to:
  /// **'Enter list name'**
  String get enterListName;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// From: lib/screens/lists/manage_categories.dart
  ///
  /// In en, this message translates to:
  /// **'Error creating category: {e}'**
  String errorCreatingCategoryE(String e);

  /// From: lib/screens/lists/manage_categories.dart
  ///
  /// In en, this message translates to:
  /// **'Error creating category: {e}'**
  String errorCreatingCategoryE1(String e);

  /// From: lib/screens/lists/manage_categories.dart
  ///
  /// In en, this message translates to:
  /// **'Error creating category: {e}'**
  String errorCreatingCategoryE2(String e);

  /// From: lib/screens/lists/manage_categories.dart
  ///
  /// In en, this message translates to:
  /// **'Error creating category: {e}'**
  String errorCreatingCategoryE3(String e);

  /// From: lib/screens/lists/manage_categories.dart
  ///
  /// In en, this message translates to:
  /// **'Error deleting category: {e}'**
  String errorDeletingCategoryE(String e);

  /// From: lib/screens/lists/manage_categories.dart
  ///
  /// In en, this message translates to:
  /// **'Error deleting category: {e}'**
  String errorDeletingCategoryE1(String e);

  /// From: lib/screens/lists/manage_categories.dart
  ///
  /// In en, this message translates to:
  /// **'Error deleting category: {e}'**
  String errorDeletingCategoryE2(String e);

  /// From: lib/screens/lists/manage_categories.dart
  ///
  /// In en, this message translates to:
  /// **'Error deleting category: {e}'**
  String errorDeletingCategoryE3(String e);

  /// From: lib/wear/screens/wear_welcome_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Error: {errorMessage}'**
  String errorErrormessage(String errorMessage);

  /// From: lib/wear/screens/wear_welcome_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Error: {errorMessage}'**
  String errorErrormessage1(String errorMessage);

  /// From: lib/wear/screens/wear_item_details_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Error: {e}'**
  String errorEtostring(String e);

  /// From: lib/wear/screens/wear_item_details_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Error: {e}'**
  String errorEtostring1(String e);

  /// From: lib/wear/screens/wear_item_details_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Error: {e}'**
  String errorEtostring2(String e);

  /// From: lib/wear/screens/wear_item_details_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Error: {e}'**
  String errorEtostring3(String e);

  /// From: lib/services/platform/maintenance_service.dart
  ///
  /// In en, this message translates to:
  /// **'Error fetching maintenance status: {e}'**
  String errorFetchingMaintenanceStatusE(String e);

  /// From: lib/services/platform/maintenance_service.dart
  ///
  /// In en, this message translates to:
  /// **'Error fetching maintenance status: {e}'**
  String errorFetchingMaintenanceStatusE1(String e);

  /// From: lib/services/platform/maintenance_service.dart
  ///
  /// In en, this message translates to:
  /// **'Error fetching maintenance status: {e}'**
  String errorFetchingMaintenanceStatusE2(String e);

  /// From: lib/services/platform/maintenance_service.dart
  ///
  /// In en, this message translates to:
  /// **'Error fetching maintenance status: {e}'**
  String errorFetchingMaintenanceStatusE3(String e);

  /// From: lib/screens/lists/list_insights.dart
  ///
  /// In en, this message translates to:
  /// **'Error loading insights: {e}'**
  String errorLoadingInsightsE(String e);

  /// From: lib/screens/lists/list_insights.dart
  ///
  /// In en, this message translates to:
  /// **'Error loading insights: {e}'**
  String errorLoadingInsightsE1(String e);

  /// From: lib/screens/lists/list_insights.dart
  ///
  /// In en, this message translates to:
  /// **'Error loading insights: {e}'**
  String errorLoadingInsightsE2(String e);

  /// From: lib/screens/lists/list_insights.dart
  ///
  /// In en, this message translates to:
  /// **'Error loading insights: {e}'**
  String errorLoadingInsightsE3(String e);

  /// From: lib/screens/home.dart
  ///
  /// In en, this message translates to:
  /// **'Error loading lists: {snapshot}'**
  String errorLoadingListsSnapshoterror(String snapshot);

  /// From: lib/screens/home.dart
  ///
  /// In en, this message translates to:
  /// **'Error loading lists: {snapshot}'**
  String errorLoadingListsSnapshoterror1(String snapshot);

  /// From: lib/screens/settings/profile.dart
  ///
  /// In en, this message translates to:
  /// **'Error signing out: {e}'**
  String errorSigningOutEtostring(String e);

  /// From: lib/screens/settings/profile.dart
  ///
  /// In en, this message translates to:
  /// **'Error signing out: {e}'**
  String errorSigningOutEtostring1(String e);

  /// From: lib/screens/settings/profile.dart
  ///
  /// In en, this message translates to:
  /// **'Error signing out: {e}'**
  String errorSigningOutEtostring2(String e);

  /// From: lib/screens/settings/profile.dart
  ///
  /// In en, this message translates to:
  /// **'Error signing out: {e}'**
  String errorSigningOutEtostring3(String e);

  /// From: lib/screens/settings/settings.dart
  ///
  /// In en, this message translates to:
  /// **'Error signing out: {e}'**
  String errorSigningOutEtostring4(String e);

  /// From: lib/screens/settings/settings.dart
  ///
  /// In en, this message translates to:
  /// **'Error signing out: {e}'**
  String errorSigningOutEtostring5(String e);

  /// From: lib/screens/settings/settings.dart
  ///
  /// In en, this message translates to:
  /// **'Error signing out: {e}'**
  String errorSigningOutEtostring6(String e);

  /// From: lib/screens/settings/settings.dart
  ///
  /// In en, this message translates to:
  /// **'Error signing out: {e}'**
  String errorSigningOutEtostring7(String e);

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export & Backup'**
  String get exportBackup;

  /// No description provided for @exportList.
  ///
  /// In en, this message translates to:
  /// **'Export List'**
  String get exportList;

  /// No description provided for @exportListAsACsv.
  ///
  /// In en, this message translates to:
  /// **'Export list as a CSV'**
  String get exportListAsACsv;

  /// No description provided for @failedToChangePermission.
  ///
  /// In en, this message translates to:
  /// **'Failed to change permission'**
  String get failedToChangePermission;

  /// No description provided for @failedToChangePermission1.
  ///
  /// In en, this message translates to:
  /// **'Failed to change permission'**
  String get failedToChangePermission1;

  /// No description provided for @failedToCreateGroupPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to create group. Please try again.'**
  String get failedToCreateGroupPleaseTryAgain;

  /// No description provided for @failedToCreateGroupPleaseTryAgain1.
  ///
  /// In en, this message translates to:
  /// **'Failed to create group. Please try again.'**
  String get failedToCreateGroupPleaseTryAgain1;

  /// No description provided for @failedToCreateItem.
  ///
  /// In en, this message translates to:
  /// **'Failed to create item'**
  String get failedToCreateItem;

  /// No description provided for @failedToCreateItem1.
  ///
  /// In en, this message translates to:
  /// **'Failed to create item'**
  String get failedToCreateItem1;

  /// No description provided for @failedToCreateListPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to create list. Please try again.'**
  String get failedToCreateListPleaseTryAgain;

  /// No description provided for @failedToCreateListPleaseTryAgain1.
  ///
  /// In en, this message translates to:
  /// **'Failed to create list. Please try again.'**
  String get failedToCreateListPleaseTryAgain1;

  /// No description provided for @failedToDeleteGroupPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete group. Please try again.'**
  String get failedToDeleteGroupPleaseTryAgain;

  /// No description provided for @failedToDeleteGroupPleaseTryAgain1.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete group. Please try again.'**
  String get failedToDeleteGroupPleaseTryAgain1;

  /// No description provided for @failedToDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete item'**
  String get failedToDeleteItem;

  /// No description provided for @failedToDeleteItem1.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete item'**
  String get failedToDeleteItem1;

  /// No description provided for @failedToDeleteItem2.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete item'**
  String get failedToDeleteItem2;

  /// No description provided for @failedToDeleteItem3.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete item'**
  String get failedToDeleteItem3;

  /// No description provided for @failedToDeleteList.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete list'**
  String get failedToDeleteList;

  /// No description provided for @failedToDeleteList1.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete list'**
  String get failedToDeleteList1;

  /// No description provided for @failedToMigrateListsPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to migrate lists. Please try again.'**
  String get failedToMigrateListsPleaseTryAgain;

  /// No description provided for @failedToMigrateListsPleaseTryAgain1.
  ///
  /// In en, this message translates to:
  /// **'Failed to migrate lists. Please try again.'**
  String get failedToMigrateListsPleaseTryAgain1;

  /// No description provided for @failedToRemoveUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove user'**
  String get failedToRemoveUser;

  /// No description provided for @failedToRemoveUser1.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove user'**
  String get failedToRemoveUser1;

  /// No description provided for @failedToRestoreItem.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore item'**
  String get failedToRestoreItem;

  /// No description provided for @failedToRestoreItem1.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore item'**
  String get failedToRestoreItem1;

  /// No description provided for @failedToSaveItemTemplate.
  ///
  /// In en, this message translates to:
  /// **'Failed to save item template'**
  String get failedToSaveItemTemplate;

  /// No description provided for @failedToSaveItemTemplate1.
  ///
  /// In en, this message translates to:
  /// **'Failed to save item template'**
  String get failedToSaveItemTemplate1;

  /// No description provided for @failedToSaveLocation.
  ///
  /// In en, this message translates to:
  /// **'Failed to save location'**
  String get failedToSaveLocation;

  /// No description provided for @failedToSaveLocation1.
  ///
  /// In en, this message translates to:
  /// **'Failed to save location'**
  String get failedToSaveLocation1;

  /// No description provided for @failedToShareList.
  ///
  /// In en, this message translates to:
  /// **'Failed to share list'**
  String get failedToShareList;

  /// No description provided for @failedToShareList1.
  ///
  /// In en, this message translates to:
  /// **'Failed to share list'**
  String get failedToShareList1;

  /// No description provided for @failedToSignInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in with Google'**
  String get failedToSignInWithGoogle;

  /// No description provided for @failedToSignInWithGoogle1.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in with Google'**
  String get failedToSignInWithGoogle1;

  /// No description provided for @failedToUpdateGroupNamePleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to update group name. Please try again.'**
  String get failedToUpdateGroupNamePleaseTryAgain;

  /// No description provided for @failedToUpdateGroupNamePleaseTryAgain1.
  ///
  /// In en, this message translates to:
  /// **'Failed to update group name. Please try again.'**
  String get failedToUpdateGroupNamePleaseTryAgain1;

  /// No description provided for @failedToUpdateItemStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to update item status'**
  String get failedToUpdateItemStatus;

  /// No description provided for @failedToUpdateItemStatus1.
  ///
  /// In en, this message translates to:
  /// **'Failed to update item status'**
  String get failedToUpdateItemStatus1;

  /// No description provided for @failedToUpdateListName.
  ///
  /// In en, this message translates to:
  /// **'Failed to update list name'**
  String get failedToUpdateListName;

  /// No description provided for @failedToUpdateListName1.
  ///
  /// In en, this message translates to:
  /// **'Failed to update list name'**
  String get failedToUpdateListName1;

  /// From: lib/screens/settings/widget_settings.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to update widget: {e}'**
  String failedToUpdateWidgetE(String e);

  /// From: lib/screens/settings/widget_settings.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to update widget: {e}'**
  String failedToUpdateWidgetE1(String e);

  /// From: lib/screens/settings/widget_settings.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to update widget: {e}'**
  String failedToUpdateWidgetE2(String e);

  /// From: lib/screens/settings/widget_settings.dart
  ///
  /// In en, this message translates to:
  /// **'Failed to update widget: {e}'**
  String failedToUpdateWidgetE3(String e);

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @githubRepository.
  ///
  /// In en, this message translates to:
  /// **'GitHub Repository'**
  String get githubRepository;

  /// No description provided for @googleAccountLinkedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Google account linked successfully!'**
  String get googleAccountLinkedSuccessfully;

  /// No description provided for @googleAccountLinkedSuccessfully1.
  ///
  /// In en, this message translates to:
  /// **'Google account linked successfully!'**
  String get googleAccountLinkedSuccessfully1;

  /// No description provided for @googleAccountUnlinkedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Google account unlinked successfully'**
  String get googleAccountUnlinkedSuccessfully;

  /// No description provided for @googleAccountUnlinkedSuccessfully1.
  ///
  /// In en, this message translates to:
  /// **'Google account unlinked successfully'**
  String get googleAccountUnlinkedSuccessfully1;

  /// No description provided for @helpTranslate.
  ///
  /// In en, this message translates to:
  /// **'Help Translate'**
  String get helpTranslate;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'high'**
  String get high;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @icon1.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon1;

  /// No description provided for @inTimeframe.
  ///
  /// In en, this message translates to:
  /// **'in timeframe'**
  String get inTimeframe;

  /// No description provided for @inTimeframe1.
  ///
  /// In en, this message translates to:
  /// **'in timeframe'**
  String get inTimeframe1;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @itemCreatedFromTemplate.
  ///
  /// In en, this message translates to:
  /// **'Item created from template'**
  String get itemCreatedFromTemplate;

  /// No description provided for @itemCreatedFromTemplate1.
  ///
  /// In en, this message translates to:
  /// **'Item created from template'**
  String get itemCreatedFromTemplate1;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @itemName1.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName1;

  /// No description provided for @itemTemplateSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Item template saved successfully'**
  String get itemTemplateSavedSuccessfully;

  /// No description provided for @itemTemplateSavedSuccessfully1.
  ///
  /// In en, this message translates to:
  /// **'Item template saved successfully'**
  String get itemTemplateSavedSuccessfully1;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @itemsAdded.
  ///
  /// In en, this message translates to:
  /// **'Items Added'**
  String get itemsAdded;

  /// No description provided for @itemsCheckedOff.
  ///
  /// In en, this message translates to:
  /// **'items checked off'**
  String get itemsCheckedOff;

  /// No description provided for @itemsCheckedOff1.
  ///
  /// In en, this message translates to:
  /// **'items checked off'**
  String get itemsCheckedOff1;

  /// No description provided for @itemsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Items Completed'**
  String get itemsCompleted;

  /// No description provided for @itemsInList.
  ///
  /// In en, this message translates to:
  /// **'items in list'**
  String get itemsInList;

  /// No description provided for @itemsPerDay.
  ///
  /// In en, this message translates to:
  /// **'items per day'**
  String get itemsPerDay;

  /// No description provided for @itemsPerDay1.
  ///
  /// In en, this message translates to:
  /// **'items per day'**
  String get itemsPerDay1;

  /// No description provided for @keepTrackOfWhatYouNeedToBuy.
  ///
  /// In en, this message translates to:
  /// **'Keep track of what you need to buy'**
  String get keepTrackOfWhatYouNeedToBuy;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @leaveUngrouped.
  ///
  /// In en, this message translates to:
  /// **'Leave Ungrouped'**
  String get leaveUngrouped;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// No description provided for @linkGoogleAccount.
  ///
  /// In en, this message translates to:
  /// **'Link Google Account'**
  String get linkGoogleAccount;

  /// No description provided for @listDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'List deleted successfully'**
  String get listDeletedSuccessfully;

  /// No description provided for @listDeletedSuccessfully1.
  ///
  /// In en, this message translates to:
  /// **'List deleted successfully'**
  String get listDeletedSuccessfully1;

  /// No description provided for @listManagement.
  ///
  /// In en, this message translates to:
  /// **'List Management'**
  String get listManagement;

  /// No description provided for @listName.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get listName;

  /// No description provided for @listNameUpdated.
  ///
  /// In en, this message translates to:
  /// **'List name updated'**
  String get listNameUpdated;

  /// No description provided for @listNameUpdated1.
  ///
  /// In en, this message translates to:
  /// **'List name updated'**
  String get listNameUpdated1;

  /// From: lib/screens/lists/list_options.dart
  ///
  /// In en, this message translates to:
  /// **'List shared with {email} as {selectedRole}'**
  String listSharedWithEmailAsSelectedrole(String email, String selectedRole);

  /// From: lib/screens/lists/list_options.dart
  ///
  /// In en, this message translates to:
  /// **'List shared with {email} as {selectedRole}'**
  String listSharedWithEmailAsSelectedrole1(String email, String selectedRole);

  /// From: lib/screens/lists/list_options.dart
  ///
  /// In en, this message translates to:
  /// **'List shared with {email} as {selectedRole}'**
  String listSharedWithEmailAsSelectedrole2(String email, String selectedRole);

  /// From: lib/screens/lists/list_options.dart
  ///
  /// In en, this message translates to:
  /// **'List shared with {email} as {selectedRole}'**
  String listSharedWithEmailAsSelectedrole3(String email, String selectedRole);

  /// From: lib/widgets/lists/manage_list_group_bottom_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'{listName} added to group'**
  String listnameAddedToGroup(String listName);

  /// From: lib/widgets/lists/manage_list_group_bottom_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'{listName} added to group'**
  String listnameAddedToGroup1(String listName);

  /// From: lib/widgets/lists/manage_list_group_bottom_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'{listName} added to group'**
  String listnameAddedToGroup2(String listName);

  /// From: lib/widgets/lists/manage_list_group_bottom_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'{listName} added to group'**
  String listnameAddedToGroup3(String listName);

  /// From: lib/widgets/lists/manage_list_group_bottom_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'{listName} removed from group'**
  String listnameRemovedFromGroup(String listName);

  /// From: lib/widgets/lists/manage_list_group_bottom_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'{listName} removed from group'**
  String listnameRemovedFromGroup1(String listName);

  /// From: lib/widgets/lists/manage_list_group_bottom_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'{listName} removed from group'**
  String listnameRemovedFromGroup2(String listName);

  /// From: lib/widgets/lists/manage_list_group_bottom_sheet.dart
  ///
  /// In en, this message translates to:
  /// **'{listName} removed from group'**
  String listnameRemovedFromGroup3(String listName);

  /// No description provided for @listsCreated.
  ///
  /// In en, this message translates to:
  /// **'Lists Created'**
  String get listsCreated;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @location1.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location1;

  /// No description provided for @locationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Location deleted'**
  String get locationDeleted;

  /// No description provided for @locationDeleted1.
  ///
  /// In en, this message translates to:
  /// **'Location deleted'**
  String get locationDeleted1;

  /// No description provided for @locationSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Location saved successfully'**
  String get locationSavedSuccessfully;

  /// No description provided for @locationSavedSuccessfully1.
  ///
  /// In en, this message translates to:
  /// **'Location saved successfully'**
  String get locationSavedSuccessfully1;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'low'**
  String get low;

  /// No description provided for @low1.
  ///
  /// In en, this message translates to:
  /// **'low'**
  String get low1;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// No description provided for @manageYourFrequentlyUsedLocations.
  ///
  /// In en, this message translates to:
  /// **'Manage your frequently used locations'**
  String get manageYourFrequentlyUsedLocations;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'medium'**
  String get medium;

  /// From: lib/screens/migration/migration_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Move to {group}'**
  String moveToGroupname(String group);

  /// From: lib/screens/migration/migration_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Move to {group}'**
  String moveToGroupname1(String group);

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nameMustBeAtLeast2Characters.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMustBeAtLeast2Characters;

  /// No description provided for @networkErrorCheckYourConnectionAndTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection and try again'**
  String get networkErrorCheckYourConnectionAndTryAgain;

  /// No description provided for @networkErrorPleaseCheckYourInternetConnectionAndTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection and try again'**
  String get networkErrorPleaseCheckYourInternetConnectionAndTryAgain;

  /// No description provided for @networkErrorPleaseCheckYourInternetConnectionAndTryAgain1.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection and try again'**
  String get networkErrorPleaseCheckYourInternetConnectionAndTryAgain1;

  /// No description provided for @noAccountFoundWithThisEmail.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email'**
  String get noAccountFoundWithThisEmail;

  /// No description provided for @noCategoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No categories available'**
  String get noCategoriesAvailable;

  /// No description provided for @noCategory.
  ///
  /// In en, this message translates to:
  /// **'No Category'**
  String get noCategory;

  /// No description provided for @noUserFoundForThatEmailPleaseCheckYourEmailAndTryAgain.
  ///
  /// In en, this message translates to:
  /// **'No user found for that email. Please check your email and try again'**
  String get noUserFoundForThatEmailPleaseCheckYourEmailAndTryAgain;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get openSourceLicenses;

  /// No description provided for @openTheDrawerFromTheLeft.
  ///
  /// In en, this message translates to:
  /// **'Open the drawer from the left'**
  String get openTheDrawerFromTheLeft;

  /// No description provided for @options.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get options;

  /// No description provided for @organizeYourListsWithTheButton.
  ///
  /// In en, this message translates to:
  /// **'Organize your lists with the + button'**
  String get organizeYourListsWithTheButton;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'owner'**
  String get owner;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @password1.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password1;

  /// No description provided for @password2.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password2;

  /// No description provided for @passwordMustBeAtLeast6Characters.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMustBeAtLeast6Characters;

  /// No description provided for @peopleCollaborating.
  ///
  /// In en, this message translates to:
  /// **'people collaborating'**
  String get peopleCollaborating;

  /// No description provided for @permanentlyDeleteThisList.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete this list'**
  String get permanentlyDeleteThisList;

  /// From: lib/screens/lists/list_options.dart
  ///
  /// In en, this message translates to:
  /// **'Permission changed to {newRole}'**
  String permissionChangedToNewrole(String newRole);

  /// From: lib/screens/lists/list_options.dart
  ///
  /// In en, this message translates to:
  /// **'Permission changed to {newRole}'**
  String permissionChangedToNewrole1(String newRole);

  /// From: lib/screens/lists/list_options.dart
  ///
  /// In en, this message translates to:
  /// **'Permission changed to {newRole}'**
  String permissionChangedToNewrole2(String newRole);

  /// From: lib/screens/lists/list_options.dart
  ///
  /// In en, this message translates to:
  /// **'Permission changed to {newRole}'**
  String permissionChangedToNewrole3(String newRole);

  /// No description provided for @pleaseEnterACategoryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a category name'**
  String get pleaseEnterACategoryName;

  /// No description provided for @pleaseEnterACategoryName1.
  ///
  /// In en, this message translates to:
  /// **'Please enter a category name'**
  String get pleaseEnterACategoryName1;

  /// No description provided for @pleaseEnterACategoryName2.
  ///
  /// In en, this message translates to:
  /// **'Please enter a category name'**
  String get pleaseEnterACategoryName2;

  /// No description provided for @pleaseEnterACategoryName3.
  ///
  /// In en, this message translates to:
  /// **'Please enter a category name'**
  String get pleaseEnterACategoryName3;

  /// No description provided for @pleaseEnterADisplayName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a display name'**
  String get pleaseEnterADisplayName;

  /// No description provided for @pleaseEnterAGroupName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a group name'**
  String get pleaseEnterAGroupName;

  /// No description provided for @pleaseEnterAGroupName1.
  ///
  /// In en, this message translates to:
  /// **'Please enter a group name'**
  String get pleaseEnterAGroupName1;

  /// No description provided for @pleaseEnterAGroupName2.
  ///
  /// In en, this message translates to:
  /// **'Please enter a group name'**
  String get pleaseEnterAGroupName2;

  /// No description provided for @pleaseEnterAGroupName3.
  ///
  /// In en, this message translates to:
  /// **'Please enter a group name'**
  String get pleaseEnterAGroupName3;

  /// No description provided for @pleaseEnterAPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterAPassword;

  /// No description provided for @pleaseEnterATemplateName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a template name'**
  String get pleaseEnterATemplateName;

  /// No description provided for @pleaseEnterATemplateName1.
  ///
  /// In en, this message translates to:
  /// **'Please enter a template name'**
  String get pleaseEnterATemplateName1;

  /// No description provided for @pleaseEnterAValidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterAValidEmailAddress;

  /// No description provided for @pleaseEnterAValidEmailAddress1.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterAValidEmailAddress1;

  /// No description provided for @pleaseEnterAValidEmailAddress2.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterAValidEmailAddress2;

  /// No description provided for @pleaseEnterAValidEmailAddress3.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterAValidEmailAddress3;

  /// No description provided for @pleaseEnterAValidEmailAddress4.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterAValidEmailAddress4;

  /// No description provided for @pleaseEnterAnEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email address'**
  String get pleaseEnterAnEmailAddress;

  /// No description provided for @pleaseEnterAnEmailAddress1.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email address'**
  String get pleaseEnterAnEmailAddress1;

  /// No description provided for @pleaseEnterAnItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter an item title'**
  String get pleaseEnterAnItemTitle;

  /// No description provided for @pleaseEnterAnItemTitle1.
  ///
  /// In en, this message translates to:
  /// **'Please enter an item title'**
  String get pleaseEnterAnItemTitle1;

  /// No description provided for @pleaseEnterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail;

  /// No description provided for @pleaseEnterYourEmail1.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail1;

  /// No description provided for @pleaseEnterYourEmail2.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterYourEmail2;

  /// No description provided for @pleaseEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterYourName;

  /// No description provided for @pleaseEnterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterYourPassword;

  /// No description provided for @productivity.
  ///
  /// In en, this message translates to:
  /// **'Productivity'**
  String get productivity;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @profileUpdatedSuccessfully1.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully1;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @recycleBin.
  ///
  /// In en, this message translates to:
  /// **'Recycle Bin'**
  String get recycleBin;

  /// No description provided for @recycleBin1.
  ///
  /// In en, this message translates to:
  /// **'Recycle Bin'**
  String get recycleBin1;

  /// No description provided for @releaseNotes.
  ///
  /// In en, this message translates to:
  /// **'Release Notes'**
  String get releaseNotes;

  /// No description provided for @removeAllCompletedItems.
  ///
  /// In en, this message translates to:
  /// **'Remove all completed items'**
  String get removeAllCompletedItems;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get removeMember;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @retry1.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry1;

  /// No description provided for @retry2.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry2;

  /// No description provided for @retry3.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry3;

  /// No description provided for @retry4.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry4;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @save1.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save1;

  /// No description provided for @save2.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save2;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @saveChanges1.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges1;

  /// No description provided for @savedItems.
  ///
  /// In en, this message translates to:
  /// **'Saved Items'**
  String get savedItems;

  /// No description provided for @savedLocations.
  ///
  /// In en, this message translates to:
  /// **'Saved Locations'**
  String get savedLocations;

  /// No description provided for @searchIcons.
  ///
  /// In en, this message translates to:
  /// **'Search icons...'**
  String get searchIcons;

  /// No description provided for @searchPackages.
  ///
  /// In en, this message translates to:
  /// **'Search packages'**
  String get searchPackages;

  /// No description provided for @searchPackages1.
  ///
  /// In en, this message translates to:
  /// **'Search packages...'**
  String get searchPackages1;

  /// No description provided for @setPassword.
  ///
  /// In en, this message translates to:
  /// **'Set Password'**
  String get setPassword;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settings1.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings1;

  /// No description provided for @shareCollaborate.
  ///
  /// In en, this message translates to:
  /// **'Share & Collaborate'**
  String get shareCollaborate;

  /// No description provided for @shareList.
  ///
  /// In en, this message translates to:
  /// **'Share List'**
  String get shareList;

  /// No description provided for @shareThisListWithOthers.
  ///
  /// In en, this message translates to:
  /// **'Share this list with others'**
  String get shareThisListWithOthers;

  /// No description provided for @shoppingLists.
  ///
  /// In en, this message translates to:
  /// **'shopping lists'**
  String get shoppingLists;

  /// No description provided for @shopsync.
  ///
  /// In en, this message translates to:
  /// **'ShopSync'**
  String get shopsync;

  /// No description provided for @shopsync1.
  ///
  /// In en, this message translates to:
  /// **'ShopSync'**
  String get shopsync1;

  /// No description provided for @shopsyncForms.
  ///
  /// In en, this message translates to:
  /// **'ShopSync Forms'**
  String get shopsyncForms;

  /// No description provided for @shopsyncLogo.
  ///
  /// In en, this message translates to:
  /// **'ShopSync logo'**
  String get shopsyncLogo;

  /// No description provided for @signInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with email'**
  String get signInWithEmail;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOut1.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut1;

  /// No description provided for @signOut2.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut2;

  /// No description provided for @signOut3.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut3;

  /// No description provided for @signOut4.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut4;

  /// No description provided for @signOut5.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut5;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get skipForNow;

  /// No description provided for @skipOrganization.
  ///
  /// In en, this message translates to:
  /// **'Skip Organization'**
  String get skipOrganization;

  /// No description provided for @smartLists.
  ///
  /// In en, this message translates to:
  /// **'Smart Lists'**
  String get smartLists;

  /// No description provided for @storeAddress.
  ///
  /// In en, this message translates to:
  /// **'Store address'**
  String get storeAddress;

  /// No description provided for @storeName.
  ///
  /// In en, this message translates to:
  /// **'Store name'**
  String get storeName;

  /// From: lib/screens/migration/migration_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Successfully organized {selectedGroups} groups'**
  String successfullyOrganizedSelectedgroupslengthGroups(String selectedGroups);

  /// From: lib/screens/migration/migration_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Successfully organized {selectedGroups} groups'**
  String successfullyOrganizedSelectedgroupslengthGroups1(
      String selectedGroups);

  /// From: lib/screens/migration/migration_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Successfully organized {selectedGroups} groups'**
  String successfullyOrganizedSelectedgroupslengthGroups2(
      String selectedGroups);

  /// From: lib/screens/migration/migration_screen.dart
  ///
  /// In en, this message translates to:
  /// **'Successfully organized {selectedGroups} groups'**
  String successfullyOrganizedSelectedgroupslengthGroups3(
      String selectedGroups);

  /// No description provided for @templateDeleted.
  ///
  /// In en, this message translates to:
  /// **'Template deleted'**
  String get templateDeleted;

  /// No description provided for @templateDeleted1.
  ///
  /// In en, this message translates to:
  /// **'Template deleted'**
  String get templateDeleted1;

  /// No description provided for @templatesShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Templates & Shortcuts'**
  String get templatesShortcuts;

  /// No description provided for @theEmailAddressIsAlreadyInUseByAnotherAccount.
  ///
  /// In en, this message translates to:
  /// **'The email address is already in use by another account'**
  String get theEmailAddressIsAlreadyInUseByAnotherAccount;

  /// No description provided for @theOperationIsNotAllowedPleaseTryAgainLaterIfItDoesn.
  ///
  /// In en, this message translates to:
  /// **'The operation is not allowed. Please try again later. If it doesn\\'**
  String get theOperationIsNotAllowedPleaseTryAgainLaterIfItDoesn;

  /// No description provided for @theOperationIsNotAllowedPleaseTryAgainLaterIfItDoesn1.
  ///
  /// In en, this message translates to:
  /// **'The operation is not allowed. Please try again later. If it doesn\\'**
  String get theOperationIsNotAllowedPleaseTryAgainLaterIfItDoesn1;

  /// No description provided for @thePasswordIsInvalidOrTheUserDoesNotHaveAPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is invalid or the user does not have a password'**
  String get thePasswordIsInvalidOrTheUserDoesNotHaveAPassword;

  /// No description provided for @theProvidedCredentialsAreIncorrectPleaseCheckYourEmailAndPassword.
  ///
  /// In en, this message translates to:
  /// **'The provided credentials are incorrect. Please check your email and password'**
  String get theProvidedCredentialsAreIncorrectPleaseCheckYourEmailAndPassword;

  /// No description provided for @thisEmailIsAlreadyRegisteredPleaseSignInInstead.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Please sign in instead'**
  String get thisEmailIsAlreadyRegisteredPleaseSignInInstead;

  /// No description provided for @thisPasswordIsTooWeakPleaseChooseAStrongerOne.
  ///
  /// In en, this message translates to:
  /// **'This password is too weak. Please choose a stronger one'**
  String get thisPasswordIsTooWeakPleaseChooseAStrongerOne;

  /// No description provided for @thisUserHasBeenDisabledPleaseContactAsdevfeedbackgmailcom.
  ///
  /// In en, this message translates to:
  /// **'This user has been disabled. Please contact asdev.feedback@gmail.com'**
  String get thisUserHasBeenDisabledPleaseContactAsdevfeedbackgmailcom;

  /// No description provided for @tooManyRequestsPleaseTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again later'**
  String get tooManyRequestsPleaseTryAgainLater;

  /// No description provided for @tooManyRequestsPleaseTryAgainLater1.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again later'**
  String get tooManyRequestsPleaseTryAgainLater1;

  /// No description provided for @tooManyRequestsPleaseTryAgainLater2.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please try again later'**
  String get tooManyRequestsPleaseTryAgainLater2;

  /// No description provided for @totalItems.
  ///
  /// In en, this message translates to:
  /// **'total items'**
  String get totalItems;

  /// No description provided for @totalItems1.
  ///
  /// In en, this message translates to:
  /// **'Total Items'**
  String get totalItems1;

  /// No description provided for @unlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get unlink;

  /// No description provided for @unlinkGoogleAccount.
  ///
  /// In en, this message translates to:
  /// **'Unlink Google Account'**
  String get unlinkGoogleAccount;

  /// No description provided for @unlinkGoogleAccount1.
  ///
  /// In en, this message translates to:
  /// **'Unlink Google Account'**
  String get unlinkGoogleAccount1;

  /// No description provided for @useYourPhoneToRegisterIfYouDoNotHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Use your phone to register if you do not have an account'**
  String get useYourPhoneToRegisterIfYouDoNotHaveAnAccount;

  /// No description provided for @userAlreadyHasAccessToThisList.
  ///
  /// In en, this message translates to:
  /// **'User already has access to this list'**
  String get userAlreadyHasAccessToThisList;

  /// No description provided for @userAlreadyHasAccessToThisList1.
  ///
  /// In en, this message translates to:
  /// **'User already has access to this list'**
  String get userAlreadyHasAccessToThisList1;

  /// No description provided for @userNotFoundTheyNeedToSignUpForShopsyncFirst.
  ///
  /// In en, this message translates to:
  /// **'User not found. They need to sign up for ShopSync first.'**
  String get userNotFoundTheyNeedToSignUpForShopsyncFirst;

  /// No description provided for @userNotFoundTheyNeedToSignUpForShopsyncFirst1.
  ///
  /// In en, this message translates to:
  /// **'User not found. They need to sign up for ShopSync first.'**
  String get userNotFoundTheyNeedToSignUpForShopsyncFirst1;

  /// No description provided for @userRemoved.
  ///
  /// In en, this message translates to:
  /// **'User removed'**
  String get userRemoved;

  /// No description provided for @userRemoved1.
  ///
  /// In en, this message translates to:
  /// **'User removed'**
  String get userRemoved1;

  /// From: lib/screens/auth/welcome.dart
  ///
  /// In en, this message translates to:
  /// **'Version {packageInfo} ({packageInfo})'**
  String versionPackageinfoversionPackageinfobuildnumber(String packageInfo);

  /// From: lib/screens/auth/welcome.dart
  ///
  /// In en, this message translates to:
  /// **'Version {packageInfo} ({packageInfo})'**
  String versionPackageinfoversionPackageinfobuildnumber1(String packageInfo);

  /// No description provided for @viewDeletedItems.
  ///
  /// In en, this message translates to:
  /// **'View deleted items'**
  String get viewDeletedItems;

  /// No description provided for @viewSourceCode.
  ///
  /// In en, this message translates to:
  /// **'View source code'**
  String get viewSourceCode;

  /// No description provided for @viewer.
  ///
  /// In en, this message translates to:
  /// **'viewer'**
  String get viewer;

  /// No description provided for @viewer1.
  ///
  /// In en, this message translates to:
  /// **'viewer'**
  String get viewer1;

  /// No description provided for @viewer2.
  ///
  /// In en, this message translates to:
  /// **'viewer'**
  String get viewer2;

  /// No description provided for @viewer3.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get viewer3;

  /// No description provided for @welcomeToShopsync.
  ///
  /// In en, this message translates to:
  /// **'Welcome to ShopSync'**
  String get welcomeToShopsync;

  /// No description provided for @widgetSettings.
  ///
  /// In en, this message translates to:
  /// **'Widget Settings'**
  String get widgetSettings;

  /// No description provided for @widgetSettings1.
  ///
  /// In en, this message translates to:
  /// **'Widget Settings'**
  String get widgetSettings1;

  /// No description provided for @widgetUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Widget updated successfully!'**
  String get widgetUpdatedSuccessfully;

  /// No description provided for @widgetUpdatedSuccessfully1.
  ///
  /// In en, this message translates to:
  /// **'Widget updated successfully!'**
  String get widgetUpdatedSuccessfully1;

  /// No description provided for @yourInsights.
  ///
  /// In en, this message translates to:
  /// **'Your Insights'**
  String get yourInsights;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'hi',
        'it',
        'ja',
        'ko',
        'ru',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
