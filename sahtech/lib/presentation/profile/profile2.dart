import 'package:flutter/material.dart';
import 'package:sahtech/core/theme/colors.dart';
import 'package:sahtech/core/utils/models/user_model.dart';

class Profile2 extends StatefulWidget {
  final UserModel userData;

  const Profile2({Key? key, required this.userData}) : super(key: key);

  @override
  State<Profile2> createState() => _Profile2State();
}

class _Profile2State extends State<Profile2> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Update user data
      widget.userData.name = _nameController.text;
      widget.userData.email = _emailController.text;

      // Here you would typically navigate to the next screen with the updated userData
      // For now we'll just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil ${widget.userData.userType} créé avec succès!'),
          backgroundColor: Colors.green,
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profil ${widget.userData.userType == 'user' ? 'utilisateur' : 'nutritioniste'}',
          style: TextStyle(
            color: Colors.black87,
            fontSize: width * 0.045,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.03),

              // Header with info about the selected account type
              Container(
                padding: EdgeInsets.all(width * 0.04),
                decoration: BoxDecoration(
                  color: AppColors.lightTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.userData.userType == 'user'
                          ? Icons.person
                          : Icons.medical_services_outlined,
                      color: AppColors.lightTeal,
                      size: width * 0.06,
                    ),
                    SizedBox(width: width * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userData.userType == 'user'
                                ? 'Compte utilisateur'
                                : 'Compte nutritioniste',
                            style: TextStyle(
                              fontSize: width * 0.04,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.userData.userType == 'user'
                                ? 'Configurez votre profil utilisateur'
                                : 'Configurez votre profil professionnel',
                            style: TextStyle(
                              fontSize: width * 0.035,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: height * 0.04),

              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations personnelles',
                          style: TextStyle(
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        SizedBox(height: height * 0.02),

                        // Name field
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nom complet',
                            hintText: 'Entrez votre nom complet',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: AppColors.lightTeal),
                            ),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre nom';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: height * 0.02),

                        // Email field
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Entrez votre adresse email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: AppColors.lightTeal),
                            ),
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre email';
                            } else if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Veuillez entrer un email valide';
                            }
                            return null;
                          },
                        ),

                        // Add additional fields specific to user type
                        if (widget.userData.userType == 'nutritionist') ...[
                          SizedBox(height: height * 0.02),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Spécialité',
                              hintText:
                                  'Ex: Diététicien, Nutritionniste clinique',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: AppColors.lightTeal),
                              ),
                              prefixIcon: Icon(Icons.medical_services_outlined),
                            ),
                          ),
                          SizedBox(height: height * 0.02),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Numéro de licence professionnelle',
                              hintText: 'Entrez votre numéro de licence',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    BorderSide(color: AppColors.lightTeal),
                              ),
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Submit button
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: height * 0.03),
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightTeal,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: height * 0.018),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Continuer',
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
    );
  }
}
