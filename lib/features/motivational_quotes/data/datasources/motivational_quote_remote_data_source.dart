import 'dart:math';

import 'package:dio/dio.dart';

import '../models/motivational_quote_model.dart';

class MotivationalQuoteRemoteDataSource {
  final Dio _dio;
  final Random _random;

  MotivationalQuoteRemoteDataSource(this._dio, {Random? random})
    : _random = random ?? Random();

  Future<MotivationalQuoteModel> getRandomQuote() async {
    final response = await _dio.get<Map<String, dynamic>>('/quotes');
    final rawQuotes = response.data?['quotes'];

    if (rawQuotes is! List || rawQuotes.isEmpty) {
      throw const FormatException('The quotes service returned no quotes.');
    }

    final quotes = rawQuotes.map((rawQuote) {
      if (rawQuote is! Map) {
        throw const FormatException(
          'The quotes service returned invalid data.',
        );
      }

      return MotivationalQuoteModel.fromMap(
        Map<String, dynamic>.from(rawQuote),
      );
    }).toList();

    return quotes[_random.nextInt(quotes.length)];
  }
}
