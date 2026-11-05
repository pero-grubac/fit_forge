/// One workout of a plan moved off its regular day: the one due on
/// [fromDate] is done on [toDate] instead. Both are whole days.
class PlanRescheduleModel {
  const PlanRescheduleModel({
    required this.planId,
    required this.fromDate,
    required this.toDate,
  });

  final String planId;
  final DateTime fromDate;
  final DateTime toDate;

  static const tableName = 'plan_reschedules';

  factory PlanRescheduleModel.fromMap(Map<String, dynamic> map) {
    return PlanRescheduleModel(
      planId: map['plan_id'] as String,
      fromDate: DateTime.parse(map['from_date'] as String),
      toDate: DateTime.parse(map['to_date'] as String),
    );
  }
}

/// 'yyyy-MM-dd', the format dates are stored in.
String dayKey(DateTime day) => day.toIso8601String().substring(0, 10);
