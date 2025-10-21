// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'صحتك';

  @override
  String get chronicDiseaseQuestion => 'هل لديك مرض مزمن؟';

  @override
  String get chronicDiseaseExplanation =>
      'لتجربة أفضل وفحص مخصص يتناسب مع ملفك الشخصي، نحتاج إلى معرفة بعض المعلومات عن حالتك الصحية';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get next => 'التالي';

  @override
  String get selectLanguage => 'اختر لغة';

  @override
  String get pleaseSelectOption => 'الرجاء تحديد خيار';

  @override
  String get informationSaved => 'تم حفظ المعلومات بنجاح!';

  @override
  String get selectProofTitle => 'اختر إثبات مهنتك! 🎓';

  @override
  String get selectProofSubtitle =>
      'يرجى اختيار إثبات يحتوي على شهادتك. هذه الخطوة إلزامية.';

  @override
  String get chooseProofHint => 'اختر إثبات مهنتك';

  @override
  String get diploma => 'شهادة';

  @override
  String get workAttestation => 'شهادة عمل';

  @override
  String get trainingAttestation => 'شهادة تدريب';
}
