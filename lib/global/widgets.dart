



import 'dart:math' show Random, pow;

import 'package:flutter/material.dart';

import 'global.dart';


class GW{
  static AppBar returnappbar(BuildContext context)=>AppBar(
    automaticallyImplyLeading: true,

  );

  static Widget button(String str,double w)=>Container(
    width: w-15,
    height: 50,
    decoration: BoxDecoration(
        color: Global.bg,
        borderRadius: BorderRadius.circular(6)
    ),
    child: Center(child: Text(str,style: TextStyle(color: Colors.white,fontWeight: FontWeight.w800),)),
  );

  static List<String> _parseProductDetails(String data) {
    // Split the string by "/ /"
    final parts = data.split('/ /');

    // Clean up whitespace and empty parts
    return parts
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }


  static Widget showRow(String rawData) {
    try {
      final details = _parseProductDetails(rawData);

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: details.map((line) {
            // Split each line into "label" and "value"
            final parts = line.split(':');
            final label = parts.isNotEmpty ? parts.first.trim() : '';
            final value = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';

            return Row(
              children: [
                // Left side (Label)
                Expanded(
                  flex: 1,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Right side (Value)
                Expanded(
                  flex: 1,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      );
    } catch (e) {
      return const SizedBox();
    }
  }
  static Widget space(double w , double h)=>SizedBox(width: w,height: h,);
  static Widget buildStarRating(int i, {double size = 15, Color filledColor = Colors.orange, Color borderColor = Colors.grey}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < i ? Icons.star : Icons.star_border,
          color: index < i ? filledColor : borderColor,
          size: size,
        );
      }),
    );
  }
  static Widget div()=>Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14.0),
    child: Divider(),
  );

  static String generateRandomNumber(int digits) {
    if (digits <= 0) {
      throw ArgumentError("Digits must be greater than 0");
    }

    final random = Random();
    int min = pow(10, digits - 1).toInt();  // Smallest number with 'digits' digits
    int max = pow(10, digits).toInt() - 1;  // Largest number with 'digits' digits

    return (min + random.nextInt(max - min + 1)).toString();
  }
}