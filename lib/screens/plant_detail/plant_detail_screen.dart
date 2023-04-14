import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/theme.dart';
import '../../db/plants_dao.dart';
import '../../models/plants_model.dart';
import '../../util/logger.dart';
import '../../util/snack_bar.dart';
import '../../models/plant.dart';

class PlantDetailScreen extends StatelessWidget {
  final String plantId;

  const PlantDetailScreen({
    super.key,
    required this.plantId,
  });

  Future<Plant> _queryPlant() async {
    final dao = PlantsDao();
    final plant = await dao.queryPlantById(plantId);
    if (plant != null) {
      return plant;
    } else {
      throw Exception('No plant found with id:$plantId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<Plant>(
          future: _queryPlant(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildFailedView(context);
            } else if (snapshot.hasData) {
              return _buildPlantDetailView(context, snapshot.data!);
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Center _buildFailedView(BuildContext context) {
    return Center(
      child: Text(
        'Failed to get Plant:$plantId',
        style: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(color: Colors.red.shade400),
      ),
    );
  }

  Widget _buildPlantDetailView(BuildContext context, final Plant plant) {
    return Stack(
      children: [
        _PlantDetailView(plant: plant),
        _BackView(onBackClick: () {
          Navigator.pop(context);
        }),
        _ShareView(onShareClick: () {
          VLog.d('onShareClick');
        }),
      ],
    );
  }
}

class _PlantDetailView extends StatefulWidget {
  final Plant plant;

  const _PlantDetailView({super.key, required this.plant});

  @override
  State<_PlantDetailView> createState() => _PlantDetailViewState();
}

class _PlantDetailViewState extends State<_PlantDetailView> {
  int _imageHeight = 0;
  bool _isPlanted =
      false; //this field can be added to Plant and store in database

  @override
  Widget build(BuildContext context) {
    final image = _buildHeaderImage();
    final textTheme = Theme.of(context).textTheme;
    _isPlanted = context.read<PlantModel>().isPlanted(widget.plant.plantId);

    return SingleChildScrollView(
      child: Stack(
        children: [
          _buildMainColumn(image, textTheme),
          if (_imageHeight > 0)
            _isPlanted ? _buildRemoveButton(context) : _buildAddButton(context)
        ],
      ),
    );
  }

  Column _buildMainColumn(FadeInImage image, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        image,
        const SizedBox(height: 25.0),
        Text(
          widget.plant.name,
          style: textTheme.headlineSmall!.copyWith(
            color: SColors.green900,
          ),
        ),
        const SizedBox(height: 18.0),
        Text(
          'Watering needs',
          style: textTheme.titleMedium!.copyWith(
            color: SColors.green700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6.0),
        Text(
          widget.plant.wateringIntervalString(),
          style: textTheme.bodyMedium!.copyWith(color: SColors.gray500),
        ),
        const SizedBox(height: 16.0),
        _buildHtml(textTheme.bodyMedium!),
        const SizedBox(height: 50.0),
      ],
    );
  }

  Html _buildHtml(TextStyle style) {
    final data = '<p>${widget.plant.description}</p>';
    return Html(
      data: data,
      style: {
        "a": Style(
          color: SColors.green700,
          textDecoration: TextDecoration.underline,
          textDecorationColor: SColors.green700,
        ),
        "p": Style(
          fontSize: FontSize(style.fontSize),
          fontWeight: style.fontWeight,
          fontFamily: style.fontFamily,
          fontStyle: style.fontStyle,
          fontFeatureSettings: style.fontFeatures,
          letterSpacing: 0.4,
          lineHeight: const LineHeight(1.3),
          color: style.color,
        )
      },
      onLinkTap: (url, context, attr, element) {
        VLog.d('onLinkTap $url');
        if (null == url || url.isEmpty) return;
        _launchInBrowser(url);
      },
    );
  }

  FadeInImage _buildHeaderImage() {
    final image = FadeInImage.assetNetwork(
      placeholder: 'assets/images/ic_launcher.png',
      image: widget.plant.imageUrl,
      fit: BoxFit.fitWidth,
    );
    if (_imageHeight <= 0) {
      ImageStream stream = image.image.resolve(ImageConfiguration.empty);
      ImageStreamListener? listener;
      listener = ImageStreamListener((info, synchronousCall) {
        stream.removeListener(listener!);
        final sw = MediaQuery.of(context).size.width;
        final h = info.image.height * sw / info.image.width;
        setState(() {
          _imageHeight = h.toInt();
          VLog.d(
              'image width=${info.image.width} height=${info.image.height} _imageHeight=${_imageHeight}');
        });
      });
      stream.addListener(listener);
    }
    return image;
  }

  Positioned _buildRemoveButton(BuildContext context) {
    return Positioned(
      top: _imageHeight - 25.0,
      right: 8.0,
      child: GestureDetector(
        onTap: () {
          GlobalSnackBar.show('Remove from garden!');
          setState(() {
            _isPlanted = false;
          });
          final model = context.read<PlantModel>();
          model.removePlantFromGarden(widget.plant.plantId);
        },
        child: Container(
          decoration: const BoxDecoration(
            color: SColors.yellow500,
            boxShadow: [
              BoxShadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 1.0,
                spreadRadius: 0.0,
                color: Color(0xFFD6D6D6),
              ),
            ],
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(25.0),
              bottomLeft: Radius.circular(25.0),
            ),
          ),
          width: 50.0,
          height: 50.0,
          child: const Icon(
            Icons.delete,
            color: Colors.blueGrey,
            size: 25.0,
          ),
        ),
      ),
    );
  }

  Positioned _buildAddButton(BuildContext context) {
    return Positioned(
      top: _imageHeight - 25.0,
      right: 8.0,
      child: GestureDetector(
        onTap: () {
          GlobalSnackBar.show('Add to garden!');
          setState(() {
            _isPlanted = true;
          });
          final model = context.read<PlantModel>();
          model.addPlant2Garden(widget.plant);
        },
        child: Container(
          decoration: const BoxDecoration(
            color: SColors.green300,
            boxShadow: [
              BoxShadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 1.0,
                spreadRadius: 0.5,
                color: Color(0xFFC8E6C9),
              ),
            ],
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(25.0),
              bottomLeft: Radius.circular(25.0),
            ),
          ),
          width: 50.0,
          height: 50.0,
          child: const Icon(
            Icons.add,
            color: SColors.yellow300,
            size: 25.0,
          ),
        ),
      ),
    );
  }

  Future<void> _launchInBrowser(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }
}

class _BackView extends StatelessWidget {
  final Function() onBackClick;

  const _BackView({super.key, required this.onBackClick});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 4.0,
      left: 4.0,
      child: GestureDetector(
        onTap: onBackClick,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: SColors.white,
          ),
          width: 40.0,
          height: 40.0,
          child: const Icon(
            Icons.arrow_back,
            color: SColors.black,
            size: 20.0,
          ),
        ),
      ),
    );
  }
}

class _ShareView extends StatelessWidget {
  final Function() onShareClick;

  const _ShareView({super.key, required this.onShareClick});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 4.0,
      right: 4.0,
      child: GestureDetector(
        onTap: onShareClick,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: SColors.white,
          ),
          width: 40.0,
          height: 40.0,
          child: const Icon(
            Icons.share,
            color: SColors.black,
            size: 16.0,
          ),
        ),
      ),
    );
  }
}
