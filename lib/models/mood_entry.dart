import 'dart:convert';

class MoodEntry {
  final DateTime date;
  final int moodLevel;
  final String? note;
  final List<String> emotions;

  MoodEntry({
    required this.date,
    required this.moodLevel,
    this.note,
    this.emotions = const [],
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'moodLevel': moodLevel,
        'note': note,
        'emotions': emotions,
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) => MoodEntry(
        date: DateTime.parse(json['date']),
        moodLevel: json['moodLevel'],
        note: json['note'],
        emotions: List<String>.from(json['emotions'] ?? []),
      );

  static String encodeList(List<MoodEntry> entries) => json.encode(
        entries.map((e) => e.toJson()).toList(),
      );

  static List<MoodEntry> decodeList(String entriesString) {
    final List<dynamic> decoded = json.decode(entriesString);
    return decoded.map((e) => MoodEntry.fromJson(e)).toList();
  }
}