import 'package:dio/dio.dart';
import 'package:domain/domain.dart';

typedef DtoToModelMap<Dto, Model> = Model? Function(Dto? dto);
typedef EntityToModelMap<Entity, Model> = Model? Function(Entity? entity);

typedef LoadFromDb<Entity> = Future<Entity?> Function();
typedef CreateNetworkCall<Dto> = Future<Dto?> Function();
typedef ShouldRefresh<Entity> = bool Function(Entity? entity);
typedef SaveNetworkResult<Dto> = Future<void> Function(Dto? dto);
typedef OnNetworkCallFailure = Function(Exception);

abstract class BaseRepository {
  Stream<Resource<Model?>> getLocalData<Entity, Model>(
      {required LoadFromDb<Entity> loadFromDb,
      required EntityToModelMap<Entity, Model> map}) async* {
    print('getLocalData: loading from local storage...');
    yield* emit(Resource.loading(null));

    final resource = await _safeDatabaseCall(loadFromDb.call());
    if (resource.status == Status.SUCCESS) {
      print('getLocalData: local storage call successful!');
      yield* emit(Resource.success(map(resource.data)!));
    } else {
      print('getLocalData: local storage call failed!');
      yield* emit(Resource.from(resource));
    }
  }

  Stream<Resource<Model?>> getNetworkData<Dto, Model>(
      {required CreateNetworkCall<Dto> createNetworkCall,
      required DtoToModelMap<Dto, Model> map}) async* {
    print('getNetworkData: loading from network...');
    yield* emit(Resource.loading(null));

    final resource = await _safeNetworkCall(createNetworkCall.call());
    if (resource.status == Status.SUCCESS) {
      print('getNetworkData: network call successful');
      yield* emit(Resource.success(map(resource.data!)));
    } else {
      print('getNetworkData: network call failed');
      yield* emit(Resource.from(resource));
    }
  }

  Stream<Resource<Model?>> getNetworkBoundData<Dto, Entity, Model>(
      {required LoadFromDb<Entity> loadFromDb,
      required CreateNetworkCall<Dto> createNetworkCall,
      required EntityToModelMap<Entity, Model> map,
      required SaveNetworkResult<Dto> saveNetworkResult,
      ShouldRefresh<Entity>? shouldRefresh,
      OnNetworkCallFailure? onNetworkCallFailure}) async* {
    print('getNetworkBoundData: Loading data from DB...');
    yield* emit(Resource.loading(null));

    /// first try to get data from db
    final dbResource = await _safeDatabaseCall<Entity>(loadFromDb.call());

    /// check if we need to fetch latest data from network or not
    if (shouldRefresh?.call(dbResource.data) ?? true) {
      /// return db data if we have
      print('getNetworkBoundData: data found in DB, loading from network...');
      yield* emit(Resource.loading(map(dbResource.data)));

      /// load data from network
      final networkResource =
          await _safeNetworkCall<Dto>(createNetworkCall.call());
      switch (networkResource.status) {
        case Status.LOADING:
          print('getNetworkBoundData: loading from network...');
          break;
        case Status.SUCCESS:

          /// save network result
          await saveNetworkResult.call(networkResource.data);

          /// get latest data from db
          final newDbResource =
              await _safeDatabaseCall<Entity>(loadFromDb.call());
          yield* emit(Resource.fromMap(newDbResource, map(newDbResource.data)));
          break;
        case Status.EXCEPTION:

          /// send exception details to network call failure callback
          onNetworkCallFailure
              ?.call(networkResource.exceptionDetails!.exception);

          /// get latest data from db
          final newDbResource =
              await _safeDatabaseCall<Entity>(loadFromDb.call());
          yield* emit(Resource.fromMap(newDbResource, map(newDbResource.data)));
          break;
        case Status.FAILURE:

          /// send failure details to network call failure callback
          onNetworkCallFailure
              ?.call(Exception(networkResource.failureDetails!.message));

          /// get latest data from db
          final newDbResource =
              await _safeDatabaseCall<Entity>(loadFromDb.call());
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
        print("Get from DB successful!");
        return Resource.success(response);
      } else {
        print("Get from DB response is null");
        return Resource.failure(
            FailureDetails(message: "DB response is null!"));
      }
    } on Exception catch (e) {
      print("Get from DB failure message -> $e");
      return Resource.exception(ExceptionDetails(e));
    }
  }

  Future<Resource<T>> _safeNetworkCall<T>(Future<T?> call) async {
    try {
      var response = await call;
      print("Network success message -> $response");
      return Resource.success(response);
    } on Exception catch (exception) {
      print("Network error message -> ${exception.toString()}");
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
