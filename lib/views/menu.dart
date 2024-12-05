import 'dart:convert';

import 'package:pizzahub/authenticator.dart';
import 'package:pizzahub/components/pizzacard.dart';
import 'package:pizzahub/state.dart';
import 'package:flat_list/flat_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MenuState();
  }
}

const int pageSize = 4;

class _MenuState extends State<Menu> {
  late dynamic _staticFeed;
  List<dynamic> _pizzas = [];

  int _nextPage = 1;
  bool _loading = false;

  late TextEditingController _filterController;
  String _filter = "";

  @override
  void initState() {
    super.initState();

    ToastContext().init(context);

    _filterController = TextEditingController();
    _loadStaticFeed();
  }

  Future<void> _loadStaticFeed() async {
    final String jsonContent =
        await rootBundle.loadString("lib/assets/json/pizzas.json");
    _staticFeed = await json.decode(jsonContent);

    _loadPizzas();
  }

  void _loadPizzas() {
    setState(() {
      _loading = true;
    });

    var morePizzas = [];
    if (_filter.isNotEmpty) {
      _staticFeed["pizzas"].where((item) {
        String name = item["pizza"]["name"];

        return name.toLowerCase().contains(_filter.toLowerCase());
      }).forEach((item) {
        morePizzas.add(item);
      });
    } else {
      morePizzas = _pizzas;

      final totalToLoad = _nextPage * pageSize;
      if (_staticFeed["pizzas"].length >= totalToLoad) {
        morePizzas = _staticFeed["pizzas"].sublist(0, totalToLoad);
      }
    }

    setState(() {
      _pizzas = morePizzas;
      _nextPage = _nextPage + 1;

      _loading = false;
    });
  }

  Future<void> _refreshPizzas() async {
    _pizzas = [];
    _nextPage = 1;

    _loadPizzas();
  }

  @override
  Widget build(BuildContext context) {
    bool loggedUser = appState.user != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 10, left: 60, right: 20),
              child: TextField(
                controller: _filterController,
                onSubmitted: (value) {
                  _filter = value;

                  _refreshPizzas();
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          loggedUser
              ? IconButton(
                  onPressed: () {
                    Authenticator.logout().then((_) {
                      setState(() {
                        appState.onLogout();
                      });

                      Toast.show("Você saiu da sua conta.",
                          duration: Toast.lengthLong, gravity: Toast.bottom);
                    });
                  },
                  icon: const Icon(Icons.logout),
                )
              : IconButton(
                  onPressed: () {
                    Authenticator.login().then((user) {
                      setState(() {
                        appState.onLogin(user);
                      });

                      Toast.show("Login realizado com sucesso.",
                          duration: Toast.lengthLong, gravity: Toast.bottom);
                    });
                  },
                  icon: const Icon(Icons.login),
                ),
        ],
      ),
      body: FlatList(
        data: _pizzas,
        numColumns: 2,
        loading: _loading,
        onRefresh: () {
          _filter = "";
          _filterController.clear();

          return _refreshPizzas();
        },
        onEndReached: () => _loadPizzas(),
        buildItem: (item, int index) {
          return SizedBox(
            height: 400,
            child: PizzaCard(pizza: item),
          );
        },
      ),
    );
  }
}
