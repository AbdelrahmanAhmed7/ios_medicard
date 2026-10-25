class OtpAttemptGuard {
  final int maximumSubmissionsPerCode;
  final Map<String, int> _submissionCounts = <String, int>{};

  OtpAttemptGuard({this.maximumSubmissionsPerCode = 2})
    : assert(maximumSubmissionsPerCode > 0);

  /// Registers a submission and returns false when this exact code has already
  /// reached the permitted number of submissions.
  bool tryRegister(String otp) {
    final count = _submissionCounts[otp] ?? 0;
    if (count >= maximumSubmissionsPerCode) return false;
    _submissionCounts[otp] = count + 1;
    return true;
  }

  void reset() => _submissionCounts.clear();
}
