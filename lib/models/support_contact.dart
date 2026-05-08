class SupportContact {
  final String id;
  final String userId;
  final String name;
  final String relationship; // 'familia', 'amigo', 'profesional', 'otro'
  final String phoneNumber;
  final String? email;
  final String? role; // 'emergencia', 'soporte', 'ambas'
  final bool isEmergencyContact;
  final DateTime? createdAt;

  SupportContact({
    required this.id,
    required this.userId,
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.email,
    this.role,
    this.isEmergencyContact = false,
    this.createdAt,
  });

  factory SupportContact.fromJson(Map<String, dynamic> json) {
    return SupportContact(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      relationship: json['relationship'] ?? 'otro',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'],
      role: json['role'],
      isEmergencyContact: json['isEmergencyContact'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'relationship': relationship,
      'phoneNumber': phoneNumber,
      'email': email,
      'role': role,
      'isEmergencyContact': isEmergencyContact,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
