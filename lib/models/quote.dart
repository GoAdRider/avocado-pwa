import 'package:hive/hive.dart';

part 'quote.g.dart';

@HiveType(typeId: 1)
class Quote extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String quote;

  @HiveField(2)
  String author;

  @HiveField(3)
  DateTime importedDate;

  Quote({
    required this.id,
    required this.quote,
    required this.author,
    DateTime? importedDate,
  }) : importedDate = importedDate ?? DateTime.now();

  Quote copyWith({
    String? id,
    String? quote,
    String? author,
    DateTime? importedDate,
  }) {
    return Quote(
      id: id ?? this.id,
      quote: quote ?? this.quote,
      author: author ?? this.author,
      importedDate: importedDate ?? this.importedDate,
    );
  }

  @override
  String toString() {
    return 'Quote(id: $id, quote: $quote, author: $author, importedDate: $importedDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Quote && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
