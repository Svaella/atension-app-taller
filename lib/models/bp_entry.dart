class BPEntry {
  final int id;
  final int systolic;
  final int diastolic;
  final DateTime takenAt;
  final String category; // NORMAL | MEDIO | ALTO

  BPEntry({
    required this.id,
    required this.systolic,
    required this.diastolic,
    required this.takenAt,
    required this.category,
  });

  factory BPEntry.fromJson(Map<String, dynamic> j) => BPEntry(
        id: j['id'] as int,
        systolic: j['systolic'] as int,
        diastolic: j['diastolic'] as int,
        takenAt: DateTime.parse(j['taken_at'] as String),
        category: (j['category'] as String).toUpperCase(),
      );
}