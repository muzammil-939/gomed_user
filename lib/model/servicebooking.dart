class ServicebookingModel {
  int? statusCode;
  bool? success;
  List<String>? messages;
  List<Data>? data;

  ServicebookingModel({this.statusCode, this.success, this.messages, this.data});

  ServicebookingModel.fromJson(Map<String, dynamic> json) {
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
    return {
      'statusCode': statusCode,
      'success': success,
      'messages': messages,
      'data': data?.map((v) => v.toJson()).toList(),
    };
  }

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

  factory ServicebookingModel.initial() => ServicebookingModel(
        statusCode: 0,
        success: false,
        messages: [],
        data: [],
      );
}

class Data {
  String? sId;
  String? serviceEngineerId;
  UserId? userId;
  List<ServiceIds>? serviceIds;
  String? location;
  String? address;
  String? status;
  String? createdAt;
  String? updatedAt;

  Data({this.sId,this.serviceEngineerId, this.userId, this.serviceIds, this.location, this.address, this.status, this.createdAt, this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    serviceEngineerId = json['serviceEngineerId'];
    userId = json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    if (json['serviceIds'] != null) {
      serviceIds = <ServiceIds>[];
      json['serviceIds'].forEach((v) {
        serviceIds!.add(ServiceIds.fromJson(v));
      });
    }
    location = json['location'];
    address = json['address'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'serviceEngineerId': serviceEngineerId,
      'userId': userId?.toJson(),
      'serviceIds': serviceIds?.map((v) => v.toJson()).toList(),
      'location': location,
      'address': address,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Data copyWith({
    String? sId,
    String? serviceEngineerId,
    UserId? userId,
    List<ServiceIds>? serviceIds,
    String? location,
    String? address,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return Data(
      sId: sId ?? this.sId,
      serviceEngineerId: serviceEngineerId ?? this.serviceEngineerId,
      userId: userId ?? this.userId,
      serviceIds: serviceIds ?? this.serviceIds,
      location: location ?? this.location,
      address: address ?? this.address,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Data.initial() => Data(
        sId: "",
        serviceEngineerId: '',
        userId: UserId.initial(),
        serviceIds: [],
        location: "",
        address: "",
        status: "",
        createdAt: "",
        updatedAt: "",
      );
}

class UserId {
  String? sId;
  String? name;
  String? email;
  String? mobile;
  List<String>? profileImage;

  UserId({this.sId, this.name, this.email, this.mobile, this.profileImage});

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    mobile = json['mobile'];
    profileImage = json['profileImage'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'name': name,
      'email': email,
      'mobile': mobile,
      'profileImage': profileImage,
    };
  }

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

  factory UserId.initial() => UserId(
        sId: "",
        name: "",
        email: "",
        mobile: "",
        profileImage: [],
      );
}

class ServiceIds {
  String? sId;
  String? name;
  String? details;
  int? price;
  List<String>? productIds;
  DistributorId? distributorId;

  ServiceIds({this.sId, this.name, this.details, this.price, this.productIds, this.distributorId});

  ServiceIds.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    details = json['details'];
    price = json['price'];
    productIds = json['productIds'].cast<String>();
    distributorId = json['distributorId'] != null ? DistributorId.fromJson(json['distributorId']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'name': name,
      'details': details,
      'price': price,
      'productIds': productIds,
      'distributorId': distributorId?.toJson(),
    };
  }

  factory ServiceIds.initial() => ServiceIds(
        sId: "",
        name: "",
        details: "",
        price: 0,
        productIds: [],
        distributorId: DistributorId.initial(),
      );
}

class DistributorId {
  String? sId;
  String? firmName;
  String? ownerName;

  DistributorId({this.sId, this.firmName, this.ownerName});

  DistributorId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    firmName = json['firmName'];
    ownerName = json['ownerName'];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'firmName': firmName,
      'ownerName': ownerName,
    };
  }

  factory DistributorId.initial() => DistributorId(
        sId: "",
        firmName: "",
        ownerName: "",
      );
}
