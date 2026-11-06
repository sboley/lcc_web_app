import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web; // Modern web package
import 'package:http/http.dart' as http; // For sending the data to your API

//This class tracks how long a user stay on the website.

class SessionTracker extends WidgetsBindingObserver {
  late DateTime _startTime;

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
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the user minimizes the browser or switches tabs on mobile
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _logSessionDuration();
    }
  }

  void _logSessionDuration() {
    final endTime = DateTime.now();
    final durationInSeconds = endTime.difference(_startTime).inSeconds;

    // Prevent logging ghost hits (less than 2 seconds)
    if (durationInSeconds > 2) {
      _sendToBackend(durationInSeconds);
    }
  }

  Future<void> _sendToBackend(int seconds) async {
    try {
      // Option A: Send it to your existing Cloudflare API routes
      // e.g., /api/analytics
      await http.post(
        Uri.parse('https://yourdomain.com'),
        body: {'duration_seconds': seconds.toString()},
      ).timeout(const Duration(milliseconds: 500)); // Keep it fast so it doesn't block closing
    } catch (e) {
      // Fail silently
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
