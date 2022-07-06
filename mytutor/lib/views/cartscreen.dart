import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mytutor/views/paymentscreen.dart';
import '../models/user.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/cart.dart';

class CartScreen extends StatefulWidget {
  final User user;
  const CartScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Cart> cartList = <Cart>[];
  String titlecenter = "Loading...";
  late double screenHeight, screenWidth, resWidth;
  double totalpayable = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      resWidth = screenWidth;
      //rowcount = 2;
    } else {
      resWidth = screenWidth * 0.75;
      //rowcount = 3;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 5),
        child: Column(
          children: [
            Text(titlecenter,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
                child: GridView.count(
                    crossAxisCount: 1,
                    childAspectRatio: (1 / 0.6),
                    children: List.generate(cartList.length, (index) {
                      return InkWell(
                          child: Card(
                              color: Colors.grey[200],
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 4,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CachedNetworkImage(
                                          imageUrl: CONSTANTS.server +
                                              "/mytutor/mobile/assets/courses/" +
                                              cartList[index].sjid.toString() +
                                              '.png',
                                          fit: BoxFit.cover,
                                          width: resWidth / 2,
                                          placeholder: (context, url) =>
                                              const LinearProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      )),
                                  Expanded(
                                      flex: 6,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 0, 16, 0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cartList[index].sjname.toString(),
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Row(
                                              children: [
                                                Text("\nRM " +
                                                    double.parse(cartList[index]
                                                            .price
                                                            .toString())
                                                        .toStringAsFixed(2) +
                                                    "\n"),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                ElevatedButton(
                                                    onPressed: () =>
                                                        _confirmationDelete(
                                                            index),
                                                    child: const Icon(
                                                        Icons.delete))
                                              ],
                                            )
                                          ],
                                        ),
                                      ))
                                ],
                              )));
                    }))),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Total Payable: RM " + totalpayable.toStringAsFixed(2),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                        onPressed: _onPaynowDialog,
                        child: const Text("Pay Now"))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _loadCart() {
    http.post(Uri.parse(CONSTANTS.server + "/mytutor/mobile/php/load_cart.php"),
        body: {
          'user_email': widget.user.email,
        }).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        return http.Response(
            'Error', 408); // Request Timeout response status code
      },
    ).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        titlecenter = "Timeout Please retry again later";
        return http.Response(
            'Error', 408); // Request Timeout response status code
      },
    ).then((response) {
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        var extractdata = jsondata['data'];
        if (extractdata['cart'] != null) {
          cartList = <Cart>[];
          extractdata['cart'].forEach((v) {
            cartList.add(Cart.fromJson(v));
          });
          int qty = 0;
          totalpayable = 0.00;
          for (var element in cartList) {
            qty = qty + int.parse(element.cartqty.toString());
            totalpayable =
                totalpayable + double.parse(element.pricetotal.toString());
          }
          titlecenter = qty.toString() + " Subjects in Your Cart";
          setState(() {});
        }
      } else {
        titlecenter = "Your Cart is Empty";
        cartList.clear();
        setState(() {});
      }
    });
  }

  void _deleteItem(int index) {
    http.post(
        Uri.parse(CONSTANTS.server + "/mytutor/mobile/php/delete_cart.php"),
        body: {
          'user_email': widget.user.email,
          'cartid': cartList[index].cartid
        }).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        return http.Response(
            'Error', 408); // Request Timeout response status code
      },
    ).then((response) {
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        _loadCart();
      } else {
        Fluttertoast.showToast(
            msg: "Failed",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      }
    });
  }

  void _onPaynowDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Pay Now",
            style: TextStyle(),
          ),
          content: const Text("Are you sure?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (content) => PaymentScreen(
                            user: widget.user, totalpayable: totalpayable)));
                _loadCart();
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _confirmationDelete(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text("Delete subject",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("Are you sure?"),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () async {
                _deleteItem(index);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
