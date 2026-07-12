import 'package:flutter/material.dart';

/// Width-breakpoint helper shared by every screen so form-factor behavior
/// stays consistent: phones get single-column card lists and full-screen
/// pushed editors, tablets get modal dialogs, desktop gets side-by-side
/// panels and real tables.
enum FormFactor {
  compact, // phones, < 600
  medium, // tablets / small windows, < 1024
  expanded; // desktop

  static FormFactor of(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return FormFactor.compact;
    if (width < 1024) return FormFactor.medium;
    return FormFactor.expanded;
  }
}

extension FormFactorContext on BuildContext {
  FormFactor get formFactor => FormFactor.of(this);
  bool get isCompact => formFactor == FormFactor.compact;
  bool get isExpanded => formFactor == FormFactor.expanded;
}
