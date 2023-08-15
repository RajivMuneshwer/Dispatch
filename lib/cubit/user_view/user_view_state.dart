part of 'user_view_cubit.dart';

@immutable
sealed class UserViewState {}

class UserViewInitial extends UserViewState {}

class UserViewWithData<M> extends UserViewState {
  final M data;
  final bool canUpdate;
  UserViewWithData({
    required this.data,
    required this.canUpdate,
  });
}
