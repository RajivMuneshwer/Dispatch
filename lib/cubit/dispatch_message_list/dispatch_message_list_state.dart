part of 'dispatch_message_list_cubit.dart';

@immutable
abstract class DispatchUserListState {}

class DispatchUserListInitial extends DispatchUserListState {}

class DispatchUserListWithNames extends DispatchUserListState {
  final List<String> names;
  DispatchUserListWithNames({required this.names});
}
