import '../../domain/entities/motivational_quote_entity.dart';

class MotivationalQuoteModel extends MotivationalQuoteEntity {
  const MotivationalQuoteModel({
    required super.id,
    required super.quote,
    required super.author,
  });

  factory MotivationalQuoteModel.fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    final quote = map['quote'];
    final author = map['author'];

    if (id is! int || quote is! String || author is! String) {
      throw const FormatException('The quotes service returned invalid data.');
    }

    return MotivationalQuoteModel(id: id, quote: quote, author: author);
  }
}
