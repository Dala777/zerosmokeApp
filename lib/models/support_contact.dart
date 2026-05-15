class SupportContact {
  final String id;
  final String userId;
  final String name;
  final String relationship;
  final String phone;
  final String? email;
  final bool isEmergency;
  final DateTime? createdAt;

  SupportContact({
    required this.id,
    required this.userId,
    required this.name,
    required this.relationship,
    required this.phone,
    this.email,
    this.isEmergency = false,
    this.createdAt,
  });

  factory SupportContact.fromJson(Map<String, dynamic> json) {
    return SupportContact(
      id: json['_id'] ?? '',
      userId: json['userId'] is Map
          ? (json['userId'] as Map)['_id']?.toString() ?? ''
          : json['userId']?.toString() ?? '',
      name: json['name'] ?? '',
      relationship: json['relationship'] ?? 'otro',
      phone: json['phone'] ?? json['phoneNumber'] ?? '',
      email: json['email'],
      isEmergency: json['isEmergency'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relationship': relationship,
      'phone': phone,
      'email': email,
      'isEmergency': isEmergency,
    };
  }
}
