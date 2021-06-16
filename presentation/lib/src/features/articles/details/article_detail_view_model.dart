import 'package:core/core/core_view_model.dart';
import 'package:domain/domain.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class ArticleDetailViewModel extends CoreViewModel {
  final GetArticleByIdUseCase _articleByIdUseCase;

  ArticleDetailViewModel(this._articleByIdUseCase);

  Stream<Resource<ArticleModel?>> articleByIdStream(int id) =>
      _articleByIdUseCase.getArticle(id);
}
