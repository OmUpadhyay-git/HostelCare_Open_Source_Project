sealed class AppError {
  final String message;
  final String? details;

  const AppError({
    required this.message,
    this.details,
  });

  @override
  String toString() => 'AppError: $message';
}

class NetworkError extends AppError {
  const NetworkError({
    super.message = 'Network error occurred',
    super.details,
  });
}

class AuthError extends AppError {
  const AuthError({
    super.message = 'Authentication error',
    super.details,
  });
}

class AuthorizationError extends AppError {
  const AuthorizationError({
    super.message = 'You do not have permission to perform this action',
    super.details,
  });
}

class ValidationError extends AppError {
  final Map<String, String>? fieldErrors;

  const ValidationError({
    super.message = 'Validation failed',
    super.details,
    this.fieldErrors,
  });
}

class DatabaseError extends AppError {
  const DatabaseError({
    super.message = 'Database error occurred',
    super.details,
  });
}

class StorageError extends AppError {
  const StorageError({
    super.message = 'Storage error occurred',
    super.details,
  });
}

class UnknownError extends AppError {
  const UnknownError({
    super.message = 'An unexpected error occurred',
    super.details,
  });
}
