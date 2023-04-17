import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sunflower/common/theme.dart';
import 'package:sunflower/util/logger.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/gallery.dart';
import '../../models/gallery_model.dart';
import '../home/plant_common_views.dart';

class GalleryScreen extends StatefulWidget {
  final String keyWord;

  const GalleryScreen({super.key, required this.keyWord});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    context.read<GalleryModel>()
      ..setup(widget.keyWord)
      ..refresh();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      final nextPageTrigger = 0.8 * _scrollController.position.maxScrollExtent;
      if (_scrollController.position.pixels > nextPageTrigger) {
        context.read<GalleryModel>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<GalleryModel>().galleryResult;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(widget.keyWord),
      ),
      body: _buildGalleryView(context, data),
    );
  }

  Widget _buildGalleryView(BuildContext context, GalleryData data) {
    if (data.photos == null || data.photos!.isEmpty) {
      if (data.loading) {
        return _buildLoadingView();
      } else if (data.error) {
        return _buildErrorView(context);
      }
    }

    final length = data.photos!.length;
    return GridView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: length + (data.hasMore ? 1 : 0),
      controller: _scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12.0,
          crossAxisSpacing: 10.0,
          childAspectRatio: 10.0 / 9.0),
      itemBuilder: (context, index) {
        if (index == length) {
          if (data.error) {
            return Center(child: _buildErrorView(context, size: 12.0));
          } else {
            return _buildLoadingView();
          }
        }

        final image = data.photos![index];
        return _buildGalleryItemView(context, image);
      },
    );
  }

  Center _buildLoadingView() =>
      const Center(child: CircularProgressIndicator(color: SColors.yellow500));

  Widget _buildErrorView(BuildContext context, {final double size = 18.0}) {
    return SizedBox(
      height: 180,
      width: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Oops~ An error occurred~',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {
              context.read<GalleryModel>().retry();
            },
            child: const Text(
              'Retry',
              style: TextStyle(
                fontSize: 18.0,
                color: SColors.green900,
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _launchInBrowser(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      VLog.e('Could not launch $url');
    }
  }

  Widget _buildGalleryItemView(BuildContext context, UnsplashImage image) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        _launchInBrowser(image.userLink);
      },
      child: Card(
        shape: plantBorder(),
        elevation: 2.0,
        child: Column(
          children: [
            plantImage(image.photoUrl),
            Expanded(
              child: Center(
                child: Text(
                  image.name,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
