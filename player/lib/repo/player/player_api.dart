import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'player_api.g.dart';

@RestApi(baseUrl: 'https://api.nocturnal-chorus.com/')
abstract class PlayerApi {
  factory PlayerApi(Dio dio, {String baseUrl}) = _PlayerApi;
}
