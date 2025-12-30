import 'package:flutter/material.dart';
import 'package:personal_app/models/user_model.dart';
import 'package:personal_app/services/auth_service.dart';
import 'package:personal_app/services/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Profile', style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              ),
              IconButton(
                icon: Icon(
                  _isEditing ? Icons.save : Icons.edit,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (_isEditing) {
                    _saveChanges(authService);
                  } else {
                    setState(() {
                      _isEditing = true;
                    });
                  }
                },
              ),
            ],
          ),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      themeProvider.primaryColor,
                    ),
                  ),
                )
              : Container(
                  color: themeProvider.backgroundColor,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Form(
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                style: TextStyle(
                                  color: themeProvider.textColor,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  labelStyle: TextStyle(
                                    color: themeProvider.secondaryTextColor,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: themeProvider.primaryColor,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabled: _isEditing,
                                  filled: true,
                                  fillColor: themeProvider.cardColor,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: themeProvider.primaryColor,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: themeProvider.secondaryTextColor
                                          .withValues(alpha: 0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: themeProvider.secondaryTextColor
                                          .withValues(alpha: 0.1),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),

                              SizedBox(height: 15),

                              TextFormField(
                                controller: _emailController,
                                style: TextStyle(
                                  color: themeProvider.textColor,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                    color: themeProvider.secondaryTextColor,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: themeProvider.primaryColor,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabled: false,
                                  filled: true,
                                  fillColor: themeProvider.cardColor.withValues(
                                    alpha: 0.7,
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: themeProvider.secondaryTextColor
                                          .withValues(alpha: 0.1),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),

                              SizedBox(height: 15),

                              TextFormField(
                                controller: _phoneController,
                                style: TextStyle(
                                  color: themeProvider.textColor,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Phone Number',
                                  labelStyle: TextStyle(
                                    color: themeProvider.secondaryTextColor,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.phone,
                                    color: themeProvider.primaryColor,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabled: _isEditing,
                                  filled: true,
                                  fillColor: themeProvider.cardColor,
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: themeProvider.primaryColor,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: themeProvider.secondaryTextColor
                                          .withValues(alpha: 0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                keyboardType: TextInputType.phone,
                              ),

                              SizedBox(height: 15),

                              if (_isEditing)
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _saveChanges(authService);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).appBarTheme.backgroundColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'Update Profile',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: themeProvider.textColor,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        SizedBox(height: 30),

                        Card(
                          elevation: 3,
                          color: themeProvider.cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Account Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.textColor,
                                  ),
                                ),
                                SizedBox(height: 10),
                                ListTile(
                                  leading: Icon(
                                    Icons.date_range,
                                    color: themeProvider.primaryColor,
                                  ),
                                  title: Text(
                                    'Creation Date',
                                    style: TextStyle(
                                      color: themeProvider.secondaryTextColor,
                                    ),
                                  ),
                                  subtitle: Text(
                                    widget.user.createdAt != null
                                        ? '${widget.user.createdAt!.day}/${widget.user.createdAt!.month}/${widget.user.createdAt!.year}'
                                        : 'Unknown',
                                    style: TextStyle(
                                      color: themeProvider.textColor,
                                    ),
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.security,
                                    color: themeProvider.primaryColor,
                                  ),
                                  title: Text(
                                    'User ID',
                                    style: TextStyle(
                                      color: themeProvider.secondaryTextColor,
                                    ),
                                  ),
                                  subtitle: Text(
                                    widget.user.uid ?? 'Unknown',
                                    style: TextStyle(
                                      color: themeProvider.textColor,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  void _saveChanges(AuthService authService) async {
    if (_nameController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please enter name',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserModel updatedUser = UserModel(
        uid: widget.user.uid,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        createdAt: widget.user.createdAt,
      );

      await authService.updateUserProfile(updatedUser);

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      Fluttertoast.showToast(
        msg: 'The changes were saved successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      Fluttertoast.showToast(
        msg: 'Error saving changes: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
      );
    }
  }
}
