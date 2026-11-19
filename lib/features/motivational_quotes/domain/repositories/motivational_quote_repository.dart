import '../entities/motivational_quote_entity.dart';

abstract class MotivationalQuoteRepository {
  Future<MotivationalQuoteEntity> getRandomQuote();
}
