class LogModel {
  final String id;
  final String utilisateurId;
  final String action;
  final String description;
  final String ipAddress;
  final DateTime createdAt;

  LogModel({
    required this.id,
    required this.utilisateurId,
    required this.action,
    required this.description,
    required this.ipAddress,
    required this.createdAt,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: json['_id'] as String? ?? '',
      utilisateurId: json['utilisateurId'] as String? ?? '',
      action: json['action'] as String? ?? 'INCONNUE',
      description: json['description'] as String? ?? '',
      ipAddress: json['ipAddress'] as String? ?? '127.0.0.1',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : DateTime.now(),
    );
  }
}
