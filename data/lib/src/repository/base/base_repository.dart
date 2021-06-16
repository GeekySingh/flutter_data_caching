import 'package:dio/dio.dart';
import 'package:domain/domain.dart';
import 'package:logger/logger.dart';

typedef DtoToModelMap<Dto, Model> = Model Function(Dto dto);
typedef EntityToModelMap<Entity, Model> = Model? Function(Entity? entity);
typedef SaveNetworkResult<Dto> = Future<void> Function(Dto? dto);
typedef OnNetworkCallFailure = Function(Exception);

abstract class BaseRepository {
  final _logger = Logger();

  Stream<Resource<Model>> getLocalData<Entity, Model>(
      {required Future<Entity?> loadFromDb,
      required EntityToModelMap<Entity, Model> map}) async* {
    yield* emit(Resource.loading(null));

    final resource = await _safeDatabaseCall(loadFromDb);
    if (resource.status == Status.SUCCESS) {
      yield* emit(Resource.success(map(resource.data)!));
    } else {
      yield* emit(Resource.from(resource));
    }
  }

  Stream<Resource<Model>> getNetworkData<Dto, Model>(
      {required Future<Dto?> createNetworkCall,
      required DtoToModelMap<Dto, Model> map}) async* {
    yield* emit(Resource.loading(null));

    final resource = await _safeNetworkCall(createNetworkCall);
    if (resource.status == Status.SUCCESS) {
      yield* emit(Resource.success(map(resource.data!)));
    } else {
      yield* emit(Resource.from(resource));
    }
  }

  Stream<Resource<Model?>> getNetworkBoundData<Dto, Entity, Model>(
      {required Future<Entity?> loadFromDb,
      required Future<Dto?> createNetworkCall,
      required EntityToModelMap<Entity, Model> map,
      required SaveNetworkResult<Dto> saveNetworkResult,
      bool shouldRefresh = true,
      OnNetworkCallFailure? onNetworkCallFailure}) async* {
    print('getNetworkBoundData: Loading data from DB...');
    yield* emit(Resource.loading(null));

    /// first try to get data from db
    final dbResource = await _safeDatabaseCall(loadFromDb);

    /// check if we need to fetch latest data from network or not
    if (shouldRefresh) {
      /// return db data if we have
      print('getNetworkBoundData: data found in DB, loading from network...');
      yield* emit(Resource.loading(map(dbResource.data)));

      /// load data from network
      final networkResource = await _safeNetworkCall(createNetworkCall);
      switch (networkResource.status) {
        case Status.LOADING:
          print('getNetworkBoundData: loading from network...');
          break;
        case Status.SUCCESS:
          print('getNetworkBoundData: network data loaded!');
          print('getNetworkBoundData: saving network data...');
          /// save network result
          saveNetworkResult(networkResource.data);

          /// get latest data from db
          final newDbResource = await _safeDatabaseCall(loadFromDb);
          print('getNetworkBoundData: returning latest data from DB!');
          yield* emit(Resource.fromMap(newDbResource, map(newDbResource.data)));
          break;
        case Status.EXCEPTION:
          print('getNetworkBoundData: exception occurred while loading data from network!');
          /// send exception details to network call failure callback
          onNetworkCallFailure
              ?.call(networkResource.exceptionDetails!.exception);

          /// get latest data from db
          final newDbResource = await _safeDatabaseCall(loadFromDb);
          print('getNetworkBoundData: returning data from DB!');
          yield* emit(Resource.fromMap(newDbResource, map(newDbResource.data)));
          break;
        case Status.FAILURE:
          print('getNetworkBoundData: loading network data failed!');
          /// send failure details to network call failure callback
          onNetworkCallFailure
              ?.call(Exception(networkResource.failureDetails!.message));

          /// get latest data from db
          final newDbResource = await _safeDatabaseCall(loadFromDb);
          print('getNetworkBoundData: returning data from DB!');
          yield* emit(Resource.fromMap(newDbResource, map(newDbResource.data)));
          break;
      }
    } else {
      print('getNetworkBoundData: returning data from DB!');
      yield* emit(Resource.fromMap(dbResource, map(dbResource.data)));
    }
  }

  Future<Resource<T>> _safeDatabaseCall<T>(Future<T?> call) async {
    try {
      final response = await call;
      if (response != null) {
        _logger.d("DB success message -> $response");
        return Resource.success(response);
      } else {
        _logger.d("DB response is null");
        return Resource.failure(
            FailureDetails(message: "DB response is null!"));
      }
    } on Exception catch (e) {
      _logger.d("DB failure message -> $e");
      return Resource.exception(ExceptionDetails(e));
    }
  }

  Future<Resource<T>> _safeNetworkCall<T>(Future<T> call) async {
    try {
      var response = await call;
      _logger.d("Network success message -> $response");
      return Resource.success(response);
    } on Exception catch (exception) {
      _logger.e("Network error message -> ${exception.toString()}");
      _logger.e(exception);
      if (exception is DioError) {
        switch ((exception).type) {
          case DioErrorType.connectTimeout:
          case DioErrorType.sendTimeout:
          case DioErrorType.receiveTimeout:
          case DioErrorType.cancel:
            return Resource.failure(
                FailureDetails(message: "Poor network connection"));

          case DioErrorType.other:
            return Resource.failure(
                FailureDetails(message: "Internet not available!"));

          case DioErrorType.response:
            return Resource.failure(FailureDetails(
                httpCode: exception.response!.statusCode,
                message: exception.response!.data));
        }
      } else {
        return Resource.exception(ExceptionDetails(exception));
      }
    }
  }
  
  Stream<T> emit<T>(T data) => Stream.value(data);
}
