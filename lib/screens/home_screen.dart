import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/noun.dart';
import '../providers/vocabulary_provider.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final String jsonString;

    if (file.bytes != null) {
      jsonString = utf8.decode(file.bytes!);
    } else if (file.path != null) {
      jsonString = await File(file.path!).readAsString();
    } else {
      return;
    }

    if (context.mounted) {
      await context.read<VocabularyProvider>().loadFromJson(jsonString, file.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vocab = context.watch<VocabularyProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BabbelGender'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Impostazioni',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Branding ──────────────────────────────────────────────
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.30),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('BabbelGender', style: theme.textTheme.displaySmall),
                  const SizedBox(height: 8),
                  Text(
                    'Impara i generi dei sostantivi tedeschi',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // ── Vocabulary status card ────────────────────────────────
            _VocabStatusCard(vocab: vocab),

            const SizedBox(height: 16),

            // ── Load button ───────────────────────────────────────────
            vocab.isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: () => _pickFile(context),
                    icon: const Icon(Icons.upload_file_outlined),
                    label: Text(
                      vocab.hasVocabulary ? 'Cambia JSON' : 'Carica JSON',
                    ),
                  ),

            const SizedBox(height: 12),

            // ── Start practice button ─────────────────────────────────
            ElevatedButton.icon(
              onPressed: vocab.hasVocabulary
                  ? () => Navigator.pushNamed(context, '/practice')
                  : null,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Inizia Pratica'),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

// ── Vocabulary status card ────────────────────────────────────────────────────

class _VocabStatusCard extends StatelessWidget {
  final VocabularyProvider vocab;

  const _VocabStatusCard({required this.vocab});

  @override
  Widget build(BuildContext context) {
    if (vocab.errorMessage != null) {
      return _StatusTile(
        icon: Icons.error_outline,
        iconColor: AppTheme.wrongColor,
        title: 'Errore di caricamento',
        subtitle: vocab.errorMessage!,
      );
    }

    if (!vocab.hasVocabulary) {
      return _StatusTile(
        icon: Icons.file_upload_outlined,
        iconColor: Colors.grey,
        title: 'Nessun file caricato',
        subtitle: 'Carica il file JSON esportato da babbel-extractor',
      );
    }

    final masc =
        vocab.nouns.where((n) => n.gender == Gender.masculine).length;
    final fem =
        vocab.nouns.where((n) => n.gender == Gender.feminine).length;
    final neut =
        vocab.nouns.where((n) => n.gender == Gender.neuter).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: AppTheme.correctColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vocab.loadedFileName ?? 'vocabulary.json',
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${vocab.nouns.length} sostantivi trovati',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _GenderBadge(
                    article: 'der',
                    count: masc,
                    color: AppTheme.masculineColor),
                const SizedBox(width: 8),
                _GenderBadge(
                    article: 'die',
                    count: fem,
                    color: AppTheme.feminineColor),
                const SizedBox(width: 8),
                _GenderBadge(
                    article: 'das',
                    count: neut,
                    color: AppTheme.neuterColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _StatusTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _StatusTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderBadge extends StatelessWidget {
  final String article;
  final int count;
  final Color color;

  const _GenderBadge({
    required this.article,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        '$article: $count',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}
