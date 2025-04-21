class GetproductModel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

  GetproductModel({this.statusCode, this.success, this.messages, this.data});

  GetproductModel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return GetproductModel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  factory GetproductModel.initial() {
    return GetproductModel(
      statusCode: 0,
      success: false,
      messages: [],
      data: [],
    );
  }

  GetproductModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    messages = json['messages'].cast<String>();
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
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
  String? sId;
  UserId? userId;
  List<ProductIds>? productIds;
  String? location;
  String? address;
  String? createdAt;
  String? updatedAt;

  Data({
    this.sId,
    this.userId,
    this.productIds,
    this.location,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  Data copyWith({
    String? sId,
    UserId? userId,
    List<ProductIds>? productIds,
    String? location,
    String? address,
    String? createdAt,
    String? updatedAt,
  }) {
    return Data(
      sId: sId ?? this.sId,
      userId: userId ?? this.userId,
      productIds: productIds ?? this.productIds,
      location: location ?? this.location,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Data.initial() {
    return Data(
      sId: '',
      userId: UserId.initial(),
      productIds: [],
      location: '',
      address: '',
      createdAt: '',
      updatedAt: '',
    );
  }

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    if (json['productIds'] != null) {
      productIds = <ProductIds>[];
      json['productIds'].forEach((v) {
        productIds!.add(ProductIds.fromJson(v));
      });
    }
    location = json['location'];
    address = json['address'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['_id'] = sId;
    if (userId != null) data['userId'] = userId!.toJson();
    if (productIds != null) {
      data['productIds'] = productIds!.map((v) => v.toJson()).toList();
    }
    data['location'] = location;
    data['address'] = address;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
class UserId {
  String? sId;
  String? name;
  String? email;
  String? mobile;
  List<String>? profileImage;

  UserId({this.sId, this.name, this.email, this.mobile, this.profileImage});

  UserId copyWith({
    String? sId,
    String? name,
    String? email,
    String? mobile,
    List<String>? profileImage,
  }) {
    return UserId(
      sId: sId ?? this.sId,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  factory UserId.initial() {
    return UserId(
      sId: '',
      name: '',
      email: '',
      mobile: '',
      profileImage: [],
    );
  }

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    mobile = json['mobile'];
    profileImage = json['profileImage'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['mobile'] = mobile;
    data['profileImage'] = profileImage;
    return data;
  }
}
class ProductIds {
  String? sId;
  int? quantity;
  String? productName;
  String? productDescription;
  int? price;
  String? category;
  List<String>? productImages;
  DistributorId? distributorId;
  String? bookingStatus;

  ProductIds({
    this.sId,
    this.quantity,
    this.productName,
    this.productDescription,
    this.price,
    this.category,
    this.productImages,
    this.distributorId,
    this.bookingStatus,
  });

  ProductIds copyWith({
    String? sId,
    int? quantity,
    String? productName,
    String? productDescription,
    int? price,
    String? category,
    List<String>? productImages,
    DistributorId? distributorId,
    String? bookingStatus,
  }) {
    return ProductIds(
      sId: sId ?? this.sId,
      quantity: quantity ?? this.quantity,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      price: price ?? this.price,
      category: category ?? this.category,
      productImages: productImages ?? this.productImages,
      distributorId: distributorId ?? this.distributorId,
      bookingStatus: bookingStatus ?? this.bookingStatus,
    );
  }

  factory ProductIds.initial() {
    return ProductIds(
      sId: '',
      quantity: 0,
      productName: '',
      productDescription: '',
      price: 0,
      category: '',
      productImages: [],
      distributorId: DistributorId.initial(),
      bookingStatus: '',
    );
  }

  ProductIds.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    quantity = json['quantity'];
    productName = json['productName'];
    productDescription = json['productDescription'];
    price = json['price'];
    category = json['category'];
    productImages = json['productImages'].cast<String>();
    distributorId = json['distributorId'] != null
        ? DistributorId.fromJson(json['distributorId'])
        : null;
    bookingStatus = json['bookingStatus'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['_id'] = sId;
    data['quantity'] = quantity;
    data['productName'] = productName;
    data['productDescription'] = productDescription;
    data['price'] = price;
    data['category'] = category;
    data['productImages'] = productImages;
    if (distributorId != null) {
      data['distributorId'] = distributorId!.toJson();
    }
    data['bookingStatus'] = bookingStatus;
    return data;
  }
}
class DistributorId {
  String? sId;
  String? firmName;
  String? ownerName;

  DistributorId({this.sId, this.firmName, this.ownerName});

  DistributorId copyWith({
    String? sId,
    String? firmName,
    String? ownerName,
  }) {
    return DistributorId(
      sId: sId ?? this.sId,
      firmName: firmName ?? this.firmName,
      ownerName: ownerName ?? this.ownerName,
    );
  }

  factory DistributorId.initial() {
    return DistributorId(
      sId: '',
      firmName: '',
      ownerName: '',
    );
  }

  DistributorId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    firmName = json['firmName'];
    ownerName = json['ownerName'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['_id'] = sId;
    data['firmName'] = firmName;
    data['ownerName'] = ownerName;
    return data;
  }
}
