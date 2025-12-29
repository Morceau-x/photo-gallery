import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;

part 'http_datasource.freezed.dart';
part 'http_datasource.g.dart';

typedef FromJson<T> = T Function(dynamic json);

abstract class HttpDatasource {
  HttpService httpService;
  HttpDatasource({required this.httpService});

  Future<T> get<T>(String path, FromJson<T> fromJson, {HttpOptions? options, bool throwOnError});
  Future<T> post<T>(String path, FromJson<T> fromJson, dynamic data, {HttpOptions? options, bool throwOnError});
  Future<T> put<T>(String path, FromJson<T> fromJson, dynamic data, {HttpOptions? options, bool throwOnError});
  Future<T> patch<T>(String path, FromJson<T> fromJson, dynamic data, {HttpOptions? options, bool throwOnError});
  Future<T> delete<T>(String path, FromJson<T> fromJson, dynamic data, {HttpOptions? options, bool throwOnError});
}

enum HttpMethod { GET, POST, PUT, DELETE, PATCH }

@freezed
class HttpOptions with _$HttpOptions {
  const factory HttpOptions({
    final Map<String, String>? headers,
    final Map<String, dynamic>? queryParameters,
    final String? fragment,
  }) = _HttpOptions;

  factory HttpOptions.fromJson(Map<String, dynamic> json) => _$HttpOptionsFromJson(json);
}

const emptyHttpOptions = HttpOptions();

class HttpService {
  final String baseUrl;

  HttpService({required this.baseUrl});

  Future request(HttpMethod method, String path, {dynamic body, HttpOptions? options}) async {
    switch (method) {
      case HttpMethod.GET:
        return get(path, options: options);
      case HttpMethod.POST:
        return post(path, body: body, options: options);
      case HttpMethod.PUT:
        return put(path, body: body, options: options);
      case HttpMethod.DELETE:
        return delete(path, body: body, options: options);
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }

  Future get(String path, {HttpOptions? options}) async {
    final Uri url = buildUri(path, options ?? emptyHttpOptions);
    return await http.get(url, headers: options?.headers);
  }

  Future post(String path, {dynamic body, HttpOptions? options}) async {
    final Uri url = buildUri(path, options ?? emptyHttpOptions);
    return await http.post(url, headers: options?.headers, body: body);
  }

  Future put(String path, {dynamic body, HttpOptions? options}) async {
    final Uri url = buildUri(path, options ?? emptyHttpOptions);
    return await http.put(url, headers: options?.headers, body: body);
  }

  Future delete(String path, {dynamic body, HttpOptions? options}) async {
    final Uri url = buildUri(path, options ?? emptyHttpOptions);
    return await http.delete(url, headers: options?.headers, body: body);
  }

  Uri buildUri(String path, HttpOptions options) {
    var uri = Uri.parse(baseUrl);
    uri = uri.replace(queryParameters: options.queryParameters, fragment: options.fragment);
    uri = uri.replace(path: _joinPath(uri, path));
    return Uri.parse(baseUrl + path).replace(fragment: options.fragment, queryParameters: options.queryParameters);
  }

  String _joinPath(Uri uri, String path) {
    return uri.pathSegments.join("/") + (path.startsWith('/') ? path : '/$path');
  }

  void throwOnError(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException('Request failed with status: ${response.statusCode}, body: ${response.body}');
    }
  }
}
