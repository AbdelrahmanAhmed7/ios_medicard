// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_refresh_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppRefreshState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppRefreshState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppRefreshState()';
}


}

/// @nodoc
class $AppRefreshStateCopyWith<$Res>  {
$AppRefreshStateCopyWith(AppRefreshState _, $Res Function(AppRefreshState) __);
}


/// Adds pattern-matching-related methods to [AppRefreshState].
extension AppRefreshStatePatterns on AppRefreshState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( LanguageChanged value)?  languageChanged,TResult Function( SessionExpired value)?  sessionExpired,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case LanguageChanged() when languageChanged != null:
return languageChanged(_that);case SessionExpired() when sessionExpired != null:
return sessionExpired(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( LanguageChanged value)  languageChanged,required TResult Function( SessionExpired value)  sessionExpired,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case LanguageChanged():
return languageChanged(_that);case SessionExpired():
return sessionExpired(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( LanguageChanged value)?  languageChanged,TResult? Function( SessionExpired value)?  sessionExpired,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case LanguageChanged() when languageChanged != null:
return languageChanged(_that);case SessionExpired() when sessionExpired != null:
return sessionExpired(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  languageChanged,TResult Function()?  sessionExpired,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case LanguageChanged() when languageChanged != null:
return languageChanged();case SessionExpired() when sessionExpired != null:
return sessionExpired();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  languageChanged,required TResult Function()  sessionExpired,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case LanguageChanged():
return languageChanged();case SessionExpired():
return sessionExpired();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  languageChanged,TResult? Function()?  sessionExpired,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case LanguageChanged() when languageChanged != null:
return languageChanged();case SessionExpired() when sessionExpired != null:
return sessionExpired();case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements AppRefreshState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppRefreshState.initial()';
}


}




/// @nodoc


class LanguageChanged implements AppRefreshState {
  const LanguageChanged();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LanguageChanged);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppRefreshState.languageChanged()';
}


}




/// @nodoc


class SessionExpired implements AppRefreshState {
  const SessionExpired();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SessionExpired);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppRefreshState.sessionExpired()';
}


}




// dart format on
