import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../models/audio_model.dart';
import '../providers/audio_provider.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/firestore_service.dart';

class AudioPlayerPage extends ConsumerStatefulWidget {
  final AudioModel audio;

  const AudioPlayerPage({
    super.key,
    required this.audio,
  });

  @override
  ConsumerState<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends ConsumerState<AudioPlayerPage> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    // Démarrer la lecture automatiquement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioPlayerNotifierProvider.notifier).playAudio(widget.audio);
    });
  }

  @override
  void dispose() {
    // Arrêter la lecture quand on quitte
    ref.read(audioPlayerNotifierProvider.notifier).stop();
    super.dispose();
  }

  Future<void> _downloadAudio() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final storageService = StorageService();
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'audio_${widget.audio.id}.mp3';
      final filePath = '${dir.path}/$fileName';

      await storageService.downloadFile(
        url: widget.audio.audioUrl,
        localPath: filePath,
        onProgress: (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
      );

      // Incrémenter le compteur de téléchargements
      await FirestoreService().incrementAudioDownloads(widget.audio.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Audio téléchargé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
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

  void _shareAudio() {
    Share.share(
      'Écoutez ce message: ${widget.audio.title}\n'
      'Par ${widget.audio.uploadedByName}',
      subject: widget.audio.title,
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(audioPlayerNotifierProvider);
    final playerNotifier = ref.read(audioPlayerNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3142)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Listen',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Album Art
              Container(
                width: double.infinity,
                height: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: widget.audio.thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: widget.audio.thumbnailUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
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
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
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
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                widget.audio.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Pastor and Date
              Text(
                '${widget.audio.uploadedByName} - ${DateFormat('MMM d, yyyy').format(widget.audio.createdAt)}',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF2E4FE8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),

              // Waveform
              Container(
                height: 60,
                child: CustomPaint(
                  painter: WaveformPainter(
                    progress: playerState.totalDuration.inSeconds > 0
                        ? playerState.currentPosition.inSeconds /
                            playerState.totalDuration.inSeconds
                        : 0.0,
                  ),
                  child: Container(),
                ),
              ),
              const SizedBox(height: 8),

              // Time indicators
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(playerState.currentPosition),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDuration(playerState.totalDuration),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Skip backward
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.replay_10, size: 28),
                          Positioned(
                            bottom: 12,
                            child: Text(
                              '10',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D3142),
                              ),
                            ),
                          ),
                        ],
                      ),
                      color: const Color(0xFF2D3142),
                      onPressed: () => playerNotifier.skipBackward(),
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Play/Pause
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E4FE8),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 40,
                      ),
                      color: Colors.white,
                      onPressed: () {
                        if (playerState.isPlaying) {
                          playerNotifier.pause();
                        } else {
                          playerNotifier.resume();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Skip forward
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.forward_10, size: 28),
                          Positioned(
                            bottom: 12,
                            child: Text(
                              '15',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D3142),
                              ),
                            ),
                          ),
                        ],
                      ),
                      color: const Color(0xFF2D3142),
                      onPressed: () => playerNotifier.skipForward(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Share and Download buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Share
                  Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6FA),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.share_outlined, size: 24),
                          color: const Color(0xFF2E4FE8),
                          onPressed: _shareAudio,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Share',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 48),

                  // Download
                  Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6FA),
                          shape: BoxShape.circle,
                        ),
                        child: _isDownloading
                            ? Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(
                                  value: _downloadProgress,
                                  strokeWidth: 3,
                                  color: const Color(0xFF2E4FE8),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.download_outlined, size: 24),
                                color: const Color(0xFF2E4FE8),
                                onPressed: _downloadAudio,
                              ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isDownloading
                            ? '${(_downloadProgress * 100).toInt()}%'
                            : 'Download',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3142),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Pastor info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF2E4FE8),
                      child: Text(
                        widget.audio.uploadedByName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.audio.uploadedByName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3142),
                            ),
                          ),
                          const Text(
                            'Lead Pastor',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF2E4FE8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF2D3142),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // You Might Also Like
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'You Might Also Like',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Related audios (placeholder)
              _RelatedAudioItem(
                title: 'Grace in Trials',
                pastor: 'Pastor Jane Doe',
                duration: '34:50',
                color: const Color(0xFFE89A6B),
              ),
              const SizedBox(height: 12),
              _RelatedAudioItem(
                title: 'Living a Purposeful Life',
                pastor: 'Pastor John Appleseed',
                duration: '41:22',
                color: const Color(0xFF8B7355),
              ),
              const SizedBox(height: 12),
              _RelatedAudioItem(
                title: 'The Heart of a Servant',
                pastor: 'Guest Speaker Mark Lee',
                duration: '29:18',
                color: const Color(0xFFC4A576),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double progress;

  WaveformPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final spacing = 4.0;
    final barCount = (size.width / spacing).floor();
    final heights = List.generate(
      barCount,
      (i) => size.height * (0.2 + 0.6 * (i % 7 / 7)),
    );

    for (int i = 0; i < barCount; i++) {
      final x = i * spacing;
      final height = heights[i];
      final isActive = i / barCount <= progress;

      paint.color = isActive
          ? const Color(0xFF2E4FE8)
          : const Color(0xFF2E4FE8).withOpacity(0.2);

      canvas.drawLine(
        Offset(x, (size.height - height) / 2),
        Offset(x, (size.height + height) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _RelatedAudioItem extends StatelessWidget {
  final String title;
  final String pastor;
  final String duration;
  final Color color;

  const _RelatedAudioItem({
    required this.title,
    required this.pastor,
    required this.duration,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.music_note,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$pastor - $duration',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF2E4FE8).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Color(0xFF2E4FE8),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}