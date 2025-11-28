import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  // Configuración de moneda
  String _currencyCode = 'PEN'; // Soles por defecto
  String _currencySymbol = 'S/';
  
  // Configuración de idioma
  Locale _locale = const Locale('es'); // Español por defecto

  String get currencyCode => _currencyCode;
  String get currencySymbol => _currencySymbol;
  Locale get locale => _locale;

  // Monedas soportadas (las más usadas en Latinoamérica + USD + EUR + CNY)
  static const Map<String, Map<String, String>> supportedCurrencies = {
    'PEN': {'name': 'Sol Peruano', 'symbol': 'S/', 'flag': '🇵🇪'},
    'USD': {'name': 'Dólar Estadounidense', 'symbol': '\$', 'flag': '🇺🇸'},
    'EUR': {'name': 'Euro', 'symbol': '€', 'flag': '🇪🇺'},
    'CLP': {'name': 'Peso Chileno', 'symbol': '\$', 'flag': '🇨🇱'},
    'ARS': {'name': 'Peso Argentino', 'symbol': '\$', 'flag': '🇦🇷'},
    'BOB': {'name': 'Boliviano', 'symbol': 'Bs.', 'flag': '🇧🇴'},
    'BRL': {'name': 'Real Brasileño', 'symbol': 'R\$', 'flag': '🇧🇷'},
    'MXN': {'name': 'Peso Mexicano', 'symbol': '\$', 'flag': '🇲🇽'},
    'COP': {'name': 'Peso Colombiano', 'symbol': '\$', 'flag': '🇨🇴'},
    'CNY': {'name': 'Yuan Chino', 'symbol': '¥', 'flag': '🇨🇳'},
    'JPY': {'name': 'Yen Japonés', 'symbol': '¥', 'flag': '🇯🇵'},
  };

  // Idiomas soportados (los más usados)
  static const Map<String, Map<String, String>> supportedLanguages = {
    'es': {'name': 'Español', 'flag': '🇪🇸'},
    'en': {'name': 'English', 'flag': '🇬🇧'},
    'pt': {'name': 'Português', 'flag': '🇧🇷'},
    'zh': {'name': '中文', 'flag': '🇨🇳'},
  };

  /// Cargar configuración guardada
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    _currencyCode = prefs.getString('currency_code') ?? 'PEN';
    _currencySymbol = prefs.getString('currency_symbol') ?? 'S/';
    
    final languageCode = prefs.getString('language_code') ?? 'es';
    _locale = Locale(languageCode);
    
    notifyListeners();
    print('✅ Configuración cargada: $_currencyCode, ${_locale.languageCode}');
  }

  /// Cambiar moneda
  Future<void> setCurrency(String code) async {
    if (!supportedCurrencies.containsKey(code)) {
      print('❌ Moneda no soportada: $code');
      return;
    }

    _currencyCode = code;
    _currencySymbol = supportedCurrencies[code]!['symbol']!;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency_code', _currencyCode);
    await prefs.setString('currency_symbol', _currencySymbol);

    notifyListeners();
    print('✅ Moneda cambiada a: $code ($_currencySymbol)');
  }

  /// Cambiar idioma
  Future<void> setLanguage(String languageCode) async {
    if (!supportedLanguages.containsKey(languageCode)) {
      print('❌ Idioma no soportado: $languageCode');
      return;
    }

    _locale = Locale(languageCode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);

    notifyListeners();
    print('✅ Idioma cambiado a: $languageCode');
  }

  /// Formatear precio con la moneda actual
  String formatPrice(double price) {
    // Monedas sin decimales (Yen, Pesos Chilenos, etc.)
    final noDecimalCurrencies = ['JPY', 'CLP', 'COP'];
    
    if (noDecimalCurrencies.contains(_currencyCode)) {
      return '$_currencySymbol${price.toStringAsFixed(0)}';
    }
    
    return '$_currencySymbol${price.toStringAsFixed(2)}';
  }

  /// Obtener nombre de la moneda actual
  String get currentCurrencyName {
    return supportedCurrencies[_currencyCode]?['name'] ?? 'Desconocida';
  }

  /// Obtener bandera de la moneda actual
  String get currentCurrencyFlag {
    return supportedCurrencies[_currencyCode]?['flag'] ?? '';
  }

  /// Obtener nombre del idioma actual
  String get currentLanguageName {
    return supportedLanguages[_locale.languageCode]?['name'] ?? 'Unknown';
  }

  /// Obtener bandera del idioma actual
  String get currentLanguageFlag {
    return supportedLanguages[_locale.languageCode]?['flag'] ?? '';
  }
}