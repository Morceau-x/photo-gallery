// ignore_for_file: non_constant_identifier_names
import 'package:freezed_annotation/freezed_annotation.dart';

import 'owner_dto.dart';

part 's3_item_dto.freezed.dart';
part 's3_item_dto.g.dart';

@freezed
abstract class S3ItemDTO with _$S3ItemDTO {
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
