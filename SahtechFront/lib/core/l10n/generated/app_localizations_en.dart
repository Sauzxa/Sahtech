// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sahtech';

  @override
  String get chronicDiseaseQuestion => 'Do you have a chronic disease?';

  @override
  String get chronicDiseaseExplanation =>
      'For a better experience and a personalized scan adapted to your profile, we need to know certain information about your health status';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get next => 'Next';

  @override
  String get selectLanguage => 'Choose a language';

  @override
  String get pleaseSelectOption => 'Please select an option';

  @override
  String get informationSaved => 'Information saved successfully!';

  @override
  String get selectProofTitle => 'Select a proof of your profession! 🎓';

  @override
  String get selectProofSubtitle =>
      'Please select a proof containing your diploma. This step is mandatory.';

  @override
  String get chooseProofHint => 'Choose a proof of your profession';

  @override
  String get diploma => 'Diploma';

  @override
  String get workAttestation => 'Work attestation';

  @override
  String get trainingAttestation => 'Training attestation';
}
