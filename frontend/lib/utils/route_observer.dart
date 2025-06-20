import 'package:flutter/material.dart';

class AppRouteObserver extends NavigatorObserver {
  final Function() onRoutePopped;
  
  AppRouteObserver({required this.onRoutePopped});
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    onRoutePopped();
  }
}