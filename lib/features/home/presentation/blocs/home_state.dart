part of 'home_bloc.dart';

/// Home state
class HomeState extends Equatable {
  /// Constructor
  const HomeState({required this.currentTab});

  /// Current tab index
  final int currentTab;

  @override
  List<Object> get props => [currentTab];
}
