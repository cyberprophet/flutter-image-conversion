import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_conversion/flutter_image_conversion.dart';
import 'package:photo_manager/photo_manager.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  static const routeUrl = '/gallery';
  static const routeName = 'gallery';

  @override
  State<StatefulWidget> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  @override
  void initState() {
    super.initState();

    _gallery();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconThemeColor = theme.primaryTextTheme.titleLarge?.color;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: iconThemeColor),
        backgroundColor: theme.scaffoldBackgroundColor,
        actions: [
          if (_images.isNotEmpty)
            IconButton(
              onPressed: () => setState(_images.clear),
              icon: const Icon(Icons.cleaning_services_outlined),
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: _galleryImages(theme),
      ),
    );
  }

  GridView _galleryImages(ThemeData theme) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: _images.length,
      itemBuilder: (context, index) {
        final image = _images[index];

        final exist = _images.any((e) => e.id == image.id);

        return GestureDetector(
          onTap: () {
            if (kDebugMode) {
              print("Selected Image: ${image.id}");
            }
            setState(() {
              if (exist) {
                _images.remove(image);
              } else {
                _images.add(image);
              }
            });
          },
          child: FutureBuilder(
            future: image.file,
            builder: (_, snapshot) => snapshot.hasData
                ? FutureBuilder(
                    future: _imgConvert.convertHeicToJpeg(snapshot.data!),
                    builder: (_, snapshot) => snapshot.hasData
                        ? Image.file(snapshot.data!)
                        : const SizedBox.shrink(),
                  )
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  Future _gallery() async {
    final permission = await PhotoManager.requestPermissionExtend();

    if (!permission.hasAccess) {
      return;
    }
    final galleryPaths = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false)
        ],
      ),
    );
    final images = await galleryPaths[0].getAssetListPaged(page: 0, size: 96);

    setState(() => _images = images);
  }

  List<AssetEntity> _images = [];

  final _imgConvert = FlutterImageConversion();
}
