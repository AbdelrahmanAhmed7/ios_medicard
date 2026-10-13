
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
import '../widgets/checkout_section_title.dart';

import '../../../home/presentation/widgets/order_placed_dialog.dart';

class CheckoutScreen extends StatefulWidget {
  final int? initialProviderId;
  final ProviderBranch? initialBranch;
  final int? packageId;
  final String? packageName;
  final double? packagePriceBefore;
  final double? packagePriceAfter;

  const CheckoutScreen({
    super.key,
    this.initialProviderId,
    this.initialBranch,
    this.packageId,
    this.packageName,
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
      initialBranch: widget.initialBranch,
      packageId: widget.packageId,
      packageName: widget.packageName,
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
                  padding: EdgeInsets.fromLTRB(8.w, 10.h, 20.w, 6.h),
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
          initialBranch: widget.initialBranch,
          packageId: widget.packageId,
          packageName: widget.packageName,
          packagePriceBefore: widget.packagePriceBefore,
          packagePriceAfter: widget.packagePriceAfter,
        ),
      );
    }

    final bottomSafePadding = MediaQuery.paddingOf(context).bottom;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        14.w,
        18.h,
        14.w,
        24.h + bottomSafePadding + 8.h,
      ),
      children: [
        CheckoutSectionTitle(text: 'cart.order_for'.tr()),
        SizedBox(height: 8.h),
        CheckoutPatientDropdown(state: state),
        SizedBox(height: 22.h),
        CheckoutSectionTitle(text: 'cart.branch_location'.tr()),
        SizedBox(height: 8.h),
        CheckoutBranchSelector(state: state),
        SizedBox(height: 22.h),
        CheckoutSectionTitle(text: 'cart.payment_method'.tr()),
        SizedBox(height: 8.h),
        CheckoutPaymentDropdown(state: state),
        SizedBox(height: 24.h),
        CheckoutSectionTitle(text: 'cart.payment_summary'.tr()),
        SizedBox(height: 12.h),
        CheckoutPaymentSummary(state: state),
        SizedBox(height: 22.h),
        CheckoutPayButton(state: state),
      ],
    );
  }
}
