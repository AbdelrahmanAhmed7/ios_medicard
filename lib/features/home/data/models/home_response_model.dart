import 'package:json_annotation/json_annotation.dart';

part 'home_response_model.g.dart';

@JsonSerializable(createFactory: false)
class HomeResponseModel {
  final int? httpStatusCode;
  final List<String>? errors;
  final bool? succeeded;
  final String? message;
  final HomeDataModel? data;

  const HomeResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory HomeResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return HomeResponseModel(
      httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
      errors: _stringList(json['errors']),
      succeeded: json['succeeded'] as bool?,
      message: json['message']?.toString(),
      data: data is Map<String, dynamic> ? HomeDataModel.fromJson(data) : null,
    );
  }

  Map<String, dynamic> toJson() => _$HomeResponseModelToJson(this);
}

List<String>? _stringList(dynamic value) {
  if (value == null) return null;
  if (value is List) return value.map((e) => e.toString()).toList();
  return [value.toString()];
}

String? _stringValue(dynamic value) => value?.toString();

int? _intValue(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _doubleValue(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

@JsonSerializable()
class HomeDataModel {
  final List<HomeSlider>? sliders;
  final List<HomePendingAppointment>? pendingAppointments;
  final List<HomeNearestProvider>? nearestProviders;
  final List<HomePackage>? packages;

  const HomeDataModel({
    this.sliders,
    this.pendingAppointments,
    this.nearestProviders,
    this.packages,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) =>
      _$HomeDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$HomeDataModelToJson(this);
}

@JsonSerializable(createFactory: false)
class HomeSlider {
  final int? id;
  final String? imageUrl;
  final int? providerId;
  final String? providerName;

  const HomeSlider({
    this.id,
    this.imageUrl,
    this.providerId,
    this.providerName,
  });

  factory HomeSlider.fromJson(Map<String, dynamic> json) => HomeSlider(
    id: _intValue(json['id']),
    imageUrl: _stringValue(json['imageUrl']),
    providerId: _intValue(json['providerId']),
    providerName: _stringValue(json['providerName']),
  );

  Map<String, dynamic> toJson() => _$HomeSliderToJson(this);
}

@JsonSerializable(createFactory: false)
class HomePendingAppointment {
  final int? invoiceId;
  final int? providerId;
  final int? providerBranchId;
  final String? providerName;
  final String? providerImageUrl;
  final String? branchName;
  final String? service;
  final String? status;
  final String? date;

  const HomePendingAppointment({
    this.invoiceId,
    this.providerId,
    this.providerBranchId,
    this.providerName,
    this.providerImageUrl,
    this.branchName,
    this.service,
    this.status,
    this.date,
  });

  factory HomePendingAppointment.fromJson(Map<String, dynamic> json) =>
      HomePendingAppointment(
        invoiceId: _intValue(json['invoiceId']),
        providerId: _intValue(json['providerId']),
        providerBranchId: _intValue(json['providerBranchId']),
        providerName: _stringValue(json['providerName']),
        providerImageUrl: _stringValue(json['providerImageUrl']),
        branchName: _stringValue(json['branchName']),
        service: _stringValue(json['service']),
        status: _stringValue(json['status']),
        date: _stringValue(json['date']),
      );

  Map<String, dynamic> toJson() => _$HomePendingAppointmentToJson(this);
}

@JsonSerializable(createFactory: false)
class HomeNearestProvider {
  final int? providerId;
  final int? providerBranchId;
  final String? providerName;
  final String? providerImageUrl;
  final String? branchName;
  final String? fullAddress;
  final String? mapUrl;
  final double? distanceKm;

  const HomeNearestProvider({
    this.providerId,
    this.providerBranchId,
    this.providerName,
    this.providerImageUrl,
    this.branchName,
    this.fullAddress,
    this.mapUrl,
    this.distanceKm,
  });

  factory HomeNearestProvider.fromJson(Map<String, dynamic> json) =>
      HomeNearestProvider(
        providerId: _intValue(json['providerId']),
        providerBranchId: _intValue(json['providerBranchId']),
        providerName: _stringValue(json['providerName']),
        providerImageUrl: _stringValue(json['providerImageUrl']),
        branchName: _stringValue(json['branchName']),
        fullAddress: _stringValue(json['fullAddress']),
        mapUrl: _stringValue(json['mapUrl']),
        distanceKm: _doubleValue(json['distanceKm']),
      );

  Map<String, dynamic> toJson() => _$HomeNearestProviderToJson(this);
}

@JsonSerializable(createFactory: false)
class HomePackage {
  final int? packageId;
  final int? providerId;
  final int? providerBranchId;
  final String? providerName;
  final String? name;
  final String? imageUrl;
  final String? description;
  final double? priceBefore;
  final double? priceAfter;
  final double? discountPercentage;
  final int? servicesCount;

  const HomePackage({
    this.packageId,
    this.providerId,
    this.providerBranchId,
    this.providerName,
    this.name,
    this.imageUrl,
    this.description,
    this.priceBefore,
    this.priceAfter,
    this.discountPercentage,
    this.servicesCount,
  });

  factory HomePackage.fromJson(Map<String, dynamic> json) => HomePackage(
    packageId: _intValue(json['packageId']),
    providerId: _intValue(json['providerId']),
    providerBranchId: _intValue(json['providerBranchId']),
    providerName: _stringValue(json['providerName']),
    name: _stringValue(json['name']),
    imageUrl: _stringValue(json['imageUrl']),
    description: _stringValue(json['description']),
    priceBefore: _doubleValue(json['priceBefore']),
    priceAfter: _doubleValue(json['priceAfter']),
    discountPercentage: _doubleValue(json['discountPercentage']),
    servicesCount: _intValue(json['servicesCount']),
  );

  Map<String, dynamic> toJson() => _$HomePackageToJson(this);
}
