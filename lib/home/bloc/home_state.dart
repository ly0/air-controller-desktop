part of 'home_bloc.dart';

enum HomeTab { image, music, video, download, allFile, toolbox, helpAndFeedback }

extension HomeTabX  on HomeTab {
  static HomeTab convertToHomeTab(int index) {
    List<HomeTab> tabs = HomeTab.values;
    if (index >= 0 && index <= tabs.length - 1) {
      return tabs[index];
    }

    return HomeTab.image;
  }
}


class HomeState extends Equatable {
  final HomeTab tab;

  const HomeState({
    this.tab = HomeTab.image,
  });

  @override
  List<Object?> get props => [tab];

  HomeState copyWith({
    HomeTab? tab,
  }) {
    return HomeState(
      tab: tab ?? this.tab,
    );
  }
}