class AppNotification {
  final String id;
  final String message;
  final String dateEnvoi;
  final bool lu;
  final String destinataire;

  AppNotification({
    required this.id,
    required this.message,
    required this.dateEnvoi,
    required this.lu,
    required this.destinataire,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'] ?? '',
      message: json['message'] ?? '',
      dateEnvoi: json['dateEnvoi'] ?? '',
      lu: json['lu'] ?? false,
      destinataire: json['destinataire'] ?? 'citoyen',
    );
  }
}
