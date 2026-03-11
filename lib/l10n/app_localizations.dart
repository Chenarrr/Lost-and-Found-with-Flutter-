import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_ckb.dart';
import 'app_localizations_en.dart';

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
    Locale('ar'),
    Locale('ckb'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Find It'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Reuniting lost items across Kurdistan'**
  String get tagline;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @loginOrSignup.
  ///
  /// In en, this message translates to:
  /// **'Login or Signup'**
  String get loginOrSignup;

  /// No description provided for @loginTab.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTab;

  /// No description provided for @signupTab.
  ///
  /// In en, this message translates to:
  /// **'Signup'**
  String get signupTab;

  /// No description provided for @phonePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phonePlaceholder;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter 10 digits starting with 7'**
  String get phoneInvalid;

  /// No description provided for @namePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get namePlaceholder;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Enter at least 2 characters'**
  String get nameTooShort;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone is required'**
  String get phoneRequired;

  /// No description provided for @emailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailPlaceholder;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get emailInvalid;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a gender'**
  String get genderRequired;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @ageRequired.
  ///
  /// In en, this message translates to:
  /// **'Age is required'**
  String get ageRequired;

  /// No description provided for @ageInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid age (13–100)'**
  String get ageInvalid;

  /// No description provided for @verifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify Phone'**
  String get verifyPhone;

  /// No description provided for @enterCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to'**
  String get enterCodeSentTo;

  /// No description provided for @codeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get codeInvalid;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyCode;

  /// No description provided for @resendCountdown.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String resendCountdown(int seconds);

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get resendCode;

  /// No description provided for @newCodeSent.
  ///
  /// In en, this message translates to:
  /// **'New code sent!'**
  String get newCodeSent;

  /// No description provided for @allCities.
  ///
  /// In en, this message translates to:
  /// **'All Cities'**
  String get allCities;

  /// No description provided for @cityErbil.
  ///
  /// In en, this message translates to:
  /// **'Erbil'**
  String get cityErbil;

  /// No description provided for @citySulaymaniyah.
  ///
  /// In en, this message translates to:
  /// **'Sulaymaniyah'**
  String get citySulaymaniyah;

  /// No description provided for @cityDuhok.
  ///
  /// In en, this message translates to:
  /// **'Duhok'**
  String get cityDuhok;

  /// No description provided for @cityHalabja.
  ///
  /// In en, this message translates to:
  /// **'Halabja'**
  String get cityHalabja;

  /// No description provided for @cityZakho.
  ///
  /// In en, this message translates to:
  /// **'Zakho'**
  String get cityZakho;

  /// No description provided for @cityKoya.
  ///
  /// In en, this message translates to:
  /// **'Koya'**
  String get cityKoya;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search items, city, street...'**
  String get searchHint;

  /// No description provided for @lostBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} Lost'**
  String lostBadge(int count);

  /// No description provided for @foundBadge.
  ///
  /// In en, this message translates to:
  /// **'{count} Found'**
  String foundBadge(int count);

  /// No description provided for @resultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String resultsCount(int count);

  /// No description provided for @filterByCity.
  ///
  /// In en, this message translates to:
  /// **'Filter by City'**
  String get filterByCity;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @lost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get lost;

  /// No description provided for @found.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get found;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @noItemsFoundHint.
  ///
  /// In en, this message translates to:
  /// **'Try another city or clear the search field.'**
  String get noItemsFoundHint;

  /// No description provided for @pleaseLogIn.
  ///
  /// In en, this message translates to:
  /// **'Please log in'**
  String get pleaseLogIn;

  /// No description provided for @logInToTrack.
  ///
  /// In en, this message translates to:
  /// **'Log in to track your posts and comments.'**
  String get logInToTrack;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTitle;

  /// No description provided for @myPostsTab.
  ///
  /// In en, this message translates to:
  /// **'My Posts ({count})'**
  String myPostsTab(int count);

  /// No description provided for @myCommentsTab.
  ///
  /// In en, this message translates to:
  /// **'My Comments ({count})'**
  String myCommentsTab(int count);

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get noPostsYet;

  /// No description provided for @createFirstPost.
  ///
  /// In en, this message translates to:
  /// **'Create your first post to get started.'**
  String get createFirstPost;

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noCommentsYet;

  /// No description provided for @commentToEngage.
  ///
  /// In en, this message translates to:
  /// **'Comment on posts to engage with the community.'**
  String get commentToEngage;

  /// No description provided for @pleaseLogInProfile.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view your profile.'**
  String get pleaseLogInProfile;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @posts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get posts;

  /// No description provided for @yourPosts.
  ///
  /// In en, this message translates to:
  /// **'Your Posts'**
  String get yourPosts;

  /// No description provided for @totalPosts.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String totalPosts(int count);

  /// No description provided for @noItemsPosted.
  ///
  /// In en, this message translates to:
  /// **'You have not posted any items yet.'**
  String get noItemsPosted;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @changeName.
  ///
  /// In en, this message translates to:
  /// **'Change Name'**
  String get changeName;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @updateDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Update your display name'**
  String get updateDisplayName;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get logoutConfirm;

  /// No description provided for @signOutDevice.
  ///
  /// In en, this message translates to:
  /// **'Sign out from this device'**
  String get signOutDevice;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete your account and all your posts. This cannot be undone.'**
  String get deleteAccountConfirm;

  /// No description provided for @permanentlyRemove.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your account and posts'**
  String get permanentlyRemove;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose app language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @kurdish.
  ///
  /// In en, this message translates to:
  /// **'کوردی'**
  String get kurdish;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @postDetails.
  ///
  /// In en, this message translates to:
  /// **'Post Details'**
  String get postDetails;

  /// No description provided for @postNotFound.
  ///
  /// In en, this message translates to:
  /// **'Post not found.'**
  String get postNotFound;

  /// No description provided for @couldNotOpenWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp.'**
  String get couldNotOpenWhatsapp;

  /// No description provided for @sharedVia.
  ///
  /// In en, this message translates to:
  /// **'Shared via Find It app'**
  String get sharedVia;

  /// No description provided for @whatsappMessagePrefix.
  ///
  /// In en, this message translates to:
  /// **'Hi, I saw your post about:'**
  String get whatsappMessagePrefix;

  /// No description provided for @loginToReport.
  ///
  /// In en, this message translates to:
  /// **'Please login to report this post.'**
  String get loginToReport;

  /// No description provided for @cannotReportOwn.
  ///
  /// In en, this message translates to:
  /// **'You cannot report your own post.'**
  String get cannotReportOwn;

  /// No description provided for @alreadyReported.
  ///
  /// In en, this message translates to:
  /// **'You already reported this post.'**
  String get alreadyReported;

  /// No description provided for @reportPost.
  ///
  /// In en, this message translates to:
  /// **'Report Post'**
  String get reportPost;

  /// No description provided for @reportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Report this post as fake or inappropriate?'**
  String get reportConfirm;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @reported.
  ///
  /// In en, this message translates to:
  /// **'Reported'**
  String get reported;

  /// No description provided for @postReported.
  ///
  /// In en, this message translates to:
  /// **'Post reported. Thank you.'**
  String get postReported;

  /// No description provided for @markAsResolved.
  ///
  /// In en, this message translates to:
  /// **'Mark as Resolved'**
  String get markAsResolved;

  /// No description provided for @markResolvedConfirm.
  ///
  /// In en, this message translates to:
  /// **'Mark this post as resolved? Others will see it has been closed.'**
  String get markResolvedConfirm;

  /// No description provided for @markResolved.
  ///
  /// In en, this message translates to:
  /// **'Mark Resolved'**
  String get markResolved;

  /// No description provided for @postMarkedResolved.
  ///
  /// In en, this message translates to:
  /// **'Post marked as resolved.'**
  String get postMarkedResolved;

  /// No description provided for @loginToComment.
  ///
  /// In en, this message translates to:
  /// **'Please login to comment.'**
  String get loginToComment;

  /// No description provided for @commentAdded.
  ///
  /// In en, this message translates to:
  /// **'Comment added.'**
  String get commentAdded;

  /// No description provided for @deletePost.
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get deletePost;

  /// No description provided for @deletePostConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post?'**
  String get deletePostConfirm;

  /// No description provided for @contactWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Contact via WhatsApp'**
  String get contactWhatsapp;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description provided.'**
  String get noDescription;

  /// No description provided for @commentsSection.
  ///
  /// In en, this message translates to:
  /// **'Comments ({count})'**
  String commentsSection(int count);

  /// No description provided for @noCommentsSection.
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Be the first to comment.'**
  String get noCommentsSection;

  /// No description provided for @typeComment.
  ///
  /// In en, this message translates to:
  /// **'Type your comment...'**
  String get typeComment;

  /// No description provided for @itemResolved.
  ///
  /// In en, this message translates to:
  /// **'Item Resolved'**
  String get itemResolved;

  /// No description provided for @resolvedBadge.
  ///
  /// In en, this message translates to:
  /// **'✓ RESOLVED'**
  String get resolvedBadge;

  /// No description provided for @viewPost.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewPost;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @createPost.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPost;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// No description provided for @shareDetails.
  ///
  /// In en, this message translates to:
  /// **'Share details to help the community identify the item.'**
  String get shareDetails;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @itemNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Item name must be at least 2 characters'**
  String get itemNameRequired;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @selectCity.
  ///
  /// In en, this message translates to:
  /// **'Select city'**
  String get selectCity;

  /// No description provided for @cityRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a city'**
  String get cityRequired;

  /// No description provided for @street.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// No description provided for @streetRequired.
  ///
  /// In en, this message translates to:
  /// **'Street is required'**
  String get streetRequired;

  /// No description provided for @imagesSection.
  ///
  /// In en, this message translates to:
  /// **'Images ({count}/3)'**
  String imagesSection(int count);

  /// No description provided for @noImagesSelected.
  ///
  /// In en, this message translates to:
  /// **'No images selected'**
  String get noImagesSelected;

  /// No description provided for @maxImagesReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum 3 images allowed.'**
  String get maxImagesReached;

  /// No description provided for @couldNotPickImage.
  ///
  /// In en, this message translates to:
  /// **'Could not pick image. Please try again.'**
  String get couldNotPickImage;

  /// No description provided for @loginToPost.
  ///
  /// In en, this message translates to:
  /// **'Please login to create a post.'**
  String get loginToPost;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addImage;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @postCreated.
  ///
  /// In en, this message translates to:
  /// **'Post created successfully.'**
  String get postCreated;

  /// No description provided for @homeNav.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeNav;

  /// No description provided for @activityNav.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityNav;

  /// No description provided for @profileNav.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileNav;

  /// No description provided for @postFab.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postFab;

  /// No description provided for @createPostTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create post'**
  String get createPostTooltip;

  /// No description provided for @typeLost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get typeLost;

  /// No description provided for @typeFound.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get typeFound;

  /// No description provided for @typeLostUpper.
  ///
  /// In en, this message translates to:
  /// **'LOST'**
  String get typeLostUpper;

  /// No description provided for @typeFoundUpper.
  ///
  /// In en, this message translates to:
  /// **'FOUND'**
  String get typeFoundUpper;

  /// No description provided for @reauthTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Identity'**
  String get reauthTitle;

  /// No description provided for @reauthBody.
  ///
  /// In en, this message translates to:
  /// **'To delete your account, we need to verify your phone number. A code will be sent to {phone}.'**
  String reauthBody(String phone);

  /// No description provided for @sendingCode.
  ///
  /// In en, this message translates to:
  /// **'Sending code…'**
  String get sendingCode;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Delete'**
  String get confirmDelete;

  /// No description provided for @editPost.
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get editPost;

  /// No description provided for @editPostTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get editPostTitle;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @postUpdated.
  ///
  /// In en, this message translates to:
  /// **'Post updated successfully.'**
  String get postUpdated;

  /// No description provided for @filterByCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get filterByCategory;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// No description provided for @categoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get categoryElectronics;

  /// No description provided for @categoryDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get categoryDocuments;

  /// No description provided for @categoryPersonalItems.
  ///
  /// In en, this message translates to:
  /// **'Personal Items'**
  String get categoryPersonalItems;

  /// No description provided for @categoryPets.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get categoryPets;

  /// No description provided for @viewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} views'**
  String viewsCount(int count);

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String memberSince(String date);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'ckb', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'ckb':
      return AppLocalizationsCkb();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
