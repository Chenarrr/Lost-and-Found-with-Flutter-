import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/l10n/app_locale_utils.dart';
import 'package:flutter_application/l10n/app_localizations_ar.dart';
import 'package:flutter_application/l10n/app_localizations_ckb.dart';
import 'package:flutter_application/l10n/app_localizations_en.dart';
import 'package:flutter_application/models/post.dart';

void main() {
  group('app locale utils', () {
    test('localizes stored city names', () {
      expect(localizeStoredCityName('Erbil', AppLocalizationsAr()), 'أربيل');
      expect(localizeStoredCityName('Erbil', AppLocalizationsCkb()), 'هەولێر');
    });

    test('localizes post categories', () {
      expect(
        PostCategory.personalItems.localizedLabel(AppLocalizationsAr()),
        'أشياء شخصية',
      );
      expect(
        PostCategory.pets.localizedLabel(AppLocalizationsCkb()),
        'ئاژەڵە ماڵییەکان',
      );
    });

    test('localizes fallback usernames', () {
      expect(localizedUserName('Unknown', AppLocalizationsAr()), 'غير معروف');
      expect(localizedUserName('', AppLocalizationsCkb()), 'ناسراو نییە');
    });

    test('localizes known auth errors', () {
      expect(
        localizeAppError(
          'Invalid code. Please try again.',
          AppLocalizationsAr(),
        ),
        'الرمز غير صحيح. يرجى المحاولة مرة أخرى.',
      );
      expect(
        localizeAppError('Failed to update name.', AppLocalizationsCkb()),
        'نوێکردنەوەی ناو سەرکەوتوو نەبوو.',
      );
    });

    test('formats member-since dates by locale', () {
      final date = DateTime(2024, 4, 20);

      expect(formatMemberSinceDate(date, AppLocalizationsEn()), 'Apr 2024');
      expect(formatMemberSinceDate(date, AppLocalizationsAr()), 'أبريل 2024');
      expect(formatMemberSinceDate(date, AppLocalizationsCkb()), 'نیسان 2024');
    });
  });
}
