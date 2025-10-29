class PlanDateOption {
  final String label;
  final int? daysFromBirth;
  final String value;

  PlanDateOption({
    required this.label,
    this.daysFromBirth,
    required this.value,
  });

  // Calculate actual date from reference date (usually birth date or today)
  DateTime? calculateDate(DateTime? referenceDate) {
    if (referenceDate == null) return null;
    if (value == 'at_birth' || daysFromBirth == 0) {
      return referenceDate;
    }
    if (daysFromBirth != null) {
      return referenceDate.add(Duration(days: daysFromBirth!));
    }
    return null;
  }

  // Format as date string (YYYY-MM-DD)
  String? formatDateString(DateTime? referenceDate) {
    final date = calculateDate(referenceDate);
    if (date == null) return null;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class PlanDateOptions {
  static List<PlanDateOption> getOptions() {
    return [
      PlanDateOption(label: 'At Birth', daysFromBirth: 0, value: 'at_birth'),
      PlanDateOption(label: '1 Week', daysFromBirth: 7, value: '1_week'),
      PlanDateOption(label: '2 Weeks', daysFromBirth: 14, value: '2_weeks'),
      PlanDateOption(label: '3 Weeks', daysFromBirth: 21, value: '3_weeks'),
      PlanDateOption(label: '4 Weeks', daysFromBirth: 28, value: '4_weeks'),
      PlanDateOption(label: '6 Weeks', daysFromBirth: 42, value: '6_weeks'),
      PlanDateOption(label: '2 Months', daysFromBirth: 60, value: '2_months'),
      PlanDateOption(label: '3 Months', daysFromBirth: 90, value: '3_months'),
      PlanDateOption(label: '4 Months', daysFromBirth: 120, value: '4_months'),
      PlanDateOption(label: '6 Months', daysFromBirth: 180, value: '6_months'),
      PlanDateOption(label: '9 Months', daysFromBirth: 270, value: '9_months'),
      PlanDateOption(label: '1 Year', daysFromBirth: 365, value: '1_year'),
      PlanDateOption(label: '15 Months', daysFromBirth: 456, value: '15_months'),
      PlanDateOption(label: '18 Months', daysFromBirth: 548, value: '18_months'),
      PlanDateOption(label: '2 Years', daysFromBirth: 730, value: '2_years'),
      PlanDateOption(label: '3 Years', daysFromBirth: 1095, value: '3_years'),
      PlanDateOption(label: '4 Years', daysFromBirth: 1460, value: '4_years'),
      PlanDateOption(label: '5 Years', daysFromBirth: 1825, value: '5_years'),
      PlanDateOption(label: '6 Years', daysFromBirth: 2190, value: '6_years'),
      PlanDateOption(label: '7 Years', daysFromBirth: 2555, value: '7_years'),
      PlanDateOption(label: '8 Years', daysFromBirth: 2920, value: '8_years'),
      PlanDateOption(label: '9 Years', daysFromBirth: 3285, value: '9_years'),
      PlanDateOption(label: '10 Years', daysFromBirth: 3650, value: '10_years'),
      PlanDateOption(label: '12 Years', daysFromBirth: 4380, value: '12_years'),
      PlanDateOption(label: '15 Years', daysFromBirth: 5475, value: '15_years'),
      PlanDateOption(label: '18 Years', daysFromBirth: 6570, value: '18_years'),
    ];
  }

  // Find option by date value (YYYY-MM-DD)
  static PlanDateOption? findOptionByDate(String? dateString, DateTime? referenceDate) {
    if (dateString == null || referenceDate == null) return null;
    
    try {
      final date = DateTime.parse(dateString);
      final daysDiff = date.difference(referenceDate).inDays;
      
      return getOptions().firstWhere(
        (option) => option.daysFromBirth == daysDiff,
        orElse: () => getOptions().first, // Default to "At Birth"
      );
    } catch (e) {
      return null;
    }
  }
}
