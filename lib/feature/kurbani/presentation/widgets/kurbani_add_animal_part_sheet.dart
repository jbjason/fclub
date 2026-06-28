import 'package:fclub/core/constants/my_string.dart';
import 'package:fclub/feature/kurbani/presentation/provider/kurbani_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class KurbaniAddAnimalPartSheet extends StatefulWidget {
  const KurbaniAddAnimalPartSheet({super.key});

  @override
  State<KurbaniAddAnimalPartSheet> createState() =>
      _KurbaniAddAnimalPartSheetState();
}

class _KurbaniAddAnimalPartSheetState
    extends State<KurbaniAddAnimalPartSheet> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedPart;
  bool _isLoading = false;

  static const _suggestedParts = [
    'Meat',
    'Bone',
    'Liver',
    'Ribs',
    'Offal',
    'Head',
    'Feet',
    'Tongue',
    'Kidney',
    'Heart',
  ];

  static const _headerGradient = LinearGradient(
    colors: [Color(0xFF7C2D12), Color(0xFF6D28D9)],
  );

  @override
  void dispose() {
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPart == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a part')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await context.read<KurbaniProvider>().addAnimalPart(
          partName: _selectedPart!,
          weightKg: double.parse(_weightController.text.trim()),
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(16.w),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: _headerGradient,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Icon(Icons.set_meal_rounded, color: Colors.white, size: 22.r),
                SizedBox(width: 10.w),
                Text(
                  'Add Animal Part',
                  style: TextStyle(
                    fontFamily: MyString.poppinsBold,
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Part name chips
                  Text(
                    'Part Name',
                    style: TextStyle(
                      fontFamily: MyString.poppinsBold,
                      fontSize: 12.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: _suggestedParts.map((part) {
                      final selected = _selectedPart == part;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedPart = part),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 7.h,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF7C2D12)
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF7C2D12)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            part,
                            style: TextStyle(
                              fontFamily: MyString.rubikRegular,
                              fontSize: 12.sp,
                              color: selected ? Colors.white : colorScheme.onSurfaceVariant,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (double.tryParse(v.trim()) == null) {
                        return 'Invalid number';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      hintText: '0.0',
                      prefixIcon:
                          Icon(Icons.scale_rounded, size: 18.r),
                      suffixText: 'kg',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: Color(0xFF7C2D12),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextFormField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: 'Note (optional)',
                      prefixIcon: Icon(Icons.notes_rounded, size: 18.r),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C2D12),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20.r,
                              height: 20.r,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Save Part',
                              style: TextStyle(
                                fontFamily: MyString.poppinsBold,
                                fontSize: 14.sp,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
