import 'package:medicard/core/widgets/app_header_back_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theming/app_spacing.dart';
import '../../../../core/theming/app_toast.dart';
import '../../../../core/utils/app_date_formatter.dart';
import '../../domain/models/invoice_details.dart';
import '../../domain/models/invoice_item.dart';
import '../cubit/invoice_details_cubit.dart';

import '../../../../core/theming/app_text_styles.dart';
import '../../../../core/utils/image_url_resolver.dart';
import '../../../../core/utils/price_formatter.dart';

part 'invoice_details_overview.dart';
part 'invoice_details_services.dart';
part 'invoice_details_actions.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  final InvoiceItem invoice;
  final int tab;
  final InvoiceDetails? initialDetails;

  const InvoiceDetailsScreen({
    super.key,
    required this.invoice,
    this.tab = 0,
    this.initialDetails,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<InvoiceDetailsCubit>();
        if (initialDetails != null) {
          cubit.emitLoaded(initialDetails!);
        } else {
          cubit.loadDetails(invoice.invoiceId);
        }
        return cubit;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: AppHeaderSpacing.padding(top: 16.h, bottom: 6.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppHeaderBackButton(
                      color: const Color(0xFF111827),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    Expanded(
                      child: Text(
                        'activity.invoice_details_title'.tr(),
                        style: AppTextStyles.of(
                          fontSize: 22.sp,
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
            Expanded(
              child: BlocBuilder<InvoiceDetailsCubit, InvoiceDetailsState>(
                builder: (context, state) {
                  return switch (state) {
                    InvoiceDetailsLoaded(:final details) => _DetailsBody(
                      invoice: invoice,
                      details: details,
                      tab: tab,
                    ),
                    InvoiceDetailsLoadFailure(:final message) => Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Text(
                          message.isEmpty
                              ? 'activity.invoice_details_load_failed'.tr()
                              : message,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    _ => const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3872B1),
                      ),
                    ),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
