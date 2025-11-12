import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/business_profile.dart';

class BusinessProvider with ChangeNotifier {
  BusinessProfile _profile = BusinessProfile();

  BusinessProfile get profile => _profile;

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('business_profile');
    if (jsonString != null) {
      _profile = BusinessProfile.fromJson(json.decode(jsonString));
      notifyListeners();
    }
  }

  Future<void> updateProfile(BusinessProfile newProfile) async {
    _profile = newProfile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('business_profile', json.encode(_profile.toJson()));
    notifyListeners();
  }

  Future<void> updateLogo(String path) async {
    _profile.logoPath = path;
    await updateProfile(_profile);
  }

  Future<void> updateBusinessName(String name) async {
    _profile.businessName = name;
    await updateProfile(_profile);
  }
}