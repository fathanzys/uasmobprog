// lib/models/user_model.dart

import 'dart:convert';

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? studentNumber;
  final int? classYear;
  final String? major;
  final String? role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.studentNumber,
    this.classYear,
    this.major,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      email: json['email'] ?? '',
      studentNumber: json['student_number'],
      classYear: json['class_year'] != null ? int.tryParse(json['class_year'].toString()) : null,
      major: json['major'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'student_number': studentNumber,
      'class_year': classYear,
      'major': major,
      'role': role,
    };
  }
}
