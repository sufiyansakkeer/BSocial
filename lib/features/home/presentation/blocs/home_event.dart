part of 'home_bloc.dart';

/// Base class for all home events
abstract class HomeEvent extends Equatable {
  /// Constructor
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to change the current tab
class ChangeTabEvent extends HomeEvent {
  /// Constructor
  const ChangeTabEvent({required this.tabIndex});

  /// Tab index
  final int tabIndex;

  @override
  List<Object> get props => [tabIndex];
}
