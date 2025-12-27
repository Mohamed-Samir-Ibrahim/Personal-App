import 'package:flutter/material.dart';
import 'package:personal_app/models/user_model.dart';
import 'package:personal_app/services/auth_service.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
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
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Form(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                            enabled: _isEditing,
                          ),
                        ),

                        SizedBox(height: 15),

                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                            enabled: false,
                          ),
                        ),

                        SizedBox(height: 15),

                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                            enabled: _isEditing,
                          ),
                          keyboardType: TextInputType.phone,
                        ),

                        SizedBox(height: 15),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  Card(
                    elevation: 3,
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
                            ),
                          ),
                          SizedBox(height: 10),
                          ListTile(
                            leading: Icon(Icons.date_range),
                            title: Text('Creation Date'),
                            subtitle: Text(
                              widget.user.createdAt != null
                                  ? '${widget.user.createdAt!.day}/${widget.user.createdAt!.month}/${widget.user.createdAt!.year}'
                                  : 'Unknown',
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.security),
                            title: Text('User ID'),
                            subtitle: Text(
                              widget.user.uid ?? 'Unknown',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
