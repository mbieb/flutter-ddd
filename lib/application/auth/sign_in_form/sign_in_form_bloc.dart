import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:demo_ddd/domain/auth/i_auth_facade.dart';
import 'package:demo_ddd/domain/auth/value_objects.dart';
import 'package:flutter/cupertino.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/auth/auth_failure.dart';

part 'sign_in_form_event.dart';
part 'sign_in_form_state.dart';
part 'sign_in_form_bloc.freezed.dart';

@injectable
class SignInFormBloc extends Bloc<SignInFormEvent, SignInFormState> {
  final IAuthFacade _authFacade;

  SignInFormBloc(this._authFacade) : super(SignInFormState.initial()) {
    on<SignInFormEvent>(_onEvent);
  }

  FutureOr<void> _onEvent(
    SignInFormEvent event,
    Emitter<SignInFormState> emit,
  ) {
    event.map(
      emailChanged: (e) async {
        emit(
          state.copyWith(
            emailAddress: EmailAddress(e.emailString),
            authFailureOrSuccessOption: none(),
          ),
        );
      },
      passwordChanged: (e) async {
        emit(
          state.copyWith(
            password: Password(e.passwordString),
            authFailureOrSuccessOption: none(),
          ),
        );
      },
      registerWithEmailAndPasswordPressed: (e) async {
        Either<AuthFailure, Unit>? failureOrSuccess;
        final isEmailValid = state.emailAddress.isValid();
        final isPasswordValid = state.password.isValid();
        if (isEmailValid && isPasswordValid) {
          emit(
            state.copyWith(
              isSubmitting: true,
              authFailureOrSuccessOption: none(),
            ),
          );

          failureOrSuccess = await _authFacade.registerWithEmailAndPassword(
            emailAddress: state.emailAddress,
            password: state.password,
          );
        }

        emit(
          state.copyWith(
            isSubmitting: false,
            showErrorMessages: AutovalidateMode.always,
            authFailureOrSuccessOption: optionOf(failureOrSuccess),
          ),
        );
      },
      signInWithEmailAndPasswordPressed: (e) async {
        Either<AuthFailure, Unit>? failureOrSuccess;
        final isEmailValid = state.emailAddress.isValid();
        final isPasswordValid = state.password.isValid();
        if (isEmailValid && isPasswordValid) {
          emit(
            state.copyWith(
              isSubmitting: true,
              authFailureOrSuccessOption: none(),
            ),
          );

          failureOrSuccess = await _authFacade.signInWithEmailAndPassword(
            emailAddress: state.emailAddress,
            password: state.password,
          );
        }

        emit(
          state.copyWith(
            isSubmitting: false,
            showErrorMessages: AutovalidateMode.always,
            authFailureOrSuccessOption: optionOf(failureOrSuccess),
          ),
        );
      },
      signInWithGooglePressed: (e) async {
        emit(
          state.copyWith(
            isSubmitting: true,
            authFailureOrSuccessOption: none(),
          ),
        );

        await _authFacade.signInWithGoogle().then((value) {
          emit(
            state.copyWith(
              isSubmitting: false,
              authFailureOrSuccessOption: some(value),
            ),
          );
        });
      },
    );
  }

  // Stream<SignInFormState> _performActionOnAuthFacadeWithEmailAndPassword(
  //   Future<Either<AuthFailure, Unit>> Function({
  //     required EmailAddress emailAddress,
  //     required Password password,
  //   })
  //       forwardedCall,
  // ) async {
  //   Either<AuthFailure, Unit>? failureOrSuccess;
  //   final isEmailValid = state.emailAddress.isValid();
  //   final isPasswordValid = state.password.isValid();
  //   if (isEmailValid && isPasswordValid) {
  //     emit(
  //       state.copyWith(
  //         isSubmitting: true,
  //         authFailureOrSuccessOption: none(),
  //       ),
  //     );

  //     failureOrSuccess = await forwardedCall(
  //       emailAddress: state.emailAddress,
  //       password: state.password,
  //     );
  //   }

  //   emit(
  //     state.copyWith(
  //       isSubmitting: false,
  //       showErrorMessages: true,
  //       authFailureOrSuccessOption: optionOf(failureOrSuccess),
  //     ),
  //   );
  // }
}
