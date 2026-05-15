// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Central Kurdish (`ckb`).
class AppLocalizationsCkb extends AppLocalizations {
  AppLocalizationsCkb([String locale = 'ckb']) : super(locale);

  @override
  String get appName => 'Find It';

  @override
  String get tagline =>
      'یارمەتیدان بۆ دۆزینەوە و گەڕاندنەوەی شتەکان لە کوردستان';

  @override
  String get getStarted => 'دەستپێبکە';

  @override
  String get loginOrSignup => 'چوونەژوورەوە یان تۆمارکردن';

  @override
  String get loginTab => 'چوونەژوورەوە';

  @override
  String get signupTab => 'تۆمارکردن';

  @override
  String get phonePlaceholder => 'ژمارەی مۆبایل';

  @override
  String get requiredField => 'پێویستە';

  @override
  String get phoneInvalid => '١٠ ژمارە بنووسە کە دەستپێدەکات بە ٧';

  @override
  String get namePlaceholder => 'ناوی تەواو';

  @override
  String get nameTooShort => 'لانیکەم ٢ پیت بنووسە';

  @override
  String get phoneRequired => 'ژمارەی مۆبایل پێویستە';

  @override
  String get emailPlaceholder => 'ئیمەیل (دەکرێت بەتاڵ بێت)';

  @override
  String get emailInvalid => 'ئیمەیلەکە دروست نییە';

  @override
  String get sendOtp => 'کۆدی دووپاتکردنەوە بنێرە';

  @override
  String get genderLabel => 'ڕەگەز';

  @override
  String get genderMale => 'نێر';

  @override
  String get genderFemale => 'مێ';

  @override
  String get genderRequired => 'تکایە ڕەگەزێک هەڵبژێرە';

  @override
  String get ageLabel => 'تەمەن';

  @override
  String get ageRequired => 'تەمەن پێویستە';

  @override
  String get ageInvalid => 'تەمەنێکی دروست بنووسە (١٣–١٠٠)';

  @override
  String get verifyPhone => 'دووپاتکردنەوەی مۆبایل';

  @override
  String get enterCodeSentTo => 'کۆدی ٦ ژمارەیی کە نێردراوە بۆ بنووسە';

  @override
  String get codeInvalid => 'کۆدی ٦ ژمارەیی بنووسە';

  @override
  String get verifyCode => 'کۆدەکە دووپات بکەرەوە';

  @override
  String resendCountdown(int seconds) {
    return 'نێردنەوەی دووبارەی کۆد لە $seconds چرکەدا';
  }

  @override
  String get resendCode => 'کۆدەکە دووبارە بنێرە';

  @override
  String get newCodeSent => 'کۆدی نوێ نێردرا!';

  @override
  String get allCities => 'هەموو شارەکان';

  @override
  String get cityErbil => 'هەولێر';

  @override
  String get citySulaymaniyah => 'سلێمانی';

  @override
  String get cityDuhok => 'دهۆک';

  @override
  String get cityHalabja => 'حەڵەبجە';

  @override
  String get cityZakho => 'زاخۆ';

  @override
  String get cityKoya => 'کۆیە';

  @override
  String get searchHint => 'بە ناوی شت، شار یان کوچە بگەڕێ...';

  @override
  String lostBadge(int count) {
    return '$count ونبوو';
  }

  @override
  String foundBadge(int count) {
    return '$count دۆزراوە';
  }

  @override
  String resultsCount(int count) {
    return '$count ئەنجام';
  }

  @override
  String get filterByCity => 'پاڵاوتن بە شار';

  @override
  String get all => 'هەموو';

  @override
  String get lost => 'ونبوو';

  @override
  String get found => 'دۆزراوە';

  @override
  String get noItemsFound => 'هیچ شتێک نەدۆزرایەوە';

  @override
  String get noItemsFoundHint =>
      'شارێکی تر هەوڵبدە یان مەیدانی گەڕان پاکبکەرەوە.';

  @override
  String get pleaseLogIn => 'تکایە بچۆ ژوورەوە';

  @override
  String get logInToTrack =>
      'چوونەژوورەوە بکە بۆ بەدواداچوونی ڕاپۆرت و لێدوانەکانت.';

  @override
  String get activityTitle => 'چالاکی';

  @override
  String myPostsTab(int count) {
    return 'ڕاپۆرتەکانم ($count)';
  }

  @override
  String myCommentsTab(int count) {
    return 'لێدوانەکانم ($count)';
  }

  @override
  String get noPostsYet => 'هێشتا هیچ ڕاپۆرتێک نییە';

  @override
  String get createFirstPost => 'یەکەم ڕاپۆرتت بڵاو بکەرەوە بۆ دەستپێکردن.';

  @override
  String get noCommentsYet => 'هێشتا هیچ لێدوانێک نییە';

  @override
  String get commentToEngage =>
      'لێدوان لەسەر ڕاپۆرتەکان بدە بۆ پەیوەندیکردن بە کۆمەڵگەوە.';

  @override
  String get pleaseLogInProfile => 'تکایە بچۆ ژوورەوە بۆ بینینی پرۆفایلەکەت.';

  @override
  String get profileTitle => 'پرۆفایل';

  @override
  String get posts => 'ڕاپۆرتەکان';

  @override
  String get yourPosts => 'ڕاپۆرتەکانت';

  @override
  String totalPosts(int count) {
    return '$count کۆی گشتی';
  }

  @override
  String get noItemsPosted => 'هێشتا هیچ ڕاپۆرتێکت بڵاو نەکردووەتەوە.';

  @override
  String get settingsTitle => 'ڕێکخستنەکان';

  @override
  String get changeName => 'گۆڕینی ناو';

  @override
  String get yourName => 'ناوت';

  @override
  String get cancel => 'پاشگەزبوونەوە';

  @override
  String get save => 'پاشەکەوتکردن';

  @override
  String get account => 'ئەکاونت';

  @override
  String get updateDisplayName => 'نەمایشی ناوت نوێبکەرەوە';

  @override
  String get logout => 'دەرچوون';

  @override
  String get logoutConfirm => 'دڵنیایت دەتەوێت دەربچیت؟';

  @override
  String get signOutDevice => 'دەرچوون لەم ئامێرە';

  @override
  String get deleteAccount => 'سڕینەوەی ئەکاونت';

  @override
  String get deleteAccountConfirm =>
      'ئەمە ئەکاونت و هەموو ڕاپۆرتەکانت بۆ هەمیشە دەسڕێتەوە. ناتوانرێت پاشگەزبوونەوە.';

  @override
  String get permanentlyRemove => 'بۆ هەمیشە ئەکاونت و ڕاپۆرتەکانت دەسڕێتەوە';

  @override
  String get delete => 'سڕینەوە';

  @override
  String get language => 'زمان';

  @override
  String get selectLanguage => 'زمانی بەرنامە هەڵبژێرە';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get kurdish => 'کوردی';

  @override
  String get unknownUser => 'ناسراو نییە';

  @override
  String appVersionLabel(String version) {
    return 'Find It v$version';
  }

  @override
  String get preferences => 'ئارەزووەکان';

  @override
  String get darkMode => 'شێوازی تاریک';

  @override
  String get postDetails => 'وردەکاری ڕاپۆرت';

  @override
  String get postNotFound => 'ڕاپۆرتەکە نەدۆزرایەوە.';

  @override
  String get couldNotOpenWhatsapp => 'نەتوانرا واتساپ کرانەوە.';

  @override
  String get sharedVia => 'بە ئەپی Find It هاوبەشکرا';

  @override
  String get whatsappMessagePrefix => 'سڵاو، ڕاپۆرتەکەت دیتم دەربارەی:';

  @override
  String get loginToReport =>
      'تکایە چوونەژوورەوە بکە بۆ سکاڵاکردن لەم ڕاپۆرتە.';

  @override
  String get cannotReportOwn => 'ناتوانیت لە ڕاپۆرتی خۆت سکاڵا بکەیت.';

  @override
  String get alreadyReported => 'پێشتر لەم ڕاپۆرتە سکاڵات کردووە.';

  @override
  String get reportPost => 'سکاڵاکردن لەم ڕاپۆرتە';

  @override
  String get reportConfirm =>
      'ئایا لەم ڕاپۆرتە وەک درۆ یان نەگونجاو سکاڵا دەکەیت؟';

  @override
  String get report => 'سکاڵاکردن';

  @override
  String get reported => 'سکاڵا کراوە';

  @override
  String get postReported => 'سکاڵاکەت نێردرا. سپاس.';

  @override
  String get markAsResolved => 'وەک داخراو نیشان بکە';

  @override
  String get markResolvedConfirm =>
      'ئایا دەتەوێت ئەم ڕاپۆرتە وەک داخراو نیشان بکەیت؟ خەڵکی تر دەبینن کە داخراوە.';

  @override
  String get markResolved => 'وەک داخراو نیشان بکە';

  @override
  String get postMarkedResolved => 'ڕاپۆرتەکە وەک داخراو نیشانکرا.';

  @override
  String get loginToComment => 'تکایە بچۆ ژوورەوە بۆ لێدوانکردن.';

  @override
  String get commentAdded => 'لێدوانەکە زیادکرا.';

  @override
  String get deletePost => 'سڕینەوەی ڕاپۆرت';

  @override
  String get deletePostConfirm => 'دڵنیایت دەتەوێت ئەم ڕاپۆرتە بسڕیتەوە؟';

  @override
  String get contactWhatsapp => 'پەیوەندی بە واتساپ';

  @override
  String get description => 'وەسف';

  @override
  String get noDescription => 'هیچ وەسفێک نەدراوە.';

  @override
  String commentsSection(int count) {
    return 'لێدوانەکان ($count)';
  }

  @override
  String get noCommentsSection =>
      'هێشتا هیچ لێدوانێک نییە. تۆ یەکەم لێدوان بنووسە.';

  @override
  String get typeComment => 'لێدوانەکەت بنووسە...';

  @override
  String get itemResolved => 'حاڵەتەکە داخراوە';

  @override
  String get resolvedBadge => '✓ داخراو';

  @override
  String get viewPost => 'بینین';

  @override
  String get share => 'هاوبەشکردن';

  @override
  String get createPost => 'ڕاپۆرتی نوێ';

  @override
  String get goHome => 'سەرەتا';

  @override
  String get shareDetails => 'وردەکارییەکان هاوبەش بکە بۆ یارمەتیدانی کۆمەڵگە.';

  @override
  String get itemName => 'ناوی شتەکە';

  @override
  String get itemNameRequired => 'ناوی شتەکە دەبێت لانیکەم ٢ پیت بێت';

  @override
  String get descriptionOptional => 'وەسف (دەکرێت بەتاڵ بێت)';

  @override
  String get photosOptional =>
      'وێنە پێویست نییە، بەڵام یارمەتی دەدات شتەکە خێراتر بناسرێتەوە.';

  @override
  String get postTypeSection => 'جۆری حاڵەت';

  @override
  String get itemDetailsSection => 'وردەکاری شتەکە';

  @override
  String get locationSection => 'شوێن';

  @override
  String get city => 'شار';

  @override
  String get selectCity => 'شار هەڵبژێرە';

  @override
  String get cityRequired => 'تکایە شارێک هەڵبژێرە';

  @override
  String get street => 'کوچە';

  @override
  String get streetRequired => 'کوچە پێویستە';

  @override
  String imagesSection(int count) {
    return 'وێنەکان ($count/3)';
  }

  @override
  String get noImagesSelected => 'هیچ وێنەیەک هەڵنەبژێردراوە';

  @override
  String get maxImagesReached => 'زیاترین ژمارەی ڕێپێدراو ٣ وێنەیە.';

  @override
  String get couldNotPickImage =>
      'نەتوانرا وێنە هەڵبژێردرێت. تکایە دووبارە هەوڵبدەرەوە.';

  @override
  String get loginToPost => 'تکایە چوونەژوورەوە بکە بۆ بڵاوکردنەوەی ڕاپۆرت.';

  @override
  String get addImage => 'زیادکردنی وێنە';

  @override
  String get submit => 'بڵاوکردنەوە';

  @override
  String get postCreated => 'ڕاپۆرتەکە بڵاوکرایەوە.';

  @override
  String get postSaveFailed =>
      'نەتوانرا ڕاپۆرتەکە بڵاو بکرێتەوە. تکایە دووبارە هەوڵبدەرەوە.';

  @override
  String get postImageUploadFailed =>
      'بارکردنی وێنە سەرکەوتوو نەبوو. وێنەیەکی بچووکتر هەڵبژێرە یان بێ وێنە بڵاوی بکەرەوە.';

  @override
  String get postPermissionDenied =>
      'نەتوانرا بڵاو بکرێتەوە. تکایە دووبارە بچۆ ژوورەوە.';

  @override
  String get postNetworkFailed =>
      'کێشەی پەیوەندی هەیە. ئینتەرنێت بپشکنە و دووبارە هەوڵبدەرەوە.';

  @override
  String get homeNav => 'سەرەتا';

  @override
  String get activityNav => 'چالاکی';

  @override
  String get profileNav => 'پرۆفایل';

  @override
  String get postFab => 'ڕاپۆرت';

  @override
  String get createPostTooltip => 'ڕاپۆرتی نوێ';

  @override
  String get typeLost => 'ونبوو';

  @override
  String get typeFound => 'دۆزراوە';

  @override
  String get typeLostUpper => 'ونبوو';

  @override
  String get typeFoundUpper => 'دۆزراوە';

  @override
  String get reauthTitle => 'دووپاتکردنەوەی ناسنامە';

  @override
  String reauthBody(String phone) {
    return 'بۆ سڕینەوەی ئەکاونتەکەت، کۆدی دووپاتکردنەوە دەنێردرێت بۆ $phone.';
  }

  @override
  String get sendingCode => 'کۆد دەنێردرێت…';

  @override
  String get confirmDelete => 'دووپاتکردنەوە و سڕینەوە';

  @override
  String get errorInvalidPhoneNumberFormat =>
      'شێوازی ژمارەی مۆبایل دروست نییە.';

  @override
  String get errorTooManyAttempts =>
      'هەوڵدان زۆر بووە. تکایە دواتر دووبارە هەوڵبدە.';

  @override
  String get errorPhoneAuthDisabled =>
      'چوونەژوورەوە بە ژمارەی مۆبایل چالاک نییە. تکایە پەیوەندی بە پاڵپشتی بکە.';

  @override
  String get errorVerificationFailed =>
      'دووپاتکردنەوە سەرکەوتوو نەبوو. تکایە دووبارە هەوڵبدە.';

  @override
  String get errorVerificationIdMissing =>
      'کۆدی پەسەندکردن ون بووە. تکایە دووبارە هەوڵبدە.';

  @override
  String get errorInvalidCode => 'کۆدەکە دروست نییە. تکایە دووبارە هەوڵبدە.';

  @override
  String get errorMissingPhoneNumberFlow =>
      'ژمارەی مۆبایل ون بووە. تکایە بگەڕێوە و دووبارە هەوڵبدە.';

  @override
  String get errorNotLoggedIn => 'تۆ نەچووویتە ژوورەوە.';

  @override
  String get errorDeleteAccountFailed => 'سڕینەوەی ئەکاونت سەرکەوتوو نەبوو.';

  @override
  String get errorPhoneNumberNotFound => 'نەتوانرا ژمارەی مۆبایل بدۆزرێتەوە.';

  @override
  String get errorUpdateNameFailed => 'نوێکردنەوەی ناو سەرکەوتوو نەبوو.';

  @override
  String get editPost => 'دەستکاریکردنی ڕاپۆرت';

  @override
  String get editPostTitle => 'دەستکاریکردنی ڕاپۆرت';

  @override
  String get update => 'نوێکردنەوە';

  @override
  String get postUpdated => 'ڕاپۆرتەکە بە سەرکەوتوویی نوێکرایەوە.';

  @override
  String get filterByCategory => 'جۆر';

  @override
  String get allCategories => 'هەموو';

  @override
  String get categoryElectronics => 'ئەلیکترۆنیات';

  @override
  String get categoryDocuments => 'بەڵگەنامە';

  @override
  String get categoryPersonalItems => 'شتی کەسی';

  @override
  String get categoryPets => 'ئاژەڵە ماڵییەکان';

  @override
  String get customCategoryOption => 'جۆری تایبەت';

  @override
  String get customCategoryField => 'جۆری تایبەت';

  @override
  String get customCategoryRequired => 'تکایە جۆرێکی تایبەت بنووسە.';

  @override
  String get customCategoryPrefix => 'جۆر';

  @override
  String viewsCount(int count) {
    return '$count بینین';
  }

  @override
  String memberSince(String date) {
    return 'ئەندام لە $date';
  }

  @override
  String profileSetupHi(String firstName) {
    return 'سڵاو، $firstName!';
  }

  @override
  String get profileSetupSubtitle => 'بمانگە لەکوێیت.';

  @override
  String get profileSetupCityTitle => 'شارەکەت';

  @override
  String get profileSetupCitySubtitle => 'ڕاپۆرتە نزیکەکان پیشانت دەدەین.';

  @override
  String get profileSetupContinue => 'بەردەوامبە →';

  @override
  String get profileSetupSelectCityError => 'تکایە شارەکەت هەڵبژێرە.';

  @override
  String get permissionsTitle => 'چەند شتێکی\nپێویست.';

  @override
  String get permissionsSubtitle =>
      'ئەمانە یارمەتی FindIt دەدەن باشتر بۆت کاربکات.';

  @override
  String get permissionsNotifications => 'ئاگادارکردنەوەکان';

  @override
  String get permissionsNotificationsDesc =>
      'کاتێک کەسێک شتەکەت دۆزیەوە یان وەڵامی ڕاپۆرتەکەت دایەوە ئاگادار بکرەیتەوە.';

  @override
  String get permissionsLocation => 'شوێن';

  @override
  String get permissionsLocationDesc =>
      'ڕاپۆرتە نزیکەکان پیشانت بدە و یارمەتی خەڵک بدە لە ناوچەکەتدا.';

  @override
  String get permissionsAllow => 'ڕازیبوون و بەردەوامبوون';

  @override
  String get permissionsSettingsHint =>
      'هەر کاتێک دەتوانیت لە ڕێکخستنەکاندا بیگۆڕیت.';

  @override
  String get doneTitle => 'ئامادەیت،';

  @override
  String get doneSubtitle => 'بەخێربێیت بۆ کۆمەڵگەی FindIt.';

  @override
  String get doneCommunitySnapshot => 'پێشاندانی کۆمەڵگە';

  @override
  String get doneItemsReturned => 'شت\nگەڕاندرایەوە';

  @override
  String get doneCitiesCovered => 'شار\nتێدەگات';

  @override
  String get doneActiveMembers => 'ئەندامی\nچالاک';

  @override
  String get doneOpenApp => 'FindIt کرانەوە →';
}
