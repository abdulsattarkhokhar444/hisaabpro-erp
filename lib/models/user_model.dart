import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'admin' or 'salesman'
  final String employeeId;
  final String? territory;
  final bool isActive;
  final Timestamp createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.employeeId,
    this.territory,
    required this.isActive,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid']?? '',
      name: map['name']?? '',
      email: map['email']?? '',
      role: map['role']?? 'salesman',
      employeeId: map['employeeId']?? '',
      territory: map['territory'],
      isActive: map['isActive']?? true,
      createdAt: map['createdAt']?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'employeeId': employeeId,
      'territory': territory?? '', // null ki jagah ''
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }

  // SDD Critical Rule: No photos, use initials only
  String get initials {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return 'U';
  
  final parts = trimmed.split(' ').where((s) => s.isNotEmpty).toList();
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return parts[0][0].toUpperCase();
  }
}