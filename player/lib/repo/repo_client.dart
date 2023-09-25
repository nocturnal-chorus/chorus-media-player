import 'package:player/repo/entity/song_list.dart';
import 'package:player/repo/player/player_client.dart';
import 'entity/basic_response.dart';

typedef ApiCall<T> = Future<T?> Function();

abstract class DataClient {
  factory DataClient() {
    return PlayerClient();
  }

  init();

  Future<CommonResponse<SongListResponse?>>? requestSongList();
}
