import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../entity/song_list.dart';

part 'player_api.g.dart';

@RestApi(baseUrl: 'https://consumer-api.nocturnal-chorus.com/')
abstract class PlayerApi {
  factory PlayerApi(Dio dio, {String baseUrl}) = _PlayerApi;

  @POST('v0/music')
  Future<SongListResponse> requestSongList(
    @Header('Content-Type') String contentType,
  );
}
