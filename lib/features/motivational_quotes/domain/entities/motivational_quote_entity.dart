import 'package:equatable/equatable.dart';

class MotivationalQuoteEntity extends Equatable {
  final int id;
  final String quote;
  final String author;

  const MotivationalQuoteEntity({
    required this.id,
    required this.quote,
    required this.author,
  });

  @override
  List<Object?> get props => [id, quote, author];
}
