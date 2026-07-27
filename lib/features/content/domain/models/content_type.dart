enum ContentType {
  privacyPolicy(slug: 'privacy-policy', titleKey: 'content.privacy_policy'),
  refundPolicy(slug: 'refund-policy', titleKey: 'content.refund_policy'),
  termsAndConditions(
    slug: 'terms-and-conditions',
    titleKey: 'content.terms_and_conditions',
  );

  const ContentType({required this.slug, required this.titleKey});

  final String slug;
  final String titleKey;

  String get apiPath => '/Content/$slug';
}
