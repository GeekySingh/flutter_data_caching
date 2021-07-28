import 'package:core/core/core_screen.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:presentation/src/common/constants/app_strings.dart';
import 'package:presentation/src/common/constants/assets.dart';
import 'package:presentation/src/di/locator.dart';
import 'package:presentation/src/widgets/network_bound_widget.dart';

import 'article_detail_view_model.dart';

class ArticleDetailScreen extends CoreScreen<ArticleDetailViewModel> {
  final int id;

  ArticleDetailScreen({required this.id});

  @override
  Widget builder(
      BuildContext context, ArticleDetailViewModel viewModel, Widget? child) {
    return Scaffold(
        appBar: AppBar(title: Text(AppStrings.articleDetail)),
        body: _buildBody(context, viewModel));
  }

  Widget _buildBody(BuildContext context, ArticleDetailViewModel viewModel) {
    return NetworkBoundWidget<ArticleModel>(
        stream: viewModel.articleByIdStream(id),
        child: (context, data) => _buildArticleDetailWidget(context, data),);
  }

  Widget _buildArticleDetailWidget(
      BuildContext context, ArticleModel articleModel) {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeInImage(
            image: NetworkImage(articleModel.imageUrl),
            placeholder: AssetImage(Assets.placeholder),
            height: 300,
            fit: BoxFit.cover),
        Padding(
            padding: EdgeInsets.all(20),
            child: Text(articleModel.title,
                style: TextStyle(
                    fontSize: 22, color: Theme.of(context).accentColor))),
        Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child:
                Text(articleModel.description, style: TextStyle(fontSize: 20))),
        Padding(
            padding: EdgeInsets.only(right: 20),
            child: Align(
                child: Text("${AppStrings.publishedOn} ${articleModel.date}"),
                alignment: Alignment.centerRight)),
        Padding(
            padding: EdgeInsets.all(20),
            child: TextButton(
              child: Text(AppStrings.readFullStory,
                  style: TextStyle(
                      fontSize: 16, color: Theme.of(context).accentColor),
                  textAlign: TextAlign.end),
              onPressed: () => {},
            )),
      ],
    ));
  }

  @override
  ArticleDetailViewModel viewModelBuilder(BuildContext context) =>
      locator<ArticleDetailViewModel>();
}
