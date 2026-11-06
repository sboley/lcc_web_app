import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web; // Modern web package

//This class tracks how long a user stay on the website.

class SessionTracker extends WidgetsBindingObserver {
  late DateTime _startTime;
  bool _hasLoggedSession = false;

  void startSession() {
    _startTime = DateTime.now();
    // Register the observer to listen to app minimization/backgrounding
    WidgetsBinding.instance.addObserver(this);

    // Also hook directly into the browser's "beforeunload" event (Tab Closing)
    web.window.addEventListener(
      'beforeunload',
      ((web.Event event) {
        _logSessionDuration();
      }).toJS, // 2. Add .toJS here
    );

    web.document.addEventListener(
      'visibilitychange',
      ((web.Event event) {
        if (web.document.hidden) {
          _logSessionDuration();
        }
      }).toJS,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the user minimizes the browser or switches tabs on mobile
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _logSessionDuration();
    }
  }

  void _logSessionDuration() {
    if (_hasLoggedSession) return;

    final endTime = DateTime.now();
    final durationInSeconds = endTime.difference(_startTime).inSeconds;

    // Prevent logging ghost hits (less than 2 seconds)
    if (durationInSeconds > 2) {
      _hasLoggedSession = true;
      _sendToBackend(durationInSeconds);
    }
  }

  Future<void> _sendToBackend(int seconds) async {
    try {
      final String jsonData = '{"duration_seconds": $seconds}';
      final blobProperties = web.BlobPropertyBag(type: 'text/plain');
      final jsArray = [jsonData.toJS].toJS;
      final web.Blob blob = web.Blob(jsArray, blobProperties);
      web.window.navigator.sendBeacon(
        'https://lccbackend-production.up.railway.app/api/analytics',
        blob,
      );
    } catch (e) {
      // Fail silently
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
