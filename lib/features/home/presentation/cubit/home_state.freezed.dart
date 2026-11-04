// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeState {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'HomeState()';
}


}

/// @nodoc
class $HomeStateCopyWith<$Res>  {
$HomeStateCopyWith(HomeState _, $Res Function(HomeState) __);
}


/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Success value)?  success,TResult Function( _Failed value)?  failed,TResult Function( _Refreshing value)?  refreshing,TResult Function( _RefreshFailed value)?  refreshFailed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Success() when success != null:
return success(_that);case _Failed() when failed != null:
return failed(_that);case _Refreshing() when refreshing != null:
return refreshing(_that);case _RefreshFailed() when refreshFailed != null:
return refreshFailed(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Success value)  success,required TResult Function( _Failed value)  failed,required TResult Function( _Refreshing value)  refreshing,required TResult Function( _RefreshFailed value)  refreshFailed,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Success():
return success(_that);case _Failed():
return failed(_that);case _Refreshing():
return refreshing(_that);case _RefreshFailed():
return refreshFailed(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Success value)?  success,TResult? Function( _Failed value)?  failed,TResult? Function( _Refreshing value)?  refreshing,TResult? Function( _RefreshFailed value)?  refreshFailed,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Success() when success != null:
return success(_that);case _Failed() when failed != null:
return failed(_that);case _Refreshing() when refreshing != null:
return refreshing(_that);case _RefreshFailed() when refreshFailed != null:
return refreshFailed(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( HomeResponseModel data)?  success,TResult Function( HomeFailureType failure,  bool isRetrying)?  failed,TResult Function( HomeResponseModel data)?  refreshing,TResult Function( HomeResponseModel data,  HomeFailureType failure)?  refreshFailed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Success() when success != null:
return success(_that.data);case _Failed() when failed != null:
return failed(_that.failure,_that.isRetrying);case _Refreshing() when refreshing != null:
return refreshing(_that.data);case _RefreshFailed() when refreshFailed != null:
return refreshFailed(_that.data,_that.failure);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( HomeResponseModel data)  success,required TResult Function( HomeFailureType failure,  bool isRetrying)  failed,required TResult Function( HomeResponseModel data)  refreshing,required TResult Function( HomeResponseModel data,  HomeFailureType failure)  refreshFailed,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Success():
return success(_that.data);case _Failed():
return failed(_that.failure,_that.isRetrying);case _Refreshing():
return refreshing(_that.data);case _RefreshFailed():
return refreshFailed(_that.data,_that.failure);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( HomeResponseModel data)?  success,TResult? Function( HomeFailureType failure,  bool isRetrying)?  failed,TResult? Function( HomeResponseModel data)?  refreshing,TResult? Function( HomeResponseModel data,  HomeFailureType failure)?  refreshFailed,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Success() when success != null:
return success(_that.data);case _Failed() when failed != null:
return failed(_that.failure,_that.isRetrying);case _Refreshing() when refreshing != null:
return refreshing(_that.data);case _RefreshFailed() when refreshFailed != null:
return refreshFailed(_that.data,_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements HomeState {
  const _Initial();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'HomeState.initial()';
}


}




/// @nodoc


class _Loading implements HomeState {
  const _Loading();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'HomeState.loading()';
}


}




/// @nodoc


class _Success implements HomeState {
  const _Success(this.data);
  

 final  HomeResponseModel data;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuccessCopyWith<_Success> get copyWith => __$SuccessCopyWithImpl<_Success>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Success&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode {
    return Object.hash(runtimeType,data);
}

@override
String toString() {
    return 'HomeState.success(data: $data)';
}


}

/// @nodoc
abstract mixin class _$SuccessCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$SuccessCopyWith(_Success value, $Res Function(_Success) _then) = __$SuccessCopyWithImpl;
@useResult
$Res call({
 HomeResponseModel data
});




}
/// @nodoc
class __$SuccessCopyWithImpl<$Res>
    implements _$SuccessCopyWith<$Res> {
  __$SuccessCopyWithImpl(this._self, this._then);

  final _Success _self;
  final $Res Function(_Success) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_Success(
null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as HomeResponseModel,
  ));
}


}

/// @nodoc


class _Failed implements HomeState {
  const _Failed(this.failure, {this.isRetrying = false});
  

 final  HomeFailureType failure;
@JsonKey() final  bool isRetrying;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FailedCopyWith<_Failed> get copyWith => __$FailedCopyWithImpl<_Failed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Failed&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.isRetrying, isRetrying) || other.isRetrying == isRetrying));
}


@override
int get hashCode {
    return Object.hash(runtimeType,failure,isRetrying);
}

@override
String toString() {
    return 'HomeState.failed(failure: $failure, isRetrying: $isRetrying)';
}


}

/// @nodoc
abstract mixin class _$FailedCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$FailedCopyWith(_Failed value, $Res Function(_Failed) _then) = __$FailedCopyWithImpl;
@useResult
$Res call({
 HomeFailureType failure, bool isRetrying
});




}
/// @nodoc
class __$FailedCopyWithImpl<$Res>
    implements _$FailedCopyWith<$Res> {
  __$FailedCopyWithImpl(this._self, this._then);

  final _Failed _self;
  final $Res Function(_Failed) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,Object? isRetrying = null,}) {
  return _then(_Failed(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as HomeFailureType,isRetrying: null == isRetrying ? _self.isRetrying : isRetrying // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _Refreshing implements HomeState {
  const _Refreshing(this.data);
  

 final  HomeResponseModel data;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefreshingCopyWith<_Refreshing> get copyWith => __$RefreshingCopyWithImpl<_Refreshing>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Refreshing&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode {
    return Object.hash(runtimeType,data);
}

@override
String toString() {
    return 'HomeState.refreshing(data: $data)';
}


}

/// @nodoc
abstract mixin class _$RefreshingCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$RefreshingCopyWith(_Refreshing value, $Res Function(_Refreshing) _then) = __$RefreshingCopyWithImpl;
@useResult
$Res call({
 HomeResponseModel data
});




}
/// @nodoc
class __$RefreshingCopyWithImpl<$Res>
    implements _$RefreshingCopyWith<$Res> {
  __$RefreshingCopyWithImpl(this._self, this._then);

  final _Refreshing _self;
  final $Res Function(_Refreshing) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_Refreshing(
null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as HomeResponseModel,
  ));
}


}

/// @nodoc


class _RefreshFailed implements HomeState {
  const _RefreshFailed(this.data, this.failure);
  

 final  HomeResponseModel data;
 final  HomeFailureType failure;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RefreshFailedCopyWith<_RefreshFailed> get copyWith => __$RefreshFailedCopyWithImpl<_RefreshFailed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RefreshFailed&&(identical(other.data, data) || other.data == data)&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode {
    return Object.hash(runtimeType,data,failure);
}

@override
String toString() {
    return 'HomeState.refreshFailed(data: $data, failure: $failure)';
}


}

/// @nodoc
abstract mixin class _$RefreshFailedCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$RefreshFailedCopyWith(_RefreshFailed value, $Res Function(_RefreshFailed) _then) = __$RefreshFailedCopyWithImpl;
@useResult
$Res call({
 HomeResponseModel data, HomeFailureType failure
});




}
/// @nodoc
class __$RefreshFailedCopyWithImpl<$Res>
    implements _$RefreshFailedCopyWith<$Res> {
  __$RefreshFailedCopyWithImpl(this._self, this._then);

  final _RefreshFailed _self;
  final $Res Function(_RefreshFailed) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,Object? failure = null,}) {
  return _then(_RefreshFailed(
null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as HomeResponseModel,null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as HomeFailureType,
  ));
}


}

// dart format on
