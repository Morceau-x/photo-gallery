// ignore_for_file: non_constant_identifier_names
import 'package:freezed_annotation/freezed_annotation.dart';

part 'owner_dto.freezed.dart';
part 'owner_dto.g.dart';

@freezed
abstract class OwnerDTO with _$OwnerDTO {
  const factory OwnerDTO({required String ID, required String DisplayName}) = _OwnerDTO;
  factory OwnerDTO.fromJson(Map<String, dynamic> json) => _$OwnerDTOFromJson(json);
}
