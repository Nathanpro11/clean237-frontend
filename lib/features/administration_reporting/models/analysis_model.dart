class AnalysisTypeIndicator {
  const AnalysisTypeIndicator({
    required this.count,
    required this.average,
    required this.minimum,
    required this.maximum,
    required this.sum,
    this.unit,
  });

  final int count;
  final double average;
  final double minimum;
  final double maximum;
  final double sum;
  final String? unit;
}

class AnalysisIndicators {
  const AnalysisIndicators({
    required this.totalPoints,
    required this.byType,
  });

  final int totalPoints;
  final Map<String, AnalysisTypeIndicator> byType;
}

class Analysis {
  const Analysis({
    required this.id,
    required this.type,
    required this.periodStart,
    required this.periodEnd,
    required this.result,
    required this.indicators,
    required this.createdAt,
    this.zoneId,
    this.zoneName,
  });

  final String id;
  final String type;
  final String? zoneId;
  final String? zoneName;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String result;
  final AnalysisIndicators indicators;
  final DateTime createdAt;
}
