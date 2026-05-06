/// Respuesta de `GET /api/v1/users/me`.
class BackendUserModel {
  const BackendUserModel({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.phoneNumber,
    this.organizationId,
  });

  final int id;
  final String email;
  final String role;
  final String? name;
  final String? phoneNumber;
  final int? organizationId;

  factory BackendUserModel.fromJson(Map<String, dynamic> json) {
    final orgId = json['organizationId'];
    return BackendUserModel(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      role: (json['role'] as String?)?.trim() ?? 'none',
      name: json['name'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      organizationId: orgId is num ? orgId.toInt() : null,
    );
  }
}
