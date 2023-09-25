// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SongListResponse _$SongListResponseFromJson(Map<String, dynamic> json) {
  return _SongListResponse.fromJson(json);
}

/// @nodoc
mixin _$SongListResponse {
  List<SongDetails?>? get items => throw _privateConstructorUsedError;

  int? get total => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SongListResponseCopyWith<SongListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SongListResponseCopyWith<$Res> {
  factory $SongListResponseCopyWith(
          SongListResponse value, $Res Function(SongListResponse) then) =
      _$SongListResponseCopyWithImpl<$Res, SongListResponse>;

  @useResult
  $Res call({List<SongDetails?>? items, int? total});
}

/// @nodoc
class _$SongListResponseCopyWithImpl<$Res, $Val extends SongListResponse>
    implements $SongListResponseCopyWith<$Res> {
  _$SongListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;

  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = freezed,
    Object? total = freezed,
  }) {
    return _then(_value.copyWith(
      items: freezed == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<SongDetails?>?,
      total: freezed == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_SongListResponseCopyWith<$Res>
    implements $SongListResponseCopyWith<$Res> {
  factory _$$_SongListResponseCopyWith(
          _$_SongListResponse value, $Res Function(_$_SongListResponse) then) =
      __$$_SongListResponseCopyWithImpl<$Res>;

  @override
  @useResult
  $Res call({List<SongDetails?>? items, int? total});
}

/// @nodoc
class __$$_SongListResponseCopyWithImpl<$Res>
    extends _$SongListResponseCopyWithImpl<$Res, _$_SongListResponse>
    implements _$$_SongListResponseCopyWith<$Res> {
  __$$_SongListResponseCopyWithImpl(
      _$_SongListResponse _value, $Res Function(_$_SongListResponse) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = freezed,
    Object? total = freezed,
  }) {
    return _then(_$_SongListResponse(
      items: freezed == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<SongDetails?>?,
      total: freezed == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_SongListResponse
    with DiagnosticableTreeMixin
    implements _SongListResponse {
  const _$_SongListResponse({final List<SongDetails?>? items, this.total})
      : _items = items;

  factory _$_SongListResponse.fromJson(Map<String, dynamic> json) =>
      _$$_SongListResponseFromJson(json);

  final List<SongDetails?>? _items;

  @override
  List<SongDetails?>? get items {
    final value = _items;
    if (value == null) return null;
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? total;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SongListResponse(items: $items, total: $total)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SongListResponse'))
      ..add(DiagnosticsProperty('items', items))
      ..add(DiagnosticsProperty('total', total));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SongListResponse &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_items), total);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SongListResponseCopyWith<_$_SongListResponse> get copyWith =>
      __$$_SongListResponseCopyWithImpl<_$_SongListResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_SongListResponseToJson(
      this,
    );
  }
}

abstract class _SongListResponse implements SongListResponse {
  const factory _SongListResponse(
      {final List<SongDetails?>? items,
      final int? total}) = _$_SongListResponse;

  factory _SongListResponse.fromJson(Map<String, dynamic> json) =
      _$_SongListResponse.fromJson;

  @override
  List<SongDetails?>? get items;

  @override
  int? get total;

  @override
  @JsonKey(ignore: true)
  _$$_SongListResponseCopyWith<_$_SongListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}
