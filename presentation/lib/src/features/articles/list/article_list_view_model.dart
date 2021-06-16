import 'package:core/core/core_view_model.dart';
import 'package:core/service/toast_service.dart';
import 'package:domain/domain.dart';
import 'package:injectable/injectable.dart';
import 'package:presentation/src/common/routes/router.dart';

@injectable
class ArticleListViewModel extends CoreViewModel {
  final GetAllArticleUseCase _allArticleUseCase;
  final ToastService _toastService;

  ArticleListViewModel(this._allArticleUseCase, this._toastService) {
    // loadArticles();

    // articlesStream().listen((event) {
    //   switch (event.status) {
    //     case Status.LOADING:
    //       if (event.data == null)
    //         print('Loading, data is null');
    //       else
    //         print('Loading, data is not null ${event.data}');
    //       break;
    //     case Status.SUCCESS:
    //       print('Success, data is not null ${event.data}');
    //       break;
    //     case Status.FAILURE:
    //       print('failure, ${event.failureDetails?.message}');
    //       break;
    //     case Status.EXCEPTION:
    //       print('exception, ${event.exceptionDetails?.exception}');
    //       break;
    //   }
    // });
  }

  // late List<ArticleModel> _articleList;
  // List<ArticleModel> get articleList => _articleList;
  //
  // late String _errorMsg;
  // String get errorMsg => _errorMsg;

  Stream<Resource<List<ArticleModel>?>> articlesStream() =>
      _allArticleUseCase.getArticles();

  // void loadArticles() async {
  //   loading();
  //
  //   final result = await _allArticleUseCase.getArticles();
  //   result.when(
  //     success: (data) => _articleList = data,
  //     error: (errorType, message) => _errorMsg = message,
  //   );
  //
  //   loaded(result.isSuccessful);
  //   if(result.isSuccessful) {
  //     _toastService.show("Data fetched!");
  //   }
  // }

  void onArticleItemClicked(int id) {
    navigationService.push(ArticleDetailScreenRoute(id: id));
  }
}
