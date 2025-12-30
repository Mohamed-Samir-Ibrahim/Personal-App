import 'package:flutter/material.dart';
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
  bool _isLoading = false;
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
                  await authService.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AuthScreen()),
                  );
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('No user data was found'),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AuthScreen(),
                            ),
                          );
                        },
                        child: Text('Login'),
                      ),
                    ],
                  ),
                );
              }

              final user = snapshot.data!;

              return SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40.0),
                    Center(
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: themeProvider.cardColor,
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              Text(
                                user.name ?? 'Unknown name',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: themeProvider.textColor,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                user.email ?? 'Unknown email',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: themeProvider.secondaryTextColor,
                                ),
                              ),
                              SizedBox(height: 10),
                              if (user.phone != null && user.phone!.isNotEmpty)
                                Text(
                                  user.phone!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: themeProvider.textColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

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
                      title: 'Creation date',
                      value: user.createdAt != null
                          ? '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                          : 'Unknown',
                    ),

                    SizedBox(height: 15),

                    _buildInfoCard(
                      themeProvider: themeProvider,
                      icon: Icons.verified_user,
                      title: 'Account Status',
                      value: 'Activated',
                    ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProfileScreen(user: authService.currentUser as UserModel),
                ),
              );
            },
            tooltip: 'Edit Profile',
            child: Icon(Icons.edit),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required ThemeProvider themeProvider,
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 3,
      color: themeProvider.cardColor,
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          children: [
            Icon(icon, color: themeProvider.primaryColor),
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
                      color: themeProvider.textColor,
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
}
