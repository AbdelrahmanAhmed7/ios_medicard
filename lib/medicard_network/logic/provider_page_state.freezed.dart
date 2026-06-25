// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'provider_page_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProviderPageState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderPageState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProviderPageState()';
}


}

/// @nodoc
class $ProviderPageStateCopyWith<$Res>  {
$ProviderPageStateCopyWith(ProviderPageState _, $Res Function(ProviderPageState) __);
}


/// Adds pattern-matching-related methods to [ProviderPageState].
extension ProviderPageStatePatterns on ProviderPageState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _ProviderLoading value)?  providerLoading,TResult Function( _ProviderSuccess value)?  providerSuccess,TResult Function( _ProviderFailed value)?  providerFailed,TResult Function( _ServicesLoading value)?  servicesLoading,TResult Function( _ServicesSuccess value)?  servicesSuccess,TResult Function( _ServicesFailed value)?  servicesFailed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _ProviderLoading() when providerLoading != null:
return providerLoading(_that);case _ProviderSuccess() when providerSuccess != null:
return providerSuccess(_that);case _ProviderFailed() when providerFailed != null:
return providerFailed(_that);case _ServicesLoading() when servicesLoading != null:
return servicesLoading(_that);case _ServicesSuccess() when servicesSuccess != null:
return servicesSuccess(_that);case _ServicesFailed() when servicesFailed != null:
return servicesFailed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _ProviderLoading value)  providerLoading,required TResult Function( _ProviderSuccess value)  providerSuccess,required TResult Function( _ProviderFailed value)  providerFailed,required TResult Function( _ServicesLoading value)  servicesLoading,required TResult Function( _ServicesSuccess value)  servicesSuccess,required TResult Function( _ServicesFailed value)  servicesFailed,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _ProviderLoading():
return providerLoading(_that);case _ProviderSuccess():
return providerSuccess(_that);case _ProviderFailed():
return providerFailed(_that);case _ServicesLoading():
return servicesLoading(_that);case _ServicesSuccess():
return servicesSuccess(_that);case _ServicesFailed():
return servicesFailed(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _ProviderLoading value)?  providerLoading,TResult? Function( _ProviderSuccess value)?  providerSuccess,TResult? Function( _ProviderFailed value)?  providerFailed,TResult? Function( _ServicesLoading value)?  servicesLoading,TResult? Function( _ServicesSuccess value)?  servicesSuccess,TResult? Function( _ServicesFailed value)?  servicesFailed,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _ProviderLoading() when providerLoading != null:
return providerLoading(_that);case _ProviderSuccess() when providerSuccess != null:
return providerSuccess(_that);case _ProviderFailed() when providerFailed != null:
return providerFailed(_that);case _ServicesLoading() when servicesLoading != null:
return servicesLoading(_that);case _ServicesSuccess() when servicesSuccess != null:
return servicesSuccess(_that);case _ServicesFailed() when servicesFailed != null:
return servicesFailed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  providerLoading,TResult Function( ProviderPageData data)?  providerSuccess,TResult Function( String error)?  providerFailed,TResult Function()?  servicesLoading,TResult Function( List<ProviderService> services,  bool hasMore,  bool isLoadingMore)?  servicesSuccess,TResult Function( String error)?  servicesFailed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _ProviderLoading() when providerLoading != null:
return providerLoading();case _ProviderSuccess() when providerSuccess != null:
return providerSuccess(_that.data);case _ProviderFailed() when providerFailed != null:
return providerFailed(_that.error);case _ServicesLoading() when servicesLoading != null:
return servicesLoading();case _ServicesSuccess() when servicesSuccess != null:
return servicesSuccess(_that.services,_that.hasMore,_that.isLoadingMore);case _ServicesFailed() when servicesFailed != null:
return servicesFailed(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  providerLoading,required TResult Function( ProviderPageData data)  providerSuccess,required TResult Function( String error)  providerFailed,required TResult Function()  servicesLoading,required TResult Function( List<ProviderService> services,  bool hasMore,  bool isLoadingMore)  servicesSuccess,required TResult Function( String error)  servicesFailed,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _ProviderLoading():
return providerLoading();case _ProviderSuccess():
return providerSuccess(_that.data);case _ProviderFailed():
return providerFailed(_that.error);case _ServicesLoading():
return servicesLoading();case _ServicesSuccess():
return servicesSuccess(_that.services,_that.hasMore,_that.isLoadingMore);case _ServicesFailed():
return servicesFailed(_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  providerLoading,TResult? Function( ProviderPageData data)?  providerSuccess,TResult? Function( String error)?  providerFailed,TResult? Function()?  servicesLoading,TResult? Function( List<ProviderService> services,  bool hasMore,  bool isLoadingMore)?  servicesSuccess,TResult? Function( String error)?  servicesFailed,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _ProviderLoading() when providerLoading != null:
return providerLoading();case _ProviderSuccess() when providerSuccess != null:
return providerSuccess(_that.data);case _ProviderFailed() when providerFailed != null:
return providerFailed(_that.error);case _ServicesLoading() when servicesLoading != null:
return servicesLoading();case _ServicesSuccess() when servicesSuccess != null:
return servicesSuccess(_that.services,_that.hasMore,_that.isLoadingMore);case _ServicesFailed() when servicesFailed != null:
return servicesFailed(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements ProviderPageState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProviderPageState.initial()';
}


}




/// @nodoc


class _ProviderLoading implements ProviderPageState {
  const _ProviderLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProviderPageState.providerLoading()';
}


}




/// @nodoc


class _ProviderSuccess implements ProviderPageState {
  const _ProviderSuccess(this.data);
  

 final  ProviderPageData data;

/// Create a copy of ProviderPageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderSuccessCopyWith<_ProviderSuccess> get copyWith => __$ProviderSuccessCopyWithImpl<_ProviderSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderSuccess&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'ProviderPageState.providerSuccess(data: $data)';
}


}

/// @nodoc
abstract mixin class _$ProviderSuccessCopyWith<$Res> implements $ProviderPageStateCopyWith<$Res> {
  factory _$ProviderSuccessCopyWith(_ProviderSuccess value, $Res Function(_ProviderSuccess) _then) = __$ProviderSuccessCopyWithImpl;
@useResult
$Res call({
 ProviderPageData data
});




}
/// @nodoc
class __$ProviderSuccessCopyWithImpl<$Res>
    implements _$ProviderSuccessCopyWith<$Res> {
  __$ProviderSuccessCopyWithImpl(this._self, this._then);

  final _ProviderSuccess _self;
  final $Res Function(_ProviderSuccess) _then;

/// Create a copy of ProviderPageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(_ProviderSuccess(
null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as ProviderPageData,
  ));
}


}

/// @nodoc


class _ProviderFailed implements ProviderPageState {
  const _ProviderFailed(this.error);
  

 final  String error;

/// Create a copy of ProviderPageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderFailedCopyWith<_ProviderFailed> get copyWith => __$ProviderFailedCopyWithImpl<_ProviderFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderFailed&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'ProviderPageState.providerFailed(error: $error)';
}


}

/// @nodoc
abstract mixin class _$ProviderFailedCopyWith<$Res> implements $ProviderPageStateCopyWith<$Res> {
  factory _$ProviderFailedCopyWith(_ProviderFailed value, $Res Function(_ProviderFailed) _then) = __$ProviderFailedCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class __$ProviderFailedCopyWithImpl<$Res>
    implements _$ProviderFailedCopyWith<$Res> {
  __$ProviderFailedCopyWithImpl(this._self, this._then);

  final _ProviderFailed _self;
  final $Res Function(_ProviderFailed) _then;

/// Create a copy of ProviderPageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_ProviderFailed(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _ServicesLoading implements ProviderPageState {
  const _ServicesLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServicesLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ProviderPageState.servicesLoading()';
}


}




/// @nodoc


class _ServicesSuccess implements ProviderPageState {
  const _ServicesSuccess({required  List<ProviderService> services, required this.hasMore, required this.isLoadingMore}): _services = services;
  

 final  List<ProviderService> _services;
 List<ProviderService> get services {
  if (_services is EqualUnmodifiableListView) return _services;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_services);
}

 final  bool hasMore;
 final  bool isLoadingMore;

/// Create a copy of ProviderPageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServicesSuccessCopyWith<_ServicesSuccess> get copyWith => __$ServicesSuccessCopyWithImpl<_ServicesSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServicesSuccess&&const DeepCollectionEquality().equals(other._services, _services)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_services),hasMore,isLoadingMore);

@override
String toString() {
  return 'ProviderPageState.servicesSuccess(services: $services, hasMore: $hasMore, isLoadingMore: $isLoadingMore)';
}


}

/// @nodoc
abstract mixin class _$ServicesSuccessCopyWith<$Res> implements $ProviderPageStateCopyWith<$Res> {
  factory _$ServicesSuccessCopyWith(_ServicesSuccess value, $Res Function(_ServicesSuccess) _then) = __$ServicesSuccessCopyWithImpl;
@useResult
$Res call({
 List<ProviderService> services, bool hasMore, bool isLoadingMore
});




}
/// @nodoc
class __$ServicesSuccessCopyWithImpl<$Res>
    implements _$ServicesSuccessCopyWith<$Res> {
  __$ServicesSuccessCopyWithImpl(this._self, this._then);

  final _ServicesSuccess _self;
  final $Res Function(_ServicesSuccess) _then;

/// Create a copy of ProviderPageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? services = null,Object? hasMore = null,Object? isLoadingMore = null,}) {
  return _then(_ServicesSuccess(
services: null == services ? _self._services : services // ignore: cast_nullable_to_non_nullable
as List<ProviderService>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _ServicesFailed implements ProviderPageState {
  const _ServicesFailed(this.error);
  

 final  String error;

/// Create a copy of ProviderPageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServicesFailedCopyWith<_ServicesFailed> get copyWith => __$ServicesFailedCopyWithImpl<_ServicesFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServicesFailed&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'ProviderPageState.servicesFailed(error: $error)';
}


}

/// @nodoc
abstract mixin class _$ServicesFailedCopyWith<$Res> implements $ProviderPageStateCopyWith<$Res> {
  factory _$ServicesFailedCopyWith(_ServicesFailed value, $Res Function(_ServicesFailed) _then) = __$ServicesFailedCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class __$ServicesFailedCopyWithImpl<$Res>
    implements _$ServicesFailedCopyWith<$Res> {
  __$ServicesFailedCopyWithImpl(this._self, this._then);

  final _ServicesFailed _self;
  final $Res Function(_ServicesFailed) _then;

/// Create a copy of ProviderPageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_ServicesFailed(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
