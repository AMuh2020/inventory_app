import 'package:flutter/material.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
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