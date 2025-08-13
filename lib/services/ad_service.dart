import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // IDs de teste para desenvolvimento (funciona imediatamente)
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  
  // IDs reais do AdMob (descomentando quando quiser usar os reais)
  // static const String _bannerAdUnitId = 'ca-app-pub-4105032687870290/6687037082';
  // static const String _interstitialAdUnitId = 'ca-app-pub-4105032687870290/5373955418';
  // static const String _rewardedAdUnitId = 'ca-app-pub-4105032687870290/1682122413';

  // Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  // Interstitial Ad
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  // Rewarded Ad
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  // Inicializar AdMob
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    print('🟢 [ADMOB] AdMob inicializado com sucesso!');
  }

  // === BANNER AD ===
  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _getBannerAdUnitId(),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdReady = true;
          print('🟢 [ADMOB] Banner carregado');
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdReady = false;
          print('🔴 [ADMOB] Banner falhou: $error');
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
  }

  BannerAd? get bannerAd => _isBannerAdReady ? _bannerAd : null;

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdReady = false;
  }

  // === INTERSTITIAL AD ===
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _getInterstitialAdUnitId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          print('🟢 [ADMOB] Intersticial carregado');
          
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
          print('🔴 [ADMOB] Intersticial falhou: $error');
        },
      ),
    );
  }

  void showInterstitialAd({VoidCallback? onAdClosed}) {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isInterstitialAdReady = false;
          _interstitialAd = null;
          print('🟡 [ADMOB] Intersticial fechado');
          onAdClosed?.call();
          // Carrega próximo anúncio
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isInterstitialAdReady = false;
          _interstitialAd = null;
          print('🔴 [ADMOB] Erro ao mostrar intersticial: $error');
          onAdClosed?.call();
          loadInterstitialAd();
        },
      );
      
      _interstitialAd!.show();
    } else {
      print('🔴 [ADMOB] Intersticial não está pronto');
      onAdClosed?.call();
      loadInterstitialAd();
    }
  }

  // === REWARDED AD ===
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _getRewardedAdUnitId(),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          print('🟢 [ADMOB] Recompensado carregado');
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdReady = false;
          print('🔴 [ADMOB] Recompensado falhou: $error');
        },
      ),
    );
  }

  void showRewardedAd({
    required VoidCallback onUserEarnedReward,
    VoidCallback? onAdClosed,
  }) {
    if (_isRewardedAdReady && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isRewardedAdReady = false;
          _rewardedAd = null;
          print('🟡 [ADMOB] Recompensado fechado');
          onAdClosed?.call();
          loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isRewardedAdReady = false;
          _rewardedAd = null;
          print('🔴 [ADMOB] Erro ao mostrar recompensado: $error');
          onAdClosed?.call();
          loadRewardedAd();
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print('🎁 [ADMOB] Usuário ganhou recompensa: ${reward.amount} ${reward.type}');
          onUserEarnedReward();
        },
      );
    } else {
      print('🔴 [ADMOB] Recompensado não está pronto');
      onAdClosed?.call();
      loadRewardedAd();
    }
  }

  // Getters para IDs dos anúncios (usando IDs de teste para desenvolvimento)
  String _getBannerAdUnitId() {
    if (Platform.isAndroid) {
      return _testBannerAdUnitId;
    } else if (Platform.isIOS) {
      return _testBannerAdUnitId;
    }
    throw UnsupportedError('Plataforma não suportada');
  }

  String _getInterstitialAdUnitId() {
    if (Platform.isAndroid) {
      return _testInterstitialAdUnitId;
    } else if (Platform.isIOS) {
      return _testInterstitialAdUnitId;
    }
    throw UnsupportedError('Plataforma não suportada');
  }

  String _getRewardedAdUnitId() {
    if (Platform.isAndroid) {
      return _testRewardedAdUnitId;
    } else if (Platform.isIOS) {
      return _testRewardedAdUnitId;
    }
    throw UnsupportedError('Plataforma não suportada');
  }

  // Limpar todos os anúncios
  void dispose() {
    disposeBannerAd();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }

  // Getters para verificar se anúncios estão prontos
  bool get isBannerReady => _isBannerAdReady;
  bool get isInterstitialReady => _isInterstitialAdReady;
  bool get isRewardedReady => _isRewardedAdReady;
}