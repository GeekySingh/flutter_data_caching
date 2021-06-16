
import 'package:domain/src/common/status.dart';

class Resource<T> {
  final T? data;
  final Status status;
  final FailureDetails? failureDetails;
  final ExceptionDetails? exceptionDetails;

  Resource(this.data, this.status,
      {this.failureDetails, this.exceptionDetails});

  static loading<T>(T? data) => Resource<T>(data, Status.LOADING);
  static success<T>(T data) => Resource<T>(data, Status.SUCCESS);
  static failure<T>(FailureDetails failureDetails) => Resource<T>(null, Status.FAILURE, failureDetails: failureDetails);
  static exception<T>(ExceptionDetails exceptionDetails) => Resource<T>(null, Status.EXCEPTION, exceptionDetails: exceptionDetails);
  static from<T>(Resource<T> resource) => Resource(resource.data, resource.status, failureDetails: resource.failureDetails, exceptionDetails: resource.exceptionDetails);
  static fromMap<T, K>(Resource<T> resource, K? data) => Resource<K>(data, resource.status, failureDetails: resource.failureDetails, exceptionDetails: resource.exceptionDetails);
}

class FailureDetails {
  final int? httpCode;
  final String message;

  FailureDetails({this.httpCode, required this.message});
}

class ExceptionDetails {
  final Exception exception;

  ExceptionDetails(this.exception);
}
