import 'package:core/service/navigation_service.dart';
import 'package:core/src/di/locator.dart';
import 'package:stacked/stacked.dart';

abstract class CoreViewModel extends BaseViewModel {
  final NavigationService navigationService = locator<NavigationService>();
}
