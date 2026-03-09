import 'dart:io';

import 'package:photo_gallery/io/datasource/s3_datasource.dart';
import 'package:photo_gallery/models/s3_item_list_model.dart';

class S3Repository {
  final S3Datasource _s3Datasource;

  S3Repository({required S3Datasource s3Datasource})
    : _s3Datasource = s3Datasource;

  S3Repository.fromCredentials({
    required String s3Host,
    required String region,
    required String clientId,
    required String clientSecret,
    required String bucketName,
  }) : _s3Datasource = S3Datasource.pathStyle(
         s3Host: s3Host,
         region: region,
         clientId: clientId,
         clientSecret: clientSecret,
         bucketName: bucketName,
       );

  Future<S3ItemListModel> listObjects() =>
      _s3Datasource.get("/", S3ItemListModel.fromJson);

  Future<File> getObject(String path, String outputPath) =>
      _s3Datasource.getFile("/$path", outputPath);

  Future addObject(String path, File file) =>
      _s3Datasource.sendFile(path, file);
}

final repository = S3Repository.fromCredentials(
  s3Host: "TODO",
  region: "TODO",
  clientId: "TODO",
  clientSecret: "TODO",
  bucketName: "TODO",
);
