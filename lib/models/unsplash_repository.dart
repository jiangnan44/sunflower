import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sunflower/models/gallery.dart';
import 'package:sunflower/util/logger.dart';

class UnsplashRepository {
  static const String _baseUrl = 'https://api.unsplash.com/';
  static const String _searchPhoto = 'search/photos';

  Future<GalleryResult?> fetchSearchResultStream(
    final String keyword,
    final int page,
    final int pageSize,
    final String clientId,
  ) async {
    final url =
        '$_baseUrl$_searchPhoto?query=$keyword&page=$page&per_page=$pageSize&client_id=$clientId';
    try {
      final response = await http.get(Uri.parse(url));
      final ret = json.decode(response.body);
      final int totalPages = ret['total_pages'];
      final int totalSize = ret['total'];

      final List? list = ret['results'];
      if (list == null || list.isEmpty) {
        return GalleryResult(totalSize: totalSize, totalPages: totalPages);
      }

      final images = _resolveImages(list);
      final result = GalleryResult(
        totalSize: totalSize,
        totalPages: totalPages,
      );
      if (images.isNotEmpty) {
        result.photos = images;
      }
      return result;
    } catch (e) {
      VLog.err('fetchSearchResultStream error', e);
      return null;
    }
  }

  List<UnsplashImage> _resolveImages(List<dynamic> list) {
    List<UnsplashImage> images = [];

    for (final data in list) {
      final urls = data['urls'];
      if (urls == null) {
        continue;
      }
      String? url = urls['thumb'];
      if (url == null) {
        continue;
      }

      String id = data['id'];
      final image = UnsplashImage(id: id, photoUrl: url);

      final user = data['user'];
      if (user == null) {
        images.add(image);
        continue;
      }
      image.username = user['username'] ?? "";
      image.name = user['name'] ?? "";

      final links = user['links'];
      if (links != null) {
        final userLink = links['html'] as String?;
        image.userLink = userLink ?? "";
      }
      images.add(image);
    }
    return images;
  }
}
