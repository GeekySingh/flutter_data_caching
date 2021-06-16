import 'package:core/core/core_view_model.dart';
import 'package:core/service/toast_service.dart';
import 'package:domain/domain.dart';
import 'package:injectable/injectable.dart';
import 'package:presentation/src/common/routes/router.dart';

@injectable
class ArticleListViewModel extends CoreViewModel {
  final GetAllArticleUseCase _allArticleUseCase;
  final ClearAllArticleUseCase clearAllArticleUseCase;
  final ToastService _toastService;

  ArticleListViewModel(
      this._allArticleUseCase, this.clearAllArticleUseCase, this._toastService);

  Stream<Resource<List<ArticleModel>?>> articlesStream() =>
      _allArticleUseCase.getArticles();

  void onArticleItemClicked(int id) {
    navigationService.push(ArticleDetailScreenRoute(id: id));
  }
}
