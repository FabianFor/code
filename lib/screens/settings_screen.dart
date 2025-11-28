import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings, style: TextStyle(fontSize: 18.sp)),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        children: [
          // ==================== MONEDA ====================
          _buildSectionHeader(
            context,
            icon: Icons.attach_money,
            title: l10n.currency,
            subtitle: 'Selecciona tu moneda preferida',
          ),
          
          _buildCurrencyTile(
            context,
            currentCode: settingsProvider.currencyCode,
            onTap: () => _showCurrencySelector(context),
          ),

          Divider(height: 32.h, thickness: 1),

          // ==================== IDIOMA ====================
          _buildSectionHeader(
            context,
            icon: Icons.language,
            title: l10n.language,
            subtitle: 'Selecciona tu idioma preferido',
          ),
          
          _buildLanguageTile(
            context,
            currentLocale: settingsProvider.locale,
            onTap: () => _showLanguageSelector(context),
          ),

          Divider(height: 32.h, thickness: 1),

          // ==================== PERFIL DEL NEGOCIO ====================
          _buildSectionHeader(
            context,
            icon: Icons.store,
            title: l10n.businessProfile,
            subtitle: 'Configura la información de tu negocio',
          ),
          
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.edit,
                color: const Color(0xFF2196F3),
                size: 24.sp,
              ),
            ),
            title: Text(
              'Editar perfil',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Nombre, logo, contacto, etc.',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),

          SizedBox(height: 24.h),

          // ==================== VERSIÓN ====================
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Center(
              child: Text(
                'MiNegocio v1.0.0',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 24.sp, color: const Color(0xFF2196F3)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyTile(
    BuildContext context, {
    required String currentCode,
    required VoidCallback onTap,
  }) {
    final currency = SettingsProvider.supportedCurrencies[currentCode]!;
    
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          currency['flag']!,
          style: TextStyle(fontSize: 24.sp),
        ),
      ),
      title: Text(
        currency['name']!,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${currency['symbol']} - $currentCode',
        style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
      onTap: onTap,
    );
  }

  Widget _buildLanguageTile(
    BuildContext context, {
    required Locale currentLocale,
    required VoidCallback onTap,
  }) {
    final language = SettingsProvider.supportedLanguages[currentLocale.languageCode]!;
    
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          language['flag']!,
          style: TextStyle(fontSize: 24.sp),
        ),
      ),
      title: Text(
        language['name']!,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        currentLocale.languageCode.toUpperCase(),
        style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
      onTap: onTap,
    );
  }

  void _showCurrencySelector(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Seleccionar Moneda',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: SettingsProvider.supportedCurrencies.length,
                itemBuilder: (context, index) {
                  final code = SettingsProvider.supportedCurrencies.keys.elementAt(index);
                  final currency = SettingsProvider.supportedCurrencies[code]!;
                  final isSelected = code == settingsProvider.currencyCode;
                  
                  return ListTile(
                    leading: Text(currency['flag']!, style: TextStyle(fontSize: 28.sp)),
                    title: Text(
                      currency['name']!,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${currency['symbol']} - $code',
                      style: TextStyle(fontSize: 13.sp),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: Colors.green, size: 24.sp)
                        : null,
                    onTap: () {
                      settingsProvider.setCurrency(code);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ Moneda cambiada a ${currency['name']}'),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Seleccionar Idioma',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            ...SettingsProvider.supportedLanguages.entries.map((entry) {
              final code = entry.key;
              final language = entry.value;
              final isSelected = code == settingsProvider.locale.languageCode;
              
              return ListTile(
                leading: Text(language['flag']!, style: TextStyle(fontSize: 28.sp)),
                title: Text(
                  language['name']!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  code.toUpperCase(),
                  style: TextStyle(fontSize: 13.sp),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: Colors.green, size: 24.sp)
                    : null,
                onTap: () {
                  settingsProvider.setLanguage(code);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Idioma cambiado a ${language['name']}'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}