// ignore_for_file: non_constant_identifier_names
import 'package:freezed_annotation/freezed_annotation.dart';

import 'DTO/bucket_list_dto.dart';
import 'DTO/owner_dto.dart';

part 'list_buckets_model.freezed.dart';

@freezed
abstract class BucketModel with _$BucketModel {
  const factory BucketModel({required String name, required String creationDate}) = _BucketModel;
}

@freezed
abstract class ListBucketsModel with _$ListBucketsModel {
  const factory ListBucketsModel({required List<BucketModel> buckets}) = _ListBucketsModel;

  factory ListBucketsModel.fromJson(dynamic json) {
    final dto = ListAllMyBucketsDTO.fromJson(json);
    final bucketsDTO = dto.Buckets.BucketList;
    final buckets = bucketsDTO.map((e) => BucketModel(name: e.Name, creationDate: e.CreationDate)).toList();
    return ListBucketsModel(buckets: buckets);
  }
}

@freezed
abstract class ListAllMyBucketsDTO with _$ListAllMyBucketsDTO {
  const factory ListAllMyBucketsDTO({required OwnerDTO Owner, required BucketListDTO Buckets}) = _ListAllMyBucketsDTO;

  factory ListAllMyBucketsDTO.fromJson(Map<String, dynamic> json) {
    return ListAllMyBucketsDTO(
      Owner: OwnerDTO.fromJson(json['ListAllMyBucketsResult']['Owner'] as Map<String, dynamic>),
      Buckets: BucketListDTO.fromJson(json['ListAllMyBucketsResult']['Buckets'] as Map<String, dynamic>),
    );
  }
}
