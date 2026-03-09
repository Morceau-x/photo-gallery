// ignore_for_file: non_constant_identifier_names
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bucket_dto.freezed.dart';
part 'bucket_dto.g.dart';

@freezed
abstract class BucketDTO with _$BucketDTO {
  const factory BucketDTO({required String Name, required String CreationDate}) = _BucketDTO;
  factory BucketDTO.fromJson(dynamic json) => _$BucketDTOFromJson(json);
}
