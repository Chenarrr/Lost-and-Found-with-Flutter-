import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_application/l10n/app_localizations.dart';
import 'package:flutter_application/models/post.dart';

class CkbMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const CkbMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ckb';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('ar'));

  @override
  bool shouldReload(CkbMaterialLocalizationsDelegate old) => false;
}

class CkbCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const CkbCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ckb';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('ar'));

  @override
  bool shouldReload(CkbCupertinoLocalizationsDelegate old) => false;
}

enum AppCity { erbil, sulaymaniyah, duhok, halabja, zakho, koya }

extension AppCityX on AppCity {
  String get storageValue => switch (this) {
    AppCity.erbil => 'Erbil',
    AppCity.sulaymaniyah => 'Sulaymaniyah',
    AppCity.duhok => 'Duhok',
    AppCity.halabja => 'Halabja',
    AppCity.zakho => 'Zakho',
    AppCity.koya => 'Koya',
  };

  String localizedLabel(AppLocalizations l10n) => switch (this) {
    AppCity.erbil => l10n.cityErbil,
    AppCity.sulaymaniyah => l10n.citySulaymaniyah,
    AppCity.duhok => l10n.cityDuhok,
    AppCity.halabja => l10n.cityHalabja,
    AppCity.zakho => l10n.cityZakho,
    AppCity.koya => l10n.cityKoya,
  };
}

AppCity? appCityFromStorageValue(String value) {
  final normalized = value.trim().toLowerCase();
  for (final city in AppCity.values) {
    if (city.storageValue.toLowerCase() == normalized) {
      return city;
    }
  }
  return null;
}

String localizeStoredCityName(String city, AppLocalizations l10n) {
  return appCityFromStorageValue(city)?.localizedLabel(l10n) ?? city;
}

extension LocalizedPostCategoryX on PostCategory {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    PostCategory.electronics => l10n.categoryElectronics,
    PostCategory.documents => l10n.categoryDocuments,
    PostCategory.personalItems => l10n.categoryPersonalItems,
    PostCategory.pets => l10n.categoryPets,
  };
}

String localizedUserName(String value, AppLocalizations l10n) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized == 'Unknown') {
    return l10n.unknownUser;
  }
  return normalized;
}

String localizeAppError(String error, AppLocalizations l10n) {
  switch (error.trim()) {
    case 'Invalid phone number format.':
      return l10n.errorInvalidPhoneNumberFormat;
    case 'Too many attempts. Try again later.':
      return l10n.errorTooManyAttempts;
    case 'Phone auth is not enabled. Please contact support.':
      return l10n.errorPhoneAuthDisabled;
    case 'Verification failed. Please try again.':
      return l10n.errorVerificationFailed;
    case 'Verification ID is missing.':
      return l10n.errorVerificationIdMissing;
    case 'Invalid code. Please try again.':
      return l10n.errorInvalidCode;
    case 'No phone number. Please go back and try again.':
      return l10n.errorMissingPhoneNumberFlow;
    case 'Not logged in.':
      return l10n.errorNotLoggedIn;
    case 'Failed to delete account.':
      return l10n.errorDeleteAccountFailed;
    case 'Could not find phone number.':
      return l10n.errorPhoneNumberNotFound;
    case 'Failed to update name.':
      return l10n.errorUpdateNameFailed;
    default:
      return error;
  }
}

String formatMemberSinceDate(DateTime date, AppLocalizations l10n) {
  const englishMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  const arabicMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  const kurdishMonths = [
    'کانوونی دووەم',
    'شوبات',
    'ئازار',
    'نیسان',
    'ئایار',
    'حوزەیران',
    'تەممووز',
    'ئاب',
    'ئەیلوول',
    'تشرینی یەکەم',
    'تشرینی دووەم',
    'کانوونی یەکەم',
  ];

  final months = switch (l10n.localeName) {
    'ar' => arabicMonths,
    'ckb' => kurdishMonths,
    _ => englishMonths,
  };

  return '${months[date.month - 1]} ${date.year}';
}
