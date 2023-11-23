import 'package:dio/dio.dart';

class TMapApi {
  static const KEY = 'F4QBZ-2TE6J-O3IFL-XUVAD-65HQ6-N4BFS';
  static Dio _getHttp() {
    var dio = Dio();

    dio.options.baseUrl = 'https://apis.map.qq.com/ws';

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.queryParameters['key'] = KEY;
        print('options -> ${options.queryParameters}');
        return handler.next(options);
      },
      onResponse: (e, handler) {
        print('e -> $e');
        if (e.data == null) {
          return handler.next(e);
        }
        if (e.data is Map) {
          if (e.data['status'] != 0) {
            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                response: e,
                error: e.data,
                message: e.data['message'],
              ),
              true,
            );
          } else {
            return handler.next(e);
          }
        }
        return handler.next(e);
      },
    ));

    return dio;
  }

  static get http => _getHttp();

  // suggestion
  static Future<List?> suggestion(
    String keyword, {
    Map<String, dynamic>? params,
  }) async {
    var res = await http.get('/place/v1/suggestion', queryParameters: {
      'keyword': keyword,
      ...(params ?? {}),
    });
    return res.data?['data'];
  }

  // geocoder
  static Future<Map?> geocoder(
    String location, {
    Map<String, dynamic>? params,
  }) async {
    var res = await http.get('/geocoder/v1', queryParameters: {
      'location': location,
      ...(params ?? {}),
    });
    return res.data?['result'];
  }
}
