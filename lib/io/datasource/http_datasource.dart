// ignore_for_file: constant_identifier_names
import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;

part 'http_datasource.freezed.dart';
part 'http_datasource.g.dart';

typedef FromJson<T> = T Function(dynamic json);

abstract class HttpDatasource {
  HttpService httpService;
  HttpDatasource({required this.httpService});

  Future<T> get<T>(
    String path,
    FromJson<T> fromJson, {
    HttpOptions? options,
    bool throwOnError,
  });
  Future<T> post<T>(
    String path,
    FromJson<T> fromJson,
    dynamic data, {
    HttpOptions? options,
    bool throwOnError,
  });
  Future<T> put<T>(
    String path,
    FromJson<T> fromJson,
    dynamic data, {
    HttpOptions? options,
    bool throwOnError,
  });
  Future<T> patch<T>(
    String path,
    FromJson<T> fromJson,
    dynamic data, {
    HttpOptions? options,
    bool throwOnError,
  });
  Future<T> delete<T>(
    String path,
    FromJson<T> fromJson,
    dynamic data, {
    HttpOptions? options,
    bool throwOnError,
  });
}

enum HttpMethod { GET, POST, PUT, DELETE, PATCH }

@freezed
abstract class HttpOptions with _$HttpOptions {
  const factory HttpOptions({
    final Map<String, String>? headers,
    final Map<String, dynamic>? queryParameters,
    final String? fragment,
  }) = _HttpOptions;

  factory HttpOptions.fromJson(Map<String, dynamic> json) =>
      _$HttpOptionsFromJson(json);
}

const emptyHttpOptions = HttpOptions();

class HttpService {
  final String baseUrl;

  HttpService({required this.baseUrl});

  Future<http.Response> request(
    HttpMethod method,
    String path, {
    dynamic body,
    HttpOptions? options,
  }) async {
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

  Future<http.StreamedResponse> requestWithStreamResponse(
    HttpMethod method,
    String path, {
    dynamic body,
    HttpOptions? options,
  }) async {
    final Uri url = buildUri(path, options ?? emptyHttpOptions);
    var request = http.Request(method.name, url);
    request.headers.addAll(options?.headers ?? {});
    request.body = body.toString();
    return await request.send();
  }

  Future<http.StreamedResponse> streamRequest(
    HttpMethod method,
    String path, {
    required Stream<List<int>> stream,
    required int length,
    HttpOptions? options,
  }) async {
    final Uri url = buildUri(path, options ?? emptyHttpOptions);
    var request = http.StreamedRequest(method.name, url);
    print("Req $request, url: $url, path: $path, length: $length");

    request.contentLength = length;
    request.headers.addAll(options?.headers ?? {});
    request.headers["content-type"] = "application/octet-stream";
    print("Headers ${request.headers}");
    print("Stream request $request");

    try {
      final futureResponse = request.send();
      await request.sink.addStream(stream);
      await request.sink.close();
      return await futureResponse;
    } catch (e) {
      print("Error $e");
      rethrow;
    }
  }

  Future<http.Response> get(String path, {HttpOptions? options}) async {
    final Uri url = buildUri(path, options ?? emptyHttpOptions);

    return await http.get(url, headers: options?.headers);
  }

  Future<http.Response> post(
    String path, {
    dynamic body,
    HttpOptions? options,
  }) async {
    final Uri url = buildUri(path, options ?? emptyHttpOptions);
    return await http.post(url, headers: options?.headers, body: body);
  }

  Future<http.Response> put(
    String path, {
    dynamic body,
    HttpOptions? options,
  }) async {
    final Uri url = buildUri(path, options ?? emptyHttpOptions);
    return await http.put(url, headers: options?.headers, body: body);
  }

  Future<http.Response> delete(
    String path, {
    dynamic body,
    HttpOptions? options,
  }) async {
    final Uri url = buildUri(path, options ?? emptyHttpOptions);
    return await http.delete(url, headers: options?.headers, body: body);
  }

  Uri buildUri(String path, HttpOptions options) {
    var uri = Uri.parse(baseUrl);
    uri = uri.replace(
      queryParameters: options.queryParameters,
      fragment: options.fragment,
    );
    uri = uri.replace(path: _joinPath(uri, path));
    return uri;
  }

  String _joinPath(Uri uri, String path) {
    return uri.pathSegments.join("/") +
        (path.startsWith('/') ? path : '/$path');
  }

  void throwOnError(http.BaseResponse response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException(
        'Request failed with status: ${response.statusCode}, type: ${response.runtimeType}',
      );
    }
  }
}
