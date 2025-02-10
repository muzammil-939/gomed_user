class ProductModel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

  ProductModel({this.statusCode, this.success, this.messages, this.data});

  factory ProductModel.initial() {
    return ProductModel(
      statusCode: 0,
      success: false,
      messages: [],
      data: [],
    );
  }

  ProductModel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return ProductModel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  ProductModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    messages = json['messages']?.cast<String>();
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;
    data['success'] = success;
    data['messages'] = messages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? productId;
  String? distributorId;
  String? productName;
  String? productDescription;
  double? price;
  String? category;
  bool? spareParts;
  String? productImage;

  Data({
    this.productId,
    this.distributorId,
    this.productName,
    this.productDescription,
    this.price,
    this.category,
    this.spareParts,
    this.productImage,
  });

  factory Data.initial() {
    return Data(
      productId: '',
      distributorId: '',
      productName: '',
      productDescription: '',
      price: 0.0,
      category: '',
      spareParts: false,
      productImage: '',
    );
  }

  Data copyWith({
    String? productId,
    String? distributorId,
    String? productName,
    String? productDescription,
    double? price,
    String? category,
    bool? spareParts,
    String? productImage,
  }) {
    return Data(
      productId: productId ?? this.productId,
      distributorId: distributorId ?? this.distributorId,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      price: price ?? this.price,
      category: category ?? this.category,
      spareParts: spareParts ?? this.spareParts,
      productImage: productImage ?? this.productImage,
    );
  }

Data.fromJson(Map<String, dynamic> json) {
  productId = json['productId'];
  distributorId = json['distributorId'];
  productName = json['productName'];
  productDescription = json['productDescription'];
  price = json['price'] is int ? (json['price'] as int).toDouble() : json['price'];
  category = json['category'];
   // Convert "true"/"false" (String) to actual boolean
  spareParts = json['spareParts'] == "true" ? true : false;
  productImage = json['productImage'];
}


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['productId'] = productId;
    data['distributorId'] = distributorId;
    data['productName'] = productName;
    data['productDescription'] = productDescription;
    data['price'] = price;
    data['category'] = category;
    data['spareParts'] = spareParts;
    data['productImage'] = productImage;
    return data;
  }
}
