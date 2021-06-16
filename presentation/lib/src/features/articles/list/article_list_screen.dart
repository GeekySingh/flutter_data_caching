import 'package:core/core/core_screen.dart';
import 'package:core/widgets/network_bound_widget_builder.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:presentation/src/common/constants/app_strings.dart';
import 'package:presentation/src/di/locator.dart';

import 'article_list_view_model.dart';

class ArticleListScreen extends CoreScreen<ArticleListViewModel> {
  @override
  Widget builder(
      BuildContext context, ArticleListViewModel viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.articleList)),
      body: _buildBody(context, viewModel),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () async => await viewModel.clearAllArticleUseCase.clearArticles(),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ArticleListViewModel viewModel) {
    return NetworkBoundWidgetBuilder(
        stream: viewModel.articlesStream(),
        builder: (context, Resource<List<ArticleModel>?> snapshot) {
          switch (snapshot.status) {
            case Status.LOADING:
              if (snapshot.data == null || snapshot.data!.isEmpty)
                return Center(child: CircularProgressIndicator());
              else
                return _buildListView(snapshot.data!, viewModel);
            case Status.SUCCESS:
              return _buildListView(snapshot.data!, viewModel);
            case Status.FAILURE:
              return Center(
                  child: Text(snapshot.failureDetails?.message ?? 'Failure'));
            case Status.EXCEPTION:
            default:
              return Center(child: Text('Something went wrong'));
          }
        });
  }

  Widget _buildListView(
      List<ArticleModel> articleList, ArticleListViewModel viewModel) {
    return ListView.builder(
        itemCount: articleList.length,
        itemBuilder: (context, index) =>
            _buildListViewItem(context, viewModel, articleList[index]));
  }

  Widget _buildListViewItem(BuildContext context,
      ArticleListViewModel viewModel, ArticleModel model) {
    return ListTile(
      isThreeLine: true,
      subtitle: Text(model.date, textDirection: TextDirection.rtl),
      contentPadding: EdgeInsets.all(10),
      title: Text(model.title, style: TextStyle(fontSize: 18)),
      leading: CircleAvatar(
          backgroundImage: NetworkImage(model.imageUrl), radius: 40),
      onTap: () => viewModel.onArticleItemClicked(model.id),
    );
  }

  @override
  ArticleListViewModel viewModelBuilder(BuildContext context) =>
      locator<ArticleListViewModel>();
}
