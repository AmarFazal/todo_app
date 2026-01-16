import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/animated_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Appearance', theme)
              .animate()
              .fadeIn(duration: 300.ms),
          const SizedBox(height: 12),
          AnimatedCard(
            child: Column(
              children: [
                _buildSettingTile(
                  context,
                  'Theme Mode',
                  _getThemeModeText(themeProvider.themeMode),
                  Icons.palette_rounded,
                  () => _showThemeDialog(context, themeProvider),
                ),
                const Divider(),
                _buildSettingTile(
                  context,
                  'Language',
                  _getLanguageText(languageProvider.locale),
                  Icons.language_rounded,
                  () => _showLanguageDialog(context, languageProvider),
                ),
              ],
            ),
          )
              .animate(delay: 100.ms)
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),
          _buildSectionHeader('About', theme)
              .animate(delay: 200.ms)
              .fadeIn(duration: 300.ms),
          const SizedBox(height: 12),
          AnimatedCard(
            child: Column(
              children: [
                _buildSettingTile(
                  context,
                  'Version',
                  '1.0.0',
                  Icons.info_rounded,
                  null,
                ),
                const Divider(),
                _buildSettingTile(
                  context,
                  'Developer',
                  'Amar Fazal',
                  Icons.person_rounded,
                  null,
                ),
              ],
            ),
          )
              .animate(delay: 300.ms)
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: theme.textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: onTap != null
          ? Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400)
          : null,
      onTap: onTap,
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  String _getLanguageText(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'tr':
        return 'Türkçe';
      default:
        return 'English';
    }
  }

  void _showThemeDialog(BuildContext context, ThemeProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: provider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  provider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: provider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  provider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: provider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  provider.setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Locale>(
              title: const Text('English'),
              value: const Locale('en'),
              groupValue: provider.locale,
              onChanged: (value) {
                if (value != null) {
                  provider.setLocale(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<Locale>(
              title: const Text('Türkçe'),
              value: const Locale('tr'),
              groupValue: provider.locale,
              onChanged: (value) {
                if (value != null) {
                  provider.setLocale(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

