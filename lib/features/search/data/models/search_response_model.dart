import 'search_provider_model.dart';

class SearchResponseModel {
  final int? httpStatusCode;
  final dynamic errors;
  final bool? succeeded;
  final String? message;
  final SearchResponseData? data;

  const SearchResponseModel({
    this.httpStatusCode,
    this.errors,
    this.succeeded,
    this.message,
    this.data,
  });

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) =>
      SearchResponseModel(
        httpStatusCode: (json['httpStatusCode'] as num?)?.toInt(),
        errors: json['errors'],
        succeeded: json['succeeded'] as bool?,
        message: json['message'] as String?,
        data: json['data'] == null
            ? null
            : SearchResponseData.fromJson(json['data'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
    'httpStatusCode': httpStatusCode,
    'errors': errors,
    'succeeded': succeeded,
    'message': message,
    'data': data?.toJson(),
  };
}

class SearchResponseData {
  final List<SearchProviderModel>? items;
  final int? pageNumber;
  final int? pageSize;
  final int? totalCount;
  final int? totalPages;

  const SearchResponseData({
    this.items,
    this.pageNumber,
    this.pageSize,
    this.totalCount,
    this.totalPages,
  });

  factory SearchResponseData.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] ?? json['providers'] ?? json['data'];
    return SearchResponseData(
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(SearchProviderModel.fromJson)
                .toList()
          : const [],
      pageNumber: (json['pageNumber'] as num?)?.toInt(),
      pageSize: (json['pageSize'] as num?)?.toInt(),
      totalCount: (json['totalCount'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items,
    'pageNumber': pageNumber,
    'pageSize': pageSize,
    'totalCount': totalCount,
    'totalPages': totalPages,
  };
}
