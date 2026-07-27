class CreateReviewRequestDto {
  final int invoiceId;
  final int rating;
  final String ratingText;

  const CreateReviewRequestDto({
    required this.invoiceId,
    required this.rating,
    required this.ratingText,
  });

  Map<String, dynamic> toJson() => {
    'invoiceId': invoiceId,
    'rating': rating,
    'ratingText': ratingText,
  };
}
