import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

/// BLoC for home page
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  /// Constructor
  HomeBloc() : super(const HomeState(currentTab: 0)) {
    on<ChangeTabEvent>(_onChangeTab);
  }

  /// Handle change tab event
  void _onChangeTab(
    ChangeTabEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(HomeState(currentTab: event.tabIndex));
  }
}
