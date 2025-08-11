part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeTabChanged extends HomeEvent {
  final HomeTab tab;

  const HomeTabChanged(this.tab);

  @override
  List<Object?> get props => [tab];
}

class HomeSubscriptionRequested extends HomeEvent {
  const HomeSubscriptionRequested();
}


class HomeProgressIndicatorStatusChanged extends HomeEvent {
  final HomeLinearProgressIndicatorStatus status;

  const HomeProgressIndicatorStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}


class HomeUpdateMobileInfo extends HomeEvent {
  final MobileInfo mobileInfo;

  const HomeUpdateMobileInfo(this.mobileInfo);

  @override
  List<Object?> get props => [mobileInfo];
}
