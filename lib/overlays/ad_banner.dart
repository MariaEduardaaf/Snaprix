import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({Key? key}) : super(key: key);

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    // Carrega banner se não estiver carregado
    if (!_adService.isBannerReady) {
      _adService.loadBannerAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se o banner estiver pronto, mostra ele
    if (_adService.isBannerReady && _adService.bannerAd != null) {
      return Container(
        width: _adService.bannerAd!.size.width.toDouble(),
        height: _adService.bannerAd!.size.height.toDouble(),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: AdWidget(ad: _adService.bannerAd!),
      );
    }
    
    // Se não estiver pronto, mostra um placeholder
    return Container(
      width: 320,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          'Carregando anúncio...',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Não dispose o banner aqui, pois ele é reutilizado
    super.dispose();
  }
}