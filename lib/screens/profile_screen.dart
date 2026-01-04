import 'dart:io';

import 'package:flutter/material.dart';
import 'package:personal_app/models/user_model.dart';
import 'package:personal_app/services/auth_service.dart';
import 'package:personal_app/services/cloudinary_service.dart';
import 'package:personal_app/services/theme_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  bool _isEditing = false;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  File? _selectedImage;
  String? _uploadedImageUrl;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
    _currentImageUrl = widget.user.profileImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileImageSection(),
              SizedBox(height: 30),
              _buildProfileForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    final theme = Theme.of(context);

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(75),
                child: _getProfileImage(),
              ),
            ),

            if (_isEditing)
              GestureDetector(
                onTap: _showImageOptions,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),

        SizedBox(height: 20),

        if (_selectedImage != null && !_isUploadingImage)
          Column(
            children: [
              ElevatedButton.icon(
                onPressed: _uploadSelectedImage,
                icon: Icon(Icons.cloud_upload, size: 20),
                label: Text('Upload Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => setState(() => _selectedImage = null),
                icon: Icon(Icons.cancel, size: 20),
                label: Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),

        if (_isUploadingImage)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text(
                  'Uploading image...',
                  style: TextStyle(color: theme.primaryColor),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _getProfileImage() {
    if (_selectedImage != null) {
      return Image.file(_selectedImage!, fit: BoxFit.cover);
    }

    final imageUrl = _uploadedImageUrl ?? _currentImageUrl;

    if (imageUrl != null) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderAvatar();
        },
      );
    }

    return _buildPlaceholderAvatar();
  }

  Widget _buildPlaceholderAvatar() {
    final theme = Theme.of(context);
    return Container(
      color: theme.primaryColor.withValues(alpha: 0.1,),
      child: Center(
        child: Icon(
          Icons.person,
          size: 60,
          color: theme.primaryColor,
        ),
      ),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.photo_library, color: Colors.blue),
                  title: Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                ),
                if (_currentImageUrl != null || _uploadedImageUrl != null)
                  ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Remove Profile Picture'),
                    onTap: () {
                      Navigator.pop(context);
                      _removeProfilePicture();
                    },
                  ),
                ListTile(
                  leading: Icon(Icons.cancel, color: Colors.grey),
                  title: Text('Cancel'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final image = await CloudinaryService.pickImage();
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _uploadedImageUrl = null;
        });
      }
    } catch (e) {
      _showSnackBar('Failed to pick image', isError: true);
    }
  }

  Future<void> _uploadSelectedImage() async {
    if (_selectedImage == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final url = await CloudinaryService.uploadProfileImage(
        _selectedImage!,
        widget.user.uid!,
      );

      if (url != null) {
        setState(() {
          _uploadedImageUrl = url;
          _isUploadingImage = false;
        });
        _showSnackBar('Image uploaded successfully');
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      _showSnackBar('Failed to upload image: $e', isError: true);
    }
  }

  Future<void> _removeProfilePicture() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Remove Profile Picture'),
            content: Text(
                'Are you sure you want to remove your profile picture?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Remove',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      if (_currentImageUrl != null) {
        await CloudinaryService.deleteImage(_currentImageUrl!);
      }

      final updatedUser = UserModel(
        uid: widget.user.uid,
        name: widget.user.name,
        email: widget.user.email,
        phone: widget.user.phone,
        profileImageUrl: null,
        createdAt: widget.user.createdAt,
      );

      await authService.updateUserProfile(updatedUser);

      setState(() {
        _currentImageUrl = null;
        _uploadedImageUrl = null;
        _selectedImage = null;
        _isLoading = false;
      });

      _showSnackBar('Profile picture removed');
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error removing picture: $e', isError: true);
    }
  }

  Widget _buildProfileForm() {
    final theme = Theme.of(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),

            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: theme.cardColor,
              ),
              enabled: _isEditing,
            ),
            SizedBox(height: 15),

            TextFormField(
              controller: TextEditingController(text: widget.user.email),
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: theme.cardColor.withValues(alpha: 0.7,),
              ),
              enabled: false,
            ),
            SizedBox(height: 15),

            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: theme.cardColor,
              ),
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _saveProfile() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      String? finalImageUrl;

      if (_uploadedImageUrl != null) {
        finalImageUrl = _uploadedImageUrl;

        if (_currentImageUrl != null && _currentImageUrl != _uploadedImageUrl) {
          await CloudinaryService.deleteImage(_currentImageUrl!);
        }
      } else {
        finalImageUrl = _currentImageUrl;
      }

      final updatedUser = UserModel(
        uid: widget.user.uid,
        name: _nameController.text.trim(),
        email: widget.user.email,
        phone: _phoneController.text.trim(),
        profileImageUrl: finalImageUrl,
        createdAt: widget.user.createdAt,
      );

      await authService.updateUserProfile(updatedUser);

      setState(() {
        _isEditing = false;
        _isLoading = false;
        _currentImageUrl = finalImageUrl;
        _selectedImage = null;
        _uploadedImageUrl = null;
      });

      _showSnackBar('Profile updated successfully', isError: false);

      await Future.delayed(Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context);
      }

    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error updating profile: $e', isError: true);
    }
  }

  bool _validateInputs() {
    if (_nameController.text
        .trim()
        .isEmpty) {
      _showSnackBar('Please enter your name', isError: true);
      return false;
    }

    return true;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}