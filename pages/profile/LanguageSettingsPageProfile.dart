import 'package:flutter/material.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  String selectedLanguage = "English";

  void _selectLanguage(BuildContext context) async {
    final List<String> languages = ["English", "Hindi", "Gujarati", "Spanish"];

    String? picked = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Choose Language"),
          children: languages
              .map(
                (lang) => SimpleDialogOption(
                  child: Text(lang),
                  onPressed: () => Navigator.pop(context, lang),
                ),
              )
              .toList(),
        );
      },
    );

    if (picked != null && picked != selectedLanguage) {
      setState(() {
        selectedLanguage = picked;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Language set to $picked")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Language Settings")),
      body: ListTile(
        leading: const Icon(Icons.language),
        title: const Text("Language"),
        subtitle: Text(selectedLanguage),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _selectLanguage(context),
      ),
    );
  }
}
