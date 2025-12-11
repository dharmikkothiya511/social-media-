import 'package:flutter/material.dart';
import 'package:social_app/login/ChangePasswordPage.dart';
import 'package:social_app/pages/add-page.dart';
import 'package:social_app/pages/home_page.dart';
import 'package:social_app/login/login_screen.dart';
import 'package:social_app/login/sign_up_screen.dart';
import 'package:social_app/pages/profile/FAQs-profilespages.dart';
import 'package:social_app/pages/profile/LanguageSettingsPageProfile.dart';
import 'package:social_app/pages/profile/PrivacySettingsPageProfile.dart';
import 'package:social_app/pages/profile/account-page.dart';
import 'package:social_app/pages/profile/community-profilepages.dart';
import 'package:social_app/pages/profile/favorite-profilepage.dart';
import 'package:social_app/pages/profile/handbook-profilepages.dart';
import 'package:social_app/pages/profile/logout-profilepage.dart';
import 'package:social_app/pages/profile/paymant-profilepage.dart';
import 'package:social_app/pages/profile/personal-data-profile.dart';
import 'package:social_app/pages/profile/setting-profile.dart';
import 'package:social_app/pages/search-page.dart';
import 'package:social_app/socialpage/social_page.dart';
import 'package:social_app/lib/storage/files_upload_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://kqsxtvzqdwyasmyplywj.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtxc3h0dnpxZHd5YXNteXBseXdqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQxMDczNzgsImV4cCI6MjA2OTY4MzM3OH0.xHxtBgYJabVvbUy21eiXQqXZvVEEu2lZJUMN5EbJ8Nk';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'login',
      routes: {
        'social': (context) => SocialFeedPage(),
        'sing': (context) => SignupScreen(),
        'login': (context) => LoginScreen(),
        'home': (context) => HomePage(),
        'account': (context) => Myaccount(),
        'addpage': (context) => ImageUpload(),
        'changepass': (context) => ChangePasswordPage(),
        'search': (context) => SearchScreen(),
        'presonal': (context) => MyPersonalDataProfile(),
        'setting': (context) => MySettingProfilepage(),
        'payment': (context) => MyPaymentProfilePager(),
        'favorites': (context) => MyFavoritesProfilepage(),
        'FAQs': (context) => MyFAQspages(),
        'hanbook': (context) => MyHandbookProfilepages(),
        'community': (context) => MyCommunityProfilepages(),
        'logout': (context) => LogoutProfilePage(),
        'privacy': (context) => PrivacySettingsPage(),
        'language': (context) => LanguageSettingsPage(),

        //uploding
        'uploding': (context) => FilesUploadScreen(),
        'imageup': (context) => ImageUpload(),
      },
    ),
  );
}
