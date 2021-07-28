import 'package:core/core/core_screen.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:presentation/src/common/constants/app_strings.dart';
import 'package:presentation/src/di/locator.dart';
import 'package:presentation/src/widgets/network_bound_widget_builder.dart';

import 'article_list_view_model.dart';

class ArticleListScreen extends CoreScreen<ArticleListViewModel> {
  @override
  Widget builder(
      BuildContext context, ArticleListViewModel viewModel, Widget? child) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.articleList)),
      body: _buildBody(context, viewModel),
    );
  }

  Widget _buildBody(BuildContext context, ArticleListViewModel viewModel) {
    return NetworkBoundWidget<List<ArticleModel>>(
        stream: viewModel.articlesStream,
        child: (context, data) => _buildListView(data, viewModel));
  }

  Widget _buildListView(
      List<ArticleModel> articleList, ArticleListViewModel viewModel) {
    return RefreshIndicator(
        onRefresh: () => viewModel.refresh(),
        child: ListView.builder(
            itemCount: articleList.length,
            itemBuilder: (context, index) =>
                _buildListViewItem(context, viewModel, articleList[index])));
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
