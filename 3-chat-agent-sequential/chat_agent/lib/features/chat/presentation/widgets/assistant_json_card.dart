import 'dart:convert';

import 'package:flutter/material.dart';

class AssistantJsonPayload {
  AssistantJsonPayload({
    required this.text,
    required this.links,
    required this.language,
    required this.additionalQuestions,
    required this.model,
    required this.modelParameters,
    required this.extras,
  });

  final String text;
  final List<String> links;
  final String language;
  final List<String> additionalQuestions;
  final String model;
  final Map<String, dynamic> modelParameters;
  final Map<String, dynamic> extras;

  static AssistantJsonPayload? tryParse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || !trimmed.startsWith('{') || !trimmed.endsWith('}')) {
      return null;
    }
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! Map<String, dynamic>) return null;
      final text = decoded['text'];
      final language = decoded['language'];
      final model = decoded['model'];
      final modelParameters = decoded['model_parameters'];
      if (text is! String ||
          language is! String ||
          model is! String ||
          modelParameters is! Map<String, dynamic>) {
        return null;
      }
      final links = _stringList(decoded['links']);
      final additionalQuestions = _stringList(decoded['additional_questions']);
      if (links.isEmpty || additionalQuestions.isEmpty) return null;
      final extras = Map<String, dynamic>.from(decoded)
        ..remove('text')
        ..remove('links')
        ..remove('language')
        ..remove('additional_questions')
        ..remove('model')
        ..remove('model_parameters');
      return AssistantJsonPayload(
        text: text,
        links: links,
        language: language,
        additionalQuestions: additionalQuestions,
        model: model,
        modelParameters: modelParameters,
        extras: extras,
      );
    } catch (_) {
      return null;
    }
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return <String>[];
    return value.whereType<String>().where((item) => item.trim().isNotEmpty).toList();
  }
}

class AssistantJsonCard extends StatelessWidget {
  const AssistantJsonCard({
    super.key,
    required this.payload,
    required this.modelLabel,
  });

  final AssistantJsonPayload payload;
  final String? modelLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurface,
    );
    final linkStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.primary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: (_resolvedModelLabel().isNotEmpty)
                  ? Text(_resolvedModelLabel(), style: labelStyle)
                  : const SizedBox.shrink(),
            ),
            _LanguageBadge(language: payload.language),
          ],
        ),
        Text(payload.text, style: bodyStyle),
        if (payload.additionalQuestions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Questions', style: labelStyle),
          const SizedBox(height: 6),
          ...payload.additionalQuestions.map(
            (question) => Text(
              '• $question',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
        if (payload.links.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('References', style: labelStyle),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: payload.links
                .map((link) => Text(link, style: linkStyle))
                .toList(growable: false),
          ),
        ],
      ],
    );
  }

  String _resolvedModelLabel() {
    final label = modelLabel?.trim();
    if (label != null && label.isNotEmpty) return label;
    return payload.model.trim();
  }
}

class _LanguageBadge extends StatelessWidget {
  const _LanguageBadge({required this.language});

  final String language;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final code = language.trim().toLowerCase();
    final flag = _flagForLanguage(code);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            flag,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            code.isEmpty ? '??' : code.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  String _flagForLanguage(String code) {
    switch (code) {
      case 'en':
        return '🇺🇸';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'it':
        return '🇮🇹';
      case 'pt':
        return '🇵🇹';
      case 'ru':
        return '🇷🇺';
      case 'uk':
        return '🇺🇦';
      case 'zh':
        return '🇨🇳';
      case 'ja':
        return '🇯🇵';
      case 'ko':
        return '🇰🇷';
      case 'ar':
        return '🇸🇦';
      case 'hi':
        return '🇮🇳';
      case 'tr':
        return '🇹🇷';
      case 'pl':
        return '🇵🇱';
      case 'nl':
        return '🇳🇱';
      default:
        return '🌐';
    }
  }
}
