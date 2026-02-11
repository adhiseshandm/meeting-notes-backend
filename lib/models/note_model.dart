class Note {
  final String? id;
  final String title;
  final String content;
  final DateTime dateTime;
  final String? audioUrl;
  final List<String> attachments;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.dateTime,
    this.audioUrl,
    this.attachments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title': title,
      'content': content,
      'createdAt': dateTime.toIso8601String(),
      'audioUrl': audioUrl,
      'attachments': attachments,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['_id'],
      title: map['title'] ?? 'Untitled Note',
      content: map['content'] ?? '',
      dateTime: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      audioUrl: map['audioUrl'],
      attachments: List<String>.from(map['attachments'] ?? []),
    );
  }
}
