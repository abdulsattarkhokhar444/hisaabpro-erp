import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'user_management.dart';

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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HisaabPro ERP',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.teal900,
                          )),
                      Text('Admin Panel v1.0',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: AppTheme.teal600,
                          )),
                    ],
                  ),
                  // Initials only - No photo per SDD
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.teal600,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('AD',
                         style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              // Glassmorphism Cards Grid - A01 to A06
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildGlassCard(context, 'Users', Icons.people_outline, 'A01', () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => UserManagementScreen()));
                    }),
                    _buildGlassCard(context, 'Products', Icons.inventory_2_outlined, 'A03', () {}),
                    _buildGlassCard(context, 'Customers', Icons.store_outlined, 'A07', () {}),
                    _buildGlassCard(context, 'Inventory', Icons.warehouse_outlined, 'A09', () {}),
                    _buildGlassCard(context, 'Orders', Icons.receipt_long_outlined, '', () {}),
                    _buildGlassCard(context, 'Reports', Icons.analytics_outlined, '', () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, String title, IconData icon, String featureId, VoidCallback onTap) {
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
                Icon(icon, size: 40, color: AppTheme.teal600),
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