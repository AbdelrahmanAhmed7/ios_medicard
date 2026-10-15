import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theming/app_text_styles.dart';
import '../../../../../core/widgets/auth_shared_widgets.dart';
import '../../../../../features/activity/domain/models/invoice_item.dart';
import '../../../../../features/activity/presentation/cubit/activity_cubit.dart';
import 'invoice_list.dart';

class InvoiceActionButton extends StatelessWidget {
  final InvoiceItem item;

  const InvoiceActionButton({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final tab = TabScope.of(context);
        final result = await context.push(
          '/invoice-details',
          extra: {'invoice': item, 'tab': tab},
        );
        if (result == true && context.mounted) {
          context.read<ActivityCubit>().loadInvoices(
            tab: tab,
            forceRefresh: true,
          );
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 16.r, color: kAuthBlue),
          SizedBox(width: 4.w),
          Text(
            'activity.details'.tr(),
            style: AppTextStyles.of(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: kAuthBlue,
              decoration: TextDecoration.underline,
              decorationColor: kAuthBlue,
            ),
          ),
        ],
      ),
    );
  }
}
