import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sunflower/models/gallery.dart';

import '../util/logger.dart';
import 'unsplash_repository.dart';

// todo use redux rewrite async work
class GalleryModel extends ChangeNotifier {
  GalleryModel() {
    _checkUnsplashKey();
  }

  String _unsplashKey = "";

  String get unsplashKey => _unsplashKey;

  bool get hasUnsplashKey => _unsplashKey.length == 43;

  final int _pageSize = 16;
  late String _keyword;
  late int _pageIndex;

  late bool _error;
  late bool _loading;
  late bool _hasMore;
  late List<UnsplashImage> _photos;
  late UnsplashRepository _repository;

  GalleryData get galleryResult => GalleryData(
        hasMore: _hasMore,
        loading: _loading,
        error: _error,
        photos: _photos,
      );

  setup(String keyword) {
    VLog.d('gallery model setup');

    _hasMore = true;
    _keyword = keyword;
    _loading = true;
    _pageIndex = 1;
    _error = false;
    _photos = [];
    _repository = UnsplashRepository();
  }

  refresh() async {
    if (_loading) return;
    _pageIndex = 1;
    _error = false;
    _loading = true;

    final result = await _repository.fetchSearchResultStream(
      _keyword,
      _pageIndex,
      _pageSize,
      _unsplashKey,
    );

    _loading = false;
    if (result == null) {
      _error = true;
      _pageIndex = 0;
      notifyListeners();
      return;
    }
    _hasMore = _pageSize < result.totalPages;
    _photos.clear();
    if (result.photos?.isNotEmpty == true) {
      _photos.addAll(result.photos!);
    }
    notifyListeners();
  }

  loadMore() async {
    if (_loading) return;
    VLog.d('start load more');
    _pageIndex++;
    _loading = true;

    final result = await _repository.fetchSearchResultStream(
      _keyword,
      _pageIndex,
      _pageSize,
      _unsplashKey,
    );

    _loading = false;
    if (result == null) {
      _pageIndex--;
      _error = true;
      notifyListeners();
      return;
    }
    _hasMore = _pageSize < result.totalPages;

    if (result.photos?.isNotEmpty == true) {
      _photos.addAll(result.photos!);
    }
    notifyListeners();
  }

  retry() {
    if (_pageIndex == 0) {
      refresh();
    } else {
      loadMore();
    }
  }

  _checkUnsplashKey() async {
    try {
      final src = await rootBundle.loadString('assets/data/secret.config');
      final parsed = jsonDecode(src);
      _unsplashKey = parsed['unsplash_access_key'] as String;
      VLog.d('_checkUnsplashKey parsed=$_unsplashKey');
      if (_unsplashKey.length != 43) _unsplashKey = "";
    } catch (e) {
      _unsplashKey = "";
      VLog.err('no valid UnsplashKey', e);
    }
    notifyListeners();
  }
}
