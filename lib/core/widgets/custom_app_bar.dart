import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDataProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Icon ou Back button
            if (showBackButton)
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3142)),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E4FE8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.business_center,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            const SizedBox(width: 12),

            // Title (dynamic)
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3142),
                ),
              ),
            ),

            // Notification bell
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // TODO: Navigate to notifications
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications - À implémenter'),
                  ),
                );
              },
            ),

            // Avatar (profile button)
            GestureDetector(
              onTap: () {
                // Navigate to profile when tapping avatar
                Navigator.pushNamed(context, '/profile');
              },
              child: currentUser.when(
                data: (user) => CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF8B9D83),
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? Text(
                    user?.displayName[0].toUpperCase() ?? 'G',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : null,
                ),
                loading: () => const CircleAvatar(radius: 20),
                error: (_, __) => const CircleAvatar(radius: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}