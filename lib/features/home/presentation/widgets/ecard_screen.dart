import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/app_blue_header.dart';

class ECardScreen extends StatefulWidget {
  const ECardScreen({super.key});

  @override
  State<ECardScreen> createState() => _ECardScreenState();
}

class _ECardScreenState extends State<ECardScreen> {
  bool _hasCard = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      body: Column(
        children: [
          const AppBlueHeader(
            title: 'E Card',
            showBack: false,
            bottomRadius: 14,
            contentHeight: 151,
            padding: EdgeInsets.fromLTRB(18, 8, 18, 20),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(15.w, 19.h, 15.w, 32.h),
              child: _hasCard
                  ? _ActiveCardView(
                      onCancel: () => setState(() => _hasCard = false),
                    )
                  : _NoCardView(onSubscribe: _showPaymentSheet),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _PaymentSheet(
          onPay: () {
            Navigator.of(context).pop();
            setState(() => _hasCard = true);
          },
        );
      },
    );
  }
}

class _NoCardView extends StatelessWidget {
  final VoidCallback onSubscribe;

  const _NoCardView({required this.onSubscribe});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(24.w, 29.h, 24.w, 37.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13.r),
            border: Border.all(color: const Color(0xFFCFE0F6)),
          ),
          child: Column(
            children: [
              Text(
                "You don't have a card yet",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF111D37),
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Get a MediCard to access 2,400+ doctors, labs,\n'
                'pharmacies and gyms across Egypt with exclusive\n'
                'member discounts.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF435579),
                  fontSize: 12.sp,
                  height: 1.18,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 22.h),
        Text(
          'Choose Card',
          style: TextStyle(
            color: Colors.black,
            fontSize: 19.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 270.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              _PlanCard(
                name: 'STANDARD PLAN',
                price: '299',
                features: const [
                  'Discounts on services',
                  'Pharmacy discounts',
                  'Search & booking',
                ],
                onSubscribe: onSubscribe,
              ),
              SizedBox(width: 13.w),
              _PlanCard(
                name: 'SILVER 50+',
                price: '499',
                badge: 'Save 20%',
                tinted: true,
                features: const [
                  'All standard Privileges',
                  'Monthly medication',
                  'Home doctor visits',
                  'Annual check-up',
                  'Elderly care',
                ],
                onSubscribe: onSubscribe,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String name;
  final String price;
  final String? badge;
  final bool tinted;
  final List<String> features;
  final VoidCallback onSubscribe;

  const _PlanCard({
    required this.name,
    required this.price,
    required this.features,
    required this.onSubscribe,
    this.badge,
    this.tinted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190.w,
      decoration: BoxDecoration(
        color: tinted ? const Color(0xFFEAF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(7.r),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 15.h, 12.w, 7.h),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF2D75D6),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 9.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          price,
                          style: TextStyle(
                            color: const Color(0xFF12213C),
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w800,
                            height: 0.95,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Padding(
                          padding: EdgeInsets.only(top: 11.h),
                          child: Text(
                            'EGP',
                            style: TextStyle(
                              color: const Color(0xFF64748B),
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (badge != null)
                  Positioned(
                    top: -6.h,
                    right: -8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 5.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0C2),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: const Color(0xFFFFB23F)),
                      ),
                      child: Text(
                        badge!,
                        style: TextStyle(
                          color: const Color(0xFFC66A00),
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE1E4EA)),
          Padding(
            padding: EdgeInsets.fromLTRB(15.w, 10.h, 10.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: features
                  .map(
                    (feature) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_rounded,
                            size: 12.sp,
                            color: const Color(0xFF00796B),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              feature,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: const Color(0xFF425071),
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 10.h),
            child: SizedBox(
              width: double.infinity,
              height: 26.h,
              child: ElevatedButton(
                onPressed: onSubscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3976B7),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'Subscribe',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveCardView extends StatelessWidget {
  final VoidCallback onCancel;

  const _ActiveCardView({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _MediCardPreview(),
        SizedBox(height: 15.h),
        Row(
          children: const [
            Expanded(
              child: _InfoTile(title: 'Plan', value: 'Standard'),
            ),
            SizedBox(width: 11),
            Expanded(
              child: _InfoTile(title: 'Expiry Date', value: '12/2027'),
            ),
            SizedBox(width: 11),
            Expanded(
              child: _InfoTile(title: 'Points', value: '250'),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 15.h, 16.w, 5.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11.r),
            border: Border.all(color: const Color(0xFFCFE0F6)),
          ),
          child: Column(
            children: const [
              _BenefitRow(text: 'Discounts on services'),
              _BenefitRow(text: 'Pharmacy discounts'),
              _BenefitRow(text: 'Search & booking'),
            ],
          ),
        ),
        SizedBox(height: 77.h),
        SizedBox(
          width: double.infinity,
          height: 49.h,
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11.r),
              ),
            ),
            child: Text(
              'Cancel Subscription',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w400),
            ),
          ),
        ),
      ],
    );
  }
}

class _MediCardPreview extends StatelessWidget {
  const _MediCardPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 188.h,
      padding: EdgeInsets.fromLTRB(29.w, 30.h, 22.w, 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF347EDD), Color(0xFF174B8B)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MediCard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 30.w),
                    child: Text(
                      'Powered by U Khusm',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 5.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 41.w,
                height: 27.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC914),
                  borderRadius: BorderRadius.circular(5.r),
                ),
              ),
            ],
          ),
          SizedBox(height: 29.h),
          Text(
            '4823 ••••  ••••  7614',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                'Ahmed Hassan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDEEFF),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Standard',
                  style: TextStyle(
                    color: const Color(0xFF2E6DB7),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 67.h,
      padding: EdgeInsets.fromLTRB(11.w, 10.h, 8.w, 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.r),
        border: Border.all(color: const Color(0xFFCFE0F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF17223C),
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 7.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: const Color(0xFF5B6273), fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;

  const _BenefitRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        children: [
          Icon(
            Icons.check_rounded,
            color: const Color(0xFF00796B),
            size: 22.sp,
          ),
          SizedBox(width: 15.w),
          Text(
            text,
            style: TextStyle(color: const Color(0xFF425071), fontSize: 15.sp),
          ),
        ],
      ),
    );
  }
}

class _PaymentSheet extends StatelessWidget {
  final VoidCallback onPay;

  const _PaymentSheet({required this.onPay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24.w,
        8.h,
        24.w,
        MediaQuery.viewPaddingOf(context).bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(13.r)),
        border: Border.all(color: const Color(0xFFC9CDD4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 134.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFC9C9C9),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 31.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                'EGP 200.34',
                style: TextStyle(
                  color: const Color(0xFF3976B7),
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),
          Text(
            'Payment Method',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 13.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13.r),
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            child: Column(
              children: const [
                _PaymentMethodRow(
                  icon: _VisaIcon(),
                  title: 'Debit Card',
                  subtitle: '•••• 4242',
                  selected: true,
                ),
                Divider(height: 1, color: Color(0xFFD1D5DB)),
                _PaymentMethodRow(
                  icon: _CashIcon(),
                  title: 'Cash',
                  selected: false,
                ),
              ],
            ),
          ),
          SizedBox(height: 22.h),
          SizedBox(
            width: double.infinity,
            height: 49.h,
            child: ElevatedButton(
              onPressed: onPay,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3976B7),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                'Pay',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodRow extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final bool selected;

  const _PaymentMethodRow({
    required this.icon,
    required this.title,
    required this.selected,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60.h,
      child: Row(
        children: [
          SizedBox(width: 16.w),
          icon,
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF17223C),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: const Color(0xFF6B7280),
                      fontSize: 12.sp,
                      height: 1.05,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? const Color(0xFF3976B7) : const Color(0xFF8B8F98),
            size: 22.sp,
          ),
          SizedBox(width: 16.w),
        ],
      ),
    );
  }
}

class _VisaIcon extends StatelessWidget {
  const _VisaIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35.w,
      height: 22.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: Text(
        'VISA',
        style: TextStyle(
          color: const Color(0xFF25348B),
          fontSize: 10.sp,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class _CashIcon extends StatelessWidget {
  const _CashIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 35.w,
      height: 18.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF6BA56D),
        border: Border.all(color: const Color(0xFFA9C99E)),
      ),
      child: Container(
        width: 20.w,
        height: 10.h,
        decoration: BoxDecoration(
          color: const Color(0xFF7FBF7E),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFE6F3E1), width: 0.8),
        ),
      ),
    );
  }
}
