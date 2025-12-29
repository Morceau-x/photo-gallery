import 'package:freezed_annotation/freezed_annotation.dart';

import 'BucketDTO.dart';
import 'dto_utils.dart';

part 'BucketListDTO.freezed.dart';

@freezed
class BucketListDTO with _$BucketListDTO {
  const factory BucketListDTO({required List<BucketDTO> BucketList}) = _BucketListDTO;

  factory BucketListDTO.fromJson(Map<String, dynamic> json) {
    final dynamic bucketList = json['Bucket'];
    return BucketListDTO(BucketList: parseS3ItemList(bucketList, BucketDTO.fromJson));
  }
}
