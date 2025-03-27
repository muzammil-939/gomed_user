class GetproductModel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

  GetproductModel({this.statusCode, this.success, this.messages, this.data});

  factory GetproductModel.initial() => GetproductModel(
        statusCode: 0,
        success: false,
        messages: [],
        data: [],
      );

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

  factory GetproductModel.fromJson(Map<String, dynamic> json) => GetproductModel(
        statusCode: json['statusCode'],
        success: json['success'],
        messages: List<String>.from(json['messages'] ?? []),
        data: (json['data'] as List?)?.map((e) => Data.fromJson(e)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'statusCode': statusCode,
        'success': success,
        'messages': messages,
        'data': data?.map((e) => e.toJson()).toList(),
      };
}

class Data {
  String? sId;
  UserId? userId;
  List<ProductIds>? productIds;
  String? location;
  String? address;
  String? status;
  String? createdAt;
  String? updatedAt;

  Data({
    this.sId,
    this.userId,
    this.productIds,
    this.location,
    this.address,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.initial() => Data(
        sId: '',
        userId: UserId.initial(),
        productIds: [],
        location: '',
        address: '',
        status: '',
        createdAt: '',
        updatedAt: '',
      );

  Data copyWith({
    String? sId,
    UserId? userId,
    List<ProductIds>? productIds,
    String? location,
    String? address,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return Data(
      sId: sId ?? this.sId,
      userId: userId ?? this.userId,
      productIds: productIds ?? this.productIds,
      location: location ?? this.location,
      address: address ?? this.address,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        sId: json['_id'],
        userId: json['userId'] != null ? UserId.fromJson(json['userId']) : null,
        productIds: (json['productIds'] as List?)
            ?.map((e) => ProductIds.fromJson(e))
            .toList(),
        location: json['location'],
        address: json['address'],
        status: json['status'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
      );

  Map<String, dynamic> toJson() => {
        '_id': sId,
        'userId': userId?.toJson(),
        'productIds': productIds?.map((e) => e.toJson()).toList(),
        'location': location,
        'address': address,
        'status': status,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class UserId {
  String? sId;
  String? name;
  String? email;
  String? mobile;
  List<String>? profileImage;

  UserId({this.sId, this.name, this.email, this.mobile, this.profileImage});

  factory UserId.initial() => UserId(
        sId: '',
        name: '',
        email: '',
        mobile: '',
        profileImage: [],
      );

  factory UserId.fromJson(Map<String, dynamic> json) => UserId(
        sId: json['_id'],
        name: json['name'],
        email: json['email'],
        mobile: json['mobile'],
        profileImage: List<String>.from(json['profileImage'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        '_id': sId,
        'name': name,
        'email': email,
        'mobile': mobile,
        'profileImage': profileImage,
      };
}

class ProductIds {
  String? sId;
  String? productName;
  String? productDescription;
  int? price;
  String? category;
  String? spareParts;
  List<String>? productImages;
  DistributorId? distributorId;

  ProductIds({
    this.sId,
    this.productName,
    this.productDescription,
    this.price,
    this.category,
    this.spareParts,
    this.productImages,
    this.distributorId,
  });

  factory ProductIds.initial() => ProductIds(
        sId: '',
        productName: '',
        productDescription: '',
        price: 0,
        category: '',
        spareParts: '',
        productImages: [],
        distributorId: DistributorId.initial(),
      );

  factory ProductIds.fromJson(Map<String, dynamic> json) => ProductIds(
        sId: json['_id'],
        productName: json['productName'],
        productDescription: json['productDescription'],
        price: json['price'],
        category: json['category'],
        spareParts: json['spareParts'],
        productImages: List<String>.from(json['productImages'] ?? []),
        distributorId: json['distributorId'] != null
            ? DistributorId.fromJson(json['distributorId'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        '_id': sId,
        'productName': productName,
        'productDescription': productDescription,
        'price': price,
        'category': category,
        'spareParts': spareParts,
        'productImages': productImages,
        'distributorId': distributorId?.toJson(),
      };
}

class DistributorId {
  String? sId;
  String? firmName;
  String? ownerName;

  DistributorId({this.sId, this.firmName, this.ownerName});

  factory DistributorId.initial() => DistributorId(
        sId: '',
        firmName: '',
        ownerName: '',
      );

  factory DistributorId.fromJson(Map<String, dynamic> json) => DistributorId(
        sId: json['_id'],
        firmName: json['firmName'],
        ownerName: json['ownerName'],
      );

  Map<String, dynamic> toJson() => {
        '_id': sId,
        'firmName': firmName,
        'ownerName': ownerName,
      };
}
