class AppNotification {
  final String id;
  final String message;
  final String dateEnvoi;
  final bool lu;
  final String destinataire;
  final String? signalementId;

  AppNotification({
    required this.id,
    required this.message,
    required this.dateEnvoi,
    required this.lu,
    required this.destinataire,
    this.signalementId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final s = json['signalementId'];
    return AppNotification(
      id: json['_id'] ?? '',
      message: json['message'] ?? '',
      dateEnvoi: json['createdAt'] ?? '',
      lu: json['lu'] ?? false,
      destinataire: json['destinataire'] ?? 'citoyen',
      signalementId: s is Map ? s['_id']?.toString() : s?.toString(),
    );
  }

  AppNotification copyWith({bool? lu}) => AppNotification(
        id: id,
        message: message,
        dateEnvoi: dateEnvoi,
        lu: lu ?? this.lu,
        destinataire: destinataire,
        signalementId: signalementId,
      );
}
