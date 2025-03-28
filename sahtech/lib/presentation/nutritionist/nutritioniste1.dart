import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/widgets/language_selector.dart';
import 'package:sahtech/presentation/nutritionist/nutritioniste2.dart';

class Nutritioniste1 extends StatefulWidget {
  final NutritionisteModel nutritionistData;
  final int currentStep;
  final int totalSteps;

  const Nutritioniste1({
    Key? key,
    required this.nutritionistData,
    this.currentStep = 1,
    this.totalSteps = 5,
  }) : super(key: key);

  @override
  State<Nutritioniste1> createState() => _Nutritioniste1State();
}

class _Nutritioniste1State extends State<Nutritioniste1> {
  late TranslationService _translationService;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prenomController;

  // Translations
  Map<String, String> _translations = {
    'welcome': 'Soyez les Bienvenu a SahTech !',
    'instructions':
        'Veuillez remplir vos informations afin que nous puissions créer votre carte, qui sera publiée dans notre application',
    'nom_label': 'Nom',
    'nom_hint': 'Entrer votre nom',
    'prenom_label': 'Prenom',
    'prenom_hint': 'Entrer votre Prenom',
    'next': 'suivant',
    'required_field': 'Ce champ est requis',
  };

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController();
    _prenomController = TextEditingController();

    // Pre-fill fields if available in nutritionist data
    if (widget.nutritionistData.name != null) {
      final nameParts = widget.nutritionistData.name!.split(' ');
      if (nameParts.length > 1) {
        _prenomController.text = nameParts[0];
        _nomController.text = nameParts.sublist(1).join(' ');
      } else if (nameParts.length == 1) {
        _nomController.text = nameParts[0];
      }
    }

    _translationService =
        Provider.of<TranslationService>(context, listen: false);
    _loadTranslations();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    super.dispose();
  }

  // Load translations based on current language
  Future<void> _loadTranslations() async {
    setState(() => _isLoading = true);

    try {
      // Only translate if not French (default language)
      if (_translationService.currentLanguageCode != 'fr') {
        final translatedStrings =
            await _translationService.translateMap(_translations);

        if (mounted) {
          setState(() {
            _translations = translatedStrings;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Handle language change
  void _handleLanguageChanged(String languageCode) {
    // Update nutritionist model with the new language
    widget.nutritionistData.preferredLanguage = languageCode;

    // Reload translations with the new language
    _loadTranslations();
  }

  void _continueToNextScreen() {
    if (_formKey.currentState!.validate()) {
      // Save the data to the nutritionist model
      widget.nutritionistData.name =
          "${_prenomController.text.trim()} ${_nomController.text.trim()}";

      // Navigate to the next screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Nutritioniste2(
            nutritionistData: widget.nutritionistData,
            currentStep: widget.currentStep + 1,
            totalSteps: widget.totalSteps,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // Enable keyboard adjustment
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: null, // Remove logo from AppBar
        actions: [
          // Language selector button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: LanguageSelectorButton(
              width: width,
              onLanguageChanged: _handleLanguageChanged,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.lightTeal))
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: width * 0.06,
                    right: width * 0.06,
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Logo added here instead of in AppBar
                        Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: height * 0.06),
                            child: Image.asset(
                              'lib/assets/images/mainlogo.jpg',
                              height: height * 0.05,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        SizedBox(height: height * 0.1),

                        // Welcome title
                        Text(
                          _translations['welcome']!,
                          style: TextStyle(
                            fontSize: width * 0.06,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        SizedBox(height: height * 0.01),

                        // Instructions text
                        Text(
                          _translations['instructions']!,
                          style: TextStyle(
                            fontSize: width * 0.035,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                        ),

                        SizedBox(height: height * 0.04),

                        // Nom field
                        Text(
                          _translations['nom_label']!,
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: height * 0.01),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextFormField(
                            controller: _nomController,
                            decoration: InputDecoration(
                              hintText: _translations['nom_hint'],
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: width * 0.035,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: width * 0.05,
                                vertical: height * 0.018,
                              ),
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return _translations['required_field'];
                              }
                              return null;
                            },
                          ),
                        ),

                        SizedBox(height: height * 0.02),

                        // Prenom field
                        Text(
                          _translations['prenom_label']!,
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: height * 0.01),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextFormField(
                            controller: _prenomController,
                            decoration: InputDecoration(
                              hintText: _translations['prenom_hint'],
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: width * 0.035,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: width * 0.05,
                                vertical: height * 0.018,
                              ),
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return _translations['required_field'];
                              }
                              return null;
                            },
                          ),
                        ),

                        SizedBox(height: height * 0.12),

                        // Suivant button
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: height * 0.03),
                          child: ElevatedButton(
                            onPressed: _continueToNextScreen,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightTeal,
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(
                                  vertical: height * 0.018),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              _translations['next']!,
                              style: TextStyle(
                                fontSize: width * 0.045,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
