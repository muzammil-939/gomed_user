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
    data['statusCode'] = this.statusCode;
    data['success'] = this.success;
    data['messages'] = this.messages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? distributorId;
  String? productId;
  String? parentId;
  String? productName;
  String? productDescription;
  String? categoryId;
  String? categoryName;
  int? price;
  int? quantity;
  List<String>? productImages;
  String? adminApproval;
  bool? activated;

  Data({
    this.distributorId,
    this.productId,
    this.parentId,
    this.productName,
    this.productDescription,
    this.categoryId,
    this.categoryName,
    this.price,
    this.quantity,
    this.productImages,
    this.adminApproval,
    this.activated,
  });

  factory Data.initial() {
    return Data(
      distributorId: '',
      productId: '',
      parentId: '',
      productName: '',
      productDescription: '',
      categoryId: '',
      categoryName: '',
      price: 0,
      quantity: 0,
      productImages: [],
      adminApproval: '',
      activated: false,
    );
  }

  Data copyWith({
    String? distributorId,
    String? productId,
    String? parentId,
    String? productName,
    String? productDescription,
    String? categoryId,
    String? categoryName,
    int? price,
    int? quantity,
    List<String>? productImages,
    String? adminApproval,
    bool? activated,
  }) {
    return Data(
      distributorId: distributorId ?? this.distributorId,
      productId: productId ?? this.productId,
      parentId: parentId ?? this.parentId,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      productImages: productImages ?? this.productImages,
      adminApproval: adminApproval ?? this.adminApproval,
      activated: activated ?? this.activated,
    );
  }

  Data.fromJson(Map<String, dynamic> json) {
    distributorId = json['distributorId'];
    productId = json['productId'];
    parentId = json['parentId'];
    productName = json['productName'];
    productDescription = json['productDescription'];
    categoryId = json['categoryId'];
    categoryName = json['categoryName'];
    price = json['price'];
    quantity = json['quantity'];
    productImages = json['productImages'].cast<String>();
    adminApproval = json['adminApproval'];
    activated = json['activated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['distributorId'] = this.productId;
    data['productId'] = this.productId;
    data['parentId'] = this.parentId;
    data['productName'] = this.productName;
    data['productDescription'] = productDescription;
    data['categoryId'] = this.categoryId;
    data['categoryName'] = this.categoryName;
    data['price'] = this.price;
    data['quantity'] = this.quantity;
    data['productImages'] = productImages;
    data['adminApproval'] = this.adminApproval;
    data['activated'] = this.activated;
    return data;
  }
}
