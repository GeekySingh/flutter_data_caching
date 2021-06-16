
import 'package:domain/domain.dart';
import 'package:domain/src/model/article_model.dart';

import 'base/base_use_case.dart';

/// abstraction of use case to be used by viewmodel
abstract class GetAllArticleUseCase implements BaseUseCase {

  Stream<Resource<List<ArticleModel>?>> getArticles();
}

/// abstraction of use case to be used by viewmodel
abstract class GetArticleByIdUseCase implements BaseUseCase {
  Stream<Resource<ArticleModel?>> getArticle(int id);
}

abstract class ClearAllArticleUseCase implements BaseUseCase {

  Future<void> clearArticles();
}