part of 'zone_bloc.dart';

@immutable
sealed class ZoneState {}

final class ZoneInitial extends ZoneState {}

final class GetAllZoneInProgress extends ZoneState {}

final class GetAllZoneSuccess extends ZoneState {
  final List<ZoneDto> zones;

  GetAllZoneSuccess(this.zones);
}

final class GetAllZoneFailure extends ZoneState {
  final String message;

  GetAllZoneFailure(this.message);
}

final class FilterZoneSuccess extends ZoneState {
  final List<ZoneDto> zones;

  FilterZoneSuccess(this.zones);
}

final class FilterZoneFailure extends ZoneState {
  final String message;

  FilterZoneFailure(this.message);
}
