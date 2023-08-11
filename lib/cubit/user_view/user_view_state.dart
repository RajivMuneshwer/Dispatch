part of 'user_view_cubit.dart';

@immutable
abstract class UserViewState {}

class UserViewInitial extends UserViewState {}

class UserViewWithUsers<T extends User> extends UserViewState {
  final List<T> users;
  UserViewWithUsers({
    required this.users,
  });
}

class UserViewWithWidget extends UserViewState {
  final Widget widget;
  UserViewWithWidget({
    required this.widget,
  });
}
