import 'package:equatable/equatable.dart';

import '../../../model/usermodel.dart';

abstract class AuthState extends Equatable{
  const AuthState();

  @override
  List<Object?> get props=>[];
}

class AuthLoading extends AuthState{}

class AuthInitial extends AuthState{}

class AuthSuccess extends AuthState{
  final UserData userData;

  const AuthSuccess(this.userData);

  @override
  List<Object?> get props=>[userData];
}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class AuthNeedsRegistration extends AuthState {}







