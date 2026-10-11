import 'package:equatable/equatable.dart';

import '../models/report_model.dart';

abstract class GenerateReportEvent extends Equatable {
  const GenerateReportEvent();
}

class TitleChanged extends GenerateReportEvent {
  const TitleChanged(this.title);
  final String title;
  @override
  List<Object?> get props => [title];
}

class PeriodChanged extends GenerateReportEvent {
  const PeriodChanged(this.period);
  final String period;
  @override
  List<Object?> get props => [period];
}

class CustomDatesChanged extends GenerateReportEvent {
  const CustomDatesChanged({
    required this.isCustomPeriod,
    this.startDate,
    this.endDate,
  });
  final bool isCustomPeriod;
  final DateTime? startDate;
  final DateTime? endDate;
  @override
  List<Object?> get props => [isCustomPeriod, startDate, endDate];
}

class ZoneToggled extends GenerateReportEvent {
  const ZoneToggled(this.zoneId);
  final String zoneId;
  @override
  List<Object?> get props => [zoneId];
}

class AllZonesSelected extends GenerateReportEvent {
  const AllZonesSelected();
  @override
  List<Object?> get props => [];
}

class ZonesCleared extends GenerateReportEvent {
  const ZonesCleared();
  @override
  List<Object?> get props => [];
}

class FormatChanged extends GenerateReportEvent {
  const FormatChanged(this.format);
  final ReportFormat format;
  @override
  List<Object?> get props => [format];
}

class NotesChanged extends GenerateReportEvent {
  const NotesChanged(this.notes);
  final String notes;
  @override
  List<Object?> get props => [notes];
}

class SubmitPressed extends GenerateReportEvent {
  const SubmitPressed({this.simulateFailure = false});
  final bool simulateFailure;
  @override
  List<Object?> get props => [simulateFailure];
}
