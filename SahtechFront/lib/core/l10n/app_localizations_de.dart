// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Sahtech';

  @override
  String get chronicDiseaseQuestion => 'Haben Sie eine chronische Krankheit?';

  @override
  String get chronicDiseaseExplanation =>
      'Für ein besseres Erlebnis und einen personalisierten Scan, der an Ihr Profil angepasst ist, benötigen wir bestimmte Informationen über Ihren Gesundheitszustand';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get next => 'Weiter';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get pleaseSelectOption => 'Bitte wählen Sie eine Option';

  @override
  String get informationSaved => 'Informationen erfolgreich gespeichert!';

  @override
  String get selectProofTitle => 'Sélection une preuve de votre métier ! 🎓';

  @override
  String get selectProofSubtitle =>
      'Veuillez sélectionner une preuve contenant votre diplôme. Cette étape est obligatoire.';

  @override
  String get chooseProofHint => 'Choisissez une preuve de votre métier';

  @override
  String get diploma => 'Diplôme';

  @override
  String get workAttestation => 'Attestation de travail';

  @override
  String get trainingAttestation => 'Attestation de formation';
}
