import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../services/ad_helper.dart';

class GSTInvoiceScreen extends StatefulWidget {
  const GSTInvoiceScreen({super.key});

  @override
  State<GSTInvoiceScreen> createState() => _GSTInvoiceScreenState();
}

class _GSTInvoiceScreenState extends State<GSTInvoiceScreen> {
  final _businessController = TextEditingController();
  final _clientController = TextEditingController();
  final _gstController = TextEditingController();
  final _amountController = TextEditingController();
  
  double _gstRate = 18.0;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    AdHelper.loadInterstitialAd(onAdLoaded: (ad) {
      _interstitialAd = ad;
    });
  }

  void _generateInvoiceWithAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
          _printInvoice();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _printInvoice();
        },
      );
      _interstitialAd!.show();
    } else {
      _printInvoice();
    }
  }

  Future<void> _printInvoice() async {
    final pdf = pw.Document();
    double baseAmount = double.tryParse(_amountController.text) ?? 0.0;
    double gstAmount = (baseAmount * _gstRate) / 100;
    double totalAmount = baseAmount + gstAmount;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(_businessController.text.isEmpty ? "Business Name" : _businessController.text, 
                    style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.Text("GSTIN: ${_gstController.text}"),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text("Bill To: ${_clientController.text}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.TableHelper.fromTextArray(
                  headers: ['Item', 'Base Amount', 'GST RATE', 'GST Tax', 'Total'],
                  data: [
                    ['Service / Product', '₹$baseAmount', '$_gstRate%', '₹$gstAmount', '₹$totalAmount'],
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text("Grand Total: ₹$totalAmount", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GST Invoice Generator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _businessController, decoration: const InputDecoration(labelText: 'Your Business Name')),
            TextField(controller: _gstController, decoration: const InputDecoration(labelText: 'GSTIN Number')),
            TextField(controller: _clientController, decoration: const InputDecoration(labelText: 'Client Name')),
            TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Base Amount (₹)')),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('GST Rate: '),
                DropdownButton<double>(
                  value: _gstRate,
                  items: [5.0, 12.0, 18.0, 28.0].map((rate) {
                    return DropdownMenuItem(value: rate, child: Text('$rate%'));
                  }).toList(),
                  onChanged: (val) => setState(() => _gstRate = val!),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _generateInvoiceWithAd,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generate & Print Bill'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}
