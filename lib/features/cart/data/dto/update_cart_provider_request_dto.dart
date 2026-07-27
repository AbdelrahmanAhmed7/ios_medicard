class UpdateCartProviderRequestDto {
  final int cartId;
  final int providerId;

  const UpdateCartProviderRequestDto({
    required this.cartId,
    required this.providerId,
  });

  Map<String, dynamic> toJson() => {'cartId': cartId, 'providerId': providerId};
}
