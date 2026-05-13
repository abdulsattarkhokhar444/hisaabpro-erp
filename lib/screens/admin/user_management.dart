import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

class UserManagementScreen extends StatelessWidget {
  final UserService _userService = UserService();

  UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mintTeal,
      appBar: AppBar(
        title: const Text('User Management - A01', 
          style: TextStyle(fontFamily: 'Poppins', color: AppTheme.teal900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.teal900),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _userService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.teal600));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found', style: TextStyle(fontFamily: 'Poppins')));
          }
          final users = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: AppTheme.glassCard, // SDD Glassmorphism
                child: ListTile(
                  // SDD Critical Rule: No photo, initials only
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.teal600,
                    child: Text(user.initials, 
                      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                  ),
                  title: Text('${user.name} - ${user.employeeId}',
                    style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: AppTheme.teal900)),
                  subtitle: Text(user.email, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  Chip(
                    label: Text(user.role.toUpperCase(),
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, color: Colors.white)),
                    backgroundColor: user.role == 'admin'? AppTheme.teal600 : AppTheme.teal300,
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: AppTheme.teal900),
                    onSelected: (value) async {
                      if (value == 'toggle_active') {
                        await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .update({'isActive': !user.isActive});
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              user.isActive ? 'User deactivated' : 'User activated',
                              style: const TextStyle(fontFamily: 'Poppins'),
                            ),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'toggle_active',
                        child: Row(
                          children: [
                            Icon(
                              user.isActive ? Icons.block : Icons.check_circle,
                              color: user.isActive ? Colors.red : Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              user.isActive ? 'Deactivate' : 'Activate',
                              style: const TextStyle(fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context),
        backgroundColor: AppTheme.teal600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final empIdController = TextEditingController();
    String selectedRole = 'salesman';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.mintTeal,
        title: const Text('Add User - A01', style: TextStyle(fontFamily: 'Poppins', color: AppTheme.teal900)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
              TextField(controller: empIdController, decoration: const InputDecoration(labelText: 'Employee ID')),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                items: ['admin', 'salesman'].map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                onChanged: (val) => selectedRole = val!,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.teal600),
            onPressed: () async {
              try {
                if (nameController.text.trim().isEmpty ||
                    emailController.text.trim().isEmpty ||
                    passwordController.text.trim().isEmpty ||
                    empIdController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All fields are required', style: TextStyle(fontFamily: 'Poppins'))),
                  );
                  return;
                }
                await _userService.createUser(
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                  employeeId: empIdController.text.trim(),
                  role: selectedRole,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e', style: const TextStyle(fontFamily: 'Poppins'))),
                );
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}