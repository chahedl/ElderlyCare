import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  final String token;

  const ProfileScreen({required this.token, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF199A8E);

    return ChangeNotifierProvider(
      create: (context) => ProfileViewModel(token)..fetchUserData(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          foregroundColor: Colors.white,
          title: const Text(
            'Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // TODO: Implement logout
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logout feature coming soon!')),
                );
              },
              tooltip: 'Log Out',
            ),
          ],
        ),
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      children: [
                        // Profile Header
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          viewModel.user?.username ?? 'User',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Loading/Error States
                        if (viewModel.isLoading)
                          Center(
                            child:
                                CircularProgressIndicator(color: primaryColor),
                          )
                        else if (viewModel.errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  viewModel.errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: viewModel.fetchUserData,
                                  child: Text(
                                    'Retry',
                                    style: TextStyle(color: primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (viewModel.user == null)
                          Center(
                            child: Text(
                              'No user data available',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        else
                          // Profile Form
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                  color: primaryColor.withOpacity(0.2)),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(24.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    primaryColor.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Form(
                                child: Column(
                                  children: [
                                    TextFormField(
                                      initialValue:
                                          viewModel.user?.username ?? '',
                                      decoration: InputDecoration(
                                        labelText: 'Username',
                                        labelStyle:
                                            TextStyle(color: primaryColor),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: primaryColor
                                                  .withOpacity(0.3)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide:
                                              BorderSide(color: primaryColor),
                                        ),
                                      ),
                                      style: const TextStyle(fontSize: 16),
                                      onChanged: (value) =>
                                          viewModel.updateUsername(value),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      initialValue: viewModel.user?.email ?? '',
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        labelStyle:
                                            TextStyle(color: primaryColor),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: primaryColor
                                                  .withOpacity(0.3)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide:
                                              BorderSide(color: primaryColor),
                                        ),
                                      ),
                                      style: const TextStyle(fontSize: 16),
                                      onChanged: (value) =>
                                          viewModel.updateEmail(value),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      initialValue:
                                          viewModel.user?.weight?.toString() ??
                                              '',
                                      decoration: InputDecoration(
                                        labelText: 'Weight (kg)',
                                        labelStyle:
                                            TextStyle(color: primaryColor),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: primaryColor
                                                  .withOpacity(0.3)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide:
                                              BorderSide(color: primaryColor),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 16),
                                      onChanged: (value) =>
                                          viewModel.updateWeight(value),
                                    ),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      initialValue:
                                          viewModel.user?.height?.toString() ??
                                              '',
                                      decoration: InputDecoration(
                                        labelText: 'Height (cm)',
                                        labelStyle:
                                            TextStyle(color: primaryColor),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: primaryColor
                                                  .withOpacity(0.3)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide:
                                              BorderSide(color: primaryColor),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 16),
                                      onChanged: (value) =>
                                          viewModel.updateHeight(value),
                                    ),
                                    const SizedBox(height: 24),
                                    // Placeholder for chronicIllnesses (read-only)
                                    if (viewModel.user?.chronicIllnesses !=
                                            null &&
                                        viewModel
                                            .user!.chronicIllnesses!.isNotEmpty)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Chronic Illnesses',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: primaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8.0,
                                            runSpacing: 8.0,
                                            children: viewModel
                                                .user!.chronicIllnesses!
                                                .map(
                                                  (illness) => Chip(
                                                    label: Text(
                                                      illness as String,
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                    backgroundColor:
                                                        primaryColor
                                                            .withOpacity(0.1),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      side: BorderSide(
                                                          color: primaryColor
                                                              .withOpacity(
                                                                  0.3)),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                          const SizedBox(height: 24),
                                        ],
                                      ),
                                    // Save Changes Button
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: viewModel.updateUserProfile,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          elevation: 2,
                                        ),
                                        child: const Text(
                                          'Save Changes',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
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
              },
            );
          },
        ),
      ),
    );
  }
}
