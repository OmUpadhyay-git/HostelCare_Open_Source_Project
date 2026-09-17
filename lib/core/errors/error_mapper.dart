import 'app_error.dart';

class ErrorMapper {
  ErrorMapper._();

  static AppError mapToAppError(dynamic error) {
    if (error is AppError) {
      return error;
    }

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return NetworkError(details: error.toString());
    }

    if (errorString.contains('unauthorized') || errorString.contains('auth')) {
      return AuthError(details: error.toString());
    }

    if (errorString.contains('permission') || errorString.contains('forbidden')) {
      return AuthorizationError(details: error.toString());
    }

    return UnknownError(details: error.toString());
  }

  static String getUserMessage(AppError error) {
    return error.message;
  }
}
