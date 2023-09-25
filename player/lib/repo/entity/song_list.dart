import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:player/repo/entity/song_detail.dart';

part 'song_list.g.dart';

part 'song_list.freezed.dart';

@freezed
class SongListResponse with _$SongListResponse {
  const factory SongListResponse({
    final List<SongDetails?>? items,
    final int? total,
  }) = _SongListResponse;

  factory SongListResponse.fromJson(Map<String, Object?> json) =>
      _$SongListResponseFromJson(json);
}
