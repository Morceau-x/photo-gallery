import 'package:freezed_annotation/freezed_annotation.dart';

import 'OwnerDTO.dart';

part 'S3ItemDTO.freezed.dart';
part 'S3ItemDTO.g.dart';

@freezed
class S3ItemDTO with _$S3ItemDTO {
  const factory S3ItemDTO({
    required String Key,
    required String ETag,
    required String Size,
    required String StorageClass,
    required String LastModified,
    required OwnerDTO Owner,
  }) = _S3ItemDTO;
  factory S3ItemDTO.fromJson(dynamic json) => _$S3ItemDTOFromJson(json);
}
