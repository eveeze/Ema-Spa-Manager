// lib/common/utils/currency_utils.dart
// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:intl/intl.dart';

class CurrencyUtils {
  /// Format a number to Indonesian Rupiah (IDR) currency
  ///
  /// Example:
  /// ```dart
  /// formatRupiah(15000); // Rp15.000
  /// formatRupiah(1500000); // Rp1.500.000
  /// formatRupiah(1500000, symbol: 'IDR '); // IDR 1.500.000
  /// formatRupiah(1500000, decimalDigits: 2); // Rp1.500.000,00
  /// ```
  static String formatRupiah(
    dynamic amount, {
    String symbol = 'Rp',
    int? decimalDigits,
    bool compactFormat = false,
  }) {
    if (amount == null) return '${symbol}0';

    // Convert to double if not already
    double value = 0.0;
    if (amount is int) {
      value = amount.toDouble();
    } else if (amount is double) {
      value = amount;
    } else if (amount is String) {
      value = double.tryParse(amount) ?? 0.0;
    }

    // Use NumberFormat from intl package
    NumberFormat formatter;

    if (compactFormat) {
      // Compact format (e.g., Rp1,5 jt for 1.500.000)
      formatter = NumberFormat.compactCurrency(
        locale: 'id',
        symbol: symbol,
        decimalDigits: decimalDigits ?? 1,
      );
    } else {
      // Standard format with period as thousand separator and comma as decimal separator
      formatter = NumberFormat.currency(
        locale: 'id',
        symbol: symbol,
        decimalDigits: decimalDigits ?? 0,
      );
    }

    return formatter.format(value);
  }

  /// Format a number to compact Indonesian Rupiah (IDR) currency
  ///
  /// Example:
  /// ```dart
  /// formatCompactRupiah(1500000); // Rp1,5 jt
  /// formatCompactRupiah(1500000000); // Rp1,5 M
  /// ```
  static String formatCompactRupiah(dynamic amount, {String symbol = 'Rp'}) {
    return formatRupiah(amount, symbol: symbol, compactFormat: true);
  }

  /// Parse a Rupiah formatted string back to a double
  ///
  /// Example:
  /// ```dart
  /// parseRupiah('Rp15.000'); // 15000.0
  /// parseRupiah('IDR 1.500.000,50'); // 1500000.5
  /// ```
  static double parseRupiah(String? formattedAmount) {
    if (formattedAmount == null || formattedAmount.isEmpty) return 0.0;

    // Remove currency symbol and any non-numeric chars except decimal separator
    String cleanedString = formattedAmount.replaceAll(RegExp(r'[^\d,.]'), '');

    // Replace comma with dot for decimal if needed
    if (cleanedString.contains(',')) {
      cleanedString = cleanedString.replaceAll('.', '').replaceAll(',', '.');
    }

    return double.tryParse(cleanedString) ?? 0.0;
  }

  /// Format price to show discount
  ///
  /// Example:
  /// ```dart
  /// formatPriceWithDiscount(1500000, 1200000); // "Rp1.200.000 (Save Rp300.000)"
  /// ```
  static String formatPriceWithDiscount(
    dynamic originalPrice,
    dynamic discountedPrice, {
    String symbol = 'Rp',
    bool showSavings = true,
  }) {
    String formattedDiscountedPrice = formatRupiah(
      discountedPrice,
      symbol: symbol,
    );

    if (!showSavings) return formattedDiscountedPrice;

    // Calculate savings amount
    double original = 0.0;
    double discounted = 0.0;

    if (originalPrice is num) {
      original = originalPrice.toDouble();
    } else if (originalPrice is String)
      original = double.tryParse(originalPrice) ?? 0.0;

    if (discountedPrice is num) {
      discounted = discountedPrice.toDouble();
    } else if (discountedPrice is String)
      discounted = double.tryParse(discountedPrice) ?? 0.0;

    double savings = original - discounted;

    if (savings <= 0) return formattedDiscountedPrice;

    String formattedSavings = formatRupiah(savings, symbol: symbol);
    return '$formattedDiscountedPrice (Save $formattedSavings)';
  }

  /// Format a discount percentage from original and discounted prices
  ///
  /// Example:
  /// ```dart
  /// formatDiscountPercentage(1500000, 1200000); // "20% OFF"
  /// ```
  static String formatDiscountPercentage(
    dynamic originalPrice,
    dynamic discountedPrice, {
    String suffix = '% OFF',
    int decimalDigits = 0,
  }) {
    double original = 0.0;
    double discounted = 0.0;

    if (originalPrice is num) {
      original = originalPrice.toDouble();
    } else if (originalPrice is String)
      original = double.tryParse(originalPrice) ?? 0.0;

    if (discountedPrice is num) {
      discounted = discountedPrice.toDouble();
    } else if (discountedPrice is String)
      discounted = double.tryParse(discountedPrice) ?? 0.0;

    if (original <= 0 || discounted >= original) return '0$suffix';

    double discountPercentage = ((original - discounted) / original) * 100;

    NumberFormat formatter =
        NumberFormat.decimalPattern('id')
          ..minimumFractionDigits = 0
          ..maximumFractionDigits = decimalDigits;

    return '${formatter.format(discountPercentage)}$suffix';
  }

  /// Convert a price to installment amount per month
  ///
  /// Example:
  /// ```dart
  /// formatInstallment(1200000, 12); // "Rp100.000/bulan"
  /// ```
  static String formatInstallment(
    dynamic totalPrice,
    int months, {
    String symbol = 'Rp',
    String suffix = '/bulan',
  }) {
    if (months <= 0) return formatRupiah(totalPrice, symbol: symbol);

    double total = 0.0;

    if (totalPrice is num) {
      total = totalPrice.toDouble();
    } else if (totalPrice is String)
      total = double.tryParse(totalPrice) ?? 0.0;

    double monthlyAmount = total / months;

    return '${formatRupiah(monthlyAmount, symbol: symbol)}$suffix';
  }

  /// Format a number as a percentage
  ///
  /// Example:
  /// ```dart
  /// formatPercentage(0.2345); // "23%"
  /// formatPercentage(0.2345, decimalDigits: 1); // "23,5%"
  /// ```
  static String formatPercentage(
    dynamic value, {
    int decimalDigits = 0,
    String suffix = '%',
  }) {
    if (value == null) return '0$suffix';

    double numValue = 0.0;

    if (value is num) {
      numValue = value.toDouble();
    } else if (value is String)
      numValue = double.tryParse(value) ?? 0.0;

    // If value is provided as decimal (0.xx instead of xx)
    if (numValue < 1 && numValue > -1 && numValue != 0) {
      numValue *= 100;
    }

    NumberFormat formatter = NumberFormat.decimalPercentPattern(
      locale: 'id',
      decimalDigits: decimalDigits,
    );

    return formatter.format(numValue / 100);
  }

  /// Convert a value from one currency to another using exchange rate
  ///
  /// Example:
  /// ```dart
  /// convertCurrency(100, 15000); // 1500000 (100 USD to IDR at rate 15000)
  /// ```
  static double convertCurrency(double amount, double exchangeRate) {
    return amount * exchangeRate;
  }

  /// Format a number as Indonesian Rupiah with a custom format
  static String formatCustomRupiah(
    dynamic amount, {
    String symbol = 'Rp',
    String pattern = '#,###',
    String locale = 'id',
  }) {
    if (amount == null) return '${symbol}0';

    double value = 0.0;
    if (amount is num) {
      value = amount.toDouble();
    } else if (amount is String)
      value = double.tryParse(amount) ?? 0.0;

    NumberFormat formatter = NumberFormat(pattern, locale);

    return '$symbol${formatter.format(value)}';
  }
}
