import 'dart:developer';

import 'package:f_journey_driver/core/data/local_datasource.dart';
import 'package:f_journey_driver/core/utils/reg_util.dart';
import 'package:f_journey_driver/model/repository/auth/auth_repository.dart';
import 'package:f_journey_driver/model/request/auth/driver_register_request.dart';
import 'package:f_journey_driver/model/request/auth/passenger_register_request.dart';
import 'package:f_journey_driver/model/response/auth/get_user_profile_response.dart';
import 'package:f_journey_driver/model/response/auth/login_driver_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginEmailPasswordStarted>(
      (event, emit) => _onLoginEmailPassword(event, emit),
    );
    on<GetUserProfileStarted>(
      (event, emit) => _onGetUserProfile(event, emit),
    );
    on<RegisterDriverProfileStarted>(
      (event, emit) => _onRegisterDriver(event, emit),
    );
    on<LogoutStarted>(
      (event, emit) => _onLogout(event, emit),
    );
  }

  Future<void> _onLoginEmailPassword(
      LoginEmailPasswordStarted event, Emitter<AuthState> emit) async {
    emit(AuthInProgress());
    try {
      if (RegUtil.validateEmail(event.email) != null &&
          RegUtil.validatePassword(event.password) != null) {
        emit(LoginError(message: 'Please enter valid email/password'));
        return;
      }
      LoginDriverResponse? user =
          await authRepository.loginDriver(event.email, event.password);
      await LocalDataSource.saveAccessToken(user?.result.accessToken);
      emit(LoginSuccess());
      return;
    } catch (e) {
      emit(LoginError(message: 'User not found'));
      if (kDebugMode) {
        print('Error while login with email/password: $e');
      }
    }
  }

  Future<void> _onGetUserProfile(
    GetUserProfileStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthInProgress());
    try {
      String? accessToken = await LocalDataSource.getAccessToken();
      GetUserProfileResult? profile =
          await authRepository.getUserProfile(accessToken!);
      if (profile!.verificationStatus == 'Init') {
        emit(UserDoesNotExist(profile: profile));
      } else if (profile.verificationStatus == 'Pending') {
        emit(ProfileUserPending());
      } else if (profile.verificationStatus == 'Approved') {
        emit(ProfileUserApproved(profile: profile));
      } else {
        emit(ProfileUserRejected());
      }
    } catch (e) {
      emit(CheckNewUserError(message: 'Error while checking new user'));
      if (kDebugMode) {
        print('Error while checking new user: $e');
      }
    }
  }

  Future<void> _onRegisterDriver(
      RegisterDriverProfileStarted event, Emitter<AuthState> emit) async {
    emit(RegisterDriverProfileInProgress());
    try {
      bool? isRegistered = await authRepository.registerDriver(event.request);
      if (isRegistered!) {
        emit(RegisterDriverProfileSuccess());
      } else {
        emit(RegisterDriverProfileError(message: 'Failed to register'));
      }
    } catch (e) {
      emit(RegisterDriverProfileError(message: 'Error while registering'));
      if (kDebugMode) {
        print('Error while registering: $e');
      }
    }
  }

  Future<void> _onLogout(LogoutStarted event, Emitter<AuthState> emit) async {
    try {
      await LocalDataSource.deleteAccessToken();
      emit(LogoutSuccess());
    } catch (e) {
      log('Error while logging out: $e');
      emit(AuthError(message: 'Error while logging out'));
    }
  }
}
