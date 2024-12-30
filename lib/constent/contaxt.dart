import 'package:flutter/material.dart';

class ContextService {
  static final ContextService _instance = ContextService._internal();

  factory ContextService() {
    return _instance;
  }

  ContextService._internal();

  BuildContext? _optionalContext;

  void setContext(BuildContext? context) {
    _optionalContext = context;
  }

  BuildContext? get optionalContext => _optionalContext;
}
