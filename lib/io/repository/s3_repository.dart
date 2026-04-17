import 'dart:io';

import 'package:photo_gallery/io/datasource/s3_datasource.dart';
import 'package:photo_gallery/models/s3_connection_config.dart';
import 'package:photo_gallery/models/s3_item_list_model.dart';
import 'package:photo_gallery/providers/s3_connection_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 's3_repository.g.dart';

class S3Repository {
  final S3Datasource _s3Datasource;

  S3Repository({required S3Datasource s3Datasource})
    : _s3Datasource = s3Datasource;

  factory S3Repository.fromConfig(S3ConnectionConfig config) {
    final datasource =
        config.urlStyle == S3UrlStyle.virtualHostedStyle
            ? S3Datasource.virtualHostedStyle(
              s3Host: config.endpoint,
              region: config.region,
              clientId: config.accessKey,
              clientSecret: config.secretKey,
              bucketName: config.bucketName,
            )
            : S3Datasource.pathStyle(
              s3Host: config.endpoint,
              region: config.region,
              clientId: config.accessKey,
              clientSecret: config.secretKey,
              bucketName: config.bucketName,
            );
    return S3Repository(s3Datasource: datasource);
  }

  Future<S3ItemListModel> listObjects() =>
      _s3Datasource.get("/", S3ItemListModel.fromJson);

  Future<File> getObject(String path, String outputPath) =>
      _s3Datasource.getFile("/$path", outputPath);

  Future addObject(String path, File file) =>
      _s3Datasource.sendFile(path, file);

  Future<bool> testConnection() async {
    try {
      await listObjects();
      return true;
    } catch (_) {
      return false;
    }
  }
}

@riverpod
S3Repository? s3Repository(Ref ref) {
  final config = ref.watch(selectedConnectionProvider);
  if (config == null) return null;
  return S3Repository.fromConfig(config);
}
