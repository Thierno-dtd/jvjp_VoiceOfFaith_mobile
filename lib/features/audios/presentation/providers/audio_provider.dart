import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../models/audio_model.dart';
import '../../../../mockTest/app_config.dart';
import '../../../../mockTest/mock_firestore_service.dart';

final audioFirestoreServiceProvider = Provider<FirestoreService>((ref) {
  /*if (AppConfig.useMockData) {
    return MockFirestoreService();
  }*/
  return FirestoreService();
});

// Provider de la liste des audios
final audiosProvider = StreamProvider<List<AudioModel>>((ref) {
  final firestoreService = ref.watch(audioFirestoreServiceProvider);
  return firestoreService.getAudios();
});

// Provider pour un audio spécifique
final audioDetailProvider = FutureProvider.family<AudioModel, String>((ref, id) async {
  final firestoreService = ref.watch(audioFirestoreServiceProvider);
  return await firestoreService.getAudio(id);
});

// Provider du lecteur audio
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() {
    player.dispose();
  });
  return player;
});

// State pour le lecteur audio
class AudioPlayerState {
  final bool isPlaying;
  final Duration currentPosition;
  final Duration totalDuration;
  final AudioModel? currentAudio;

  AudioPlayerState({
    this.isPlaying = false,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.currentAudio,
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    Duration? currentPosition,
    Duration? totalDuration,
    AudioModel? currentAudio,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      currentAudio: currentAudio ?? this.currentAudio,
    );
  }
}

// Notifier pour gérer l'état du lecteur
class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final AudioPlayer _audioPlayer;
  final FirestoreService _firestoreService;

  AudioPlayerNotifier(this._audioPlayer, this._firestoreService)
      : super(AudioPlayerState()) {
    _initializeListeners();
  }

  void _initializeListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      this.state = this.state.copyWith(
        isPlaying: state == PlayerState.playing,
      );
    });

    _audioPlayer.onPositionChanged.listen((position) {
      state = state.copyWith(currentPosition: position);
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      state = state.copyWith(totalDuration: duration);
    });
  }

  Future<void> playAudio(AudioModel audio) async {
    await _audioPlayer.play(UrlSource(audio.audioUrl));
    state = state.copyWith(currentAudio: audio);

    // Incrémenter le compteur de lectures
    await _firestoreService.incrementAudioPlays(audio.id);
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> skipForward() async {
    final newPosition = state.currentPosition + const Duration(seconds: 15);
    await seek(newPosition);
  }

  Future<void> skipBackward() async {
    final newPosition = state.currentPosition - const Duration(seconds: 10);
    await seek(newPosition > Duration.zero ? newPosition : Duration.zero);
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    state = AudioPlayerState();
  }
}

// Provider pour le notifier
final audioPlayerNotifierProvider =
StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  final audioPlayer = ref.watch(audioPlayerProvider);
  final firestoreService = ref.watch(audioFirestoreServiceProvider);
  return AudioPlayerNotifier(audioPlayer, firestoreService);
});

// Provider pour les filtres
final audioFilterProvider = StateProvider<String?>((ref) => null);
final audioSearchProvider = StateProvider<String>((ref) => '');