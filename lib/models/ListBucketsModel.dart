import 'package:freezed_annotation/freezed_annotation.dart';

import 'DTO/BucketListDTO.dart';
import 'DTO/OwnerDTO.dart';

part 'ListBucketsModel.freezed.dart';

@freezed
class BucketModel with _$BucketModel {
  const factory BucketModel({required String name, required String creationDate}) = _BucketModel;
}

@freezed
class ListBucketsModel with _$ListBucketsModel {
  const factory ListBucketsModel({required List<BucketModel> buckets}) = _ListBucketsModel;

  factory ListBucketsModel.fromJson(dynamic json) {
    final dto = ListAllMyBucketsDTO.fromJson(json);
    final bucketsDTO = dto.Buckets.BucketList;
    final buckets = bucketsDTO.map((e) => BucketModel(name: e.Name, creationDate: e.CreationDate)).toList();
    return ListBucketsModel(buckets: buckets);
  }
}

@freezed
class ListAllMyBucketsDTO with _$ListAllMyBucketsDTO {
  const factory ListAllMyBucketsDTO({required OwnerDTO Owner, required BucketListDTO Buckets}) = _ListAllMyBucketsDTO;

  factory ListAllMyBucketsDTO.fromJson(Map<String, dynamic> json) {
    return ListAllMyBucketsDTO(
      Owner: OwnerDTO.fromJson(json['ListAllMyBucketsResult']['Owner'] as Map<String, dynamic>),
      Buckets: BucketListDTO.fromJson(json['ListAllMyBucketsResult']['Buckets'] as Map<String, dynamic>),
    );
  }
}
