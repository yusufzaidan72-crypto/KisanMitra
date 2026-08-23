import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;

  const AppDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    T? safeValue;
    if (value != null) {
      if (items.contains(value)) {
        safeValue = value;
      } else if (value is String && (value as String).isNotEmpty) {
        final String valStr = (value as String).trim().toLowerCase();
        for (final item in items) {
          final String itemStr = item.toString().toLowerCase();
          if (itemStr == valStr ||
              itemStr.contains(valStr) ||
              valStr.contains(itemStr.split(' ').first.toLowerCase())) {
            safeValue = item;
            break;
          }
        }
      }
    }

    return DropdownButtonFormField<T>(
      initialValue: safeValue,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon,
      ),
      isExpanded: true,
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemLabel(item),
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium,
                ),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
