import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:intl/intl.dart';
import 'package:xml2json/xml2json.dart';

import 'http_datasource.dart';

enum S3UrlStyle { virtualHostedStyle, pathStyle }

/// Datasource that enables access to an S3 bucket.
///
/// Handles authentication with AWS Signature Version 4, using the provided [clientId] and [clientSecret].
///
/// The S3 endpoint is determined by the [s3Host] parameter.
///
/// The [bucketName] parameter is used to construct the S3 URL.
///
/// The [urlStyle] parameter is used to determine the S3 URL style.
///
/// The [httpService] parameter is used to send requests to S3.
///
///
/// See: https://docs.aws.amazon.com/AmazonS3/latest/userguide/RESTAuthentication.html
///
/// NOTE: This class is not a real S3 client. It only supports the operations that are needed by this package.
///       If you need a full S3 client, please use the official AWS SDK.
class S3Datasource extends HttpDatasource {
  final String s3Host;
  final String region;
  final String clientId;
  final String clientSecret;
  final String bucketName;
  final S3UrlStyle urlStyle;

  static const algorithm = "AWS4-HMAC-SHA256";
  static const requestType = "aws4_request";
  static const service = "s3";

  /// Creates a S3 datasource with virtual hosted style url.
  ///
  /// Virtual hosted style url looks like this: https://bucketname.s3.amazonaws.com/keyname
  ///
  /// See more : https://docs.aws.amazon.com/AmazonS3/latest/userguide/VirtualHosting.html#virtual-hosted-style-access
  ///
  /// The [s3Host] should be the host of S3 without the bucket name. E.g. s3.amazonaws.com, 80.99.123.12:8080.
  ///
  /// The [clientId] and [clientSecret] are the access key and secret key of the S3 account.
  S3Datasource.virtualHostedStyle({
    required this.s3Host,
    required this.region,
    required this.clientId,
    required this.clientSecret,
    required this.bucketName,
  }) : urlStyle = S3UrlStyle.virtualHostedStyle,
       super(httpService: HttpService(baseUrl: 'https://$bucketName.$s3Host'));

  /// Creates a S3 datasource with path style url.
  ///
  /// Path style url looks like this: https://s3.amazonaws.com/bucketname/keyname
  ///
  /// See more : https://docs.aws.amazon.com/AmazonS3/latest/userguide/VirtualHosting.html#path-style-access
  ///
  /// The [s3Host] should be the host of S3 without the bucket name. E.g. s3.amazonaws.com, 80.99.123.12:8080.
  ///
  /// The [clientId] and [clientSecret] are the access key and secret key of the S3 account.
  S3Datasource.pathStyle({
    required this.s3Host,
    required this.region,
    required this.clientId,
    required this.clientSecret,
    required this.bucketName,
  }) : urlStyle = S3UrlStyle.pathStyle,
       super(httpService: HttpService(baseUrl: 'https://$s3Host/$bucketName'));

  Future<T> request<T>(
    HttpMethod method,
    String path,
    FromJson<T> fromJson, {
    HttpOptions? options,
    String? data,
    bool? throwOnError,
  }) async {
    throwOnError = throwOnError ?? true;
    options = options ?? HttpOptions();
    final signature = _signUrl(method, path, data, options);
    options = options.copyWith(
      headers: {...options.headers ?? {}, ...signature},
    );
    final response = await httpService.request(method, path, options: options);
    if (throwOnError) {
      httpService.throwOnError(response);
    }
    final xml2json = Xml2Json();
    xml2json.parse(response.body);
    final jsonData = xml2json.toParker();
    return fromJson(jsonDecode(jsonData));
  }

  Future<File> getFile(
    String path,
    String outputPath, {
    HttpOptions? options,
    String? data,
    bool? throwOnError,
  }) async {
    throwOnError = throwOnError ?? true;
    options = options ?? HttpOptions();
    final signature = _signUrl(HttpMethod.GET, path, data, options);
    options = options.copyWith(
      headers: {...options.headers ?? {}, ...signature},
    );
    final response = await httpService.requestWithStreamResponse(
      HttpMethod.GET,
      path,
      options: options,
    );
    if (throwOnError) {
      httpService.throwOnError(response);
    }
    final file = await File(outputPath).create(recursive: true);
    final writer = file.openWrite();
    await response.stream.pipe(writer);
    await writer.flush();
    await writer.close();
    return file;
  }

  Future sendFile(
    String path,
    File file, {
    HttpOptions? options,
    bool? throwOnError,
  }) async {
    throwOnError = throwOnError ?? true;
    options = options ?? HttpOptions();
    final signature = _signUrl(HttpMethod.PUT, path, null, options);
    options = options.copyWith(
      headers: {...options.headers ?? {}, ...signature},
    );

    final response = await httpService.streamRequest(
      HttpMethod.PUT,
      path,
      length: file.lengthSync(),
      stream: file.openRead(),
      options: options,
    );
    print("Resonse ${response.statusCode} $response");
    if (throwOnError) {
      httpService.throwOnError(response);
    }
    return null;
  }

  @override
  Future<T> get<T>(
    String path,
    FromJson<T> fromJson, {
    HttpOptions? options,
    bool? throwOnError,
  }) => request(
    HttpMethod.GET,
    path,
    fromJson,
    options: options,
    throwOnError: throwOnError,
  );

  @override
  Future<T> post<T>(
    String path,
    FromJson<T> fromJson,
    dynamic data, {
    HttpOptions? options,
    bool? throwOnError,
  }) => request(
    HttpMethod.POST,
    path,
    fromJson,
    data: data,
    options: options,
    throwOnError: throwOnError,
  );

  @override
  Future<T> put<T>(
    String path,
    FromJson<T> fromJson,
    dynamic data, {
    HttpOptions? options,
    bool? throwOnError,
  }) => request(
    HttpMethod.PUT,
    path,
    fromJson,
    data: data,
    options: options,
    throwOnError: throwOnError,
  );

  @override
  Future<T> patch<T>(
    String path,
    FromJson<T> fromJson,
    dynamic data, {
    HttpOptions? options,
    bool? throwOnError,
  }) => request(
    HttpMethod.PATCH,
    path,
    fromJson,
    data: data,
    options: options,
    throwOnError: throwOnError,
  );

  @override
  Future<T> delete<T>(
    String path,
    FromJson<T> fromJson,
    dynamic data, {
    HttpOptions? options,
    bool? throwOnError,
  }) => request(
    HttpMethod.DELETE,
    path,
    fromJson,
    data: data,
    options: options,
    throwOnError: throwOnError,
  );

  String _makeCanonicalHeadersString(Map<String, String> headers) {
    return headers.entries
        .map((e) => "${e.key.toLowerCase()}:${e.value.trim()}\n")
        .join();
  }

  Map<String, String> _signUrl(
    HttpMethod method,
    String path,
    String? data,
    HttpOptions options,
  ) {
    final date = DateTime.now().toUtc();
    final specialFormattedDate = date
        .toIso8601String()
        .replaceAll("-", "")
        .replaceAll(":", "")
        .replaceAll(RegExp("\\.\\d+Z"), "Z");
    final DateFormat dateFormatter = DateFormat('yyyyMMdd');

    final scope = "${dateFormatter.format(date)}/$region/$service/$requestType";
    final signedHeaders = "host;x-amz-content-sha256;x-amz-date";
    final payloadHash = crypto.sha256
        .convert(utf8.encode(data ?? ""))
        .toString();
    final url = httpService.buildUri(path, options);
    final canonicalHeaders = {
      "host": s3Host,
      "x-amz-content-sha256": payloadHash,
      "x-amz-date": specialFormattedDate,
    };
    final canonicalRequest =
        "${method.name}\n${url.path}\n${url.query}\n${_makeCanonicalHeadersString(canonicalHeaders)}\n$signedHeaders\n$payloadHash";
    final stringToSign =
        "$algorithm\n$specialFormattedDate\n$scope\n${crypto.sha256.convert(utf8.encode(canonicalRequest))}";
    final dateKey = crypto.Hmac(
      crypto.sha256,
      utf8.encode("AWS4$clientSecret"),
    ).convert(utf8.encode(dateFormatter.format(date))).bytes;
    final regionKey = crypto.Hmac(
      crypto.sha256,
      dateKey,
    ).convert(utf8.encode(region)).bytes;
    final serviceKey = crypto.Hmac(
      crypto.sha256,
      regionKey,
    ).convert(utf8.encode(service)).bytes;
    final signingKey = crypto.Hmac(
      crypto.sha256,
      serviceKey,
    ).convert(utf8.encode(requestType)).bytes;
    final signature = crypto.Hmac(
      crypto.sha256,
      signingKey,
    ).convert(utf8.encode(stringToSign));

    return {
      "Authorization":
          "$algorithm Credential=$clientId/$scope, SignedHeaders=$signedHeaders, Signature=$signature",
      ...canonicalHeaders,
    };
  }
}
