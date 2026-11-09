import 'package:flutter/material.dart';

class AppColors {
  static const blackClr = Color(0xff090F47);

  // Design system neutrals (ink scale)
  static const inkClr = Color(0xFF111827);
  static const inkSoftClr = Color(0xFF475569);
  static const inkMutedClr = Color(0xFF64748B);
  static const inkFaintClr = Color(0xFF94A3B8);
  static const lineClr = Color(0xFFE2E8F0);
  static const errorClr = Color(0xFFEA5D5D);
  static const primaryClr = Color(0xFF4285F4);
  static const brandBlueClr = Color(0xFF3872B1);
  static const dropdownHoverClr = Color(0xFFEAF2FB);
  static const dropdownFocusClr = Color(0xFFDCEAF8);
  static const backgroundClr = Color(0xFFF5F5F5);
  static const splashScreenBackgroundClr = Color(0xFFEAF4FE);

  // Plan Colors (fallback only)
  static const goldPlanColor = Color(0xFFFFD700);

  // Quick Access Colors
  static const approvalColor = Color(0xFFDCEDE3);
  static const refundColor = Color(0xFFCBDCF9);
  static const chronicMedicineColor = Color(0xFFF5E1E9);
  static const approvalTextColor = Color(0xFF287826);
  static const refundTextColor = Color(0xFF1F427F);
  static const chronicMedicineTextColor = Color(0xFF9D4C6C);

  // White and other colors
  static const whiteClr = Color(0xFFFFFFFF);
  static const lightGreyClr = Color(0xFFF8F9FA);
  static const greyClr = Color(0xFF9E9E9E);
  static const blueClr = Color(0xFF0B51C1);
  static const successClr = Color(0xFF35BA83);
  static Color borderClr = greyClr.withValues(alpha: 0.5);
  static const greenClrW = Color(0xff347C28);
  static const blueClrW = Color(0xff083D91);

  // Enhanced gradient colors
  static const primaryDarkClr = Color(0xFF2962FF);
  static const primaryLightClr = Color(0xFF82B1FF);
  static const secondaryClr = Color(0xFF6C63FF);

  // Semantic colors
  static const warningClr = Color(0xFFFFA726);
  static const infoClr = Color(0xFF29B6F6);

  // Shadow colors
  static const cardShadowClr = Color(0x1A000000);
  static const primaryShadowClr = Color(0x404285F4);
  static const successShadowClr = Color(0x4035BA83);
  static const errorShadowClr = Color(0x40EA5D5D);

  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [primaryClr, primaryDarkClr],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const primaryGradientVertical = LinearGradient(
    colors: [primaryClr, primaryDarkClr],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const errorGradient = LinearGradient(
    colors: [Color(0xFFEF5350), Color(0xFFC62828)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cardGradient = LinearGradient(
    colors: [whiteClr, Color(0xFFFAFAFA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const shimmerGradient = LinearGradient(
    colors: [Color(0xFFEEEEEE), Color(0xFFF5F5F5), Color(0xFFEEEEEE)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );

  // Exact-value compatibility tokens for existing feature colors. These preserve each original ARGB value.
  static const materialBlack = Color(0xFF000000);
  static const materialBlack26 = Color(0x42000000);
  static const materialBlack54 = Color(0x8A000000);
  static const materialBlack87 = Color(0xDD000000);
  static const materialRed = Color(0xFFF44336);
  static const materialGreen = Color(0xFF4CAF50);
  static const materialBlue = Color(0xFF2196F3);
  static const materialYellow = Color(0xFFFFEB3B);
  static const materialOrange = Color(0xFFFF9800);
  static const materialPurple = Color(0xFF9C27B0);
  static const materialPink = Color(0xFFE91E63);
  static const materialTeal = Color(0xFF009688);
  static const materialIndigo = Color(0xFF3F51B5);
  static const materialCyan = Color(0xFF00BCD4);
  static const materialAmber = Color(0xFFFFC107);
  static const materialLime = Color(0xFFCDDC39);
  static const materialBrown = Color(0xFF795548);
  static const materialDeepOrange = Color(0xFFFF5722);
  static const materialDeepPurple = Color(0xFF673AB7);
  static const materialLightBlue = Color(0xFF03A9F4);
  static const materialLightGreen = Color(0xFF8BC34A);
  static const materialBlueGrey = Color(0xFF607D8B);
  static const exactFF2E7D32 = Color(0xFF2E7D32);
  static const exactFFC62828 = Color(0xFFC62828);
  static const exact14000000 = Color(0X14000000);
  static const exactFF047857 = Color(0XFF047857);
  static const exactFF059669 = Color(0XFF059669);
  static const exactFF0B1435 = Color(0XFF0B1435);
  static const exactFF0F172A = Color(0XFF0F172A);
  static const exactFF0F8A5F = Color(0XFF0F8A5F);
  static const exactFF10B981 = Color(0XFF10B981);
  static const exactFF1565C0 = Color(0XFF1565C0);
  static const exactFF15803D = Color(0XFF15803D);
  static const exactFF159447 = Color(0XFF159447);
  static const exactFF16A34A = Color(0XFF16A34A);
  static const exactFF16A374 = Color(0XFF16A374);
  static const exactFF1A1A2E = Color(0XFF1A1A2E);
  static const exactFF1E293B = Color(0XFF1E293B);
  static const exactFF1E3A5F = Color(0XFF1E3A5F);
  static const exactFF1E3A8A = Color(0XFF1E3A8A);
  static const exactFF1F2937 = Color(0XFF1F2937);
  static const exactFF1F6BC1 = Color(0XFF1F6BC1);
  static const exactFF22C55E = Color(0XFF22C55E);
  static const exactFF2563A6 = Color(0XFF2563A6);
  static const exactFF2563A9 = Color(0XFF2563A9);
  static const exactFF2563EB = Color(0XFF2563EB);
  static const exactFF25D366 = Color(0XFF25D366);
  static const exactFF2E73BA = Color(0XFF2E73BA);
  static const exactFF334155 = Color(0XFF334155);
  static const exactFF374151 = Color(0XFF374151);
  static const exactFF3976B7 = Color(0XFF3976B7);
  static const exactFF4B5563 = Color(0XFF4B5563);
  static const exactFF566384 = Color(0XFF566384);
  static const exactFF657293 = Color(0XFF657293);
  static const exactFF6B7280 = Color(0XFF6B7280);
  static const exactFF6C6C6C = Color(0XFF6C6C6C);
  static const exactFF7481A1 = Color(0XFF7481A1);
  static const exactFF7A9EC7 = Color(0XFF7A9EC7);
  static const exactFF8A5BD6 = Color(0XFF8A5BD6);
  static const exactFF8A94A6 = Color(0XFF8A94A6);
  static const exactFF8B5CF6 = Color(0XFF8B5CF6);
  static const exactFF92400E = Color(0XFF92400E);
  static const exactFF98A2B3 = Color(0XFF98A2B3);
  static const exactFF991B1B = Color(0XFF991B1B);
  static const exactFF9A6A00 = Color(0XFF9A6A00);
  static const exactFF9CA3AF = Color(0XFF9CA3AF);
  static const exactFF9DB7D3 = Color(0XFF9DB7D3);
  static const exactFF9DB7D4 = Color(0XFF9DB7D4);
  static const exactFFA7F3D0 = Color(0XFFA7F3D0);
  static const exactFFB0B8C1 = Color(0XFFB0B8C1);
  static const exactFFB45309 = Color(0XFFB45309);
  static const exactFFB9CBE4 = Color(0XFFB9CBE4);
  static const exactFFBFD9F7 = Color(0XFFBFD9F7);
  static const exactFFBFDBFE = Color(0XFFBFDBFE);
  static const exactFFC2410C = Color(0XFFC2410C);
  static const exactFFC3CEDD = Color(0XFFC3CEDD);
  static const exactFFC83C3C = Color(0XFFC83C3C);
  static const exactFFCBD5E1 = Color(0XFFCBD5E1);
  static const exactFFD1D5DB = Color(0XFFD1D5DB);
  static const exactFFD1FAE5 = Color(0XFFD1FAE5);
  static const exactFFD8E8FA = Color(0XFFD8E8FA);
  static const exactFFD97706 = Color(0XFFD97706);
  static const exactFFD99A28 = Color(0XFFD99A28);
  static const exactFFD9DDE5 = Color(0XFFD9DDE5);
  static const exactFFDBEAFE = Color(0XFFDBEAFE);
  static const exactFFDC2626 = Color(0XFFDC2626);
  static const exactFFDC8A8A = Color(0XFFDC8A8A);
  static const exactFFE05B5B = Color(0XFFE05B5B);
  static const exactFFE0E0E0 = Color(0XFFE0E0E0);
  static const exactFFE5E7EB = Color(0XFFE5E7EB);
  static const exactFFE5E9F0 = Color(0XFFE5E9F0);
  static const exactFFE65100 = Color(0XFFE65100);
  static const exactFFE6F6EE = Color(0XFFE6F6EE);
  static const exactFFE8E8E8 = Color(0XFFE8E8E8);
  static const exactFFE8EDF3 = Color(0XFFE8EDF3);
  static const exactFFE8F0FB = Color(0XFFE8F0FB);
  static const exactFFE9ECF2 = Color(0XFFE9ECF2);
  static const exactFFEAF1F9 = Color(0XFFEAF1F9);
  static const exactFFEBF1FB = Color(0XFFEBF1FB);
  static const exactFFECFDF5 = Color(0XFFECFDF5);
  static const exactFFEEF1F5 = Color(0XFFEEF1F5);
  static const exactFFEEF2F6 = Color(0XFFEEF2F6);
  static const exactFFEEF3FB = Color(0XFFEEF3FB);
  static const exactFFEF4444 = Color(0XFFEF4444);
  static const exactFFEFF6FF = Color(0XFFEFF6FF);
  static const exactFFF0B7B7 = Color(0XFFF0B7B7);
  static const exactFFF0F0F0 = Color(0XFFF0F0F0);
  static const exactFFF0F2F5 = Color(0XFFF0F2F5);
  static const exactFFF0F4F8 = Color(0XFFF0F4F8);
  static const exactFFF0F6FD = Color(0XFFF0F6FD);
  static const exactFFF0F7FF = Color(0XFFF0F7FF);
  static const exactFFF0FDF4 = Color(0XFFF0FDF4);
  static const exactFFF1F5F9 = Color(0XFFF1F5F9);
  static const exactFFF1F6FC = Color(0XFFF1F6FC);
  static const exactFFF1F7FF = Color(0XFFF1F7FF);
  static const exactFFF3EDFB = Color(0XFFF3EDFB);
  static const exactFFF3F4F6 = Color(0XFFF3F4F6);
  static const exactFFF4F6F9 = Color(0XFFF4F6F9);
  static const exactFFF4F8FD = Color(0XFFF4F8FD);
  static const exactFFF59E0B = Color(0XFFF59E0B);
  static const exactFFF5A623 = Color(0XFFF5A623);
  static const exactFFF5F3FF = Color(0XFFF5F3FF);
  static const exactFFF5F9FF = Color(0XFFF5F9FF);
  static const exactFFF8FAFC = Color(0XFFF8FAFC);
  static const exactFFF97316 = Color(0XFFF97316);
  static const exactFFF9FAFB = Color(0XFFF9FAFB);
  static const exactFFFB923C = Color(0XFFFB923C);
  static const exactFFFBBF24 = Color(0XFFFBBF24);
  static const exactFFFBF2F3 = Color(0XFFFBF2F3);
  static const exactFFFDE68A = Color(0XFFFDE68A);
  static const exactFFFDE6AE = Color(0XFFFDE6AE);
  static const exactFFFDECEC = Color(0XFFFDECEC);
  static const exactFFFECACA = Color(0XFFFECACA);
  static const exactFFFEE2E2 = Color(0XFFFEE2E2);
  static const exactFFFEF2F2 = Color(0XFFFEF2F2);
  static const exactFFFEF3C7 = Color(0XFFFEF3C7);
  static const exactFFFEF4E2 = Color(0XFFFEF4E2);
  static const exactFFFF454B = Color(0XFFFF454B);
  static const exactFFFFBE2E = Color(0XFFFFBE2E);
  static const exactFFFFF7ED = Color(0XFFFFF7ED);
  static const exactFFFFF7F7 = Color(0XFFFFF7F7);
  static const exactFFFFF8E7 = Color(0XFFFFF8E7);
  static const exactFFFFFAFA = Color(0XFFFFFAFA);
  static const exactFFFFFBEB = Color(0XFFFFFBEB);
}
