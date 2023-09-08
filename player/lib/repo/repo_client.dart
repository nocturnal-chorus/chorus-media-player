import 'package:player/repo/player/player_client.dart';

typedef ApiCall<T> = Future<T?> Function();

abstract class DataClient {
  factory DataClient() {
    return PlayerClient();
  }

  init();
}
