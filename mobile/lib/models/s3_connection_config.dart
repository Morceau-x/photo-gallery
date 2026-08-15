import 'package:freezed_annotation/freezed_annotation.dart';

part 's3_connection_config.freezed.dart';
part 's3_connection_config.g.dart';

enum S3UrlStyle {
  virtualHostedStyle,
  pathStyle
}

@freezed
abstract class S3ConnectionConfig with _$S3ConnectionConfig {
  const factory S3ConnectionConfig({
    required String id,
    required String name,
    required String endpoint,
    required String region,
    required String bucketName,
    required S3UrlStyle urlStyle,
    required bool isDefault,
    required bool isSafeStorage,
    required String accessKey,
    required String secretKey,
  }) = _S3ConnectionConfig;

  factory S3ConnectionConfig.fromJson(Map<String, dynamic> json) =>
      _$S3ConnectionConfigFromJson(json);
}
