import '../constances/report_constants.dart';

String? validateReportTitle(String title) {
  final trimmed = title.trim();
  if (trimmed.isEmpty) {
    return 'Le titre du rapport est obligatoire.';
  }
  if (trimmed.length < ReportConstants.titleMinLength) {
    return 'Le titre doit comporter au moins ${ReportConstants.titleMinLength} caractères.';
  }
  if (trimmed.length > ReportConstants.titleMaxLength) {
    return 'Le titre ne doit pas dépasser ${ReportConstants.titleMaxLength} caractères.';
  }
  return null;
}

String? validateReportZones(Set<String> zoneIds) {
  if (zoneIds.isEmpty) {
    return 'Veuillez sélectionner au moins une zone d’analyse.';
  }
  return null;
}

String? validateAnalysisZones(Set<String> zoneIds) {
  if (zoneIds.isEmpty) {
    return 'Sélectionnez au moins une zone pour lancer l’analyse.';
  }
  return null;
}

String? validateAnalysisPeriod({
  required DateTime? startDate,
  required DateTime? endDate,
  DateTime? today,
}) {
  if (startDate == null || endDate == null) {
    return 'La période de l’analyse est obligatoire.';
  }
  if (startDate.isAfter(endDate)) {
    return 'La date de début doit précéder ou être égale à la date de fin.';
  }
  final now = today ?? DateTime.now();
  final endOfDay = DateTime(endDate.year, endDate.month, endDate.day);
  final currentDay = DateTime(now.year, now.month, now.day);
  if (endOfDay.isAfter(currentDay)) {
    return 'La date de fin ne peut pas être située dans le futur.';
  }
  return null;
}

String? validateReportDates({
  required bool isCustomPeriod,
  required DateTime? startDate,
  required DateTime? endDate,
  DateTime? today,
}) {
  if (!isCustomPeriod) return null;
  if (startDate == null || endDate == null) {
    return 'Veuillez renseigner la date de début et la date de fin.';
  }
  if (startDate.isAfter(endDate)) {
    return 'La date de début doit être antérieure à la date de fin.';
  }
  final now = today ?? DateTime.now();
  final endOfDay = DateTime(endDate.year, endDate.month, endDate.day);
  final currentDay = DateTime(now.year, now.month, now.day);
  if (endOfDay.isAfter(currentDay)) {
    return 'La date de fin ne peut pas être située dans le futur.';
  }
  return null;
}

String? validateReportNotes(String notes) {
  if (notes.length > ReportConstants.notesMaxLength) {
    return 'Les observations ne doivent pas dépasser ${ReportConstants.notesMaxLength} caractères (${notes.length}/${ReportConstants.notesMaxLength})';
  }
  return null;
}
