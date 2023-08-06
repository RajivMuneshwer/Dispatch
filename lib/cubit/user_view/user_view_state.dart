part of 'user_view_cubit.dart';

@immutable
abstract class UserViewState {}

class UserViewInitial extends UserViewState {}

class UserViewWithData extends UserViewState {
  final List<User> users;
  UserViewWithData({
    required this.users,
  });
}
