import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medicard/core/constants/api_result.dart';
import 'package:medicard/core/di/service_locator.dart';
import 'package:medicard/core/routing/app_router.dart';
import 'package:medicard/core/utils/platform_type.dart';
import 'package:medicard/features/activity/domain/models/invoice_details.dart';
import 'package:medicard/features/activity/domain/models/invoice_item.dart';
import 'package:medicard/features/activity/domain/repositories/invoice_repository.dart';
import 'package:medicard/medicard_network/repository/medicard_network_repository.dart';
import 'package:medicard/network/data/provider_page_response_model.dart';
import 'package:medicard/features/notifications/data/domain/notification_repo.dart';
import 'package:medicard/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  if (kDebugMode) debugPrint('Background message: ${message.messageId}');

  if (message.notification != null) {
    if (kDebugMode) {
      debugPrint(
        'Skipping local background notification; it is displayed by the OS.',
      );
    }
    return;
  }

  await PushNotificationService.instance.setupFlutterNotifications();
  await PushNotificationService.instance.showNotification(message);
}

/// Production-ready notification service with comprehensive error handling
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  // Resolve lazily so consumers can subscribe to the service's local event
  // streams before Firebase finishes its non-blocking startup initialization.
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;
  bool _isInitialized = false;

  /// Stream for notification actions (tap/interaction)
  final _notificationActionController =
      StreamController<NotificationAction>.broadcast();
  Stream<NotificationAction> get onNotificationAction =>
      _notificationActionController.stream;

  /// Stream for FCM token updates
  final _tokenController = StreamController<String>.broadcast();
  Stream<String> get onTokenRefresh => _tokenController.stream;

  /// Broadcasts every foreground FCM message so UI (e.g. the notifications
  /// list) can refresh itself without manual navigation.
  final _messageController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onMessageReceived => _messageController.stream;

  String? _currentToken;
  String? get currentToken => _currentToken;

  /// Initialize notification service
  /// Call this in main() before runApp()
  Future<bool> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) debugPrint('PushNotificationService already initialized');
      return true;
    }

    try {
      if (kDebugMode) debugPrint('Initializing PushNotificationService...');

      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Request permissions. A denial only affects *displaying*
      // notifications — the FCM token (needed for backend registration and
      // tap handling) does not require permission, so always continue.
      final permissionGranted = await _requestPermission();
      if (!permissionGranted) {
        if (kDebugMode) {
          debugPrint(
            'Notification permission not granted; continuing with token setup only',
          );
        }
      }

      // Setup local notifications
      await setupFlutterNotifications();

      // Setup message handlers
      await _setupMessageHandlers();

      // Get and listen to FCM token
      await _setupTokenHandling();

      _isInitialized = true;
      if (kDebugMode) {
        debugPrint('PushNotificationService initialized successfully');
      }
      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error initializing PushNotificationService: $e');
      }
      if (kDebugMode) debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Request notification permissions
  Future<bool> _requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      final isAuthorized =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      if (kDebugMode) {
        debugPrint('Permission status: ${settings.authorizationStatus}');
      }
      return isAuthorized;
    } catch (e) {
      if (kDebugMode) debugPrint('Error requesting permission: $e');
      return false;
    }
  }

  /// Setup flutter local notifications
  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) return;

    try {
      // Android notification channel
      const channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      // Optional extra channels for future use (won't affect current behavior)
      const promoChannel = AndroidNotificationChannel(
        'promotions',
        'Promotions',
        description: 'Offers and campaigns',
        importance: Importance.high,
      );
      const updatesChannel = AndroidNotificationChannel(
        'updates',
        'Updates',
        description: 'App and policy updates',
        importance: Importance.defaultImportance,
      );

      // Create Android notification channel
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      // Create extra channels (safe no-op if already exists)
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(promoChannel);
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(updatesChannel);

      // Initialize settings for both platforms
      final initializationSettings = InitializationSettings(
        android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          notificationCategories: <DarwinNotificationCategory>[
            DarwinNotificationCategory(
              'MC_GENERAL',
              actions: <DarwinNotificationAction>[
                DarwinNotificationAction.plain('view', 'View'),
                DarwinNotificationAction.plain('mark_read', 'Mark as read'),
              ],
            ),
          ],
        ),
      );

      // Initialize plugin
      await _localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: _handleNotificationTap,
        onDidReceiveBackgroundNotificationResponse: _handleNotificationTap,
      );

      _isFlutterLocalNotificationsInitialized = true;
      if (kDebugMode) debugPrint('Local notifications initialized');
    } catch (e) {
      if (kDebugMode) debugPrint('Error setting up local notifications: $e');
      rethrow;
    }
  }

  /// Display notification
  Future<void> showNotification(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final data = message.data;
      final title = notification?.title ?? data['title']?.toString();
      final body = notification?.body ?? data['body']?.toString();

      // A data-only message may be intended for silent background work. Only
      // turn it into a visible notification when it contains display content.
      if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
        if (kDebugMode) debugPrint('Message has no notification content');
        return;
      }

      // Check platform-specific notification data
      final android = notification?.android;

      // Support multiple image field names
      final imageUrl =
          data['image'] as String? ??
          data['imageUrl'] as String? ??
          data['picture'] as String? ??
          android?.imageUrl;

      final largeIconUrl = data['largeIcon'] as String? ?? imageUrl;
      final groupKey = data['group'] as String? ?? 'mc_general_group';
      final colorHex = data['color'] as String?; // e.g. #1E88E5
      final channelId = data['channel'] as String? ?? 'high_importance_channel';
      final channelName = channelId == 'promotions'
          ? 'Promotions'
          : channelId == 'updates'
          ? 'Updates'
          : 'High Importance Notifications';

      // Auto-enable big picture if image URL exists
      final forceBigPicture =
          (data['forceBigPicture'] == 'true') ||
          (imageUrl != null && imageUrl.isNotEmpty);

      if (kDebugMode) debugPrint('Notification Image URL: $imageUrl');
      if (kDebugMode) debugPrint('Force Big Picture: $forceBigPicture');

      // حمّل الصورة الكبيرة (largeIcon) مرة واحدة في البداية
      ByteArrayAndroidBitmap? largeIconBitmap;
      if (largeIconUrl != null && largeIconUrl.isNotEmpty) {
        try {
          largeIconBitmap = ByteArrayAndroidBitmap(
            await _downloadBytes(largeIconUrl),
          );
          if (kDebugMode) debugPrint('Large icon loaded successfully');
        } catch (e) {
          if (kDebugMode) debugPrint('Failed to load large icon: $e');
        }
      }

      // Prepare notification details
      StyleInformation styleInfo;
      if (forceBigPicture && imageUrl != null && imageUrl.isNotEmpty) {
        try {
          final bigPicture = ByteArrayAndroidBitmap(
            await _downloadBytes(imageUrl),
          );
          styleInfo = BigPictureStyleInformation(
            bigPicture,
            largeIcon: largeIconBitmap,
            contentTitle: title,
            summaryText: body,
            hideExpandedLargeIcon: false,
          );
          if (kDebugMode) debugPrint('Big picture style loaded successfully');
        } catch (e) {
          if (kDebugMode) debugPrint('Failed to load big picture: $e');
          styleInfo = BigTextStyleInformation(
            body ?? '',
            contentTitle: title,
            summaryText: data['summary'],
          );
        }
      } else {
        styleInfo = BigTextStyleInformation(
          body ?? '',
          contentTitle: title,
          summaryText: data['summary'],
        );
      }

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: 'This channel is used for notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
            styleInformation: styleInfo,
            showWhen: true,
            ticker: title,
            largeIcon: largeIconBitmap,
            color: colorHex != null ? _parseColor(colorHex) : null,
            groupKey: groupKey,
            actions: <AndroidNotificationAction>[
              const AndroidNotificationAction(
                'view',
                'View',
                showsUserInterface: true,
                cancelNotification: true,
              ),
              const AndroidNotificationAction(
                'mark_read',
                'Mark as read',
                showsUserInterface: false,
                cancelNotification: true,
              ),
            ],
          );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Show notification
      await _localNotifications.show(
        id: _notificationId(message, title: title, body: body),
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: message.data.isNotEmpty ? jsonEncode(message.data) : null,
      );

      if (kDebugMode) debugPrint('Notification shown: $title');
    } catch (e) {
      if (kDebugMode) debugPrint('Error showing notification: $e');
    }
  }

  int _notificationId(
    RemoteMessage message, {
    required String? title,
    required String? body,
  }) {
    final rawId =
        message.data['notificationId']?.toString() ??
        message.data['notification_id']?.toString() ??
        message.messageId ??
        '${title ?? ''}|${body ?? ''}|${message.sentTime?.millisecondsSinceEpoch ?? ''}';

    final numericId = int.tryParse(rawId);
    if (numericId != null) return numericId & 0x7fffffff;

    // Deterministic 31-bit FNV-1a hash. Re-delivery of the same FCM message
    // replaces the existing local notification instead of adding another one.
    var hash = 0x811c9dc5;
    for (final codeUnit in rawId.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }

  Future<Uint8List> _downloadBytes(String url) async {
    final req = await HttpClient().getUrl(Uri.parse(url));
    final res = await req.close();
    return consolidateHttpClientResponseBytes(res);
  }

  Color _parseColor(String hex) {
    final normalized = hex.replaceFirst('#', '');
    final value = int.parse(normalized, radix: 16);
    return Color(normalized.length == 6 ? (0xFF000000 | value) : value);
  }

  /// Setup message handlers for different app states
  Future<void> _setupMessageHandlers() async {
    try {
      // Foreground messages
      FirebaseMessaging.onMessage.listen((message) {
        if (kDebugMode) debugPrint('Foreground message: ${message.messageId}');
        _messageController.add(message);
        showNotification(message);
      });

      // Background messages (app in background, user taps notification)
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        if (kDebugMode) {
          debugPrint('Notification opened (background): ${message.messageId}');
        }
        _handleMessageOpen(message);
      });

      // Terminated state (app was closed, user taps notification)
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        if (kDebugMode) {
          debugPrint(
            '🚀 App opened from notification: ${initialMessage.messageId}',
          );
        }
        // Delay to ensure app is fully initialized
        Future.delayed(const Duration(seconds: 1), () {
          _handleMessageOpen(initialMessage);
        });
      }

      if (kDebugMode) debugPrint('Message handlers setup complete');
    } catch (e) {
      if (kDebugMode) debugPrint('Error setting up message handlers: $e');
    }
  }

  /// Setup FCM token handling
  Future<void> _setupTokenHandling() async {
    try {
      // Refresh listener first: it must stay active even if the initial
      // token fetch below bails out (e.g. APNs not ready yet on iOS).
      _messaging.onTokenRefresh.listen((token) {
        if (kDebugMode) {
          debugPrint('Token refreshed: $token');
        }
        // TEMP-FCM-DEBUG: verify on 2nd device, then remove.
        debugPrint('[FCM] token refresh: ${_short(token)}');
        _currentToken = token;
        _tokenController.add(token);
        unawaited(registerDeviceToken());
      });

      // iOS delivers the APNs token asynchronously after permission is
      // granted; FCM getToken() throws `apns-token-not-set` until then.
      if (!kIsWeb && Platform.isIOS) {
        final apnsToken = await _waitForApnsToken();
        if (apnsToken == null) {
          if (kDebugMode) {
            debugPrint(
              'APNs token unavailable — FCM token deferred. '
              'Needs the Push capability (aps-environment) for this bundle ID; '
              'the refresh listener above will pick the token up later.',
            );
          }
          return;
        }
      }

      // Get initial token
      _currentToken = await _messaging.getToken();
      if (_currentToken != null) {
        if (kDebugMode) {
          debugPrint('FCM token obtained successfully');
          debugPrint('FCM token: $_currentToken');
        }
        _tokenController.add(_currentToken!);
        // Fire-and-forget: must never block startup or throw.
        unawaited(registerDeviceToken());
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error setting up token handling: $e');
    }
  }

  /// Polls for the iOS APNs token (up to ~10s). Null means iOS never issued
  /// one — almost always a missing Push capability/provisioning profile.
  Future<String?> _waitForApnsToken() async {
    for (var i = 0; i < 10; i++) {
      try {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null && apnsToken.isNotEmpty) return apnsToken;
      } catch (_) {
        // Not ready yet — keep polling.
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    return null;
  }

  /// Registers the current FCM token with the backend so pushes can reach
  /// this device. Safe to call anytime: no-ops when there is no token yet
  /// or nobody is logged in, and never throws (secondary flow).
  Future<bool> registerDeviceToken() async {
    try {
      var fcmToken = _currentToken;
      if (fcmToken == null || fcmToken.isEmpty) {
        // Startup may have run before the token existed (iOS APNs gate, a
        // transient getToken() failure, or login beating initialization).
        // Fetch it lazily now instead of dropping this registration.
        // TEMP-FCM-DEBUG: verify on 2nd device, then remove.
        debugPrint('[FCM] registerDeviceToken: no cached token, fetching…');
        fcmToken = await _fetchTokenForRegistration();
        if (fcmToken != null && fcmToken.isNotEmpty) {
          _currentToken = fcmToken;
          _tokenController.add(fcmToken);
        }
      }
      if (fcmToken == null || fcmToken.isEmpty) {
        if (kDebugMode) {
          debugPrint('registerDeviceToken skipped: no FCM token yet');
        }
        // TEMP-FCM-DEBUG: verify on 2nd device, then remove.
        debugPrint('[FCM] register skipped: no FCM token yet');
        return false;
      }
      // TEMP-FCM-DEBUG: truncated token only — never log full tokens.
      // Verify on 2nd device, then remove.
      debugPrint(
        '[FCM] token obtained: ${_short(fcmToken)} '
        '(platform=${PlatformType.current.value})',
      );
      final registered = await sl<NotificationRepository>().registerDeviceToken(
        fcmToken: fcmToken,
        platform: PlatformType.current.value,
      );
      // TEMP-FCM-DEBUG: verify on 2nd device, then remove.
      debugPrint('[FCM] request sent, registered=$registered');
      if (kDebugMode) {
        debugPrint(
          registered
              ? 'Device token registered (platform=${PlatformType.current.value})'
              : 'registerDeviceToken skipped: not logged in',
        );
      }
      return registered;
    } catch (e) {
      if (kDebugMode) debugPrint('registerDeviceToken failed: $e');
      // TEMP-FCM-DEBUG: verify on 2nd device, then remove.
      debugPrint('[FCM] register failed: $e');
      return false;
    }
  }

  /// Best-effort token fetch used when registration is requested but no
  /// cached token exists yet. Returns null instead of throwing.
  Future<String?> _fetchTokenForRegistration() async {
    try {
      if (!kIsWeb && Platform.isIOS) {
        final apnsToken = await _waitForApnsToken();
        if (apnsToken == null) {
          // TEMP-FCM-DEBUG: verify on 2nd device, then remove.
          debugPrint('[FCM] APNs token unavailable, cannot fetch FCM token');
          return null;
        }
      }
      return await _messaging.getToken();
    } catch (e) {
      if (kDebugMode) debugPrint('Lazy FCM token fetch failed: $e');
      return null;
    }
  }

  /// First characters only — full FCM tokens must never hit the logs.
  String _short(String token) =>
      token.length > 12 ? '${token.substring(0, 12)}…' : token;

  /// Handle notification tap
  @pragma('vm:entry-point')
  static void _handleNotificationTap(NotificationResponse response) {
    if (kDebugMode) debugPrint('Notification tapped: ${response.id}');

    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        instance._notificationActionController.add(
          NotificationAction(
            type: NotificationActionType.tap,
            data: data,
            actionId: response.actionId,
          ),
        );
        // Same deep-link as in-app taps: provider page when present.
        instance._navigateFromPayload(data);
      } catch (e) {
        if (kDebugMode) debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Handle message open (from FCM directly)
  void _handleMessageOpen(RemoteMessage message) {
    _notificationActionController.add(
      NotificationAction(
        type: NotificationActionType.open,
        data: message.data,
        messageId: message.messageId,
      ),
    );
    _navigateFromPayload(message.data);
  }

  /// Deep-links a push payload. Priority: direct `InvoiceId` →
  /// invoice details; `ProviderId` → provider page; `PackageId` → fetch its
  /// provider → provider page with the package sheet auto-opened.
  /// Works from any app state via the static router since
  /// these handlers have no BuildContext.
  void _navigateFromPayload(Map<String, dynamic> data) {
    final rawInvoice =
        data['InvoiceId'] ?? data['invoiceId'] ?? data['invoice_id'];
    final invoiceId = _intOrNull(rawInvoice);
    if (invoiceId != null) {
      if (kDebugMode) {
        debugPrint('[Push] opening invoice $invoiceId from notification');
      }
      unawaited(openNotificationInvoice(invoiceId));
      return;
    }

    final raw = data['ProviderId'] ?? data['providerId'];
    final providerId = raw is int ? raw : int.tryParse('${raw ?? ''}');
    if (providerId != null) {
      if (kDebugMode) {
        debugPrint('[Push] opening provider $providerId from notification');
      }
      AppRouter.current?.push('/provider-page', extra: providerId);
      return;
    }
    final packageId = _intOrNull(
      data['PackageId'] ?? data['packageId'],
    );
    if (packageId == null) {
      if (kDebugMode) {
        debugPrint(
          '[Push] tap has no recognized target '
          '(invoice=${data['InvoiceId'] ?? data['invoiceId']}, '
          'provider=${data['ProviderId'] ?? data['providerId']}, '
          'package=${data['PackageId'] ?? data['packageId']}), staying put',
        );
      }
      return;
    }
    unawaited(_openPackageFromNotification(packageId));
  }

  /// Deep-links an invoice from notification: calls the get-invoice-by-id endpoint,
  /// maps the details, and navigates to the invoice details screen.
  static Future<bool> openNotificationInvoice(int invoiceId) async {
    try {
      final ApiResult<InvoiceDetails> result =
          await sl<InvoiceRepository>().getInvoiceDetails(invoiceId);

      return result.when(
        success: (details) {
          final invoiceItem = InvoiceItem(
            invoiceId: details.invoiceId ?? invoiceId,
            providerName: details.providerName ?? '',
            branchName: details.branchName ?? '',
            status: details.status ?? '',
            date: details.date ?? DateTime.now(),
            providerImageUrl: details.providerImageUrl,
            isReviewed: details.review != null,
            points: null,
            isFromPackage: false,
            priceAfter: details.totalAfter,
            priceBefore: details.totalBefore,
            discountPercentage: details.discountPercentage,
            familyId: details.familyId,
            beneficiaryName: details.beneficiaryName,
          );

          AppRouter.current?.push(
            '/invoice-details',
            extra: {
              'invoice': invoiceItem,
              'details': details,
              'invoiceId': invoiceId,
              'tab': _tabFromStatus(details.status),
            },
          );
          return true;
        },
        failure: (error) {
          if (kDebugMode) {
            debugPrint('[Push] getInvoiceDetails failed for $invoiceId: $error');
          }
          return false;
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[Push] invoice resolve failed: $e');
      return false;
    }
  }

  static int _tabFromStatus(String? status) {
    final s = status?.trim().toLowerCase();
    return switch (s) {
      'pending' => 1,
      'paid' => 2,
      'used' || 'completed' => 3,
      'canceled' || 'cancelled' => 4,
      _ => 1,
    };
  }

  /// Shared package deep-link: resolves the package's provider, then opens
  /// the provider page with the package sheet auto-opened. Returns false
  /// when the backend doesn't ship `providerId` yet (or the fetch fails).
  static Future<bool> openNotificationPackage(int packageId) async {
    try {
      final ApiResult<PackageDetailsResponse> result =
          await sl<MedicardNetworkRepository>().getPackageDetails(
        packageId: packageId,
      );
      final resolvedProviderId = result.maybeWhen(
        success: (response) => response.data?.providerId,
        orElse: () => null,
      );
      if (resolvedProviderId == null) {
        if (kDebugMode) {
          debugPrint(
            '[Push] package $packageId has no providerId yet',
          );
        }
        return false;
      }
      AppRouter.current?.push(
        '/provider-page',
        extra: {
          'providerId': resolvedProviderId,
          'autoOpenPackageId': packageId,
        },
      );
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('[Push] package resolve failed: $e');
      return false;
    }
  }

  Future<void> _openPackageFromNotification(int packageId) async {
    final opened = await openNotificationPackage(packageId);
    if (!opened && kDebugMode) {
      debugPrint('[Push] could not deep-link package $packageId');
    }
  }

  /// Parses backend ids that arrive as int or numeric string.
  static int? _intOrNull(Object? raw) =>
      raw is int ? raw : int.tryParse('${raw ?? ''}');

  /// Subscribe to topic
  Future<bool> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) debugPrint('Subscribed to topic: $topic');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Error subscribing to topic: $e');
      return false;
    }
  }

  /// Unsubscribe from topic
  Future<bool> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) ('Unsubscribed from topic: $topic');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Error unsubscribing from topic: $e');
      return false;
    }
  }

  /// Delete FCM token
  Future<bool> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _currentToken = null;
      if (kDebugMode) debugPrint('FCM token deleted');
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Error deleting token: $e');
      return false;
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      if (kDebugMode) debugPrint('All notifications cancelled');
    } catch (e) {
      if (kDebugMode) debugPrint('Error cancelling notifications: $e');
    }
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _localNotifications.cancel(id: id);
      if (kDebugMode) debugPrint('Notification $id cancelled');
    } catch (e) {
      if (kDebugMode) debugPrint('Error cancelling notification: $e');
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _localNotifications.pendingNotificationRequests();
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting pending notifications: $e');
      return [];
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isIOS) {
      final settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } else if (Platform.isAndroid) {
      final plugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await plugin?.areNotificationsEnabled() ?? false;
    }
    return false;
  }

  /// Dispose resources
  void dispose() {
    _notificationActionController.close();
    _tokenController.close();
    _messageController.close();
    if (kDebugMode) debugPrint('PushNotificationService disposed');
  }
}

/// Notification action data model
class NotificationAction {
  final NotificationActionType type;
  final Map<String, dynamic> data;
  final String? actionId;
  final String? messageId;

  NotificationAction({
    required this.type,
    required this.data,
    this.actionId,
    this.messageId,
  });

  @override
  String toString() {
    return 'NotificationAction(type: $type, data: $data, actionId: $actionId, messageId: $messageId)';
  }
}

/// Notification action types
enum NotificationActionType {
  tap, // User tapped on notification
  open, // App opened from notification
}
