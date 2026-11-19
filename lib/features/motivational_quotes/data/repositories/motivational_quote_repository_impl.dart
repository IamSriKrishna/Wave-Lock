import '../../domain/entities/motivational_quote_entity.dart';
import '../../domain/repositories/motivational_quote_repository.dart';
import '../datasources/motivational_quote_remote_data_source.dart';

class MotivationalQuoteRepositoryImpl implements MotivationalQuoteRepository {
  final MotivationalQuoteRemoteDataSource _remoteDataSource;

  MotivationalQuoteRepositoryImpl(this._remoteDataSource);

  @override
  Future<MotivationalQuoteEntity> getRandomQuote() {
    return _remoteDataSource.getRandomQuote();
  }
}
