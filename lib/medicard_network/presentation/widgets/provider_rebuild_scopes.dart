import '../../logic/provider_page_state.dart';

/// Single source of truth for which state slice each provider-page section
/// renders. Widgets reference these in `buildWhen`; unit tests assert the
/// scoping directly, so a search keystroke can never silently start
/// rebuilding the whole screen again.
abstract final class ProviderRebuildScopes {
  static bool isHeaderSliceChanged(
    ProviderPageState previous,
    ProviderPageState current,
  ) =>
      previous.providerData != current.providerData ||
      previous.isProviderLoading != current.isProviderLoading ||
      previous.providerError != current.providerError ||
      previous.currentView != current.currentView;

  static bool isSearchRowSliceChanged(
    ProviderPageState previous,
    ProviderPageState current,
  ) =>
      previous.currentView != current.currentView ||
      previous.catalogView != current.catalogView;

  static bool isCartBarSliceChanged(
    ProviderPageState previous,
    ProviderPageState current,
  ) =>
      previous.getCartItemCount() != current.getCartItemCount();

  /// Header-only fields are excluded: they have their own builder and must
  /// not rebuild the lists.
  static bool isContentSliceChanged(
    ProviderPageState previous,
    ProviderPageState current,
  ) =>
      previous.currentView != current.currentView ||
      previous.searchQuery != current.searchQuery ||
      previous.categoryTabs != current.categoryTabs ||
      previous.selectedCategoryIndex != current.selectedCategoryIndex ||
      previous.services != current.services ||
      previous.fullServices != current.fullServices ||
      previous.isServicesLoading != current.isServicesLoading ||
      previous.isServicesLoadingMore != current.isServicesLoadingMore ||
      previous.servicesHasMore != current.servicesHasMore ||
      previous.servicesError != current.servicesError ||
      previous.packages != current.packages ||
      previous.fullPackages != current.fullPackages ||
      previous.isPackagesLoading != current.isPackagesLoading ||
      previous.isPackagesLoadingMore != current.isPackagesLoadingMore ||
      previous.packagesHasMore != current.packagesHasMore ||
      previous.packagesError != current.packagesError ||
      previous.reviews != current.reviews ||
      previous.fullReviews != current.fullReviews ||
      previous.isReviewsLoading != current.isReviewsLoading ||
      previous.isReviewsLoadingMore != current.isReviewsLoadingMore ||
      previous.reviewsHasMore != current.reviewsHasMore ||
      previous.reviewsError != current.reviewsError ||
      previous.pendingCartActionIds != current.pendingCartActionIds ||
      previous.pendingPackageInvoiceIds !=
          current.pendingPackageInvoiceIds;

  static bool isPackageSheetSliceChanged(
    int packageId,
    ProviderPageState previous,
    ProviderPageState current,
  ) =>
      previous.packageDetailsById[packageId] !=
          current.packageDetailsById[packageId] ||
      previous.loadingPackageDetailsIds.contains(packageId) !=
          current.loadingPackageDetailsIds.contains(packageId) ||
      previous.packageDetailsErrors[packageId] !=
          current.packageDetailsErrors[packageId];
}
