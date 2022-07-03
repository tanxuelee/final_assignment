class Cart {
  String? cartid;
  String? sjname;
  String? price;
  String? cartqty;
  String? sjid;
  String? pricetotal;

  Cart(
      {this.cartid,
      this.sjname,
      this.price,
      this.cartqty,
      this.sjid,
      this.pricetotal});

  Cart.fromJson(Map<String, dynamic> json) {
    cartid = json['cartid'];
    sjname = json['sjname'];
    price = json['price'];
    cartqty = json['cartqty'];
    sjid = json['sjid'];
    pricetotal = json['pricetotal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cartid'] = cartid;
    data['sjname'] = sjname;
    data['price'] = price;
    data['cartqty'] = cartqty;
    data['sjid'] = sjid;
    data['pricetotal'] = pricetotal;
    return data;
  }
}
