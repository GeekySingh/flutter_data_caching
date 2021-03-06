
import 'package:domain/src/model/article_model.dart';
import 'package:domain/src/repository/article_repository.dart';
import 'package:injectable/injectable.dart';

import '../../domain.dart';

@Injectable(as: GetAllArticleUseCase)
/// implementation of use cases
class GetAllArticleUseCaseImpl extends GetAllArticleUseCase {
  final ArticleRepository _repository;

  GetAllArticleUseCaseImpl(this._repository);

  @override
  Stream<Resource<List<ArticleModel>?>> getArticles(bool forceRefresh) => _repository.getArticles(forceRefresh);
}

@Injectable(as: GetArticleByIdUseCase)
/// implementation of use cases
class GetArticleByIdUseCaseImpl extends GetArticleByIdUseCase {
  final ArticleRepository _repository;

  GetArticleByIdUseCaseImpl(this._repository);

  @override
  Stream<Resource<ArticleModel?>> getArticle(int id) => _repository.getArticle(id);
}

@Injectable(as: ClearAllArticleUseCase)
class ClearAllArticleUseCaseImpl extends ClearAllArticleUseCase {
  final ArticleRepository _repository;

  ClearAllArticleUseCaseImpl(this._repository);

  @override
  Future<void> clearArticles() => _repository.clearArticles();
}
