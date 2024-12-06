import 'dart:convert';

import 'package:pizzahub/state.dart';
import 'package:flat_list/flat_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:intl/intl.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:toast/toast.dart';

class Details extends StatefulWidget {
  const Details({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DetailsState();
  }
}

enum _PizzaStatus { notLoaded, hasPizza, noPizza }

class _DetailsState extends State<Details> {
  late dynamic _staticFeed;
  late dynamic _staticComments;

  _PizzaStatus _pizzaStatus = _PizzaStatus.notLoaded;
  late dynamic _pizza;

  List<dynamic> _comments = [];
  bool _loadingComments = false;
  bool _hasComments = false;

  late TextEditingController _newCommentController;

  late PageController _pageController;
  late int _selectedSlide;

  @override
  void initState() {
    super.initState();

    ToastContext().init(context);

    _loadStaticFeed();
    _initializeSlides();

    _newCommentController = TextEditingController();
  }

  void _initializeSlides() {
    _selectedSlide = 0;
    _pageController = PageController(initialPage: _selectedSlide);
  }

  Future<void> _loadStaticFeed() async {
    String jsonContent =
        await rootBundle.loadString("lib/assets/json/pizzas.json");
    _staticFeed = await json.decode(jsonContent);

    jsonContent = await rootBundle.loadString("lib/assets/json/comments.json");
    _staticComments = await json.decode(jsonContent);

    _loadPizza();
    _loadComments();
  }

  void _loadPizza() {
    setState(() {
      _pizza = _staticFeed['pizzas']
          .firstWhere((pizza) => pizza["_id"] == appState.idPizza);

      _pizzaStatus =
          _pizza != null ? _PizzaStatus.hasPizza : _PizzaStatus.noPizza;
    });
  }

  void _loadComments() {
    setState(() {
      _loadingComments = true;
    });

    var moreComments = [];
    _staticComments["comments"].where((item) {
      return item["pizzaId"] == appState.idPizza;
    }).forEach((item) {
      moreComments.add(item);
    });

    setState(() {
      _loadingComments = false;
      _comments = moreComments;

      _hasComments = _comments.isNotEmpty;
    });
  }

  Widget _showPizzaNotFoundMessage() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('PizzaHub', style: TextStyle(color: Colors.orange)),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              appState.showMenu();
            },
          )
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 32, color: Colors.red),
            Text("Pizza não encontrada",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
            Text("Por favor, selecione outra pizza do menu.",
                style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _showNoCommentsMessage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 32, color: Colors.red),
          Text("Nenhum comentário ainda...",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
        ],
      ),
    );
  }

  Widget _showComments() {
    return Expanded(
      child: FlatList(
        data: _comments,
        loading: _loadingComments,
        buildItem: (item, index) {
          bool isUserComment = appState.user != null &&
              appState.user!.email == item["user"]["email"];

          return Dismissible(
            key: Key(item["_id"].toString()),
            direction: isUserComment
                ? DismissDirection.endToStart
                : DismissDirection.none,
            background: Container(
              alignment: Alignment.centerRight,
              child: const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Icon(Icons.delete, color: Colors.red),
              ),
            ),
            child: Card(
              color: isUserComment ? Colors.green[100] : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item["content"], style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(item["user"]["name"],
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                final dismissedComment = item;
                setState(() {
                  _comments.removeAt(index);
                });

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Deseja excluir o seu comentário?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _comments.insert(index, dismissedComment);
                            });

                            Navigator.of(context).pop();
                          },
                          child: const Text("NÃO"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {});

                            Navigator.of(context).pop();
                          },
                          child: const Text("SIM"),
                        ),
                      ],
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }

  void _addComment() {
    String content = _newCommentController.text.trim();
    if (content.isNotEmpty) {
      final comment = {
        "content": content,
        "user": {
          "name": appState.user!.name,
          "email": appState.user!.email,
        },
        "datetime": DateTime.now().toString(),
        "pizzaId": appState.idPizza,
      };

      setState(() {
        _comments.insert(0, comment);
      });

      _newCommentController.clear();
    } else {
      Toast.show("Digite um comentário",
          duration: Toast.lengthLong, gravity: Toast.bottom);
    }
  }

  Widget _showPizzaDetails() {
    bool isUserLoggedIn = appState.user != null;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Row(children: [
          Row(children: [
            Image.asset('lib/assets/images/logo.png', width: 38),
            Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
                child: Text(
                  _pizza["company"]["name"],
                  style: const TextStyle(fontSize: 15),
                ))
          ]),
          const Spacer(),
          GestureDetector(
            onTap: () {
              appState.showMenu();
            },
            child: const Icon(Icons.arrow_back, size: 30),
          )
        ]),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 230,
            child: Stack(children: [
              PageView.builder(
                itemCount: 3,
                controller: _pageController,
                onPageChanged: (slide) {
                  setState(() {
                    _selectedSlide = slide;
                  });
                },
                itemBuilder: (context, pagePosition) {
                  return Image.asset(
                    _pizza["pizza"]["image"],
                    fit: BoxFit.cover,
                  );
                },
              ),
              Align(
                  alignment: Alignment.topRight,
                  child: Column(children: [
                    IconButton(
                        onPressed: () {
                          final texto =
                              '${_pizza["pizza"]["name"]} por R\$ ${_pizza["pizza"]["price"].toString()} disponível na Pizza Hub.';
                          FlutterShare.share(title: "PizzaHub", text: texto);
                        },
                        icon: const Icon(Icons.share),
                        color: Colors.orange,
                        iconSize: 26)
                  ]))
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: PageViewDotIndicator(
              currentItem: _selectedSlide,
              count: 3,
              unselectedColor: Colors.grey,
              selectedColor: Colors.orange,
              duration: const Duration(milliseconds: 200),
              boxShape: BoxShape.circle,
            ),
          ),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      _pizza["pizza"]["name"],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    )),
                Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text("Tipo: ${_pizza["pizza"]["description"]}",
                        style: const TextStyle(fontSize: 12))),
                Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(_pizza["pizza"]["type"],
                        style: const TextStyle(fontSize: 12))),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    isUserLoggedIn
                        ? "Ingredientes: ${_pizza["pizza"]["ingredients"].join(", ")}"
                        : "Ingredientes não disponíveis",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                  child: Row(
                    children: [
                      const Text(
                        "Tamanhos disponíveis: ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            _pizza["pizza"]["sizes"].keys.map<Widget>((size) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "$size: R\$ ${_pizza["pizza"]["sizes"][size].toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const Center(
              child: Text(
            "Comentários",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          )),
          isUserLoggedIn
              ? Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: TextField(
                      controller: _newCommentController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black87, width: 0.0),
                          ),
                          border: const OutlineInputBorder(),
                          hintStyle: const TextStyle(fontSize: 14),
                          hintText: 'Faça um comentário...',
                          suffixIcon: GestureDetector(
                              onTap: () {
                                _addComment();
                              },
                              child: const Icon(Icons.send,
                                  color: Colors.black87)))))
              : const SizedBox.shrink(),
          _hasComments ? _showComments() : _showNoCommentsMessage()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget details = const SizedBox.shrink();

    if (_pizzaStatus == _PizzaStatus.notLoaded) {
      details = const SizedBox.shrink();
    } else if (_pizzaStatus == _PizzaStatus.hasPizza) {
      details = _showPizzaDetails();
    } else {
      details = _showPizzaNotFoundMessage();
    }

    return details;
  }
}
