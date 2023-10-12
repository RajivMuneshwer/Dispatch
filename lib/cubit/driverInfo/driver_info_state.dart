part of 'driver_info_cubit.dart';

@immutable
sealed class DriverInfoState {}

final class DriverInfoInitial extends DriverInfoState {}

final class DriverInfoWithData extends DriverInfoState {
  final List<String> pickups;
  final List<String> cars;
  final Map<String, Map<String, String>> json;
  DriverInfoWithData({
    required this.pickups,
    required this.cars,
    required this.json,
  });
}
