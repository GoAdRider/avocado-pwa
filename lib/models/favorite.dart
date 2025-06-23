import 'package:hive/hive.dart';

part 'favorite.g.dart';

@HiveType(typeId: 2)
class Favorite extends HiveObject {
  @HiveField(0)
  String wordId;

  @HiveField(1)
  String vocabularyFile;

  @HiveField(2)
  DateTime addedDate;

  Favorite({
    required this.wordId,
    required this.vocabularyFile,
    DateTime? addedDate,
  }) : addedDate = addedDate ?? DateTime.now();

  Favorite copyWith({
    String? wordId,
    String? vocabularyFile,
    DateTime? addedDate,
  }) {
    return Favorite(
      wordId: wordId ?? this.wordId,
      vocabularyFile: vocabularyFile ?? this.vocabularyFile,
      addedDate: addedDate ?? this.addedDate,
    );
  }

  @override
  String toString() {
    return 'Favorite(wordId: $wordId, vocabularyFile: $vocabularyFile, addedDate: $addedDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Favorite && other.wordId == wordId;
  }

  @override
  int get hashCode => wordId.hashCode;
}
