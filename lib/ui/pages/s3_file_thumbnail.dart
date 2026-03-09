import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_gallery/io/repository/s3_repository.dart';
import 'package:photo_gallery/models/s3_item_list_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 's3_file_thumbnail.freezed.dart';
part 's3_file_thumbnail.g.dart';

@freezed
abstract class ThumbnailDisplayData with _$ThumbnailDisplayData {
  const factory ThumbnailDisplayData({
    required String path,
    required File file,
    double? width,
    double? height,
  }) = _ThumbnailDisplayData;
}

@riverpod
Future<ThumbnailDisplayData> fileUrl(Ref ref, S3ItemModel item) async {
  final temporaryDirectory = await getTemporaryDirectory();
  print("GET ITEMMMMMM: $item");
  final outputPath = "${temporaryDirectory.path}/s3/${item.name}";
  print("INPUT ${item.name}, $outputPath");
  final content = await repository.getObject(item.name, outputPath);
  print(
    "${item.name} - ${lookupMimeType(outputPath)}: ${crypto.md5.convert(content.readAsBytesSync()).toString()} / ${item.eTag}",
  );
  final mediaInfo = (await FFprobeKit.getMediaInformation(
    outputPath,
  )).getMediaInformation();
  final stream = mediaInfo?.getStreams().firstOrNull;
  final width = stream?.getWidth()?.toDouble();
  final height = stream?.getHeight()?.toDouble();

  return ThumbnailDisplayData(
    path: outputPath,
    file: content,
    width: width,
    height: height,
  );
}

class S3FileThumbnail extends HookConsumerWidget {
  const S3FileThumbnail({super.key, required this.item});
  final S3ItemModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(fileUrlProvider(item));
    return image.when(
      data: (file) {
        return Image.file(file.file);
      },
      error: (err, stack) {
        print("ERROR: $err");
        return Container(color: Colors.red);
      },
      loading: () => Center(child: const CircularProgressIndicator()),
    );
  }
}
