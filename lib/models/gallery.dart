class GalleryResult {
  int totalSize;
  int totalPages;

  List<UnsplashImage>? photos;

  GalleryResult({
    required this.totalSize,
    required this.totalPages,
    this.photos,
  });
}

class UnsplashImage {
  String id;
  String username;
  String name;
  String photoUrl;
  String userLink;

  UnsplashImage({
    required this.id,
    required this.photoUrl,
    this.name = "",
    this.username = "",
    this.userLink = "",
  });
}

class GalleryData {
  final bool hasMore;
  final bool loading;
  final bool error;

  List<UnsplashImage>? photos;

  GalleryData({
    required this.hasMore,
    required this.loading,
    required this.error,
    this.photos,
  });
}
