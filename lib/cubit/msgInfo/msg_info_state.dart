part of 'msg_info_cubit.dart';

@immutable
sealed class MsgInfoState {}

final class MsgInfoInitial extends MsgInfoState {}

class MsgInfoLoaded extends MsgInfoState {
  final List<User> users;
  MsgInfoLoaded({
    required this.users,
  });
}
