part of 'user_view_cubit.dart';

@immutable
abstract class UserViewState {}

class UserViewInitial extends UserViewState {}

class UserViewWithData<T extends User> extends UserViewState {
  final List<T> users;
  UserViewWithData({
    required this.users,
  });
}
