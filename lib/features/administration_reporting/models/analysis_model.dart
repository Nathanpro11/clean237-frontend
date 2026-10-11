class AnalysisIndicators {
  const AnalysisIndicators({
    required this.totalPoints,
    required this.average,
    required this.minimum,
    required this.maximum,
    required this.sum,
    required this.unit,
  });

  final int totalPoints;
  final double average;
  final int minimum;
  final int maximum;
  final int sum;
  final String unit;

  Map<String, dynamic> toMap() => {
    'totalPoints': totalPoints,
    'average': average,
    'minimum': minimum,
    'maximum': maximum,
    'sum': sum,
    'unit': unit,
  };

  factory AnalysisIndicators.fromMap(Map<String, dynamic> map) =>
      AnalysisIndicators(
        totalPoints: (map['totalPoints'] as num).toInt(),
        average: (map['average'] as num).toDouble(),
        minimum: (map['minimum'] as num).toInt(),
        maximum: (map['maximum'] as num).toInt(),
        sum: (map['sum'] as num).toInt(),
        unit: map['unit'] as String,
      );
}

class Analysis {
  const Analysis({
    required this.id,
    required this.type,
    required this.periodStart,
    required this.periodEnd,
    required this.zoneIds,
    required this.result,
    required this.indicators,
    required this.createdAt,
  });

  final String id;
  final String type;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<String> zoneIds;
  final String result;
  final AnalysisIndicators indicators;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'periodStart': periodStart.toIso8601String(),
    'periodEnd': periodEnd.toIso8601String(),
    'zoneIds': zoneIds,
    'result': result,
    'indicators': indicators.toMap(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory Analysis.fromMap(Map<String, dynamic> map) => Analysis(
    id: map['id'] as String,
    type: map['type'] as String,
    periodStart: DateTime.parse(map['periodStart'] as String),
    periodEnd: DateTime.parse(map['periodEnd'] as String),
    zoneIds: (map['zoneIds'] as List<dynamic>)
        .map((zoneId) => zoneId as String)
        .toList(growable: false),
    result: map['result'] as String,
    indicators: AnalysisIndicators.fromMap(
      Map<String, dynamic>.from(map['indicators'] as Map),
    ),
    createdAt: DateTime.parse(map['createdAt'] as String),
  );
}
