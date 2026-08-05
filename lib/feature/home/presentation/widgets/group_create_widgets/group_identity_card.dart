import 'package:easy_localization/easy_localization.dart';
import 'package:fclub/core/constants/my_color.dart';
import 'package:fclub/feature/home/presentation/widgets/group_create_widgets/group_form_section_card.dart';
import 'package:fclub/feature/home/presentation/widgets/group_create_widgets/group_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupIdentityCard extends StatelessWidget {
  const GroupIdentityCard({
    super.key,
    required this.nameController,
    required this.pinController,
    required this.onGeneratePin,
  });

  final TextEditingController nameController;
  final TextEditingController pinController;
  final VoidCallback onGeneratePin;

  @override
  Widget build(BuildContext context) {
    return GroupFormSectionCard(
      icon: Icons.auto_awesome_rounded,
      accent: MyColor.primary,
      title: 'group_identity_title'.tr(),
      description: 'group_identity_description'.tr(),
      child: Column(
        children: [
          GroupTextField(
            controller: nameController,
            label: 'group_name_label'.tr(),
            hint: 'group_name_hint'.tr(),
            icon: Icons.groups_rounded,
            inputFormatters: [LengthLimitingTextInputFormatter(50)],
            validator: (value) {
              final name = value?.trim() ?? '';
              if (name.isEmpty) return 'group_name_required'.tr();
              if (name.length < 3) return 'group_name_too_short'.tr();
              return null;
            },
          ),
          SizedBox(height: 15.h),
          GroupTextField(
            key: const Key('group-pin-code-field'),
            controller: pinController,
            label: 'group_pin_label'.tr(),
            hint: 'group_pin_hint'.tr(),
            helperText: 'group_pin_helper'.tr(),
            icon: Icons.key_rounded,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: const [
              UpperCaseTextFormatter(),
              _PinCodeFormatter(),
            ],
            suffix: IconButton(
              tooltip: 'group_pin_regenerate'.tr(),
              onPressed: onGeneratePin,
              icon: Icon(
                Icons.autorenew_rounded,
                color: MyColor.tertiary,
                size: 20.r,
              ),
            ),
            validator: (value) {
              final pin = (value ?? '').replaceAll(RegExp('[^A-Z0-9]'), '');
              if (pin.isEmpty) return 'group_pin_required'.tr();
              if (pin.length < 6) return 'group_pin_too_short'.tr();
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _PinCodeFormatter extends TextInputFormatter {
  const _PinCodeFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final filtered = newValue.text.replaceAll(RegExp('[^A-Z0-9-]'), '');
    if (filtered.length > 12) return oldValue;
    return newValue.copyWith(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}
