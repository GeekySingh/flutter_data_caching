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
        loadFromDb: () => _articleDao.getArticleById(id),
        map: (entity) => entity?.toModel());
  }

  @override
  Stream<Resource<List<ArticleModel>?>> getArticles(bool forceRefresh) {
    /// get always from network in case of force refresh,
    /// otherwise use cached approach to load data
    if (forceRefresh)
      return getNetworkData<ArticleResponse, List<ArticleModel>>(
          createNetworkCall: () => _articleService.getArticles(),
          map: (response) =>
              response?.articles.map((e) => e.toModel()).toList());
    else
      return getNetworkBoundData<ArticleResponse, List<ArticleEntity>,
              List<ArticleModel>>(
          loadFromDb: () => _articleDao.getArticles(),
          createNetworkCall: () => _articleService.getArticles(),
          map: (list) => list?.map((e) => e.toModel()).toList(),
          saveNetworkResult: (response) async {
            if (response != null) {
              await _articleDao.saveArticles(
                  response.articles.map((e) => e.toEntity()).toList());
            }
          },
          onNetworkCallFailure: (ex) => {print('Network call failed: $ex')});
  }

  @override
  Future<void> clearArticles() {
    return _articleDao.clearArticles();
  }
}
