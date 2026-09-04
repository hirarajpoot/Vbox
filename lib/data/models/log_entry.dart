class LogEntry {
  LogEntry({required this.message, DateTime? at}) : at = at ?? DateTime.now();

  final DateTime at;
  final String message;

  Map<String, dynamic> toMap() => {
        'at': at.toIso8601String(),
        'message': message,
      };

  factory LogEntry.fromMap(Map map) => LogEntry(
        at: DateTime.tryParse(map['at'] as String? ?? '') ?? DateTime.now(),
        message: map['message'] as String? ?? '',
      );
}
