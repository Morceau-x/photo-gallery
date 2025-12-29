import 'package:freezed_annotation/freezed_annotation.dart';

part 'BucketDTO.freezed.dart';
part 'BucketDTO.g.dart';

@freezed
class BucketDTO with _$BucketDTO {
  const factory BucketDTO({required String Name, required String CreationDate}) = _BucketDTO;
  factory BucketDTO.fromJson(dynamic json) => _$BucketDTOFromJson(json);
}
