import 'package:domain/domain.dart';
import 'package:domain/src/model/article_model.dart';

abstract class ArticleRepository {
  Stream<Resource<List<ArticleModel>?>> getArticles(bool forceRefresh);

  Stream<Resource<ArticleModel?>> getArticle(int id);

  Future<void> clearArticles();
}
