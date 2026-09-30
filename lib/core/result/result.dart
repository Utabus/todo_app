import '../errors/failure.dart';

/// Sealed functional Result class representing either Success(data) or Error(failure)
sealed class Result<T, E extends Failure> {
  const Result();

  bool get isSuccess => this is Success<T, E>;
  bool get isError => this is Error<T, E>;

  T? get dataOrNull => switch (this) {
        Success(data: final data) => data,
        Error() => null,
      };

  E? get failureOrNull => switch (this) {
        Success() => null,
        Error(failure: final failure) => failure,
      };

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(E failure) onError,
  }) {
    return switch (this) {
      Success(data: final data) => onSuccess(data),
      Error(failure: final failure) => onError(failure),
    };
  }
}

final class Success<T, E extends Failure> extends Result<T, E> {
  final T data;
  const Success(this.data);
}

final class Error<T, E extends Failure> extends Result<T, E> {
  final E failure;
  const Error(this.failure);
}
