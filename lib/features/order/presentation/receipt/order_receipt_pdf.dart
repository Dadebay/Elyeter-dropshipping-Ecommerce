import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/formatters/date_formatter.dart';
import '../../domain/entities/pre_order.dart';

/// The words on a receipt, already in the customer's language. The caller
/// fills them from the localizations, so this file knows no language.
class ReceiptLabels {
  const ReceiptLabels({
    required this.title,
    required this.number,
    required this.status,
    required this.customer,
    required this.address,
    required this.date,
    required this.products,
    required this.quantity,
    required this.price,
    required this.amount,
    required this.productsTotal,
    required this.cargo,
    required this.discount,
    required this.total,
    required this.thanks,
  });

  final String title;
  final String Function(String number) number;
  final String status;
  final String customer;
  final String address;
  final String date;
  final String products;
  final String quantity;
  final String price;
  final String amount;
  final String productsTotal;
  final String cargo;
  final String discount;
  final String total;
  final String thanks;
}

/// A receipt for one order, as a PDF: who ordered, what, and what it came to.
///
/// Drawn in Inter, the app's own face, loaded from the bundle: the PDF
/// built-in fonts cover neither Cyrillic nor the Turkmen letters.
abstract final class OrderReceiptPdf {
  static const _brand = PdfColor.fromInt(0xFFFF6B35);
  static const _brandSoft = PdfColor.fromInt(0xFFFFF1EA);
  static const _ink = PdfColor.fromInt(0xFF171717);
  static const _muted = PdfColor.fromInt(0xFF8E8E93);
  static const _line = PdfColor.fromInt(0xFFE5E5EA);
  static const _good = PdfColor.fromInt(0xFF2ECC71);
  static const _bad = PdfColor.fromInt(0xFFE74C3C);
  static const _goodSoft = PdfColor.fromInt(0xFFE9F8F0);
  static const _badSoft = PdfColor.fromInt(0xFFFDECEC);

  static Future<Uint8List> build(
    PreOrder order,
    ReceiptLabels labels, {
    required String locale,
    Map<int, Uint8List> productImages = const {},
  }) async {
    // The date is written in the customer's language, whatever has or has
    // not been loaded for it elsewhere.
    await initializeDateFormatting(locale);
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/InterDisplay-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/InterDisplay-Bold.ttf'),
    );
    final theme = pw.ThemeData.withFont(base: regular, bold: bold);

    final money = NumberFormat.decimalPattern(
      Intl.verifiedLocale(
        Intl.canonicalizedLocale(locale),
        NumberFormat.localeExists,
        onFailure: (_) => 'en',
      ),
    );
    String amount(num value) => money.format(value);
    final currency = order.currency.isEmpty
        ? AppConstants.currencySymbol
        : order.currency;
    final date = order.createdAt == null
        ? null
        : DateFormatter.dayTime(
            order.createdAt!,
            locale: locale,
            fullMonth: true,
          );

    final goods = order.items.isEmpty
        ? order.totalPrice
        : order.items.fold<num>(0, (sum, item) => sum + item.lineTotal);
    final extra = order.totalPrice - goods;

    final cancelled = order.status == PreOrderStatus.cancelled;
    final statusColor = cancelled
        ? _bad
        : order.status == PreOrderStatus.completed
        ? _good
        : _brand;
    final statusSoft = cancelled
        ? _badSoft
        : order.status == PreOrderStatus.completed
        ? _goodSoft
        : _brandSoft;

    pw.Widget row(
      String label,
      String value, {
      PdfColor? color,
      bool strong = false,
    }) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 11, color: _muted),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              color: color ?? _ink,
              fontWeight: strong ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );

    pw.Widget info(String label, String? value) {
      if (value == null || value.isEmpty) return pw.SizedBox();
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 9, color: _muted),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 11,
                color: _ink,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    pw.Widget cell(
      String text, {
      pw.TextAlign align = pw.TextAlign.left,
      bool head = false,
      bool strong = false,
    }) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 7, horizontal: 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: head ? 9 : 10.5,
          color: head ? _muted : _ink,
          fontWeight: head || strong
              ? pw.FontWeight.bold
              : pw.FontWeight.normal,
        ),
      ),
    );

    final doc = pw.Document(title: order.number, author: AppConstants.appName);
    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(40, 40, 40, 36),
          theme: theme,
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 12),
          child: pw.Text(
            '${labels.thanks}  ·  ${AppConstants.appName}',
            style: const pw.TextStyle(fontSize: 9, color: _muted),
          ),
        ),
        build: (context) => [
          // Masthead: the brand, and what this is.
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'elýeter' /* the wordmark as the app writes it */,
                    style: pw.TextStyle(
                      fontSize: 26,
                      color: _brand,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    labels.title,
                    style: const pw.TextStyle(fontSize: 11, color: _muted),
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: pw.BoxDecoration(
                  color: statusSoft,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Text(
                  labels.status,
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 22),
          // The order number, on a soft band.
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: _brandSoft,
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  labels.number(order.number),
                  style: pw.TextStyle(
                    fontSize: 16,
                    color: _ink,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                if (date != null)
                  pw.Text(
                    date,
                    style: const pw.TextStyle(fontSize: 10, color: _muted),
                  ),
              ],
            ),
          ),
          pw.SizedBox(height: 18),
          info(
            labels.customer,
            [
              order.customerName,
              order.phone,
            ].whereType<String>().where((s) => s.isNotEmpty).join('  ·  '),
          ),
          info(labels.address, order.address),
          pw.SizedBox(height: 10),
          // The lines.
          pw.Text(
            labels.products,
            style: pw.TextStyle(
              fontSize: 12,
              color: _ink,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Table(
            columnWidths: const {
              0: pw.FlexColumnWidth(5),
              1: pw.FixedColumnWidth(36),
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(2),
            },
            border: const pw.TableBorder(
              horizontalInside: pw.BorderSide(color: _line, width: 0.6),
              bottom: pw.BorderSide(color: _line, width: 0.6),
            ),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: _ink, width: 0.8),
                  ),
                ),
                children: [
                  cell(labels.products, head: true),
                  cell(labels.quantity, head: true, align: pw.TextAlign.center),
                  cell(labels.price, head: true, align: pw.TextAlign.right),
                  cell(labels.amount, head: true, align: pw.TextAlign.right),
                ],
              ),
              for (final item in order.items)
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        vertical: 7,
                        horizontal: 6,
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          if (productImages[item.productId]
                              case final image?) ...[
                            pw.SizedBox(
                              width: 40,
                              height: 40,
                              child: pw.Image(
                                pw.MemoryImage(image),
                                fit: pw.BoxFit.cover,
                              ),
                            ),
                            pw.SizedBox(width: 8),
                          ],
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  item.name,
                                  maxLines: 2,
                                  style: pw.TextStyle(
                                    fontSize: 10.5,
                                    color: _ink,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                if (item.variant != null &&
                                    item.variant!.isNotEmpty)
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.only(top: 2),
                                    child: pw.Text(
                                      item.variant!,
                                      style: const pw.TextStyle(
                                        fontSize: 9,
                                        color: _muted,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    cell('${item.quantity}', align: pw.TextAlign.center),
                    cell(
                      '${amount(item.price)} $currency',
                      align: pw.TextAlign.right,
                    ),
                    cell(
                      '${amount(item.lineTotal)} $currency',
                      align: pw.TextAlign.right,
                      strong: true,
                    ),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 14),
          // The totals, pushed to the right.
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.SizedBox(
              width: 230,
              child: pw.Column(
                children: [
                  row(labels.productsTotal, '${amount(goods)} $currency'),
                  if (extra > 0)
                    row(labels.cargo, '${amount(extra)} $currency'),
                  if (extra < 0)
                    row(
                      labels.discount,
                      '-${amount(-extra)} $currency',
                      color: _bad,
                    ),
                  pw.Divider(color: _line, thickness: 0.6),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 4),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          labels.total,
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: _ink,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          '${amount(order.totalPrice)} $currency',
                          style: pw.TextStyle(
                            fontSize: 18,
                            color: _brand,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    return doc.save();
  }
}
