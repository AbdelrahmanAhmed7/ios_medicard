// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family_members_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FamilyMembersState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FamilyMembersState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FamilyMembersState()';
}


}

/// @nodoc
class $FamilyMembersStateCopyWith<$Res>  {
$FamilyMembersStateCopyWith(FamilyMembersState _, $Res Function(FamilyMembersState) __);
}


/// Adds pattern-matching-related methods to [FamilyMembersState].
extension FamilyMembersStatePatterns on FamilyMembersState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Success value)?  success,TResult Function( _Failed value)?  failed,TResult Function( _Creating value)?  creating,TResult Function( _Created value)?  created,TResult Function( _Updating value)?  updating,TResult Function( _Updated value)?  updated,TResult Function( _Deleting value)?  deleting,TResult Function( _Deleted value)?  deleted,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Success() when success != null:
return success(_that);case _Failed() when failed != null:
return failed(_that);case _Creating() when creating != null:
return creating(_that);case _Created() when created != null:
return created(_that);case _Updating() when updating != null:
return updating(_that);case _Updated() when updated != null:
return updated(_that);case _Deleting() when deleting != null:
return deleting(_that);case _Deleted() when deleted != null:
return deleted(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Success value)  success,required TResult Function( _Failed value)  failed,required TResult Function( _Creating value)  creating,required TResult Function( _Created value)  created,required TResult Function( _Updating value)  updating,required TResult Function( _Updated value)  updated,required TResult Function( _Deleting value)  deleting,required TResult Function( _Deleted value)  deleted,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Success():
return success(_that);case _Failed():
return failed(_that);case _Creating():
return creating(_that);case _Created():
return created(_that);case _Updating():
return updating(_that);case _Updated():
return updated(_that);case _Deleting():
return deleting(_that);case _Deleted():
return deleted(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Success value)?  success,TResult? Function( _Failed value)?  failed,TResult? Function( _Creating value)?  creating,TResult? Function( _Created value)?  created,TResult? Function( _Updating value)?  updating,TResult? Function( _Updated value)?  updated,TResult? Function( _Deleting value)?  deleting,TResult? Function( _Deleted value)?  deleted,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Success() when success != null:
return success(_that);case _Failed() when failed != null:
return failed(_that);case _Creating() when creating != null:
return creating(_that);case _Created() when created != null:
return created(_that);case _Updating() when updating != null:
return updating(_that);case _Updated() when updated != null:
return updated(_that);case _Deleting() when deleting != null:
return deleting(_that);case _Deleted() when deleted != null:
return deleted(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<FamilyMemberModel> members)?  success,TResult Function( String error)?  failed,TResult Function()?  creating,TResult Function()?  created,TResult Function()?  updating,TResult Function()?  updated,TResult Function()?  deleting,TResult Function()?  deleted,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Success() when success != null:
return success(_that.members);case _Failed() when failed != null:
return failed(_that.error);case _Creating() when creating != null:
return creating();case _Created() when created != null:
return created();case _Updating() when updating != null:
return updating();case _Updated() when updated != null:
return updated();case _Deleting() when deleting != null:
return deleting();case _Deleted() when deleted != null:
return deleted();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<FamilyMemberModel> members)  success,required TResult Function( String error)  failed,required TResult Function()  creating,required TResult Function()  created,required TResult Function()  updating,required TResult Function()  updated,required TResult Function()  deleting,required TResult Function()  deleted,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Success():
return success(_that.members);case _Failed():
return failed(_that.error);case _Creating():
return creating();case _Created():
return created();case _Updating():
return updating();case _Updated():
return updated();case _Deleting():
return deleting();case _Deleted():
return deleted();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<FamilyMemberModel> members)?  success,TResult? Function( String error)?  failed,TResult? Function()?  creating,TResult? Function()?  created,TResult? Function()?  updating,TResult? Function()?  updated,TResult? Function()?  deleting,TResult? Function()?  deleted,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Success() when success != null:
return success(_that.members);case _Failed() when failed != null:
return failed(_that.error);case _Creating() when creating != null:
return creating();case _Created() when created != null:
return created();case _Updating() when updating != null:
return updating();case _Updated() when updated != null:
return updated();case _Deleting() when deleting != null:
return deleting();case _Deleted() when deleted != null:
return deleted();case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements FamilyMembersState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FamilyMembersState.initial()';
}


}




/// @nodoc


class _Loading implements FamilyMembersState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FamilyMembersState.loading()';
}


}




/// @nodoc


class _Success implements FamilyMembersState {
  const _Success( List<FamilyMemberModel> members): _members = members;
  

 final  List<FamilyMemberModel> _members;
 List<FamilyMemberModel> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}


/// Create a copy of FamilyMembersState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SuccessCopyWith<_Success> get copyWith => __$SuccessCopyWithImpl<_Success>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Success&&const DeepCollectionEquality().equals(other._members, _members));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_members));

@override
String toString() {
  return 'FamilyMembersState.success(members: $members)';
}


}

/// @nodoc
abstract mixin class _$SuccessCopyWith<$Res> implements $FamilyMembersStateCopyWith<$Res> {
  factory _$SuccessCopyWith(_Success value, $Res Function(_Success) _then) = __$SuccessCopyWithImpl;
@useResult
$Res call({
 List<FamilyMemberModel> members
});




}
/// @nodoc
class __$SuccessCopyWithImpl<$Res>
    implements _$SuccessCopyWith<$Res> {
  __$SuccessCopyWithImpl(this._self, this._then);

  final _Success _self;
  final $Res Function(_Success) _then;

/// Create a copy of FamilyMembersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? members = null,}) {
  return _then(_Success(
null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<FamilyMemberModel>,
  ));
}


}

/// @nodoc


class _Failed implements FamilyMembersState {
  const _Failed(this.error);
  

 final  String error;

/// Create a copy of FamilyMembersState
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
  return 'FamilyMembersState.failed(error: $error)';
}


}

/// @nodoc
abstract mixin class _$FailedCopyWith<$Res> implements $FamilyMembersStateCopyWith<$Res> {
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

/// Create a copy of FamilyMembersState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_Failed(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Creating implements FamilyMembersState {
  const _Creating();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Creating);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FamilyMembersState.creating()';
}


}




/// @nodoc


class _Created implements FamilyMembersState {
  const _Created();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Created);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FamilyMembersState.created()';
}


}




/// @nodoc


class _Updating implements FamilyMembersState {
  const _Updating();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Updating);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FamilyMembersState.updating()';
}


}




/// @nodoc


class _Updated implements FamilyMembersState {
  const _Updated();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Updated);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FamilyMembersState.updated()';
}


}




/// @nodoc


class _Deleting implements FamilyMembersState {
  const _Deleting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Deleting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FamilyMembersState.deleting()';
}


}




/// @nodoc


class _Deleted implements FamilyMembersState {
  const _Deleted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Deleted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FamilyMembersState.deleted()';
}


}




// dart format on
