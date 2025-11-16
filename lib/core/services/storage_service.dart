import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  // Upload un fichier avec progression
  Future<String> uploadFile({
    required File file,
    required String folder,
    String? fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final name = fileName ?? '${_uuid.v4()}_${file.path.split('/').last}';
      final ref = _storage.ref().child('$folder/$name');

      final uploadTask = ref.putFile(file);

      // Écouter la progression
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      await uploadTask;
      
      // Retourner l'URL de téléchargement
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erreur lors de l\'upload: $e');
    }
  }

  // Upload audio
  Future<String> uploadAudio({
    required File file,
    required String audioId,
    Function(double)? onProgress,
  }) async {
    return await uploadFile(
      file: file,
      folder: 'audios',
      fileName: '$audioId.mp3',
      onProgress: onProgress,
    );
  }

  // Upload image
  Future<String> uploadImage({
    required File file,
    required String folder,
    Function(double)? onProgress,
  }) async {
    return await uploadFile(
      file: file,
      folder: folder,
      onProgress: onProgress,
    );
  }

  // Upload vidéo
  Future<String> uploadVideo({
    required File file,
    required String folder,
    Function(double)? onProgress,
  }) async {
    return await uploadFile(
      file: file,
      folder: folder,
      onProgress: onProgress,
    );
  }

  // Upload PDF
  Future<String> uploadPdf({
    required File file,
    required String sermonId,
    Function(double)? onProgress,
  }) async {
    return await uploadFile(
      file: file,
      folder: 'sermons',
      fileName: '$sermonId.pdf',
      onProgress: onProgress,
    );
  }

  // Supprimer un fichier
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  // Télécharger un fichier localement
  Future<File> downloadFile({
    required String url,
    required String localPath,
    Function(double)? onProgress,
  }) async {
    try {
      final ref = _storage.refFromURL(url);
      final file = File(localPath);

      final downloadTask = ref.writeToFile(file);

      if (onProgress != null) {
        downloadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      await downloadTask;
      return file;
    } catch (e) {
      throw Exception('Erreur lors du téléchargement: $e');
    }
  }

  // Obtenir les métadonnées d'un fichier
  Future<FullMetadata> getFileMetadata(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      return await ref.getMetadata();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des métadonnées: $e');
    }
  }

  // Obtenir la taille d'un fichier
  Future<int> getFileSize(String url) async {
    final metadata = await getFileMetadata(url);
    return metadata.size ?? 0;
  }
}