// ignore_for_file: non_constant_identifier_names
import 'package:freezed_annotation/freezed_annotation.dart';

import 'bucket_dto.dart';
import 'dto_utils.dart';

part 'bucket_list_dto.freezed.dart';

@freezed
abstract class BucketListDTO with _$BucketListDTO {
  const factory BucketListDTO({required List<BucketDTO> BucketList}) = _BucketListDTO;

  factory BucketListDTO.fromJson(Map<String, dynamic> json) {
    final dynamic bucketList = json['Bucket'];
    return BucketListDTO(BucketList: parseS3ItemList(bucketList, BucketDTO.fromJson));
  }
}
