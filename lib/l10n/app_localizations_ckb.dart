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
  String get tagline => 'گەڕانەوەی شتە وەڵاوبووەکان لە کوردستان';

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
  String get searchHint => 'بگەڕێ بۆ شت، شار، کوچە...';

  @override
  String lostBadge(int count) {
    return '$count وەڵاوبوو';
  }

  @override
  String foundBadge(int count) {
    return '$count دۆزرایەوە';
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
  String get lost => 'وەڵاوبوو';

  @override
  String get found => 'دۆزرایەوە';

  @override
  String get noItemsFound => 'هیچ شتێک نەدۆزرایەوە';

  @override
  String get noItemsFoundHint =>
      'شارێکی تر هەوڵبدە یان مەیدانی گەڕان پاکبکەرەوە.';

  @override
  String get pleaseLogIn => 'تکایە بچۆ ژوورەوە';

  @override
  String get logInToTrack =>
      'بچۆ ژوورەوە بۆ شوێنکەوتنی پۆستەکانت و لێدوانەکانت.';

  @override
  String get activityTitle => 'چالاکی';

  @override
  String myPostsTab(int count) {
    return 'پۆستەکانم ($count)';
  }

  @override
  String myCommentsTab(int count) {
    return 'لێدوانەکانم ($count)';
  }

  @override
  String get noPostsYet => 'هێشتا هیچ پۆستێک نییە';

  @override
  String get createFirstPost => 'یەکەم پۆستەکەت دروست بکە بۆ دەستپێکردن.';

  @override
  String get noCommentsYet => 'هێشتا هیچ لێدوانێک نییە';

  @override
  String get commentToEngage =>
      'لێدوان لەسەر پۆستەکان بدە بۆ پەیوەندیکردن بە کۆمەڵگەوە.';

  @override
  String get pleaseLogInProfile => 'تکایە بچۆ ژوورەوە بۆ بینینی پرۆفایلەکەت.';

  @override
  String get profileTitle => 'پرۆفایل';

  @override
  String get posts => 'پۆستەکان';

  @override
  String get yourPosts => 'پۆستەکانت';

  @override
  String totalPosts(int count) {
    return '$count کۆی گشتی';
  }

  @override
  String get noItemsPosted => 'هێشتا هیچ شتێکت نەناردووە.';

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
      'ئەمە ئەکاونت و هەموو پۆستەکانت بۆ هەمیشە دەسڕێتەوە. ناتوانرێت پاشگەزبوونەوە.';

  @override
  String get permanentlyRemove => 'بۆ هەمیشە ئەکاونت و پۆستەکانت دەسڕێتەوە';

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
  String get preferences => 'ئارەزووەکان';

  @override
  String get darkMode => 'شێوازی تاریک';

  @override
  String get postDetails => 'وردەکاری پۆست';

  @override
  String get postNotFound => 'پۆستەکە نەدۆزرایەوە.';

  @override
  String get couldNotOpenWhatsapp => 'نەتوانرا واتساپ کرانەوە.';

  @override
  String get sharedVia => 'بە ئەپی Find It هاوبەشکرا';

  @override
  String get whatsappMessagePrefix => 'سڵاو، پۆستەکەت دیتم دەربارەی:';

  @override
  String get loginToReport => 'تکایە بچۆ ژوورەوە بۆ ئاگادارکردنەوە لەم پۆستە.';

  @override
  String get cannotReportOwn => 'ناتوانیت پۆستی خۆت ئاگادار بکەیتەوە.';

  @override
  String get alreadyReported => 'پێشتر ئاگادارت کردووەتەوە لەم پۆستە.';

  @override
  String get reportPost => 'ئاگادارکردنەوە لەم پۆستە';

  @override
  String get reportConfirm =>
      'ئایا ئاگادار بکەیتەوە لەم پۆستە وەک درۆ یان نەگونجاو؟';

  @override
  String get report => 'ئاگادارکردنەوە';

  @override
  String get reported => 'ئاگادارکرایەوە';

  @override
  String get postReported => 'پۆستەکە ئاگادارکرایەوە. سپاس.';

  @override
  String get markAsResolved => 'وەک چارەسەرکراو نیشانبکە';

  @override
  String get markResolvedConfirm =>
      'ئایا ئەم پۆستە وەک چارەسەرکراو نیشانبکەیت؟ تریش دەیبینن کە داخراوە.';

  @override
  String get markResolved => 'وەک چارەسەرکراو نیشانبکە';

  @override
  String get postMarkedResolved => 'پۆستەکە وەک چارەسەرکراو نیشانکرا.';

  @override
  String get loginToComment => 'تکایە بچۆ ژوورەوە بۆ لێدوانکردن.';

  @override
  String get commentAdded => 'لێدوانەکە زیادکرا.';

  @override
  String get deletePost => 'سڕینەوەی پۆست';

  @override
  String get deletePostConfirm => 'دڵنیایت دەتەوێت ئەم پۆستە بسڕیتەوە؟';

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
  String get noCommentsSection => 'هێشتا هیچ لێدوانێک نییە. یەکەم بە.';

  @override
  String get typeComment => 'لێدوانەکەت بنووسە...';

  @override
  String get itemResolved => 'شتەکە چارەسەرکرا';

  @override
  String get resolvedBadge => '✓ چارەسەرکرا';

  @override
  String get viewPost => 'بینین';

  @override
  String get share => 'هاوبەشکردن';

  @override
  String get createPost => 'دروستکردنی پۆست';

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
  String get maxImagesReached => 'زۆربەی ٣ وێنە ڕێپێدراوە.';

  @override
  String get couldNotPickImage =>
      'نەتوانرا وێنە هەڵبژێردرێت. تکایە دووبارە هەوڵبدەرەوە.';

  @override
  String get loginToPost => 'تکایە بچۆ ژوورەوە بۆ دروستکردنی پۆست.';

  @override
  String get addImage => 'زیادکردنی وێنە';

  @override
  String get submit => 'ناردن';

  @override
  String get postCreated => 'پۆستەکە بە سەرکەوتوویی دروستکرا.';

  @override
  String get homeNav => 'سەرەتا';

  @override
  String get activityNav => 'چالاکی';

  @override
  String get profileNav => 'پرۆفایل';

  @override
  String get postFab => 'پۆست';

  @override
  String get createPostTooltip => 'دروستکردنی پۆست';

  @override
  String get typeLost => 'وەڵاوبوو';

  @override
  String get typeFound => 'دۆزرایەوە';

  @override
  String get typeLostUpper => 'وەڵاوبوو';

  @override
  String get typeFoundUpper => 'دۆزرایەوە';

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
  String get editPost => 'دەستکاریکردنی پۆست';

  @override
  String get editPostTitle => 'دەستکاریکردنی پۆست';

  @override
  String get update => 'نوێکردنەوە';

  @override
  String get postUpdated => 'پۆستەکە بە سەرکەوتوویی نوێکرایەوە.';

  @override
  String get filterByCategory => 'جۆر';

  @override
  String get allCategories => 'هەموو';

  @override
  String get categoryElectronics => 'ئەلیکترۆنی';

  @override
  String get categoryDocuments => 'بەڵگەنامە';

  @override
  String get categoryPersonalItems => 'شتی کەسی';

  @override
  String get categoryPets => 'ئاژەڵ';

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
}
