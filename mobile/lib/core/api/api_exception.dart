/// Typed exceptions for HTTP API failures.
///
/// Handlers should catch [ApiException] and display an appropriate message
/// to the user. Subtypes make it easy to handle specific failure modes
/// (e.g., redirecting to login on [UnauthorisedException]).
sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// 400 Bad Request — the client sent malformed data.
final class BadRequestException extends ApiException {
  const BadRequestException(super.message);
}

/// 401 Unauthorized — the session token is missing or expired.
final class UnauthorisedException extends ApiException {
  const UnauthorisedException(super.message);
}

/// 403 Forbidden — the user is authenticated but lacks permission.
final class ForbiddenException extends ApiException {
  const ForbiddenException(super.message);
}

/// 404 Not Found.
final class NotFoundException extends ApiException {
  const NotFoundException(super.message);
}

/// 409 Conflict — e.g., duplicate email on registration.
final class ConflictException extends ApiException {
  const ConflictException(super.message);
}

/// 422 Unprocessable Entity — server-side validation failure.
final class ValidationException extends ApiException {
  const ValidationException(super.message);
}

/// Any 5xx response or unexpected status code.
final class ServerException extends ApiException {
  const ServerException(super.message);
}

/// The device could not reach the server (no network, wrong host, etc.).
final class NetworkException extends ApiException {
  const NetworkException(super.message);
}
