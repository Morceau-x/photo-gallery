import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_gallery/io/repository/s3_repository.dart';
import 'package:photo_gallery/models/s3_item_list_model.dart';
import 'package:photo_gallery/routes/root.dart';
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
  final repo = ref.watch(s3RepositoryProvider);
  if (repo == null) return [];
  return (await repo.listObjects()).items.map((item) {
    return GridItem(width: 1, height: 1, item: item);
  }).toList();
}

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(s3ItemsProvider);
    final hasConnection = ref.watch(s3RepositoryProvider) != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => const ConnectionsRoute().push(context),
          ),
        ],
      ),
      body: !hasConnection
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No S3 connection configured.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => const EditConnectionRoute(connectionId: 'new').push(context),
                    child: const Text('Add Connection'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.refresh(s3ItemsProvider.future),
              child: items.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const Center(child: Text('No photos found.'));
                  }
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
                error: (err, stack) => Center(child: Text('Error: $err')),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
      floatingActionButton: hasConnection
          ? FloatingActionButton(
              onPressed: () {
                final repo = ref.read(s3RepositoryProvider);
                if (repo == null) return;
                ImagePicker()
                    .pickImage(source: ImageSource.gallery)
                    .then((image) async {
                  if (image == null) return;
                  final File file = File(image.path);
                  await repo.addObject(image.name, file);
                  ref.invalidate(s3ItemsProvider);
                });
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
