import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../provider/pack_check_provider.dart';

/// Bottom-sheet dialog to add a custom item — either icon-based or photo-based.
class PackAddItemDialog extends StatefulWidget {
  const PackAddItemDialog({super.key});

  /// Opens the dialog as a modal bottom sheet.
  /// Captures the provider before the new route is pushed so the sheet's
  /// isolated widget-tree can still access [PackCheckProvider].
  static Future<void> show(BuildContext context) {
    final provider = context.read<PackCheckProvider>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: provider,
        child: const PackAddItemDialog(),
      ),
    );
  }

  @override
  State<PackAddItemDialog> createState() => _PackAddItemDialogState();
}

class _PackAddItemDialogState extends State<PackAddItemDialog> {
  final _nameCtrl = TextEditingController();
  IconData _selectedIcon = Icons.star_rounded;

  static const _iconChoices = [
    Icons.star_rounded,
    Icons.favorite_rounded,
    Icons.bolt_rounded,
    Icons.local_fire_department_rounded,
    Icons.emoji_objects_rounded,
    Icons.music_note_rounded,
    Icons.sports_soccer_rounded,
    Icons.color_lens_rounded,
    Icons.eco_rounded,
    Icons.pets_rounded,
    Icons.card_giftcard_rounded,
    Icons.devices_other_rounded,
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF13102C), Color(0xFF0A0E27)],
          ),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
          ),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // Title
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [Color(0xFFA855F7), Color(0xFF06B6D4)],
              ).createShader(b),
              child: Text(
                'Add Custom Item',
                style: TextStyle(
                  fontFamily: 'Poppins_Bold',
                  fontSize: 18.sp,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // Name field
            TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: Colors.white),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Item name…',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFA855F7), width: 1.5),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // Icon selector
            Text(
              'Choose an icon',
              style: TextStyle(
                fontFamily: 'Poppins_Medium',
                fontSize: 12.sp,
                color: Colors.white60,
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 52.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _iconChoices.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, i) {
                  final icon = _iconChoices[i];
                  final selected = icon == _selectedIcon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 48.r,
                      height: 48.r,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        gradient: selected
                            ? const LinearGradient(
                                colors: [Color(0xFFA855F7), Color(0xFF06B6D4)],
                              )
                            : null,
                        color: selected ? null : Colors.white.withOpacity(0.07),
                        border: Border.all(
                          color: selected
                              ? Colors.transparent
                              : Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Icon(icon, color: Colors.white, size: 22.r),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Add Icon Item',
                    icon: Icons.add_circle_outline_rounded,
                    gradient: const [Color(0xFFA855F7), Color(0xFF7C3AED)],
                    onTap: () => _submit(context, usePhoto: false),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _ActionButton(
                    label: 'Take Photo',
                    icon: Icons.camera_alt_rounded,
                    gradient: const [Color(0xFF06B6D4), Color(0xFF0891B2)],
                    onTap: () => _submit(context, usePhoto: true, source: ImageSource.camera),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _ActionButton(
                    label: 'From Gallery',
                    icon: Icons.photo_library_rounded,
                    gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                    onTap: () => _submit(context, usePhoto: true, source: ImageSource.gallery),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(
    BuildContext context, {
    required bool usePhoto,
    ImageSource source = ImageSource.camera,
  }) async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty && !usePhoto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name.')),
      );
      return;
    }
    Navigator.pop(context);
    final provider = context.read<PackCheckProvider>();
    if (usePhoto) {
      await provider.addPhotoItem(name: name.isEmpty ? 'Custom' : name, source: source);
    } else {
      await provider.addCustomItem(name: name, icon: _selectedIcon);
    }
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 11.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(colors: gradient),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18.r),
            SizedBox(height: 3.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins_Medium',
                fontSize: 9.5.sp,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
