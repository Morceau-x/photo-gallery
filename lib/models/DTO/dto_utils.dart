import 'package:photo_gallery/io/datasource/http_datasource.dart';

parseS3ItemList<T>(dynamic json, FromJson<T> fromJson) {
  if (json is List) {
    return json.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  } else if (json is Map<String, dynamic>) {
    return [fromJson(json)];
  }
  throw UnsupportedError('Unsupported type: ${json.runtimeType}');
}
