import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import 'user_management.dart';
import 'product_management.dart';
import 'sales_management.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mintTeal,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - No avatar per SDD Critical Rule
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HisaabPro ERP',
                          style: AppTheme.lightTheme.textTheme.displayLarge),
                      Text('Admin Panel v1.0',
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(color: AppTheme.teal600)),
                    ],
                  ),
                  // Initials only - No photo per SDD
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.teal600,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text('Admin',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                  const SizedBox(width: 8,),
                  IconButton(
                    icon: const Icon(Icons.logout, color: AppTheme.teal600),
                    onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  }, 
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Glassmorphism Cards Grid - A01 to A06
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  children: [
                    _buildGlassCard(
                      context: context,
                      title: 'Users',
                      icon: Icons.people_alt_outlined,
                      featureId: 'A01',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => UserManagementScreen()));
                      },
                    ),
                    _buildGlassCard(
                      context: context,
                      title: 'Products',
                      icon: Icons.inventory_2_outlined,
                      featureId: 'A03',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductManagement())),
                    ),
                    _buildGlassCard(
                      context: context,
                      title: 'Customers',
                      icon: Icons.store_outlined,
                      featureId: 'A07',
                      onTap: () {},
                    ),
                    _buildGlassCard(
                      context: context,
                      title: 'Inventory',
                      icon: Icons.warehouse_outlined,
                      featureId: 'A09',
                      onTap: () {},
                    ),
                    _buildGlassCard(
                      context: context,
                      title: 'Sales',
                      icon: Icons.point_of_sale_outlined,
                      featureId: 'A05',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SalesManagement())
                      ),
                    ),
                    _buildGlassCard(
                      context: context,
                      title: 'Reports',
                      icon: Icons.analytics_outlined,
                      featureId: '',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String featureId,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: AppTheme.glassCard, // SDD 2.3
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16), // SDD blur(16px)
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: AppTheme.teal600),
                const SizedBox(height: 12),
                Text(title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.teal900,
                    )),
                if (featureId.isNotEmpty)
                  Text(featureId,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: AppTheme.teal600,
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
