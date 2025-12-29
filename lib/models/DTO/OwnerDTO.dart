import 'package:freezed_annotation/freezed_annotation.dart';

part 'OwnerDTO.freezed.dart';
part 'OwnerDTO.g.dart';

@freezed
class OwnerDTO with _$OwnerDTO {
  const factory OwnerDTO({required String ID, required String DisplayName}) = _OwnerDTO;
  factory OwnerDTO.fromJson(Map<String, dynamic> json) => _$OwnerDTOFromJson(json);
}
