import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHandbookProfilepages extends StatefulWidget {
  const MyHandbookProfilepages({super.key});

  @override
  State<MyHandbookProfilepages> createState() => _MyHandbookProfilepagesState();
}

class _MyHandbookProfilepagesState extends State<MyHandbookProfilepages> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> handbookItems = [
    {
      'title': 'Getting Started',
      'subtitle': 'A quick overview of how to use the app',
    },
    {
      'title': 'App Guidelines',
      'subtitle': 'Rules for posting, commenting, and interactions',
    },
    {
      'title': 'Community Rules',
      'subtitle': 'Respect others, no spam, no hate speech, etc.',
    },
    {
      'title': 'Privacy & Security',
      'subtitle': 'How your data is stored and protected',
    },
    {
      'title': 'Tips & Best Practices',
      'subtitle': 'How to grow your account and engage better',
    },
  ];

  List<Map<String, String>> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = handbookItems;
    _searchController.addListener(_filterList);
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredItems = handbookItems.where((item) {
        return item['title']!.toLowerCase().contains(query) ||
            item['subtitle']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _launchPDF() async {
    const pdfUrl =
        'https://example.com/handbook.pdf'; // replace with actual URL
    final Uri url = Uri.parse(pdfUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open handbook PDF")),
      );
    }
  }

  void _showHandbookDetail(String title, String subtitle) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(subtitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Handbook 📘"),
        leading: const BackButton(),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search Handbook',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ...filteredItems.map(
            (item) => ListTile(
              leading: const Icon(Icons.book),
              title: Text(item['title']!),
              subtitle: Text(item['subtitle']!),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showHandbookDetail(item['title']!, item['subtitle']!);
              },
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: _launchPDF,
              icon: const Icon(Icons.download),
              label: const Text("Download Full Handbook"),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
