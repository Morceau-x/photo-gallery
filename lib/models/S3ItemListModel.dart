import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:photo_gallery/models/DTO/S3ItemDTO.dart';
import 'package:photo_gallery/models/DTO/dto_utils.dart';

part 'S3ItemListModel.freezed.dart';

@freezed
class S3ItemModel with _$S3ItemModel {
  const factory S3ItemModel({
    required String name,
    required String eTag,
    required int size,
    required String lastModified,
  }) = _S3ItemModel;
}

@freezed
class S3ItemListModel with _$S3ItemListModel {
  const factory S3ItemListModel({required List<S3ItemModel> items}) = _S3ItemListModel;

  factory S3ItemListModel.fromJson(dynamic json) {
    final dto = S3ItemListDTO.fromJson(json);
    final itemsDTO = dto.Contents;
    final items =
        itemsDTO
            .map((e) => S3ItemModel(name: e.Key, eTag: e.ETag, size: int.parse(e.Size), lastModified: e.LastModified))
            .toList();
    return S3ItemListModel(items: items);
  }
}

@freezed
class S3ItemListDTO with _$S3ItemListDTO {
  const factory S3ItemListDTO({required List<S3ItemDTO> Contents}) = _S3ItemListDTO;

  factory S3ItemListDTO.fromJson(dynamic json) {
    final contentsJson = json['ListBucketResult']['Contents'];
    if (contentsJson == null) {
      return S3ItemListDTO(Contents: []);
    }
    return S3ItemListDTO(Contents: parseS3ItemList(contentsJson, S3ItemDTO.fromJson));
  }
}
