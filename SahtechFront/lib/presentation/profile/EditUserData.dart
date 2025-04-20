import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sahtech/core/services/api_service.dart';
import 'package:sahtech/core/widgets/custom_button.dart';

class EditUserData extends StatefulWidget {
  final UserModel user;

  const EditUserData({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<EditUserData> createState() => _EditUserDataState();
}

class _EditUserDataState extends State<EditUserData> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Text controllers for form fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  bool _isLoading = false;
  bool _hasChanges = false;
  bool _isDropdownOpen = false;

  // Maladie options and selections
  final Map<String, bool> _maladieOptions = {
    'Diabète': false,
    'Hypertension': false,
    'Asthme': false,
    'Cholestérol': false,
    'Anémie': false,
    'Arthrite': false,
    'Maladie cardiaque': false,
    'Dépression': false,
    'Anxiété': false,
    'Allergie alimentaire': false,
    'Maladie coeliaque': false,
    'Intolérance au lactose': false,
  };

  List<String> _selectedMaladies = [];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
        text: widget.user.name != null && widget.user.name!.contains(" ")
            ? widget.user.name!.split(" ")[0]
            : widget.user.name);
    _lastNameController = TextEditingController(
        text: widget.user.name != null && widget.user.name!.contains(" ")
            ? widget.user.name!.split(" ").length > 1
                ? widget.user.name!.split(" ")[1]
                : ""
            : "");
    _emailController = TextEditingController(text: widget.user.email);
    _heightController = TextEditingController(
        text: widget.user.height != null ? '${widget.user.height}' : '');
    _weightController = TextEditingController(
        text: widget.user.weight != null ? '${widget.user.weight}' : '');

    // Initialize selected maladies from user data
    _selectedMaladies = widget.user.chronicConditions ?? [];

    // Initialize the checkboxes based on user data
    for (var maladie in _selectedMaladies) {
      if (_maladieOptions.containsKey(maladie)) {
        _maladieOptions[maladie] = true;
      }
    }

    // Add listeners to detect changes
    _firstNameController.addListener(_onFieldChanged);
    _lastNameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _heightController.addListener(_onFieldChanged);
    _weightController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    // Dispose controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    setState(() {
      _hasChanges = true;
    });
  }

  void _toggleDropdown() {
    setState(() {
      _isDropdownOpen = !_isDropdownOpen;
    });
  }

  void _toggleMaladie(String maladie) {
    setState(() {
      _maladieOptions[maladie] = !_maladieOptions[maladie]!;
      _selectedMaladies = _maladieOptions.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();
      _hasChanges = true;
    });
  }

  String _getDropdownLabel() {
    if (_selectedMaladies.isEmpty) {
      return "Sélectionner vos maladies";
    } else {
      return "${_selectedMaladies.length} maladies sélectionnées";
    }
  }

  Widget _buildMaladieOption(String maladie, bool isSelected) {
    return InkWell(
      onTap: () => _toggleMaladie(maladie),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.lightTeal : Colors.transparent,
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  color: isSelected ? AppColors.lightTeal : Colors.grey,
                  width: 1.5.w,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16.sp,
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                maladie,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to update user data
  Future<void> _updateUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create a copy of the user model
      final updatedUser = UserModel(
        userType: widget.user.userType,
        name: "${_firstNameController.text} ${_lastNameController.text}",
        email: _emailController.text,
        phoneNumber: widget.user.phoneNumber,
        profileImageUrl: widget.user.profileImageUrl,
        userId: widget.user.userId,
        tempPassword: widget.user.tempPassword,
        preferredLanguage: widget.user.preferredLanguage,
        doesExercise: widget.user.doesExercise,
        activityLevel: widget.user.activityLevel,
        physicalActivities: widget.user.physicalActivities,
        dailyActivities: widget.user.dailyActivities,
        healthGoals: widget.user.healthGoals,
        hasAllergies: widget.user.hasAllergies,
        allergies: widget.user.allergies,
        allergyYear: widget.user.allergyYear,
        allergyMonth: widget.user.allergyMonth,
        allergyDay: widget.user.allergyDay,
        weightUnit: widget.user.weightUnit,
        heightUnit: widget.user.heightUnit,
      );

      // Update height and weight if provided
      if (_heightController.text.isNotEmpty) {
        updatedUser.height = double.tryParse(_heightController.text);
      }

      if (_weightController.text.isNotEmpty) {
        updatedUser.weight = double.tryParse(_weightController.text);
      }

      // Update chronic conditions
      if (_selectedMaladies.isNotEmpty) {
        updatedUser.hasChronicDisease = true;
        updatedUser.chronicConditions = _selectedMaladies;
      } else {
        updatedUser.hasChronicDisease = false;
        updatedUser.chronicConditions = [];
      }

      // Create JSON data for the API request
      final userData = updatedUser.toMap();

      // Store user token and details
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');
      final String? userId = prefs.getString('user_id');

      if (token == null || userId == null) {
        throw Exception("Authentication data missing");
      }

      // Make API call
      final response = await http.put(
        Uri.parse('http://192.168.1.69:8080/API/Sahtech/Utilisateurs/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(userData),
      );

      // Log response for debugging
      print('Update user response: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Check if update was successful
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to profile screen
        Navigator.pop(context, updatedUser);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour du profil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5F0E2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Modifier les Données Personale',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.lightTeal),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.lightTeal))
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile image
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 40.r,
                              backgroundImage: widget.user.profileImageUrl !=
                                      null
                                  ? NetworkImage(widget.user.profileImageUrl!)
                                  : null,
                              child: widget.user.profileImageUrl == null
                                  ? Icon(Icons.person, size: 40.r)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: AppColors.lightTeal,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30.h),

                      // User Name Label
                      Text(
                        'Nom Utilisateur',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // First name input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            hintText: 'Prénom',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                            border: InputBorder.none,
                            suffixIcon:
                                Icon(Icons.person_outline, color: Colors.grey),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre prénom';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Last name input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            hintText: 'Nom',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                            border: InputBorder.none,
                            suffixIcon:
                                Icon(Icons.person_outline, color: Colors.grey),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre nom';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Email Label
                      Text(
                        'Adresse Email',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Email input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                            border: InputBorder.none,
                            suffixIcon:
                                Icon(Icons.email_outlined, color: Colors.grey),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre email';
                            }
                            // Simple email validation
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Veuillez entrer un email valide';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Maladie Label
                      Text(
                        'Maladie',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Maladie dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Maladie chronique",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // Custom dropdown
                          GestureDetector(
                            onTap: _toggleDropdown,
                            child: Container(
                              width: double.infinity,
                              height: 55.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF9E8),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: Colors.transparent,
                                  width: 1.w,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _getDropdownLabel(),
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: _selectedMaladies.isNotEmpty
                                            ? Colors.black87
                                            : Colors.black54,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                  Icon(
                                    _isDropdownOpen
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.black54,
                                    size: 24.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Dropdown options
                          if (_isDropdownOpen)
                            Container(
                              margin: EdgeInsets.only(top: 4.h),
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.35,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8.r,
                                    offset: Offset(0, 3.h),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: _maladieOptions.entries
                                        .map((entry) => _buildMaladieOption(
                                            entry.key, entry.value))
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Hauteur Label
                      Text(
                        'Hauteur',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Hauteur input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextFormField(
                          controller: _heightController,
                          decoration: InputDecoration(
                            hintText: '175cm',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                            border: InputBorder.none,
                            suffixIcon: Icon(Icons.height, color: Colors.grey),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Poids Label
                      Text(
                        'Poids',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Poids input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextFormField(
                          controller: _weightController,
                          decoration: InputDecoration(
                            hintText: '80kg',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                            border: InputBorder.none,
                            suffixIcon: Icon(Icons.monitor_weight_outlined,
                                color: Colors.grey),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(height: 30.h),

                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Sauvegarder Modification',
                          isLoading: _isLoading,
                          onPressed: _hasChanges ? _updateUserData : null,
                          backgroundColor:
                              _hasChanges ? AppColors.lightTeal : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
