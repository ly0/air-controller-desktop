import 'dart:async';

import 'package:air_controller/bootstrap.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/mobile_info.dart';
import '../../repository/common_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeLinearProgressIndicatorStatus extends Equatable {
  final bool visible;
  final int current;
  final int total;

  const HomeLinearProgressIndicatorStatus(
      {this.visible = false, this.current = 0, this.total = 0});

  @override
  List<Object?> get props => [visible, current, total];
}


class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final CommonRepository _commonRepository;
  final StreamController<HomeLinearProgressIndicatorStatus>
      _progressIndicatorStreamController = StreamController();
  final StreamController<MobileInfo> _updateMobileInfoStreamController =
      StreamController();

  Stream<HomeLinearProgressIndicatorStatus> get progressIndicatorStream =>
      _progressIndicatorStreamController.stream;
  Stream<MobileInfo> get updateMobileInfoStream =>
      _updateMobileInfoStreamController.stream;

  HomeBloc({required CommonRepository commonRepository})
      : _commonRepository = commonRepository,
        super(HomeState(tab: HomeTab.image)) {
    on<HomeTabChanged>(_onHomeTabChanged);
    on<HomeSubscriptionRequested>(_onSubscriptionRequested);
    on<HomeProgressIndicatorStatusChanged>(_onProgressIndicatorStatusChanged);
    on<HomeUpdateMobileInfo>(_onUpdateMobileInfo);
  }

  void _onHomeTabChanged(HomeTabChanged event, Emitter<HomeState> emit) {
    emit(state.copyWith(tab: event.tab));
  }

  void _onSubscriptionRequested(
      HomeSubscriptionRequested event, Emitter<HomeState> emit) async {
    try {
      MobileInfo mobileInfo = await _commonRepository.getMobileInfo();

      _updateMobileInfoStreamController.add(mobileInfo);
    } catch (e) {
      logger.e("_onSubscriptionRequested: ${e.toString()}");
    }
  }


  void _onProgressIndicatorStatusChanged(
      HomeProgressIndicatorStatusChanged event, Emitter<HomeState> emit) async {
    if (_progressIndicatorStreamController.isClosed) return;

    _progressIndicatorStreamController.add(event.status);
  }


  void _onUpdateMobileInfo(
      HomeUpdateMobileInfo event, Emitter<HomeState> emit) {
    _updateMobileInfoStreamController.add(event.mobileInfo);
  }

  @override
  Future<void> close() {
    _progressIndicatorStreamController.close();
    _updateMobileInfoStreamController.close();
    return super.close();
  }
}
