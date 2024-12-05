// ignore_for_file: unnecessary_getters_setters

import 'package:pizzahub/authenticator.dart';
import 'package:flutter/material.dart';

enum ViewState { showingMenu, showingDetails }

class AppState extends ChangeNotifier {
  ViewState _viewState = ViewState.showingMenu;
  ViewState get viewState => _viewState;

  late int _idPizza;
  int get idPizza => _idPizza;

  User? _user;
  User? get user => _user;
  set user(User? user) {
    _user = user;
  }

  void showMenu() {
    _viewState = ViewState.showingMenu;

    notifyListeners();
  }

  void showDetails(int idPizza) {
    _viewState = ViewState.showingDetails;
    _idPizza = idPizza;

    notifyListeners();
  }

  void onLogin(User? user) {
    _user = user;

    notifyListeners();
  }

  void onLogout() {
    _user = null;

    notifyListeners();
  }
}

late AppState appState;
