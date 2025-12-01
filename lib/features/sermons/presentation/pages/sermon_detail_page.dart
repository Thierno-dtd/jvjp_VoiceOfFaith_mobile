import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../models/sermon_model.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/firestore_service.dart';
import 'package:open_filex/open_filex.dart';
//import 'package:flutter_pdfview/flutter_pdfview.dart';
//import 'dart:io';

class SermonDetailPage extends ConsumerStatefulWidget {
  final SermonModel sermon;

  const SermonDetailPage({
    super.key,
    required this.sermon,
  });

  @override
  ConsumerState<SermonDetailPage> createState() => _SermonDetailPageState();
}

class _SermonDetailPageState extends ConsumerState<SermonDetailPage> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  Future<void> _downloadPdf() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final storageService = StorageService();
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'sermon_${widget.sermon.id}.pdf';
      final filePath = '${dir.path}/$fileName';

      await storageService.downloadFile(
        url: widget.sermon.pdfUrl,
        localPath: filePath,
        onProgress: (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
      );

      // Incrémenter le compteur de téléchargements
      await FirestoreService().incrementSermonDownloads(widget.sermon.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF téléchargé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );

        // Ouvrir le PDF
        await OpenFilex.open(filePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  void _shareSermon() {
    Share.share(
      'Découvrez ce sermon: ${widget.sermon.title}\n'
      'Date: ${DateFormat('dd/MM/yyyy').format(widget.sermon.date)}',
      subject: widget.sermon.title,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        slivers: [
          // Image Header with back button
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3142)),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.sermon.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.sermon.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pastor and Date
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF2E4FE8),
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pastor John Doe',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3142),
                              ),
                            ),
                            Text(
                              DateFormat('MMMM d, yyyy').format(widget.sermon.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'This sermon explores the fundamental question of our purpose in life through the lens of faith. Pastor John guides us through scripture to understand how faith can guide our daily actions, decisions, and ultimately lead to a more fulfilling existence aligned with a divine plan.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF2D3142),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      // Download button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isDownloading ? null : _downloadPdf,
                          icon: _isDownloading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    value: _downloadProgress,
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.download_outlined, size: 20),
                          label: Text(
                            _isDownloading
                                ? '${(_downloadProgress * 100).toInt()}%'
                                : 'Download',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E4FE8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Share button
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: _shareSermon,
                          icon: const Icon(Icons.share_outlined),
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(
                          icon: Icons.visibility_outlined,
                          value: '1.2k',
                          label: 'Views',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[300],
                        ),
                        _buildStat(
                          icon: Icons.download_outlined,
                          value: widget.sermon.downloads.toString(),
                          label: 'Downloads',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey[300],
                        ),
                        _buildStat(
                          icon: Icons.favorite_outline,
                          value: '89',
                          label: 'Likes',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2E4FE8), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3142),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}