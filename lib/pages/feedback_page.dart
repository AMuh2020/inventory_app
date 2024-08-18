import 'package:flutter/material.dart';
import 'package:inventory_app/pages/main_page.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // instead of popping the context, remove stack and push homepage
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainPage()),
              (route) => false,
            );
          },
        ),
      ),
      body: const Center(
        child: Column(
          children: [

            Text('We would love to hear from you! Please email us at'),
            SelectableText('amalworks2024@gmail.com'),
            Text('for any feedback or suggestions'),
          ],
        ),
      ),
    );
  }
}