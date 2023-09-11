import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'song_detail.g.dart';

part 'song_detail.freezed.dart';

@freezed
class SongDetails with _$SongDetails {
  const factory SongDetails({
    final String? id,
    final String? name,
    final String? avatar,
  }) = _SongDetails;

  factory SongDetails.fromJson(Map<String, Object?> json) =>
      _$SongDetailsFromJson(json);
}
