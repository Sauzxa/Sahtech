// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Sahtech';

  @override
  String get chronicDiseaseQuestion => 'Avez vous une maldie chronique ?';

  @override
  String get chronicDiseaseExplanation =>
      'Pour une meilleure expérience et un scan personnalisé adapté à votre profil, nous avons besoin de connaître certaines informations sur votre état de santé';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get next => 'suivant';

  @override
  String get selectLanguage => 'Choisir une langue';

  @override
  String get pleaseSelectOption => 'Veuillez sélectionner une option';

  @override
  String get informationSaved => 'Informations enregistrées avec succès!';

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
