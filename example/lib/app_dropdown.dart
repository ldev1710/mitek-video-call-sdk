import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class AppDropdown<T> extends StatelessWidget {
  AppDropdown({
    required this.dropdownMenuItemList,
    required this.onChanged,
    required this.hint,
    required this.value,
    this.fontSizeHint,
    super.key,
    this.height,
    this.width,
  });
  List<DropdownMenuItem<T>> dropdownMenuItemList;
  void Function(T?) onChanged;
  T? value;
  final String hint;
  final double? height;
  final double? fontSizeHint;
  final double? width;
  final OutlineInputBorder border = OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.grey),
    borderRadius: BorderRadius.circular(8),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DropdownButtonFormField2(
        dropdownStyleData: const DropdownStyleData(
          decoration: BoxDecoration(color: Colors.white),
          maxHeight: 300,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          enabledBorder: border,
          contentPadding: const EdgeInsets.all(8),
          // border: border,
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            size: 32,
            color: Colors.grey,
          ),
        ),
        buttonStyleData: ButtonStyleData(
          width: width,
          height: height,
        ),
        hint: Text(
          hint,
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: fontSizeHint,
          ),
        ),
        value: value,
        items: dropdownMenuItemList,
        onChanged: onChanged,
        isExpanded: true,
      ),
    );
  }
}
