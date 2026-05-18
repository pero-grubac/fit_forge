class QuoteModel {
  static const tableName = 'motivational_quotes';

  final String   id;
  final String   text;
  final bool     isActive;
  final DateTime createdAt;

  const QuoteModel({
    required this.id,
    required this.text,
    required this.isActive,
    required this.createdAt,
  });

  factory QuoteModel.fromMap(Map<String, dynamic> map) {
    return QuoteModel(
      id:        map['id'] as String,
      text:      map['text'] as String,
      isActive:  (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id':         id,
      'text':       text,
      'is_active':  isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  QuoteModel copyWith({bool? isActive}) {
    return QuoteModel(
      id:        id,
      text:      text,
      isActive:  isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}