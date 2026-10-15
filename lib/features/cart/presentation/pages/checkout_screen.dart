import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/cubit/app_refresh_cubit.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theming/app_text_styles.dart';
import '../../../../network/data/provider_page_response_model.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/checkout_branch_selector.dart';
import '../widgets/checkout_error_view.dart';
import '../widgets/checkout_patient_dropdown.dart';
import '../widgets/checkout_pay_button.dart';
import '../widgets/checkout_payment_dropdown.dart';
import '../widgets/checkout_payment_summary.dart';
import '../widgets/checkout_pricing.dart';
import '../widgets/checkout_section_title.dart';
import '../widgets/checkout_summary_row.dart';

import '../../../home/presentation/widgets/order_placed_dialog.dart';

class CheckoutScreen extends StatefulWidget {
  final int? initialProviderId;
  final String? initialProviderName;
  final ProviderBranch? initialBranch;
  final int? packageId;
  final String? packageName;
  final List<String> packageServiceNames;
  final double? packagePriceBefore;
  final double? packagePriceAfter;

  const CheckoutScreen({
    super.key,
    this.initialProviderId,
    this.initialProviderName,
    this.initialBranch,
    this.packageId,
    this.packageName,
    this.packageServiceNames = const [],
    this.packagePriceBefore,
    this.packagePriceAfter,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with WidgetsBindingObserver {
  bool _didLaunchPayment = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<CartCubit>().loadCheckout(
      initialProviderId: widget.initialProviderId,
      initialProviderName: widget.initialProviderName,
      initialBranch: widget.initialBranch,
      packageId: widget.packageId,
      packageName: widget.packageName,
      packageServiceNames: widget.packageServiceNames,
      packagePriceBefore: widget.packagePriceBefore,
      packagePriceAfter: widget.packagePriceAfter,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When the user returns from the external browser after completing payment,
    // navigate to the activity tab so they can see their order status.
    if (state == AppLifecycleState.resumed && _didLaunchPayment && mounted) {
      _didLaunchPayment = false;
      // Payment status cannot be verified from the backend, so land on the
      // activity tab where the real invoice status is shown.
      sl<AppRefreshCubit>().triggerInvoicesRefresh();
      context.go('/medicard-home?tab=activity');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<CartCubit, CartState>(
        listenWhen: (previous, current) =>
            previous.createInvoiceError != current.createInvoiceError ||
            previous.createdInvoiceId != current.createdInvoiceId ||
            previous.createdInvoicePaymentLink !=
                current.createdInvoicePaymentLink,
        listener: (context, state) async {
          if (state.createInvoiceError != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.createInvoiceError!)));
          }
          if (state.createdInvoiceId != null) {
            // A new invoice exists — tell the invoices tab to reload so it
            // appears without any manual refresh or tab switching.
            sl<AppRefreshCubit>().triggerInvoicesRefresh();
            final paymentLink = state.createdInvoicePaymentLink;
            if (paymentLink != null && paymentLink.isNotEmpty) {
              final opened = await UrlLauncherService().launchURL(paymentLink);
              if (!context.mounted) return;
              if (!opened) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('cart.could_not_open_payment_link'.tr()),
                  ),
                );
              } else {
                _didLaunchPayment = true;
              }
              // Don't navigate away — the user will return to the app from the
              // browser themselves. Clearing the stack here causes the app to
              // exit when the user presses Back on a fresh install because the
              // navigator history is empty.
              return;
            }
            if (!context.mounted) return;
            await OrderPlacedDialog.maybeShow(
              context,
              orderNumber: state.createdInvoiceId,
            );
            if (context.mounted) {
              context.go('/medicard-home?tab=activity');
            }
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 6.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: const Color(0xFF111827),
                          size: 22.sp,
                        ),
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      Expanded(
                        child: Text(
                          'cart.checkout'.tr(),
                          style: AppTextStyles.of(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child: _buildBody(context, state)),
              if (state.checkoutProvider != null) _CheckoutPayBar(state: state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, CartState state) {
    if (state.isCheckoutLoading && state.checkoutProvider == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF3872B1)),
      );
    }

    if (state.checkoutError != null && state.checkoutProvider == null) {
      return CheckoutErrorView(
        message: state.checkoutError!,
        onRetry: () => context.read<CartCubit>().loadCheckout(
          initialProviderId: widget.initialProviderId,
          initialProviderName: widget.initialProviderName,
          initialBranch: widget.initialBranch,
          packageId: widget.packageId,
          packageName: widget.packageName,
          packageServiceNames: widget.packageServiceNames,
          packagePriceBefore: widget.packagePriceBefore,
          packagePriceAfter: widget.packagePriceAfter,
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      children: [
        CheckoutSectionTitle(
          text: 'cart.order_for'.tr(),
          icon: Icons.person_outline_rounded,
        ),
        SizedBox(height: 10.h),
        CheckoutPatientDropdown(state: state),
        SizedBox(height: 24.h),
        CheckoutSectionTitle(
          text: 'cart.branch_location'.tr(),
          icon: Icons.location_on_outlined,
        ),
        SizedBox(height: 10.h),
        CheckoutBranchSelector(state: state),
        SizedBox(height: 24.h),
        CheckoutSectionTitle(
          text: 'cart.payment_method'.tr(),
          icon: Icons.credit_card_rounded,
        ),
        SizedBox(height: 10.h),
        CheckoutPaymentDropdown(state: state),
        SizedBox(height: 24.h),
        CheckoutSectionTitle(
          text: 'cart.payment_summary'.tr(),
          icon: Icons.receipt_long_outlined,
        ),
        SizedBox(height: 10.h),
        CheckoutPaymentSummary(state: state),
      ],
    );
  }
}

class _CheckoutPayBar extends StatelessWidget {
  final CartState state;

  const _CheckoutPayBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final pricing = CheckoutPricing.fromState(state);
    final showTotal = !state.isInvoiceOutcomeUnknown;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE5E9F0))),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
          child: showTotal
              ? Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'cart.total_to_pay'.tr(),
                            style: AppTextStyles.of(
                              fontSize: 11.5.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'cart.egp_amount'.tr(
                              args: [checkoutMoney(pricing.total)],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.of(
                              fontSize: 18.sp,
                              color: const Color(0xFF2563A9),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(flex: 3, child: CheckoutPayButton(state: state)),
                  ],
                )
              : CheckoutPayButton(state: state),
        ),
      ),
    );
  }
}
