import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/widgets/language_selector.dart';
import 'dart:math';

class Profile10 extends StatefulWidget {
  final UserModel userData;
  final int currentStep;
  final int totalSteps;

  const Profile10({
    Key? key,
    required this.userData,
    this.currentStep = 4,
    this.totalSteps = 5,
  }) : super(key: key);

  @override
  State<Profile10> createState() => _Profile10State();
}

class _Profile10State extends State<Profile10> {
  late TranslationService _translationService;
  bool _isLoading = false;

  // Years, months, days for date picker
  final List<String> _years = List.generate(
      126, // 2025 - 1900 + 1 = 126 years
      (index) =>
          (2025 - index).toString()); // Start from 2025 and go back to 1900
  final List<String> _months = [
    'Jan',
    'Fev',
    'Mar',
    'Avr',
    'Mai',
    'Juin',
    'Juil',
    'Aout',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  final List<String> _days =
      List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));

  // Date options to display (year, month, day)
  List<List<String>> _dateOptions = [
    ['2002', 'Fev', '03'],
    ['2003', 'Mar', '04'],
    ['2004', 'Avr', '05'],
    ['2005', 'Mai', '06'],
  ];

  // Current start index for date display
  int _dateDisplayStartIndex = 0;

  // Selected date
  String _selectedYear = '2004';
  String _selectedMonth = 'Avr'; // Default to April
  String _selectedDay = '05'; // Default to 5th

  // Common food allergies
  final List<String> _commonAllergies = [
    'Lactose',
    'Gluten',
    'Fruits de mer',
    'Arachides',
    'Soja',
    'Œufs',
    'Fruits à coque',
    'Poisson',
  ];

  // Selected allergies
  final List<String> _selectedAllergies = [];

  // Key translations
  Map<String, String> _translations = {
    'title': 'choisir les choses que vous avez une allergie ?',
    'subtitle':
        'Choisissez un objectif pour mieux adapter votre expérience. Cette option est optionnelle!',
    'year': 'Year',
    'month': 'Month',
    'day': 'Day',
    'next': 'suivant',
    'success_message': 'Informations enregistrées avec succès!',
  };

  @override
  void initState() {
    super.initState();
    _translationService =
        Provider.of<TranslationService>(context, listen: false);
    _translationService.addListener(_onLanguageChanged);
    _loadTranslations();

    // Initialize from user data if available
    if (widget.userData.allergyYear != null) {
      _selectedYear = widget.userData.allergyYear!;
    }
    if (widget.userData.allergyMonth != null) {
      _selectedMonth = widget.userData.allergyMonth!;
    }
    if (widget.userData.allergyDay != null) {
      _selectedDay = widget.userData.allergyDay!;
    }
    if (widget.userData.allergies.isNotEmpty) {
      _selectedAllergies.addAll(widget.userData.allergies);
    }
  }

  @override
  void dispose() {
    _translationService.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) {
      _loadTranslations();
    }
  }

  // Load all needed translations
  Future<void> _loadTranslations() async {
    setState(() => _isLoading = true);

    try {
      // Only translate if not French (our default language)
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
    // Update user model with the new language
    widget.userData.preferredLanguage = languageCode;

    // Language change is handled by the listener (_onLanguageChanged)
  }

  // Toggle allergy selection
  void _toggleAllergy(String allergy) {
    setState(() {
      if (_selectedAllergies.contains(allergy)) {
        _selectedAllergies.remove(allergy);
      } else {
        _selectedAllergies.add(allergy);
      }
    });
  }

  void _continueToNextScreen() {
    // Store allergy data in the user model
    widget.userData.allergies = List.from(_selectedAllergies);
    widget.userData.allergyYear = _selectedYear;
    widget.userData.allergyMonth = _selectedMonth;
    widget.userData.allergyDay = _selectedDay;

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_translations['success_message']!),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // For now, navigate back to home as this is the last screen
    // If you have a next screen, you would use:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => NextScreen(
    //       userData: widget.userData,
    //       currentStep: widget.currentStep + 1,
    //       totalSteps: widget.totalSteps,
    //     ),
    //   ),
    // );

    // As this is the last screen, go back to the home screen
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: width * 0.12,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: Colors.green, size: width * 0.05),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.only(left: width * 0.04),
        ),
        title: Image.asset(
          'lib/assets/images/mainlogo.jpg',
          height: kToolbarHeight * 0.6,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        actions: [
          // Language selector button
          LanguageSelectorButton(
            width: width,
            onLanguageChanged: _handleLanguageChanged,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // Green progress bar/line at the top
                  Container(
                    width: double.infinity,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: width *
                              0.9, // Representing 90% progress (step 9 - almost done)
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.lightTeal,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(2),
                              bottomRight: Radius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main content area
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title and description section
                          SizedBox(height: height * 0.04),
                          Text(
                            _translations['title']!,
                            style: TextStyle(
                              fontSize: min(width * 0.07, 28),
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: height * 0.05),
                          Text(
                            _translations['subtitle']!,
                            style: TextStyle(
                              fontSize: min(width * 0.035, 14),
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                          ),

                          // Added more space between text and date picker
                          SizedBox(height: height * 0.12),

                          // Date picker
                          Center(
                            child: Container(
                              width: width * 0.8,
                              height: height * 0.25,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Year dropdown header
                                  GestureDetector(
                                    onTap: _showYearPicker,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: width * 0.05,
                                        vertical: height * 0.015,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey[200]!),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            _selectedYear,
                                            style: TextStyle(
                                              fontSize: min(width * 0.045, 18),
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Icon(
                                            Icons.keyboard_arrow_down,
                                            size: min(width * 0.05, 20),
                                            color: Colors.black54,
                                          ),
                                          Spacer(),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Table layout with Years, Months, Days
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        // Years column
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          bottom: 0,
                                          width: width * 0.2,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                right: BorderSide(
                                                    color: Colors.grey[200]!,
                                                    width: 0.5),
                                              ),
                                            ),
                                            child: ListView.builder(
                                              physics: BouncingScrollPhysics(),
                                              itemCount: _years.length,
                                              itemBuilder: (context, index) {
                                                final year = _years[index];
                                                final isSelected =
                                                    year == _selectedYear;
                                                return _buildDateItem(
                                                  year,
                                                  isSelected: isSelected,
                                                  isYear: true,
                                                );
                                              },
                                            ),
                                          ),
                                        ),

                                        // Months column
                                        Positioned(
                                          left: width * 0.2,
                                          top: 0,
                                          bottom: 0,
                                          width: width * 0.2,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                right: BorderSide(
                                                    color: Colors.grey[200]!,
                                                    width: 0.5),
                                              ),
                                            ),
                                            child: ListView.builder(
                                              physics: BouncingScrollPhysics(),
                                              itemCount: _months.length,
                                              itemBuilder: (context, index) {
                                                final month = _months[index];
                                                final isSelected =
                                                    month == _selectedMonth;
                                                return _buildDateItem(
                                                  month,
                                                  isSelected: isSelected,
                                                  isMonth: true,
                                                );
                                              },
                                            ),
                                          ),
                                        ),

                                        // Days column
                                        Positioned(
                                          left: width * 0.4,
                                          top: 0,
                                          bottom: 0,
                                          width: width * 0.2,
                                          child: Container(
                                            child: ListView.builder(
                                              physics: BouncingScrollPhysics(),
                                              itemCount: _days.length,
                                              itemBuilder: (context, index) {
                                                final day = _days[index];
                                                final isSelected =
                                                    day == _selectedDay;
                                                return _buildDateItem(
                                                  day,
                                                  isSelected: isSelected,
                                                  isDay: true,
                                                );
                                              },
                                            ),
                                          ),
                                        ),

                                        // Navigation buttons
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          bottom: 0,
                                          width: width * 0.1,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.chevron_left,
                                                color: Colors.grey,
                                                size: min(width * 0.05, 20),
                                              ),
                                              SizedBox(height: height * 0.04),
                                              Icon(
                                                Icons.chevron_right,
                                                color: Colors.grey,
                                                size: min(width * 0.05, 20),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Expanding area between date picker and button
                          Expanded(child: SizedBox()),
                        ],
                      ),
                    ),
                  ),

                  // Next button at the bottom
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.06,
                      right: width * 0.06,
                      bottom: height * 0.03,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: height * 0.06,
                      child: ElevatedButton(
                        onPressed: _continueToNextScreen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightTeal,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          _translations['next']!,
                          style: TextStyle(
                            fontSize: min(width * 0.04, 16),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Show year picker
  void _showYearPicker() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return Container(
          height: 300,
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  _translations['year'] ?? 'Year',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _years.length,
                  itemBuilder: (context, index) {
                    final year = _years[index];
                    final isSelected = year == _selectedYear;

                    return ListTile(
                      title: Center(
                        child: Text(
                          year,
                          style: TextStyle(
                            color:
                                isSelected ? AppColors.lightTeal : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedYear = year;

                          // Update the date options display index
                          for (int i = 0; i < _dateOptions.length; i++) {
                            if (_dateOptions[i][0] == _selectedYear) {
                              _dateDisplayStartIndex = i > 2 ? i - 2 : 0;
                              break;
                            }
                          }
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to build a scrollable column
  Widget _buildScrollableColumn({
    required List<String> values,
    required String selectedValue,
    required Function(String) onSelected,
  }) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      itemCount: values.length,
      itemBuilder: (context, index) {
        final bool isSelected = values[index] == selectedValue;
        return GestureDetector(
          onTap: () => onSelected(values[index]),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.lightTeal.withOpacity(0.3)
                  : Colors.transparent,
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Center(
              child: Text(
                values[index],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.black : Colors.grey[500],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Initialize date options with a range of years, months, and days
  void _initializeDateOptions() {
    _dateOptions = [];
    for (int i = 0; i < _years.length; i++) {
      for (int j = 0; j < _months.length; j += 3) {
        _dateOptions
            .add([_years[i], _months[j], (j + 1).toString().padLeft(2, '0')]);
      }
    }

    // Find the index of the selected date
    for (int i = 0; i < _dateOptions.length; i++) {
      if (_dateOptions[i][0] == _selectedYear &&
          _dateOptions[i][1] == _selectedMonth &&
          _dateOptions[i][2] == _selectedDay) {
        _dateDisplayStartIndex = i > 2 ? i - 2 : 0;
        break;
      }
    }
  }

  Widget _buildDateItem(String value,
      {bool isYear = false,
      bool isMonth = false,
      bool isSelected = false,
      bool isDay = false}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isYear) {
            _selectedYear = value;
          } else if (isMonth) {
            _selectedMonth = value;
          } else if (isDay) {
            _selectedDay = value;
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.lightTeal.withOpacity(0.3)
              : Colors.transparent,
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.black : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }
}
