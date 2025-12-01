import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class SocialFeedPage extends StatelessWidget {
  const SocialFeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: const CustomAppBar(title: 'Media'),
      body: const Center(
        child: Text('Page Social Feed - À implémenter'),
      ),
    );
  }
}