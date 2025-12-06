import 'dart:convert';
import 'package:http/http.dart' as http;

class SongData {
  final String title;
  final String artistName;
  final String thumbnailUrl;
  final String? spotifyUrl;
  final String? youtubeMusicUrl;
  final String? youtubeUrl;

  SongData({
    required this.title,
    required this.artistName,
    required this.thumbnailUrl,
    this.spotifyUrl,
    this.youtubeMusicUrl,
    this.youtubeUrl,
  });

  factory SongData.fromJson(Map<String, dynamic> json) {
    // Get platform links
    final links = json['linksByPlatform'] as Map<String, dynamic>;
    final spotifyLink = links['spotify'] as Map<String, dynamic>?;
    final youtubeMusicLink = links['youtubeMusic'] as Map<String, dynamic>?;
    final youtubeLink = links['youtube'] as Map<String, dynamic>?;

    // Get song details from Spotify entity
    final entities = json['entitiesByUniqueId'] as Map<String, dynamic>;
    final spotifyEntityId = spotifyLink?['entityUniqueId'] as String?;
    final spotifyEntity = spotifyEntityId != null
        ? entities[spotifyEntityId] as Map<String, dynamic>?
        : null;

    // Fallback to first entity if Spotify not available
    final songEntity =
        spotifyEntity ?? entities.values.first as Map<String, dynamic>;

    return SongData(
      title: songEntity['title'] as String,
      artistName: songEntity['artistName'] as String,
      thumbnailUrl: songEntity['thumbnailUrl'] as String,
      spotifyUrl: spotifyLink?['url'] as String?,
      youtubeMusicUrl: youtubeMusicLink?['url'] as String?,
      youtubeUrl: youtubeLink?['url'] as String?,
    );
  }
}

class ApiService {
  static const String baseUrl = 'https://api.song.link/v1-alpha.1/links';

  Future<SongData?> fetchSongLinks(String url) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?url=${Uri.encodeComponent(url)}'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return SongData.fromJson(json);
      } else {
        print('Failed to fetch song links: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching song links: $e');
      return null;
    }
  }
}
