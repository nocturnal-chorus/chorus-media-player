// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SongDetails _$SongDetailsFromJson(Map<String, dynamic> json) {
  return _SongDetails.fromJson(json);
}

/// @nodoc
mixin _$SongDetails {
  String? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SongDetailsCopyWith<SongDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SongDetailsCopyWith<$Res> {
  factory $SongDetailsCopyWith(
          SongDetails value, $Res Function(SongDetails) then) =
      _$SongDetailsCopyWithImpl<$Res, SongDetails>;
  @useResult
  $Res call({String? id, String? name, String? avatar});
}

/// @nodoc
class _$SongDetailsCopyWithImpl<$Res, $Val extends SongDetails>
    implements $SongDetailsCopyWith<$Res> {
  _$SongDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? avatar = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_SongDetailsCopyWith<$Res>
    implements $SongDetailsCopyWith<$Res> {
  factory _$$_SongDetailsCopyWith(
          _$_SongDetails value, $Res Function(_$_SongDetails) then) =
      __$$_SongDetailsCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? id, String? name, String? avatar});
}

/// @nodoc
class __$$_SongDetailsCopyWithImpl<$Res>
    extends _$SongDetailsCopyWithImpl<$Res, _$_SongDetails>
    implements _$$_SongDetailsCopyWith<$Res> {
  __$$_SongDetailsCopyWithImpl(
      _$_SongDetails _value, $Res Function(_$_SongDetails) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? avatar = freezed,
  }) {
    return _then(_$_SongDetails(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      avatar: freezed == avatar
          ? _value.avatar
          : avatar // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_SongDetails with DiagnosticableTreeMixin implements _SongDetails {
  const _$_SongDetails({this.id, this.name, this.avatar});

  factory _$_SongDetails.fromJson(Map<String, dynamic> json) =>
      _$$_SongDetailsFromJson(json);

  @override
  final String? id;
  @override
  final String? name;
  @override
  final String? avatar;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SongDetails(id: $id, name: $name, avatar: $avatar)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SongDetails'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('avatar', avatar));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SongDetails &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatar, avatar) || other.avatar == avatar));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, avatar);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SongDetailsCopyWith<_$_SongDetails> get copyWith =>
      __$$_SongDetailsCopyWithImpl<_$_SongDetails>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_SongDetailsToJson(
      this,
    );
  }
}

abstract class _SongDetails implements SongDetails {
  const factory _SongDetails(
      {final String? id,
      final String? name,
      final String? avatar}) = _$_SongDetails;

  factory _SongDetails.fromJson(Map<String, dynamic> json) =
      _$_SongDetails.fromJson;

  @override
  String? get id;
  @override
  String? get name;
  @override
  String? get avatar;
  @override
  @JsonKey(ignore: true)
  _$$_SongDetailsCopyWith<_$_SongDetails> get copyWith =>
      throw _privateConstructorUsedError;
}
