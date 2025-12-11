import 'package:flutter/material.dart';
import 'package:social_app/widgetpge/widget.dart';

class MyPaymentProfilePager extends StatefulWidget {
  const MyPaymentProfilePager({super.key});

  @override
  State<MyPaymentProfilePager> createState() => _MyPaymentProfilePagerState();
}

class _MyPaymentProfilePagerState extends State<MyPaymentProfilePager> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Payment')),
      bottomNavigationBar: BottomNavigationBarWidget(),
    );
  }
}
