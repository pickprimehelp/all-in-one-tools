import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'services/ad_helper.dart';
import 'modules/gst_invoice/gst_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MultiToolApp());
}

class MultiToolApp extends StatelessWidget {
  const MultiToolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Multi Tools',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tools = [
      {'title': 'GST Invoice Maker', 'icon': Icons.receipt_long, 'color': Colors.blue, 'widget': const GSTInvoiceScreen()},
      {'title': 'Wedding Card Maker', 'icon': Icons.card_giftcard, 'color': Colors.pink, 'widget': null},
      {'title': 'WhatsApp Status Maker', 'icon': Icons.camera_alt, 'color': Colors.green, 'widget': null},
      {'title': 'YouTube Tag Generator', 'icon': Icons.video_library, 'color': Colors.red, 'widget': null},
      {'title': 'Meme Maker', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.orange, 'widget': null},
      {'title': 'Smart Calculator', 'icon': Icons.calculate, 'color': Colors.purple, 'widget': null},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('All-in-One Multi Tools'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: tools.length,
              itemBuilder: (context, index) {
                final tool = tools[index];
                return InkWell(
                  onTap: () {
                    if (tool['widget'] != null) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => tool['widget']));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${tool['title']} coming in next update!')),
                      );
                    }
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: (tool['color'] as Color).withOpacity(0.2),
                          child: Icon(tool['icon'], color: tool['color'], size: 30),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tool['title'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isBannerAdReady)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}
