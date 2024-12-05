import 'package:pizzahub/state.dart';
import 'package:pizzahub/views/details.dart';
import 'package:pizzahub/views/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pizzahub/theme/theme.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => AppState(),
        child: MaterialApp(
          title: "PizzaHub",
          theme: PizzaHubTheme.lightTheme,
          darkTheme: PizzaHubTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: const MainScreen(),
        ));
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  void _lockPortraitMode() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    _lockPortraitMode();

    appState = context.watch<AppState>();

    Widget screen = const SizedBox.shrink();
    if (appState.viewState == ViewState.showingMenu) {
      screen = const Menu();
    } else if (appState.viewState == ViewState.showingDetails) {
      screen = const Details();
    }

    return screen;
  }
}
