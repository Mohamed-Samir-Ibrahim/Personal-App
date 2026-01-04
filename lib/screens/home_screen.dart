import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:personal_app/models/user_model.dart';
import 'package:personal_app/screens/auth_screen.dart';
import 'package:personal_app/screens/profile_screen.dart';
import 'package:personal_app/services/auth_service.dart';
import 'package:personal_app/services/theme_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Home'),
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
                icon: Icon(Icons.logout),
                onPressed: () async {
                  final shouldLogout = await _showLogoutDialog(context);
                  if (shouldLogout) {
                    await _performLogout(authService, context);
                  }
                },
              ),
            ],
          ),
          body: StreamBuilder<UserModel?>(
            stream: authService.currentUserStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return _buildNoUserFound(themeProvider, context);
              }

              final user = snapshot.data!;
              return _buildUserProfile(user, themeProvider, authService);
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (authService.currentUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileScreen(user: authService.currentUser!),
                  ),
                );
              }
            },
            tooltip: 'Edit Profile',
            backgroundColor: themeProvider.primaryColor,
            child: Icon(Icons.edit),
          ),
        );
      },
    );
  }

  Widget _buildNoUserFound(ThemeProvider themeProvider, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 80,
            color: themeProvider.secondaryTextColor,
          ),
          SizedBox(height: 20),
          Text(
            'No user data was found',
            style: TextStyle(fontSize: 18, color: themeProvider.textColor),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: Text(
              'Go to Login',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile(
    UserModel user,
    ThemeProvider themeProvider,
    AuthService authService,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),

          _buildProfileCard(user, themeProvider),

          SizedBox(height: 30),

          Text(
            'Account Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          SizedBox(height: 15),

          _buildInfoCard(
            themeProvider: themeProvider,
            icon: Icons.calendar_today,
            title: 'Account Created',
            value: user.createdAt != null
                ? '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                : 'Unknown',
          ),

          SizedBox(height: 15),

          _buildInfoCard(
            themeProvider: themeProvider,
            icon: Icons.verified_user,
            title: 'Account Status',
            value: 'Active',
            statusColor: Colors.green,
          ),

          SizedBox(height: 15),

          _buildInfoCard(
            themeProvider: themeProvider,
            icon: Icons.contact_phone,
            title: 'Contact Info',
            value: user.phone ?? 'Not provided',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(UserModel user, ThemeProvider themeProvider) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: themeProvider.cardColor,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: themeProvider.primaryColor, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: _buildProfileImage(user, themeProvider),
              ),
            ),

            SizedBox(height: 20),

            Text(
              user.name ?? 'Unknown User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 10),

            Text(
              user.email ?? 'No email',
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 10),

            if (user.phone != null && user.phone!.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone,
                    size: 16,
                    color: themeProvider.secondaryTextColor,
                  ),
                  SizedBox(width: 8),
                  Text(
                    user.phone!,
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.textColor,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(UserModel user, ThemeProvider themeProvider) {
    if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) {
      return Image.network(
        user.profileImageUrl!,
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
          return _buildDefaultAvatar(themeProvider);
        },
      );
    } else {
      return _buildDefaultAvatar(themeProvider);
    }
  }

  Widget _buildDefaultAvatar(ThemeProvider themeProvider) {
    return Container(
      color: themeProvider.primaryColor.withValues(alpha: 0.1),
      child: Center(
        child: Icon(Icons.person, size: 50, color: themeProvider.primaryColor),
      ),
    );
  }

  Widget _buildInfoCard({
    required ThemeProvider themeProvider,
    required IconData icon,
    required String title,
    required String value,
    Color? statusColor,
  }) {
    return Card(
      elevation: 3,
      color: themeProvider.cardColor,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: themeProvider.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: themeProvider.primaryColor, size: 22),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.secondaryTextColor,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: statusColor ?? themeProvider.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<void> _performLogout(
    AuthService authService,
    BuildContext context,
  ) async {
    try {
      await authService.signOut();

      Fluttertoast.showToast(
        msg: 'Logged out successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error logging out: $e',
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
