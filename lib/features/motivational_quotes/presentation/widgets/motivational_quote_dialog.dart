import 'package:flutter/material.dart';

import '../../../../injection_container.dart';
import '../../domain/entities/motivational_quote_entity.dart';
import '../../domain/repositories/motivational_quote_repository.dart';

Future<bool> showMotivationalQuoteDialog(
  BuildContext context, {
  required String title,
  bool canCancel = false,
}) async {
  final shouldContinue = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _MotivationalQuoteDialog(
      title: title,
      canCancel: canCancel,
      quoteFuture: getIt<MotivationalQuoteRepository>().getRandomQuote(),
    ),
  );

  return shouldContinue ?? false;
}

class _MotivationalQuoteDialog extends StatelessWidget {
  final String title;
  final bool canCancel;
  final Future<MotivationalQuoteEntity> quoteFuture;

  const _MotivationalQuoteDialog({
    required this.title,
    required this.canCancel,
    required this.quoteFuture,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(title),
      content: FutureBuilder<MotivationalQuoteEntity>(
        future: quoteFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 72,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return const Text(
              'A motivational quote could not be loaded. You can still continue.',
            );
          }

          final quote = snapshot.data!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '“${quote.quote}”',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '— ${quote.author}',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        if (canCancel)
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(canCancel ? 'Let’s go' : 'Continue'),
        ),
      ],
    );
  }
}
