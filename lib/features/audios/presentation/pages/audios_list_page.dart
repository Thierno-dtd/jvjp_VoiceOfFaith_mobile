import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/audio_provider.dart';
import '../../../../models/audio_model.dart';
import 'audio_player_page.dart';

class AudiosListPage extends ConsumerStatefulWidget {
  const AudiosListPage({super.key});

  @override
  ConsumerState<AudiosListPage> createState() => _AudiosListPageState();
}

class _AudiosListPageState extends ConsumerState<AudiosListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audios = ref.watch(audiosProvider);
    final selectedFilter = ref.watch(audioFilterProvider);
    final searchQuery = ref.watch(audioSearchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF2D3142)),
          onPressed: () {
            // TODO: Open drawer
          },
        ),
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                ref.read(audioSearchProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Search messages...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 15,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          // Filters
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'Filter by Pastor',
                  isSelected: selectedFilter == 'pastor',
                  hasDropdown: true,
                  onTap: () {
                    _showPastorFilter(context);
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pastor John',
                  isSelected: true,
                  showClose: true,
                  onTap: () {
                    ref.read(audioFilterProvider.notifier).state = null;
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pastor Mark',
                  isSelected: false,
                  showClose: false,
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Messages list
          Expanded(
            child: audios.when(
              data: (audiosList) {
                if (audiosList.isEmpty) {
                  return const Center(
                    child: Text('Aucun message disponible'),
                  );
                }

                // Filtrer par recherche
                var filteredAudios = audiosList;
                if (searchQuery.isNotEmpty) {
                  filteredAudios = audiosList
                      .where((audio) =>
                          audio.title
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()) ||
                          audio.uploadedByName
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()))
                      .toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredAudios.length,
                  itemBuilder: (context, index) {
                    final audio = filteredAudios[index];
                    return _AudioMessageCard(
                      audio: audio,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AudioPlayerPage(audio: audio),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Erreur: $error'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to upload audio page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Upload audio - À implémenter'),
            ),
          );
        },
        backgroundColor: const Color(0xFF2E4FE8),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  void _showPastorFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter by Pastor',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Pastor John'),
                onTap: () {
                  ref.read(audioFilterProvider.notifier).state = 'pastor_john';
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Pastor Emily'),
                onTap: () {
                  ref.read(audioFilterProvider.notifier).state = 'pastor_emily';
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('All Pastors'),
                onTap: () {
                  ref.read(audioFilterProvider.notifier).state = null;
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool hasDropdown;
  final bool showClose;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.hasDropdown = false,
    this.showClose = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2E4FE8) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E4FE8) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF2D3142),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hasDropdown) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: isSelected ? Colors.white : const Color(0xFF2D3142),
              ),
            ],
            if (showClose) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.close,
                size: 18,
                color: isSelected ? Colors.white : const Color(0xFF2D3142),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AudioMessageCard extends StatelessWidget {
  final AudioModel audio;
  final VoidCallback onTap;

  const _AudioMessageCard({
    required this.audio,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: audio.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: audio.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.headphones),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue[800]!,
                              Colors.blue[400]!,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.headphones,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    audio.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    audio.uploadedByName,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF2E4FE8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${audio.formattedDuration} • ${DateFormat('MMM d, yyyy').format(audio.createdAt)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Play button
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF2E4FE8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}