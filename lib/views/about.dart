import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme/app_theme.dart';
import '../widgets/app_icon_decorative.dart';
import '../localizations/app_localizations.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '1.0.0';
  bool _isLoadingVersion = true;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _version = packageInfo.version;
        _isLoadingVersion = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingVersion = false;
      });
    }
  }

  Future<void> _launchGitHub() async {
    final url = Uri.parse('https://github.com/blspeiser');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppIconDecorative(),
        title: Text(
          AppLocalizations.of(context)!.translate('about'),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: Container(
        color: AppTheme.backgroundColor,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Name
                Text(
                  'Yahrtzeit Manager',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                // Version
                if (_isLoadingVersion)
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  )
                else
                  Text(
                    '${AppLocalizations.of(context)!.translate('version')} $_version',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                SizedBox(height: 32),
                // Author
                Text(
                  AppLocalizations.of(context)!.translate('developed_by'),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textTertiary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.translate('author_name'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 24),
                // GitHub Link
                InkWell(
                  onTap: _launchGitHub,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.cardBorderColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.code,
                          color: AppTheme.textPrimary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'https://github.com/blspeiser',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 48),
                // All Rights Reserved
                Text(
                  AppLocalizations.of(context)!.translate('all_rights_reserved'),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
