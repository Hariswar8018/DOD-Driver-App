import 'package:bloc/bloc.dart';

import 'state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState().init());
}
