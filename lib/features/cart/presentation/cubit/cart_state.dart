import '../../../../features/family_members/data/models/family_member_model.dart';
import '../../../../network/data/provider_page_response_model.dart';
import '../../domain/models/cart.dart';
import '../../domain/models/category_services.dart';
import '../../domain/models/provider_option.dart';

enum CartPaymentMethod { cash, visa }

class CartState {
  final Cart? cart;
  final bool isCartLoading;
  final String? cartError;
  final CategoryServices? categoryServices;
  final bool isCategoryServicesLoading;
  final String? categoryServicesError;
  final Set<int> pendingServiceIds;

  // choose-providers state
  final List<ProviderOption> providers;
  final bool isProvidersLoading;
  final String? providersError;
  final bool isAssigningProvider;
  final String? assignProviderError;

  /// The provider the user has selected in the choose-provider screen.
  final ProviderOption? selectedProvider;
  final ProviderOption? checkoutProvider;
  final List<ProviderBranch> checkoutBranches;
  final ProviderBranch? selectedBranch;
  final bool isCheckoutLoading;
  final String? checkoutError;
  final List<FamilyMemberModel> familyMembers;
  final bool isFamilyMembersLoading;
  final String? familyMembersError;
  final FamilyMemberModel? selectedFamilyMember;
  final CartPaymentMethod paymentMethod;
  final bool isCreatingInvoice;
  final bool isInvoiceOutcomeUnknown;
  final String? createInvoiceError;
  final String? createdInvoiceId;
  final String? createdInvoicePaymentLink;
  final int? checkoutPackageId;
  final String? checkoutPackageName;
  final double? checkoutPackagePriceBefore;
  final double? checkoutPackagePriceAfter;

  const CartState({
    this.cart,
    this.isCartLoading = false,
    this.cartError,
    this.categoryServices,
    this.isCategoryServicesLoading = false,
    this.categoryServicesError,
    this.pendingServiceIds = const {},
    this.providers = const [],
    this.isProvidersLoading = false,
    this.providersError,
    this.isAssigningProvider = false,
    this.assignProviderError,
    this.selectedProvider,
    this.checkoutProvider,
    this.checkoutBranches = const [],
    this.selectedBranch,
    this.isCheckoutLoading = false,
    this.checkoutError,
    this.familyMembers = const [],
    this.isFamilyMembersLoading = false,
    this.familyMembersError,
    this.selectedFamilyMember,
    this.paymentMethod = CartPaymentMethod.cash,
    this.isCreatingInvoice = false,
    this.isInvoiceOutcomeUnknown = false,
    this.createInvoiceError,
    this.createdInvoiceId,
    this.createdInvoicePaymentLink,
    this.checkoutPackageId,
    this.checkoutPackageName,
    this.checkoutPackagePriceBefore,
    this.checkoutPackagePriceAfter,
  });

  CartState copyWith({
    Cart? cart,
    bool? isCartLoading,
    String? cartError,
    bool resetCartError = false,
    CategoryServices? categoryServices,
    bool? isCategoryServicesLoading,
    String? categoryServicesError,
    bool resetCategoryServicesError = false,
    Set<int>? pendingServiceIds,
    List<ProviderOption>? providers,
    bool? isProvidersLoading,
    String? providersError,
    bool resetProvidersError = false,
    bool? isAssigningProvider,
    String? assignProviderError,
    bool resetAssignProviderError = false,
    ProviderOption? selectedProvider,
    bool resetSelectedProvider = false,
    ProviderOption? checkoutProvider,
    bool resetCheckoutProvider = false,
    List<ProviderBranch>? checkoutBranches,
    ProviderBranch? selectedBranch,
    bool resetSelectedBranch = false,
    bool? isCheckoutLoading,
    String? checkoutError,
    bool resetCheckoutError = false,
    List<FamilyMemberModel>? familyMembers,
    bool? isFamilyMembersLoading,
    String? familyMembersError,
    bool resetFamilyMembersError = false,
    FamilyMemberModel? selectedFamilyMember,
    bool resetSelectedFamilyMember = false,
    CartPaymentMethod? paymentMethod,
    bool? isCreatingInvoice,
    bool? isInvoiceOutcomeUnknown,
    String? createInvoiceError,
    bool resetCreateInvoiceError = false,
    String? createdInvoiceId,
    bool resetCreatedInvoiceId = false,
    String? createdInvoicePaymentLink,
    bool resetCreatedInvoicePaymentLink = false,
    int? checkoutPackageId,
    bool resetCheckoutPackageId = false,
    String? checkoutPackageName,
    bool resetCheckoutPackageName = false,
    double? checkoutPackagePriceBefore,
    bool resetCheckoutPackagePriceBefore = false,
    double? checkoutPackagePriceAfter,
    bool resetCheckoutPackagePriceAfter = false,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      isCartLoading: isCartLoading ?? this.isCartLoading,
      cartError: resetCartError ? null : (cartError ?? this.cartError),
      categoryServices: categoryServices ?? this.categoryServices,
      isCategoryServicesLoading:
          isCategoryServicesLoading ?? this.isCategoryServicesLoading,
      categoryServicesError: resetCategoryServicesError
          ? null
          : (categoryServicesError ?? this.categoryServicesError),
      pendingServiceIds: pendingServiceIds ?? this.pendingServiceIds,
      providers: providers ?? this.providers,
      isProvidersLoading: isProvidersLoading ?? this.isProvidersLoading,
      providersError: resetProvidersError
          ? null
          : (providersError ?? this.providersError),
      isAssigningProvider: isAssigningProvider ?? this.isAssigningProvider,
      assignProviderError: resetAssignProviderError
          ? null
          : (assignProviderError ?? this.assignProviderError),
      selectedProvider: resetSelectedProvider
          ? null
          : (selectedProvider ?? this.selectedProvider),
      checkoutProvider: resetCheckoutProvider
          ? null
          : (checkoutProvider ?? this.checkoutProvider),
      checkoutBranches: checkoutBranches ?? this.checkoutBranches,
      selectedBranch: resetSelectedBranch
          ? null
          : (selectedBranch ?? this.selectedBranch),
      isCheckoutLoading: isCheckoutLoading ?? this.isCheckoutLoading,
      checkoutError: resetCheckoutError
          ? null
          : (checkoutError ?? this.checkoutError),
      familyMembers: familyMembers ?? this.familyMembers,
      isFamilyMembersLoading:
          isFamilyMembersLoading ?? this.isFamilyMembersLoading,
      familyMembersError: resetFamilyMembersError
          ? null
          : (familyMembersError ?? this.familyMembersError),
      selectedFamilyMember: resetSelectedFamilyMember
          ? null
          : (selectedFamilyMember ?? this.selectedFamilyMember),
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isCreatingInvoice: isCreatingInvoice ?? this.isCreatingInvoice,
      isInvoiceOutcomeUnknown:
          isInvoiceOutcomeUnknown ?? this.isInvoiceOutcomeUnknown,
      createInvoiceError: resetCreateInvoiceError
          ? null
          : (createInvoiceError ?? this.createInvoiceError),
      createdInvoiceId: resetCreatedInvoiceId
          ? null
          : (createdInvoiceId ?? this.createdInvoiceId),
      createdInvoicePaymentLink: resetCreatedInvoicePaymentLink
          ? null
          : (createdInvoicePaymentLink ?? this.createdInvoicePaymentLink),
      checkoutPackageId: resetCheckoutPackageId
          ? null
          : (checkoutPackageId ?? this.checkoutPackageId),
      checkoutPackageName: resetCheckoutPackageName
          ? null
          : (checkoutPackageName ?? this.checkoutPackageName),
      checkoutPackagePriceBefore: resetCheckoutPackagePriceBefore
          ? null
          : (checkoutPackagePriceBefore ?? this.checkoutPackagePriceBefore),
      checkoutPackagePriceAfter: resetCheckoutPackagePriceAfter
          ? null
          : (checkoutPackagePriceAfter ?? this.checkoutPackagePriceAfter),
    );
  }
}
