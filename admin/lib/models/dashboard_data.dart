class DashboardData {
  final int vaccinesCount;
  final int brandsCount;
  final int dosesCount;
  final int doctorsCount;
  final int usersCount;
  final bool isLoading;
  final String? errorMessage;

  const DashboardData({
    required this.vaccinesCount,
    required this.brandsCount,
    required this.dosesCount,
    required this.doctorsCount,
    required this.usersCount,
    this.isLoading = false,
    this.errorMessage,
  });

  // Factory constructor for loading state
  factory DashboardData.loading() {
    return const DashboardData(
      vaccinesCount: 0,
      brandsCount: 0,
      dosesCount: 0,
      doctorsCount: 0,
      usersCount: 0,
      isLoading: true,
    );
  }

  // Factory constructor for error state
  factory DashboardData.error(String errorMessage) {
    return DashboardData(
      vaccinesCount: 0,
      brandsCount: 0,
      dosesCount: 0,
      doctorsCount: 0,
      usersCount: 0,
      isLoading: false,
      errorMessage: errorMessage,
    );
  }

  // Copy with method
  DashboardData copyWith({
    int? vaccinesCount,
    int? brandsCount,
    int? dosesCount,
    int? doctorsCount,
    int? usersCount,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DashboardData(
      vaccinesCount: vaccinesCount ?? this.vaccinesCount,
      brandsCount: brandsCount ?? this.brandsCount,
      dosesCount: dosesCount ?? this.dosesCount,
      doctorsCount: doctorsCount ?? this.doctorsCount,
      usersCount: usersCount ?? this.usersCount,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Check if data is valid
  bool get hasData => !isLoading && errorMessage == null;

  // Check if there's an error
  bool get hasError => errorMessage != null;

  @override
  String toString() {
    return 'DashboardData(vaccines: $vaccinesCount, brands: $brandsCount, doses: $dosesCount, doctors: $doctorsCount, users: $usersCount, isLoading: $isLoading, error: $errorMessage)';
  }
}
