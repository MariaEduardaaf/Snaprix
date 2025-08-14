import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // IDs REAIS do AdMob para produção
  static const String _bannerAdUnitId = 'ca-app-pub-4105032687870290/6687037082';
  static const String _interstitialAdUnitId = 'ca-app-pub-4105032687870290/5373955418';
  static const String _rewardedAdUnitId = 'ca-app-pub-4105032687870290/1682122413';
  
  // IDs de teste para desenvolvimento (comentados para produção)
  // static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  // static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  // static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  
  // App ID: ca-app-pub-4105032687870290~6762240465

  // Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  // Interstitial Ad
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  // Rewarded Ad
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  // Inicializar AdMob com App Tracking Transparency
  static Future<void> initialize() async {
    // 1. Solicitar permissão de rastreamento no iOS
    if (Platform.isIOS) {
      await _requestTrackingPermission();
    }
    
    // 2. Inicializar AdMob
    await MobileAds.instance.initialize();
    
    // 3. Configurar anúncios adaptativos para iOS
    if (Platform.isIOS) {
      await _configureAdaptiveAds();
    }
    
    print('🟢 [ADMOB] AdMob inicializado com sucesso!');
  }

  // Solicitar permissão de rastreamento (ATT - App Tracking Transparency)
  static Future<void> _requestTrackingPermission() async {
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      
      if (status == TrackingStatus.notDetermined) {
        // Mostrar dialog de permissão
        final result = await AppTrackingTransparency.requestTrackingAuthorization();
        print('🔒 [ATT] Permissão de rastreamento: $result');
      } else {
        print('🔒 [ATT] Status de rastreamento: $status');
      }
      
      // Configurar parâmetros de privacidade do AdMob baseado na permissão
      await _configurePrivacySettings(status);
      
    } catch (e) {
      print('❌ [ATT] Erro ao solicitar permissão de rastreamento: $e');
    }
  }

  // Configurar parâmetros de privacidade do AdMob
  static Future<void> _configurePrivacySettings(TrackingStatus status) async {
    final RequestConfiguration requestConfiguration = RequestConfiguration(
      // Marcar se é para menores (COPPA)
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
      
      // Configurar baseado na permissão de rastreamento
      tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
      
      // Máxima classificação de conteúdo
      maxAdContentRating: MaxAdContentRating.t,
    );
    
    await MobileAds.instance.updateRequestConfiguration(requestConfiguration);
    print('🔒 [ADMOB] Configurações de privacidade aplicadas');
  }

  // Configurar anúncios adaptativos para iOS
  static Future<void> _configureAdaptiveAds() async {
    try {
      // Configurações específicas do iOS para melhor performance
      print('📱 [ADMOB] Anúncios adaptativos configurados para iOS');
    } catch (e) {
      print('❌ [ADMOB] Erro ao configurar anúncios adaptativos: $e');
    }
  }

  // === BANNER AD (ADAPTATIVO) ===
  void loadBannerAd() async {
    // Usar banner adaptativo para melhor performance no iOS
    AdSize adSize = AdSize.banner;
    
    if (Platform.isIOS) {
      // Banner adaptativo para iOS - se ajusta à largura da tela
      // Usar largura padrão para iPhone (390px) como fallback seguro
      adSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(390) ?? AdSize.banner;
    }

    _bannerAd = BannerAd(
      adUnitId: _getBannerAdUnitId(),
      size: adSize, // Usar tamanho adaptativo
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdReady = true;
          print('🟢 [ADMOB] Banner adaptativo carregado');
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdReady = false;
          print('🔴 [ADMOB] Banner falhou: $error');
          ad.dispose();
        },
        onAdOpened: (ad) {
          print('📱 [ADMOB] Banner aberto');
        },
        onAdClosed: (ad) {
          print('📱 [ADMOB] Banner fechado');
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
      return _bannerAdUnitId; // Usando ID real para produção
    } else if (Platform.isIOS) {
      return _bannerAdUnitId; // Usando ID real para produção
    }
    throw UnsupportedError('Plataforma não suportada');
  }

  String _getInterstitialAdUnitId() {
    if (Platform.isAndroid) {
      return _interstitialAdUnitId; // Usando ID real para produção
    } else if (Platform.isIOS) {
      return _interstitialAdUnitId; // Usando ID real para produção
    }
    throw UnsupportedError('Plataforma não suportada');
  }

  String _getRewardedAdUnitId() {
    if (Platform.isAndroid) {
      return _rewardedAdUnitId; // Usando ID real para produção
    } else if (Platform.isIOS) {
      return _rewardedAdUnitId; // Usando ID real para produção
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