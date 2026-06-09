import 'package:flutter/material.dart';
import '../orchestrators/translate_orchestrator.dart';

class TranslationOutput extends StatelessWidget {
  final String translatedText;
  final bool isLoading;
  final String? errorMessage;
  final TranslationSource? source;
  final VoidCallback? onCopy;
  final VoidCallback? onClear;

  const TranslationOutput({
    super.key,
    this.translatedText = '',
    this.isLoading = false,
    this.errorMessage,
    this.source,
    this.onCopy,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorMessage!,
                style: TextStyle(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      );
    }

    if (translatedText.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            'Translation will appear here',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (source != null) ...[
            Row(
              children: [
                Icon(
                  source == TranslationSource.cache
                      ? Icons.memory
                      : source == TranslationSource.offline
                      ? Icons.wifi_off
                      : Icons.cloud_done,
                  size: 14,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  _sourceLabel(source!),
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          SelectableText(
            translatedText,
            style: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.onSecondaryContainer,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onCopy != null)
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  tooltip: 'Copy',
                  onPressed: onCopy,
                ),
              if (onClear != null)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  tooltip: 'Clear',
                  onPressed: onClear,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _sourceLabel(TranslationSource source) {
    switch (source) {
      case TranslationSource.cache:
        return 'Cached';
      case TranslationSource.offline:
        return 'Offline';
      case TranslationSource.cloud:
        return 'Online';
    }
  }
}
