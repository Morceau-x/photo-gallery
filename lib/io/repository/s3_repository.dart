import 'package:photo_gallery/io/datasource/s3_datasource.dart';
import 'package:photo_gallery/models/S3ItemListModel.dart';

class S3Repository {
  final S3Datasource _s3Datasource;

  S3Repository({S3Datasource? s3Datasource})
    : _s3Datasource =
          s3Datasource ??
          S3Datasource.pathStyle(
            s3Host: "s3.host.fr",
            region: "eu-west-1",
            clientId: "<clientId>",
            clientSecret: "<clientSecret>",
            bucketName: "<bucketName>",
          );

  Future<S3ItemListModel> listObjects() => _s3Datasource.get("/", S3ItemListModel.fromJson);
}
