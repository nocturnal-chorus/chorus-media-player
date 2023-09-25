// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_SongListResponse _$$_SongListResponseFromJson(Map<String, dynamic> json) =>
    _$_SongListResponse(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => e == null
              ? null
              : SongDetails.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int?,
    );

Map<String, dynamic> _$$_SongListResponseToJson(_$_SongListResponse instance) =>
    <String, dynamic>{
      'items': instance.items,
      'total': instance.total,
    };
