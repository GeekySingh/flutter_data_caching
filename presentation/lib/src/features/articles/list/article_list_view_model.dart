import 'dart:async';

import 'package:core/core/core_view_model.dart';
import 'package:core/service/toast_service.dart';
import 'package:domain/domain.dart';
import 'package:injectable/injectable.dart';
import 'package:presentation/src/common/routes/router.dart';

@injectable
class ArticleListViewModel extends CoreViewModel {
  final GetAllArticleUseCase _allArticleUseCase;
  final ToastService _toastService;

  ArticleListViewModel(this._allArticleUseCase, this._toastService);

  bool _forceRefresh = false;

  Stream<Resource<List<ArticleModel>?>> get articlesStream => _allArticleUseCase.getArticles(_forceRefresh);

  Future<void> refresh() {
    _toastService.show('Refreshing...');
    _forceRefresh = true;
    notifyListeners();
    return Future.delayed(Duration(seconds: 2));
  }

  void onArticleItemClicked(int id) {
    navigationService.push(ArticleDetailScreenRoute(id: id));
  }
}
