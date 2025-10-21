import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/nutritioniste_model.dart';
import 'package:sahtech/core/services/translation_service.dart';
import 'package:sahtech/presentation/nutritionist/Attest_nutri_screnn.dart';
import 'package:sahtech/core/CustomWidgets/language_selector.dart';
import 'package:sahtech/core/l10n/generated/app_localizations.dart';



class ProveAttestationScreen extends StatefulWidget {
  final NutritionisteModel nutritionistData;
  final int currentStep;
  final int totalSteps;

  const ProveAttestationScreen({
    Key? key,
    required this.nutritionistData,
    this.currentStep = 2,
    this.totalSteps = 5,
  }) : super(key: key);

  @override
  State<ProveAttestationScreen> createState() => _ProveAttestationScreenState();
}

class _ProveAttestationScreenState extends State<ProveAttestationScreen> {
  String? _selectedProof;
  bool _isDropdownExpanded = false;
  late TranslationService _translationService;
  bool _isLoading = false;

  final List<String> _proofOptions = [
    'diploma',
    'work_attestation',
    'training_attestation',
  ];

  @override
  void initState() {
    super.initState();
    _translationService = Provider.of<TranslationService>(context, listen: false);
    
    // Only initialize if null or empty - this ensures compatibility regardless of how the model was constructed
    if (widget.nutritionistData.proveAttestationType == null || widget.nutritionistData.proveAttestationType.isEmpty) {
      widget.nutritionistData.proveAttestationType = [];
    }
  }

  void _handleLanguageChanged(String languageCode) {
    widget.nutritionistData.preferredLanguage = languageCode;
    setState(() {});
  }

  void _onSelectProof(String value) {
    setState(() {
      _selectedProof = value;
      _isDropdownExpanded = false;
    });
  }

  void _onNext() {
    if (_selectedProof != null) {
      // Make sure proveAttestationType is initialized
      if (widget.nutritionistData.proveAttestationType == null) {
        widget.nutritionistData.proveAttestationType = [];
      }
      
      // Clear existing values and add the new selection
      widget.nutritionistData.proveAttestationType.clear();
      widget.nutritionistData.proveAttestationType.add(_selectedProof!);
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Nutritioniste3(
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
    // Safe check for localizations
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      // Return a loading indicator when localizations are not ready
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final proofLabels = [
      localizations.diploma,
      localizations.workAttestation,
      localizations.trainingAttestation,
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: width * 0.12,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.lightTeal,
            size: width * 0.05,
          ),
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
          LanguageSelectorButton(
            width: width,
            onLanguageChanged: _handleLanguageChanged,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.lightTeal))
          : SafeArea(
              child: Column(
                children: [
                  // Progress bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: Container(
                      width: double.infinity,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: width * (widget.currentStep / widget.totalSteps),
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: AppColors.lightTeal,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(2),
                                bottomRight: Radius.circular(2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 32.h),
                            Text(
                              localizations.selectProofTitle,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              localizations.selectProofSubtitle,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey[600],
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 36.h),
                            // Dropdown
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isDropdownExpanded = !_isDropdownExpanded;
                                });
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF9E8),
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: AppColors.lightTeal.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _selectedProof == null
                                          ? localizations.chooseProofHint
                                          : proofLabels[_proofOptions.indexOf(_selectedProof!)],
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Icon(
                                      _isDropdownExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Colors.black54,
                                      size: 20.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_isDropdownExpanded)
                              Container(
                                width: double.infinity,
                                constraints: BoxConstraints(
                                  maxHeight: 180.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(15.r),
                                    bottomRight: Radius.circular(15.r),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _proofOptions.length,
                                  itemBuilder: (context, index) {
                                    final value = _proofOptions[index];
                                    return CheckboxListTile(
                                      title: Text(
                                        proofLabels[index],
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      value: value == _selectedProof,
                                      activeColor: AppColors.lightTeal,
                                      onChanged: (_) => _onSelectProof(value),
                                      dense: true,
                                      controlAffinity: ListTileControlAffinity.leading,
                                    );
                                  },
                                ),
                              ),
                            SizedBox(height: 200.h),
                            Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(bottom: 32.h, top: 32.h),
                              child: ElevatedButton(
                                onPressed: _selectedProof == null ? null : _onNext,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.lightTeal,
                                  foregroundColor: Colors.black87,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.r),
                                  ),
                                ),
                                child: Text(
                                  localizations.next,
                                  style: TextStyle(
                                    fontSize: 16.sp,
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
                ],
              ),
            ),
    );
  }
}