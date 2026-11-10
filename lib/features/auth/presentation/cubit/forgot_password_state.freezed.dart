// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'forgot_password_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ForgotPasswordState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForgotPasswordState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ForgotPasswordState()';
}


}

/// @nodoc
class $ForgotPasswordStateCopyWith<$Res>  {
$ForgotPasswordStateCopyWith(ForgotPasswordState _, $Res Function(ForgotPasswordState) __);
}


/// Adds pattern-matching-related methods to [ForgotPasswordState].
extension ForgotPasswordStatePatterns on ForgotPasswordState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _OtpSent value)?  otpSent,TResult Function( _OtpVerified value)?  otpVerified,TResult Function( _ResetSuccess value)?  resetSuccess,TResult Function( _Failed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _OtpSent() when otpSent != null:
return otpSent(_that);case _OtpVerified() when otpVerified != null:
return otpVerified(_that);case _ResetSuccess() when resetSuccess != null:
return resetSuccess(_that);case _Failed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _OtpSent value)  otpSent,required TResult Function( _OtpVerified value)  otpVerified,required TResult Function( _ResetSuccess value)  resetSuccess,required TResult Function( _Failed value)  failed,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _OtpSent():
return otpSent(_that);case _OtpVerified():
return otpVerified(_that);case _ResetSuccess():
return resetSuccess(_that);case _Failed():
return failed(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _OtpSent value)?  otpSent,TResult? Function( _OtpVerified value)?  otpVerified,TResult? Function( _ResetSuccess value)?  resetSuccess,TResult? Function( _Failed value)?  failed,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _OtpSent() when otpSent != null:
return otpSent(_that);case _OtpVerified() when otpVerified != null:
return otpVerified(_that);case _ResetSuccess() when resetSuccess != null:
return resetSuccess(_that);case _Failed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( String phoneNumber,  String otp)?  otpSent,TResult Function( String phoneNumber,  String token)?  otpVerified,TResult Function()?  resetSuccess,TResult Function( String error)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _OtpSent() when otpSent != null:
return otpSent(_that.phoneNumber,_that.otp);case _OtpVerified() when otpVerified != null:
return otpVerified(_that.phoneNumber,_that.token);case _ResetSuccess() when resetSuccess != null:
return resetSuccess();case _Failed() when failed != null:
return failed(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( String phoneNumber,  String otp)  otpSent,required TResult Function( String phoneNumber,  String token)  otpVerified,required TResult Function()  resetSuccess,required TResult Function( String error)  failed,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _OtpSent():
return otpSent(_that.phoneNumber,_that.otp);case _OtpVerified():
return otpVerified(_that.phoneNumber,_that.token);case _ResetSuccess():
return resetSuccess();case _Failed():
return failed(_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( String phoneNumber,  String otp)?  otpSent,TResult? Function( String phoneNumber,  String token)?  otpVerified,TResult? Function()?  resetSuccess,TResult? Function( String error)?  failed,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _OtpSent() when otpSent != null:
return otpSent(_that.phoneNumber,_that.otp);case _OtpVerified() when otpVerified != null:
return otpVerified(_that.phoneNumber,_that.token);case _ResetSuccess() when resetSuccess != null:
return resetSuccess();case _Failed() when failed != null:
return failed(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements ForgotPasswordState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ForgotPasswordState.initial()';
}


}




/// @nodoc


class _Loading implements ForgotPasswordState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ForgotPasswordState.loading()';
}


}




/// @nodoc


class _OtpSent implements ForgotPasswordState {
  const _OtpSent(this.phoneNumber, this.otp);
  

 final  String phoneNumber;
 final  String otp;

/// Create a copy of ForgotPasswordState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpSentCopyWith<_OtpSent> get copyWith => __$OtpSentCopyWithImpl<_OtpSent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpSent&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.otp, otp) || other.otp == otp));
}


@override
int get hashCode => Object.hash(runtimeType,phoneNumber,otp);

@override
String toString() {
  return 'ForgotPasswordState.otpSent(phoneNumber: $phoneNumber, otp: $otp)';
}


}

/// @nodoc
abstract mixin class _$OtpSentCopyWith<$Res> implements $ForgotPasswordStateCopyWith<$Res> {
  factory _$OtpSentCopyWith(_OtpSent value, $Res Function(_OtpSent) _then) = __$OtpSentCopyWithImpl;
@useResult
$Res call({
 String phoneNumber, String otp
});




}
/// @nodoc
class __$OtpSentCopyWithImpl<$Res>
    implements _$OtpSentCopyWith<$Res> {
  __$OtpSentCopyWithImpl(this._self, this._then);

  final _OtpSent _self;
  final $Res Function(_OtpSent) _then;

/// Create a copy of ForgotPasswordState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? phoneNumber = null,Object? otp = null,}) {
  return _then(_OtpSent(
null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,null == otp ? _self.otp : otp // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _OtpVerified implements ForgotPasswordState {
  const _OtpVerified(this.phoneNumber, this.token);
  

 final  String phoneNumber;
 final  String token;

/// Create a copy of ForgotPasswordState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpVerifiedCopyWith<_OtpVerified> get copyWith => __$OtpVerifiedCopyWithImpl<_OtpVerified>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpVerified&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.token, token) || other.token == token));
}


@override
int get hashCode => Object.hash(runtimeType,phoneNumber,token);

@override
String toString() {
  return 'ForgotPasswordState.otpVerified(phoneNumber: $phoneNumber, token: $token)';
}


}

/// @nodoc
abstract mixin class _$OtpVerifiedCopyWith<$Res> implements $ForgotPasswordStateCopyWith<$Res> {
  factory _$OtpVerifiedCopyWith(_OtpVerified value, $Res Function(_OtpVerified) _then) = __$OtpVerifiedCopyWithImpl;
@useResult
$Res call({
 String phoneNumber, String token
});




}
/// @nodoc
class __$OtpVerifiedCopyWithImpl<$Res>
    implements _$OtpVerifiedCopyWith<$Res> {
  __$OtpVerifiedCopyWithImpl(this._self, this._then);

  final _OtpVerified _self;
  final $Res Function(_OtpVerified) _then;

/// Create a copy of ForgotPasswordState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? phoneNumber = null,Object? token = null,}) {
  return _then(_OtpVerified(
null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _ResetSuccess implements ForgotPasswordState {
  const _ResetSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResetSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ForgotPasswordState.resetSuccess()';
}


}




/// @nodoc


class _Failed implements ForgotPasswordState {
  const _Failed(this.error);
  

 final  String error;

/// Create a copy of ForgotPasswordState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FailedCopyWith<_Failed> get copyWith => __$FailedCopyWithImpl<_Failed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Failed&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'ForgotPasswordState.failed(error: $error)';
}


}

/// @nodoc
abstract mixin class _$FailedCopyWith<$Res> implements $ForgotPasswordStateCopyWith<$Res> {
  factory _$FailedCopyWith(_Failed value, $Res Function(_Failed) _then) = __$FailedCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class __$FailedCopyWithImpl<$Res>
    implements _$FailedCopyWith<$Res> {
  __$FailedCopyWithImpl(this._self, this._then);

  final _Failed _self;
  final $Res Function(_Failed) _then;

/// Create a copy of ForgotPasswordState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_Failed(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
