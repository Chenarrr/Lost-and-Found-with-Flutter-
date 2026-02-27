// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Find It';

  @override
  String get tagline => 'إعادة الأشياء المفقودة في كردستان';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get loginOrSignup => 'تسجيل الدخول أو إنشاء حساب';

  @override
  String get loginTab => 'دخول';

  @override
  String get signupTab => 'حساب جديد';

  @override
  String get phonePlaceholder => 'رقم الهاتف';

  @override
  String get requiredField => 'مطلوب';

  @override
  String get phoneInvalid => 'أدخل 10 أرقام تبدأ بـ 7';

  @override
  String get namePlaceholder => 'الاسم الكامل';

  @override
  String get nameTooShort => 'أدخل حرفين على الأقل';

  @override
  String get phoneRequired => 'الهاتف مطلوب';

  @override
  String get emailPlaceholder => 'البريد الإلكتروني (اختياري)';

  @override
  String get emailInvalid => 'بريد إلكتروني غير صالح';

  @override
  String get sendOtp => 'إرسال رمز التحقق';

  @override
  String get genderLabel => 'الجنس';

  @override
  String get genderMale => 'ذكر';

  @override
  String get genderFemale => 'أنثى';

  @override
  String get genderRequired => 'يرجى اختيار الجنس';

  @override
  String get ageLabel => 'العمر';

  @override
  String get ageRequired => 'العمر مطلوب';

  @override
  String get ageInvalid => 'أدخل عمرًا صحيحًا (13–100)';

  @override
  String get verifyPhone => 'التحقق من الهاتف';

  @override
  String get enterCodeSentTo => 'أدخل الرمز المكون من 6 أرقام المُرسل إلى';

  @override
  String get codeInvalid => 'أدخل الرمز المكون من 6 أرقام';

  @override
  String get verifyCode => 'تحقق من الرمز';

  @override
  String resendCountdown(int seconds) {
    return 'إعادة الإرسال خلال $seconds ثانية';
  }

  @override
  String get resendCode => 'إعادة إرسال الرمز';

  @override
  String get newCodeSent => 'تم إرسال رمز جديد!';

  @override
  String get allCities => 'جميع المدن';

  @override
  String get cityErbil => 'أربيل';

  @override
  String get citySulaymaniyah => 'السليمانية';

  @override
  String get cityDuhok => 'دهوك';

  @override
  String get cityHalabja => 'حلبجة';

  @override
  String get cityZakho => 'زاخو';

  @override
  String get cityKoya => 'كوية';

  @override
  String get searchHint => 'ابحث عن أشياء، مدينة، شارع...';

  @override
  String lostBadge(int count) {
    return '$count مفقود';
  }

  @override
  String foundBadge(int count) {
    return '$count موجود';
  }

  @override
  String resultsCount(int count) {
    return '$count نتيجة';
  }

  @override
  String get filterByCity => 'تصفية حسب المدينة';

  @override
  String get all => 'الكل';

  @override
  String get lost => 'مفقود';

  @override
  String get found => 'موجود';

  @override
  String get noItemsFound => 'لا توجد عناصر';

  @override
  String get noItemsFoundHint => 'جرب مدينة أخرى أو امسح حقل البحث.';

  @override
  String get pleaseLogIn => 'يرجى تسجيل الدخول';

  @override
  String get logInToTrack => 'سجل الدخول لمتابعة منشوراتك وتعليقاتك.';

  @override
  String get activityTitle => 'النشاط';

  @override
  String myPostsTab(int count) {
    return 'منشوراتي ($count)';
  }

  @override
  String myCommentsTab(int count) {
    return 'تعليقاتي ($count)';
  }

  @override
  String get noPostsYet => 'لا توجد منشورات بعد';

  @override
  String get createFirstPost => 'أنشئ منشورك الأول للبدء.';

  @override
  String get noCommentsYet => 'لا توجد تعليقات بعد';

  @override
  String get commentToEngage => 'علق على المنشورات للتفاعل مع المجتمع.';

  @override
  String get pleaseLogInProfile => 'يرجى تسجيل الدخول لعرض ملفك الشخصي.';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get posts => 'المنشورات';

  @override
  String get yourPosts => 'منشوراتك';

  @override
  String totalPosts(int count) {
    return '$count إجمالي';
  }

  @override
  String get noItemsPosted => 'لم تنشر أي عناصر بعد.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get changeName => 'تغيير الاسم';

  @override
  String get yourName => 'اسمك';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get account => 'الحساب';

  @override
  String get updateDisplayName => 'تحديث اسمك المعروض';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirm => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get signOutDevice => 'تسجيل الخروج من هذا الجهاز';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountConfirm =>
      'سيحذف هذا حسابك وجميع منشوراتك بشكل دائم. لا يمكن التراجع عن ذلك.';

  @override
  String get permanentlyRemove => 'إزالة حسابك ومنشوراتك بشكل دائم';

  @override
  String get delete => 'حذف';

  @override
  String get language => 'اللغة';

  @override
  String get selectLanguage => 'اختر لغة التطبيق';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get preferences => 'التفضيلات';

  @override
  String get postDetails => 'تفاصيل المنشور';

  @override
  String get postNotFound => 'المنشور غير موجود.';

  @override
  String get couldNotOpenWhatsapp => 'تعذر فتح واتساب.';

  @override
  String get sharedVia => 'مشاركة عبر تطبيق Find It';

  @override
  String get whatsappMessagePrefix => 'مرحباً، رأيت منشورك عن:';

  @override
  String get loginToReport => 'يرجى تسجيل الدخول للإبلاغ عن هذا المنشور.';

  @override
  String get cannotReportOwn => 'لا يمكنك الإبلاغ عن منشورك الخاص.';

  @override
  String get alreadyReported => 'لقد أبلغت عن هذا المنشور مسبقًا.';

  @override
  String get reportPost => 'الإبلاغ عن المنشور';

  @override
  String get reportConfirm =>
      'الإبلاغ عن هذا المنشور باعتباره مزيفًا أو غير لائق؟';

  @override
  String get report => 'إبلاغ';

  @override
  String get reported => 'تم الإبلاغ';

  @override
  String get postReported => 'تم الإبلاغ عن المنشور. شكرًا.';

  @override
  String get markAsResolved => 'وضع علامة محلول';

  @override
  String get markResolvedConfirm =>
      'وضع علامة محلول على هذا المنشور؟ سيرى الآخرون أنه تم إغلاقه.';

  @override
  String get markResolved => 'تحديد كمحلول';

  @override
  String get postMarkedResolved => 'تم وضع علامة محلول على المنشور.';

  @override
  String get loginToComment => 'يرجى تسجيل الدخول للتعليق.';

  @override
  String get commentAdded => 'تمت إضافة التعليق.';

  @override
  String get deletePost => 'حذف المنشور';

  @override
  String get deletePostConfirm => 'هل أنت متأكد من حذف هذا المنشور؟';

  @override
  String get contactWhatsapp => 'التواصل عبر واتساب';

  @override
  String get description => 'الوصف';

  @override
  String get noDescription => 'لم يتم تقديم وصف.';

  @override
  String commentsSection(int count) {
    return 'التعليقات ($count)';
  }

  @override
  String get noCommentsSection => 'لا توجد تعليقات بعد. كن أول من يعلق.';

  @override
  String get typeComment => 'اكتب تعليقك...';

  @override
  String get itemResolved => 'تم حل العنصر';

  @override
  String get resolvedBadge => '✓ محلول';

  @override
  String get viewPost => 'عرض';

  @override
  String get share => 'مشاركة';

  @override
  String get createPost => 'إنشاء منشور';

  @override
  String get goHome => 'الرئيسية';

  @override
  String get shareDetails =>
      'شارك التفاصيل لمساعدة المجتمع على التعرف على العنصر.';

  @override
  String get itemName => 'اسم العنصر';

  @override
  String get itemNameRequired => 'يجب أن يكون اسم العنصر حرفين على الأقل';

  @override
  String get descriptionOptional => 'الوصف (اختياري)';

  @override
  String get city => 'المدينة';

  @override
  String get selectCity => 'اختر المدينة';

  @override
  String get cityRequired => 'يرجى اختيار مدينة';

  @override
  String get street => 'الشارع';

  @override
  String get streetRequired => 'الشارع مطلوب';

  @override
  String imagesSection(int count) {
    return 'الصور ($count/3)';
  }

  @override
  String get noImagesSelected => 'لم يتم اختيار صور';

  @override
  String get maxImagesReached => 'الحد الأقصى 3 صور مسموح به.';

  @override
  String get couldNotPickImage => 'تعذر اختيار صورة. يرجى المحاولة مجددًا.';

  @override
  String get loginToPost => 'يرجى تسجيل الدخول لإنشاء منشور.';

  @override
  String get addImage => 'إضافة صورة';

  @override
  String get submit => 'إرسال';

  @override
  String get postCreated => 'تم إنشاء المنشور بنجاح.';

  @override
  String get homeNav => 'الرئيسية';

  @override
  String get activityNav => 'النشاط';

  @override
  String get profileNav => 'الملف الشخصي';

  @override
  String get postFab => 'نشر';

  @override
  String get createPostTooltip => 'إنشاء منشور';

  @override
  String get typeLost => 'مفقود';

  @override
  String get typeFound => 'موجود';

  @override
  String get typeLostUpper => 'مفقود';

  @override
  String get typeFoundUpper => 'موجود';

  @override
  String get reauthTitle => 'التحقق من هويتك';

  @override
  String reauthBody(String phone) {
    return 'لحذف حسابك، سنرسل رمز تحقق إلى $phone.';
  }

  @override
  String get sendingCode => 'جارٍ الإرسال…';

  @override
  String get confirmDelete => 'تأكيد وحذف';
}
