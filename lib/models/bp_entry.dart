class BPEntry {
  final int id;
  final int systolic;
  final int diastolic;
  final String category;
  final DateTime takenAt;

  BPEntry({
    required this.id,
    required this.systolic,
    required this.diastolic,
    required this.category,
    required this.takenAt,
  });

  factory BPEntry.fromJson(Map<String, dynamic> j) {
    final raw = j['taken_at'] as String?;
    // Convertir de UTC (o ISO) a hora local para la UI
    final local = raw != null ? DateTime.parse(raw).toLocal() : DateTime.now();
    return BPEntry(
      id: j['id'] as int,
      systolic: j['systolic'] as int,
      diastolic: j['diastolic'] as int,
      category: (j['category'] ?? '').toString(),
      takenAt: local,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'systolic': systolic,
        'diastolic': diastolic,
        'category': category,
        // Guardar siempre en UTC
        'taken_at': takenAt.toUtc().toIso8601String(),
      };
}