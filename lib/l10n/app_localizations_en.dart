// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Find It';

  @override
  String get tagline => 'Reuniting lost items across Kurdistan';

  @override
  String get getStarted => 'Get Started';

  @override
  String get loginOrSignup => 'Login or Signup';

  @override
  String get loginTab => 'Login';

  @override
  String get signupTab => 'Signup';

  @override
  String get phonePlaceholder => 'Phone number';

  @override
  String get requiredField => 'Required';

  @override
  String get phoneInvalid => 'Enter 10 digits starting with 7';

  @override
  String get namePlaceholder => 'Full Name';

  @override
  String get nameTooShort => 'Enter at least 2 characters';

  @override
  String get phoneRequired => 'Phone is required';

  @override
  String get emailPlaceholder => 'Email (optional)';

  @override
  String get emailInvalid => 'Invalid email';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderRequired => 'Please select a gender';

  @override
  String get ageLabel => 'Age';

  @override
  String get ageRequired => 'Age is required';

  @override
  String get ageInvalid => 'Enter a valid age (13–100)';

  @override
  String get verifyPhone => 'Verify Phone';

  @override
  String get enterCodeSentTo => 'Enter the 6-digit code sent to';

  @override
  String get codeInvalid => 'Enter the 6-digit code';

  @override
  String get verifyCode => 'Verify Code';

  @override
  String resendCountdown(int seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get resendCode => 'Resend Code';

  @override
  String get newCodeSent => 'New code sent!';

  @override
  String get allCities => 'All Cities';

  @override
  String get cityErbil => 'Erbil';

  @override
  String get citySulaymaniyah => 'Sulaymaniyah';

  @override
  String get cityDuhok => 'Duhok';

  @override
  String get cityHalabja => 'Halabja';

  @override
  String get cityZakho => 'Zakho';

  @override
  String get cityKoya => 'Koya';

  @override
  String get searchHint => 'Search items, city, street...';

  @override
  String lostBadge(int count) {
    return '$count Lost';
  }

  @override
  String foundBadge(int count) {
    return '$count Found';
  }

  @override
  String resultsCount(int count) {
    return '$count results';
  }

  @override
  String get filterByCity => 'Filter by City';

  @override
  String get all => 'All';

  @override
  String get lost => 'Lost';

  @override
  String get found => 'Found';

  @override
  String get noItemsFound => 'No items found';

  @override
  String get noItemsFoundHint => 'Try another city or clear the search field.';

  @override
  String get pleaseLogIn => 'Please log in';

  @override
  String get logInToTrack => 'Log in to track your posts and comments.';

  @override
  String get activityTitle => 'Activity';

  @override
  String myPostsTab(int count) {
    return 'My Posts ($count)';
  }

  @override
  String myCommentsTab(int count) {
    return 'My Comments ($count)';
  }

  @override
  String get noPostsYet => 'No posts yet';

  @override
  String get createFirstPost => 'Create your first post to get started.';

  @override
  String get noCommentsYet => 'No comments yet';

  @override
  String get commentToEngage =>
      'Comment on posts to engage with the community.';

  @override
  String get pleaseLogInProfile => 'Please log in to view your profile.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get posts => 'Posts';

  @override
  String get yourPosts => 'Your Posts';

  @override
  String totalPosts(int count) {
    return '$count total';
  }

  @override
  String get noItemsPosted => 'You have not posted any items yet.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get changeName => 'Change Name';

  @override
  String get yourName => 'Your name';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get account => 'Account';

  @override
  String get updateDisplayName => 'Update your display name';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm =>
      'Are you sure you want to log out of your account?';

  @override
  String get signOutDevice => 'Sign out from this device';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirm =>
      'This will permanently delete your account and all your posts. This cannot be undone.';

  @override
  String get permanentlyRemove => 'Permanently remove your account and posts';

  @override
  String get delete => 'Delete';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Choose app language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get kurdish => 'کوردی';

  @override
  String get preferences => 'Preferences';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get postDetails => 'Post Details';

  @override
  String get postNotFound => 'Post not found.';

  @override
  String get couldNotOpenWhatsapp => 'Could not open WhatsApp.';

  @override
  String get sharedVia => 'Shared via Find It app';

  @override
  String get whatsappMessagePrefix => 'Hi, I saw your post about:';

  @override
  String get loginToReport => 'Please login to report this post.';

  @override
  String get cannotReportOwn => 'You cannot report your own post.';

  @override
  String get alreadyReported => 'You already reported this post.';

  @override
  String get reportPost => 'Report Post';

  @override
  String get reportConfirm => 'Report this post as fake or inappropriate?';

  @override
  String get report => 'Report';

  @override
  String get reported => 'Reported';

  @override
  String get postReported => 'Post reported. Thank you.';

  @override
  String get markAsResolved => 'Mark as Resolved';

  @override
  String get markResolvedConfirm =>
      'Mark this post as resolved? Others will see it has been closed.';

  @override
  String get markResolved => 'Mark Resolved';

  @override
  String get postMarkedResolved => 'Post marked as resolved.';

  @override
  String get loginToComment => 'Please login to comment.';

  @override
  String get commentAdded => 'Comment added.';

  @override
  String get deletePost => 'Delete Post';

  @override
  String get deletePostConfirm => 'Are you sure you want to delete this post?';

  @override
  String get contactWhatsapp => 'Contact via WhatsApp';

  @override
  String get description => 'Description';

  @override
  String get noDescription => 'No description provided.';

  @override
  String commentsSection(int count) {
    return 'Comments ($count)';
  }

  @override
  String get noCommentsSection => 'No comments yet. Be the first to comment.';

  @override
  String get typeComment => 'Type your comment...';

  @override
  String get itemResolved => 'Item Resolved';

  @override
  String get resolvedBadge => '✓ RESOLVED';

  @override
  String get viewPost => 'View';

  @override
  String get share => 'Share';

  @override
  String get createPost => 'Create Post';

  @override
  String get goHome => 'Go Home';

  @override
  String get shareDetails =>
      'Share details to help the community identify the item.';

  @override
  String get itemName => 'Item Name';

  @override
  String get itemNameRequired => 'Item name must be at least 2 characters';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get city => 'City';

  @override
  String get selectCity => 'Select city';

  @override
  String get cityRequired => 'Please select a city';

  @override
  String get street => 'Street';

  @override
  String get streetRequired => 'Street is required';

  @override
  String imagesSection(int count) {
    return 'Images ($count/3)';
  }

  @override
  String get noImagesSelected => 'No images selected';

  @override
  String get maxImagesReached => 'Maximum 3 images allowed.';

  @override
  String get couldNotPickImage => 'Could not pick image. Please try again.';

  @override
  String get loginToPost => 'Please login to create a post.';

  @override
  String get addImage => 'Add Image';

  @override
  String get submit => 'Submit';

  @override
  String get postCreated => 'Post created successfully.';

  @override
  String get homeNav => 'Home';

  @override
  String get activityNav => 'Activity';

  @override
  String get profileNav => 'Profile';

  @override
  String get postFab => 'Post';

  @override
  String get createPostTooltip => 'Create post';

  @override
  String get typeLost => 'Lost';

  @override
  String get typeFound => 'Found';

  @override
  String get typeLostUpper => 'LOST';

  @override
  String get typeFoundUpper => 'FOUND';

  @override
  String get reauthTitle => 'Verify Your Identity';

  @override
  String reauthBody(String phone) {
    return 'To delete your account, we need to verify your phone number. A code will be sent to $phone.';
  }

  @override
  String get sendingCode => 'Sending code…';

  @override
  String get confirmDelete => 'Confirm & Delete';

  @override
  String get editPost => 'Edit Post';

  @override
  String get editPostTitle => 'Edit Post';

  @override
  String get update => 'Update';

  @override
  String get postUpdated => 'Post updated successfully.';

  @override
  String get filterByCategory => 'Category';

  @override
  String get allCategories => 'All';

  @override
  String get categoryElectronics => 'Electronics';

  @override
  String get categoryDocuments => 'Documents';

  @override
  String get categoryPersonalItems => 'Personal Items';

  @override
  String get categoryPets => 'Pets';

  @override
  String viewsCount(int count) {
    return '$count views';
  }

  @override
  String memberSince(String date) {
    return 'Member since $date';
  }
}
