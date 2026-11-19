import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakelock/features/motivational_quotes/data/datasources/motivational_quote_remote_data_source.dart';

void main() {
  test('loads and selects a quote from the quotes API response', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://dummyjson.com'))
      ..httpClientAdapter = _JsonResponseAdapter({
        'quotes': [
          {'id': 1, 'quote': 'Keep going.', 'author': 'A'},
          {'id': 2, 'quote': 'You can do it.', 'author': 'B'},
        ],
        'total': 2,
        'skip': 0,
        'limit': 30,
      });
    final dataSource = MotivationalQuoteRemoteDataSource(
      dio,
      random: Random(1),
    );

    final quote = await dataSource.getRandomQuote();

    expect(quote.id, anyOf(1, 2));
    expect(quote.quote, isNotEmpty);
    expect(quote.author, isNotEmpty);
  });

  test('reports invalid quote payloads', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://dummyjson.com'))
      ..httpClientAdapter = _JsonResponseAdapter({'quotes': []});
    final dataSource = MotivationalQuoteRemoteDataSource(dio);

    expect(dataSource.getRandomQuote(), throwsFormatException);
  });
}

class _JsonResponseAdapter implements HttpClientAdapter {
  final Map<String, Object?> payload;

  _JsonResponseAdapter(this.payload);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(payload),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
