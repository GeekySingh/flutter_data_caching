import 'package:data/src/datasource/local/dao/article_dao.dart';
import 'package:data/src/datasource/local/entity/article_entity.dart';
import 'package:data/src/datasource/remote/dto/article_response.dart';
import 'package:data/src/datasource/remote/service/article_service.dart';
import 'package:data/src/mapper/article_mapper.dart';
import 'package:domain/domain.dart';
import 'package:injectable/injectable.dart';

import 'base/base_repository.dart';

@Injectable(as: ArticleRepository)
class ArticleRepositoryImpl extends BaseRepository
    implements ArticleRepository {
  final ArticleService _articleService;
  final ArticleDao _articleDao;

  ArticleRepositoryImpl(this._articleService, this._articleDao);

  @override
  Stream<Resource<ArticleModel?>> getArticle(int id) {
    return getLocalData<ArticleEntity, ArticleModel>(
        loadFromDb: _articleDao.getArticleById(id),
        map: (entity) => entity?.toModel());
  }

  @override
  Stream<Resource<List<ArticleModel>?>> getArticles() {
    return getNetworkBoundData<ArticleResponse, List<ArticleEntity>,
            List<ArticleModel>>(
        loadFromDb: _articleDao.getArticles(),
        createNetworkCall: _articleService.getArticles(),
        map: (list) => list?.map((e) => e.toModel()).toList(),
        saveNetworkResult: (response) async {
          print('Saving response in DB: ${response?.toJson()}');
          if (response != null) {
            await _articleDao.saveArticles(
                response.articles.map((e) => e.toEntity()).toList());
            print('Response saved in DB!');
          }
        });
  }

  @override
  Future<void> clearArticles() {
    return _articleDao.clearArticles();
  }
}
