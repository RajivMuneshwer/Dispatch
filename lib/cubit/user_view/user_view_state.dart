part of 'user_view_cubit.dart';

@immutable
sealed class UserViewState {}

class UserViewInitial extends UserViewState {}

class UserViewWithData<M> extends UserViewState {
  final M data;
  UserViewWithData({
    required this.data,
  });
}
