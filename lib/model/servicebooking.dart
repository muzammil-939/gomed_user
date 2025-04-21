class ServicebookingModel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

  ServicebookingModel({this.statusCode, this.success, this.messages, this.data});

  factory ServicebookingModel.initial() => ServicebookingModel(
        statusCode: 0,
        success: false,
        messages: [],
        data: [],
      );

  ServicebookingModel copyWith({
    int? statusCode,
    bool? success,
    List<String>? messages,
    List<Data>? data,
  }) {
    return ServicebookingModel(
      statusCode: statusCode ?? this.statusCode,
      success: success ?? this.success,
      messages: messages ?? this.messages,
      data: data ?? this.data,
    );
  }

  ServicebookingModel.fromJson(Map<String, dynamic> json) {
  statusCode = json['statusCode'];
  success = json['success'];
  messages = json['messages'] != null ? List<String>.from(json['messages']) : [];
  if (json['data'] != null) {
    data = <Data>[];
    json['data'].forEach((v) {
      data!.add(Data.fromJson(v));
    });
  }
}


  Map<String, dynamic> toJson() => {
        'statusCode': statusCode,
        'success': success,
        'messages': messages,
        'data': data?.map((v) => v.toJson()).toList(),
      };
}

class Data {
  String? sId;
  UserId? userId;
  List<ServiceIds>? serviceIds;
  String? productId;
  String? location;
  String? address;
  String? date;
  String? time;
  String? status;
  String? serviceEngineerId;
  String? createdAt;
  String? updatedAt;

  Data({
    this.sId,
    this.userId,
    this.serviceIds,
    this.productId,
    this.location,
    this.address,
    this.date,
    this.time,
    this.status,
    this.serviceEngineerId,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.initial() => Data(
        sId: '',
        userId: UserId.initial(),
        serviceIds: [],
        productId: '',
        location: '',
        address: '',
        date: '',
        time: '',
        status: '',
        serviceEngineerId: '',
        createdAt: '',
        updatedAt: '',
      );

  Data copyWith({
    String? sId,
    UserId? userId,
    List<ServiceIds>? serviceIds,
    String? productId,
    String? location,
    String? address,
    String? date,
    String? time,
    String? status,
    String? serviceEngineerId,
    String? createdAt,
    String? updatedAt,
  }) {
    return Data(
      sId: sId ?? this.sId,
      userId: userId ?? this.userId,
      serviceIds: serviceIds ?? this.serviceIds,
      productId: productId ?? this.productId,
      location: location ?? this.location,
      address: address ?? this.address,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      serviceEngineerId: serviceEngineerId ?? this.serviceEngineerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    if (json['serviceIds'] != null) {
      serviceIds = <ServiceIds>[];
      json['serviceIds'].forEach((v) {
        serviceIds!.add(ServiceIds.fromJson(v));
      });
    }
    productId = json['productId'];
    location = json['location'];
    address = json['address'];
    date = json['date'];
    time = json['time'];
    status = json['status'];
    serviceEngineerId = json['serviceEngineerId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() => {
        '_id': sId,
        'userId': userId?.toJson(),
        'serviceIds': serviceIds?.map((v) => v.toJson()).toList(),
        'productId': productId,
        'location': location,
        'address': address,
        'date': date,
        'time': time,
        'status': status,
        'serviceEngineerId': serviceEngineerId,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class UserId {
  String? sId;
  String? mobile;
  String? name;
  String? email;
  List<String>? profileImage;

  UserId({this.sId, this.mobile, this.name, this.email, this.profileImage});

  factory UserId.initial() => UserId(
        sId: '',
        mobile: '',
        name: '',
        email: '',
        profileImage: [],
      );

  UserId copyWith({
    String? sId,
    String? mobile,
    String? name,
    String? email,
    List<String>? profileImage,
  }) {
    return UserId(
      sId: sId ?? this.sId,
      mobile: mobile ?? this.mobile,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    mobile = json['mobile'];
    name = json['name'];
    email = json['email'];
    profileImage = json['profileImage'] != null ? List<String>.from(json['profileImage']) : [];

  }

  Map<String, dynamic> toJson() => {
        '_id': sId,
        'mobile': mobile,
        'name': name,
        'email': email,
        'profileImage': profileImage,
      };
}

class ServiceIds {
  String? sId;
  String? name;
  String? details;
  int? price;
  List<String>? productIds;
  DistributorId? distributorId;

  ServiceIds({
    this.sId,
    this.name,
    this.details,
    this.price,
    this.productIds,
    this.distributorId,
  });

  factory ServiceIds.initial() => ServiceIds(
        sId: '',
        name: '',
        details: '',
        price: 0,
        productIds: [],
        distributorId: DistributorId.initial(),
      );

  ServiceIds copyWith({
    String? sId,
    String? name,
    String? details,
    int? price,
    List<String>? productIds,
    DistributorId? distributorId,
  }) {
    return ServiceIds(
      sId: sId ?? this.sId,
      name: name ?? this.name,
      details: details ?? this.details,
      price: price ?? this.price,
      productIds: productIds ?? this.productIds,
      distributorId: distributorId ?? this.distributorId,
    );
  }

  ServiceIds.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    details = json['details'];
    price = json['price'];
    productIds = json['productIds'] != null ? List<String>.from(json['productIds']) : [];
    distributorId = json['distributorId'] != null
        ? DistributorId.fromJson(json['distributorId'])
        : null;
  }

  Map<String, dynamic> toJson() => {
        '_id': sId,
        'name': name,
        'details': details,
        'price': price,
        'productIds': productIds,
        'distributorId': distributorId?.toJson(),
      };
}

class DistributorId {
  String? sId;
  String? ownerName;
  String? firmName;

  DistributorId({this.sId, this.ownerName, this.firmName});

  factory DistributorId.initial() => DistributorId(
        sId: '',
        ownerName: '',
        firmName: '',
      );

  DistributorId copyWith({
    String? sId,
    String? ownerName,
    String? firmName,
  }) {
    return DistributorId(
      sId: sId ?? this.sId,
      ownerName: ownerName ?? this.ownerName,
      firmName: firmName ?? this.firmName,
    );
  }

  DistributorId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    ownerName = json['ownerName'];
    firmName = json['firmName'];
  }

  Map<String, dynamic> toJson() => {
        '_id': sId,
        'ownerName': ownerName,
        'firmName': firmName,
      };
}
