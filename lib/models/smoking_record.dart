class SmokingRecord {
  final DateTime timestamp;
  final String? emotion;
  final List<String> symptoms;
  final String? note;

  SmokingRecord({
    required this.timestamp,
    this.emotion,
    this.symptoms = const [],
    this.note,
  });
}
