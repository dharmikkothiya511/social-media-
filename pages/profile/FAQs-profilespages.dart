import 'package:flutter/material.dart';

class MyFAQspages extends StatelessWidget {
  const MyFAQspages({super.key});

  final List<Map<String, String>> faqs = const [
    {
      'question': 'What is this app for?',
      'answer':
          'This app helps users post, like, and share content in real time.',
    },
    {
      'question': 'How do I reset my password?',
      'answer': 'Go to Settings > Account > Reset Password.',
    },
    {
      'question': 'Can I delete my account?',
      'answer': 'Yes, go to your profile > settings > delete account.',
    },
    {
      'question': 'How to report a bug?',
      'answer': 'Use the "Report a bug" form under Help & Support.',
    },
    {
      'question': 'Is my data private?',
      'answer': 'Yes, we use secure encryption to protect your data.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQs'), leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search FAQs...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ...faqs.map(
            (faq) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ExpansionTile(
                title: Text(faq['question']!),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(faq['answer']!),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: () {
                // Navigate to contact support or open dialog
              },
              child: const Text('Still have questions? Contact Support'),
            ),
          ),
        ],
      ),
    );
  }
}
