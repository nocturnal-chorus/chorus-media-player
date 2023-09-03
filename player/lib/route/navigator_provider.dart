import 'package:flutter/material.dart';

class NavigatorProvider {
  final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'NavigatorProvider');

  static final NavigatorProvider _instance = NavigatorProvider._();

  NavigatorProvider._();

  static GlobalKey<NavigatorState> get navigatorKey => _instance._navigatorKey;

  static BuildContext? get navigatorContext =>
      _instance._navigatorKey.currentState?.context;
}
