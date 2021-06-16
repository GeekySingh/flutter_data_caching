library domain;

export 'src/model/article_model.dart';
export 'src/usecase/article_use_case.dart';
export 'src/common/status.dart';
export 'src/common/resource.dart';
export 'src/common/error_type.dart';
export 'src/repository/article_repository.dart';

import 'package:domain/src/di/locator.dart';

class Domain {
  static void init() {
    /// setup required locators for domain module
    setupLocator();
  }
}