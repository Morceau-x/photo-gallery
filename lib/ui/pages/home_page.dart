import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_gallery/io/repository/s3_repository.dart';
import 'package:photo_gallery/models/s3_item_list_model.dart';
import 'package:photo_gallery/ui/atoms/grid_delegate_with_staggered_tiles.dart';
import 'package:photo_gallery/ui/pages/s3_file_thumbnail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_page.g.dart';

class GridItem with SizedItem {
  GridItem({required this.width, required this.height, required this.item});
  final double width;
  final double height;
  @override
  get aspectRatio => width / height;
  final S3ItemModel item;
}

@riverpod
Future<List<GridItem>> s3Items(Ref ref) async {
  return (await repository.listObjects()).items.map((item) {
    print(item.eTag);
    if (item.eTag == "9fce16d6ef7383d15b5373636f96261a") {
      return GridItem(width: 1.29, height: 1, item: item);
    }
    if (item.eTag == "d42b30846f1a249a49ae7c7cb6a3c9b2") {
      return GridItem(width: 1, height: 1.7, item: item);
    }
    if (item.eTag == "ee269e873199f63efa3d2ca3172512cc") {
      return GridItem(width: 1, height: 1.3, item: item);
    }
    return GridItem(width: 1, height: 1, item: item);
  }).toList();
}

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(s3ItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('TODO TL Gallery')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(),
            left: BorderSide(),
            right: BorderSide(),
            bottom: BorderSide(),
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(s3ItemsProvider.future),
          child: items.when(
            data: (items) {
              return GridView.builder(
                gridDelegate: GridDelegateWithStaggeredTiles(
                  items: items,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  crossAxisCount: 2,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return S3FileThumbnail(
                    item: item.item,
                    key: Key(item.item.eTag),
                  );
                },
                cacheExtent: 1000,
                itemCount: items.length,
              );
            },
            error: (err, stack) => Text('Error: $err'),
            loading: () => const CircularProgressIndicator(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ImagePicker()
            .pickImage(source: ImageSource.gallery)
            .then((image) async {
              if (image == null) {
                return null;
              }
              final File file = File(image.path);
              print('uploading ${image.name} $file');
              await repository.addObject(image.name, file);
              return ref.refresh(s3ItemsProvider.future);
            }),
        child: const Icon(Icons.add),
      ),
    );
  }
}

//               return MasonryListViewGrid(
//                 column: 2,
//                 padding: const EdgeInsets.all(8.0),
//                 children: items.items.map((item) {
//                   print('item ${item}');
//                   return S3FileThumbnail(item: item);
//                 }).toList(),
//               );
