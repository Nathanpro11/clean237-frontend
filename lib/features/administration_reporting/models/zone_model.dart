enum ZoneStatus { normal, warning, critical }

extension ZoneStatusExtension on ZoneStatus {
  String get label {
    switch (this) {
      case ZoneStatus.normal:
        return 'Normal';
      case ZoneStatus.warning:
        return 'À surveiller';
      case ZoneStatus.critical:
        return 'Critique';
    }
  }
}

class Zone {
  final String id;
  final String name;
  final int score;
  final ZoneStatus status;
  final int evolutionPoints;
  final String lastUpdate;
  final List<double> evolution30Days;
  final String interpretation;
  final List<String> priorities;

  const Zone({
    required this.id,
    required this.name,
    required this.score,
    required this.status,
    this.evolutionPoints = 0,
    this.lastUpdate = 'il y a 10 min',
    this.evolution30Days = const [35, 38, 40, 44, 42, 48, 52, 54],
    this.interpretation = '',
    this.priorities = const [],
  });

  Zone copyWith({
    String? id,
    String? name,
    int? score,
    ZoneStatus? status,
    int? evolutionPoints,
    String? lastUpdate,
    List<double>? evolution30Days,
    String? interpretation,
    List<String>? priorities,
  }) {
    return Zone(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      status: status ?? this.status,
      evolutionPoints: evolutionPoints ?? this.evolutionPoints,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      evolution30Days: evolution30Days ?? this.evolution30Days,
      interpretation: interpretation ?? this.interpretation,
      priorities: priorities ?? this.priorities,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'score': score,
      'status': status.name,
      'evolutionPoints': evolutionPoints,
      'lastUpdate': lastUpdate,
      'evolution30Days': evolution30Days,
      'interpretation': interpretation,
      'priorities': priorities,
    };
  }

  factory Zone.fromMap(Map<String, dynamic> map) {
    return Zone(
      id: map['id'] as String,
      name: map['name'] as String,
      score: (map['score'] as num).toInt(),
      status: ZoneStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ZoneStatus.normal,
      ),
      evolutionPoints: (map['evolutionPoints'] as num?)?.toInt() ?? 0,
      lastUpdate: map['lastUpdate'] as String? ?? 'il y a 10 min',
      evolution30Days: (map['evolution30Days'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const [35, 38, 40, 44, 42, 48, 52, 54],
      interpretation: map['interpretation'] as String? ?? '',
      priorities: (map['priorities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
