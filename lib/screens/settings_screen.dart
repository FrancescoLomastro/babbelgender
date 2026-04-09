import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ── Section: Sessione di pratica ──────────────────────────
          _SectionHeader(label: 'Sessione di pratica'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: List.generate(kSessionLengthOptions.length, (i) {
                final option = kSessionLengthOptions[i];
                final isSelected = settings.sessionLength == option.value;
                final isLast = i == kSessionLengthOptions.length - 1;

                return Column(
                  children: [
                    _OptionTile(
                      label: option.label,
                      subtitle: option.subtitle,
                      isSelected: isSelected,
                      onTap: () => settings.setSessionLength(option.value),
                    ),
                    if (!isLast)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                );
              }),
            ),
          ),

          const SizedBox(height: 32),

          // ── Section: Info ─────────────────────────────────────────
          _SectionHeader(label: 'Informazioni'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Versione'),
                  trailing: Text(
                    '1.0.0',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.source_outlined),
                  title: const Text('Sorgente dati'),
                  trailing: Text(
                    'babbel-extractor',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected ? AppTheme.primaryColor : null,
            ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded,
              color: AppTheme.primaryColor)
          : const Icon(Icons.radio_button_unchecked,
              color: Colors.grey),
      onTap: onTap,
    );
  }
}
