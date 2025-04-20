import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

  // Text controllers for form fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _maladieController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with user data
    final nameParts = widget.user.name?.split(' ') ?? ['', ''];
    _firstNameController = TextEditingController(
        text: nameParts.isNotEmpty ? nameParts.first : '');
    _lastNameController =
        TextEditingController(text: nameParts.length > 1 ? nameParts.last : '');
    _emailController = TextEditingController(text: widget.user.email ?? '');

    // Initialize disease field
    String disease = '';
    if (widget.user.hasChronicDisease == true &&
        widget.user.chronicConditions.isNotEmpty) {
      disease = widget.user.chronicConditions.join(', ');
    }
    _maladieController = TextEditingController(text: disease);

    // Initialize height and weight with units
    _heightController = TextEditingController(
        text: widget.user.height != null ? '${widget.user.height}' : '');
    _weightController = TextEditingController(
        text: widget.user.weight != null ? '${widget.user.weight}' : '');
  }

  @override
  void dispose() {
    // Dispose controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _maladieController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // Function to update user data
  Future<void> _updateUserData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // API endpoint
      final apiUrl =
          'http://192.168.1.69:8080/API/Sahtech/Utilisateurs/${widget.user.userId}';

      // Update user model with form data
      final updatedUser = widget.user;
      updatedUser.name =
          '${_firstNameController.text} ${_lastNameController.text}';
      updatedUser.email = _emailController.text;

      // Update chronic conditions
      if (_maladieController.text.isNotEmpty) {
        updatedUser.hasChronicDisease = true;
        updatedUser.chronicConditions = [_maladieController.text];
      } else {
        updatedUser.hasChronicDisease = false;
        updatedUser.chronicConditions = [];
      }

      // Update height and weight
      if (_heightController.text.isNotEmpty) {
        updatedUser.height = double.tryParse(_heightController.text);
        updatedUser.heightUnit = 'cm';
      }

      if (_weightController.text.isNotEmpty) {
        updatedUser.weight = double.tryParse(_weightController.text);
        updatedUser.weightUnit = 'kg';
      }

      // Prepare data for API
      final userData = updatedUser.toMap();

      // Get token from local storage
      final storageService = await SharedPreferences.getInstance();
      final token = storageService.getString('authToken');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Make API call
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        // Success - pop back to profile with updated data
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profil mis à jour avec succès'),
              backgroundColor: AppColors.lightTeal,
            ),
          );
          Navigator.pop(context, updatedUser);
        }
      } else {
        throw Exception('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          icon: Icon(Icons.arrow_back_ios, color: Colors.green),
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

                      // Maladie input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextFormField(
                          controller: _maladieController,
                          decoration: InputDecoration(
                            hintText: 'Diabete',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                            border: InputBorder.none,
                            suffixIcon: Icon(Icons.medical_information_outlined,
                                color: Colors.grey),
                          ),
                        ),
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
                        child: ElevatedButton(
                          onPressed: _updateUserData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightTeal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          child: Text(
                            'Sauvegarder Modification',
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
    );
  }
}
