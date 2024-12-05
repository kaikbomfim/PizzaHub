import 'package:pizzahub/state.dart';
import 'package:flutter/material.dart';

class PizzaCard extends StatelessWidget {
  final dynamic pizza;

  const PizzaCard({super.key, required this.pizza});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        appState.showDetails(pizza["_id"]);
      },
      child: Card(
        child: Column(children: [
          Image.asset(pizza["pizza"]["image"],
              fit: BoxFit.cover, height: 150, width: double.infinity),
          Row(children: [
            CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Image.asset("lib/assets/images/logo.png")),
            Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(pizza["company"]["name"],
                    style: const TextStyle(fontSize: 15))),
          ]),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Text(pizza["pizza"]["name"],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16))),
          Padding(
              padding: const EdgeInsets.only(left: 10, top: 5, bottom: 10),
              child: Text(
                pizza["pizza"]["description"],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              )),
          const Spacer(),
          Row(children: [
            Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 5),
                child: Text("R\$ ${pizza['pizza']['price'].toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    )))
          ])
        ]),
      ),
    );
  }
}
