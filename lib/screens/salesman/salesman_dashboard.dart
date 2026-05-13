import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../admin/sales_management.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';

class SalesmanDashboard extends StatefulWidget {
  const SalesmanDashboard({super.key});

  @override
  State<SalesmanDashboard> createState() => _SalesmanDashboardState();
}

class _SalesmanDashboardState extends State<SalesmanDashboard> {
  final UserService _userService = UserService();
  UserModel? currentUser;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    UserModel? user = await _userService.getCurrentUserData();
    setState(() {
      currentUser = user;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.mintTeal,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.mintTeal,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'HisaabPro POS',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.teal600),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Salesman Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.glassCard,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.teal600,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        currentUser?.name.substring(0, 1).toUpperCase() ?? 'S',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser?.name ?? 'Salesman',
                          style: AppTheme.lightTheme.textTheme.titleLarge,
                        ),
                        Text(
                          'ID: ${currentUser?.employeeId ?? '000'}',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.teal600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sales POS Card
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SalesManagement()),
                  ),
                  child: Container(
                    width: double.infinity,
                    decoration: AppTheme.glassCard,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.point_of_sale_outlined,
                          size: 80,
                          color: AppTheme.teal600,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start New Sale',
                          style: AppTheme.lightTheme.textTheme.displaySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to open POS',
                          style: AppTheme.lightTheme.textTheme.bodyLarge
                              ?.copyWith(color: AppTheme.teal600),
                        ),
                      ],
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