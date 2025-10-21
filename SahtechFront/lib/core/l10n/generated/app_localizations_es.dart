// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Sahtech';

  @override
  String get chronicDiseaseQuestion => '¿Tiene alguna enfermedad crónica?';

  @override
  String get chronicDiseaseExplanation =>
      'Para una mejor experiencia y un escaneo personalizado adaptado a su perfil, necesitamos conocer cierta información sobre su estado de salud';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get next => 'Siguiente';

  @override
  String get selectLanguage => 'Elegir un idioma';

  @override
  String get pleaseSelectOption => 'Por favor seleccione una opción';

  @override
  String get informationSaved => '¡Información guardada con éxito!';

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
