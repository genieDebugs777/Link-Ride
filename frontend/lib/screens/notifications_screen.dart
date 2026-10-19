import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  static const Color primaryBlue =
      Color(0xFF003F73);

  static const Color linkGreen =
      Color(0xFF4A9B45);

  static const Color background =
      Color(0xFFF7F9FB);

  static const Color textPrimary =
      Color(0xFF17212B);

  static const Color textSecondary =
      Color(0xFF667085);

  static const Color cardBorder =
      Color(0xFFE4E9EE);

  final AuthStorage _authStorage =
      AuthStorage();

  final NotificationService
      _notificationService =
      NotificationService();

  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>>
      _notifications = [];

  @override
  void initState() {
    super.initState();

    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String? token =
          await _authStorage.getToken();

      if (token == null ||
          token.isEmpty) {
        throw Exception(
          'Your Link Ride session is no longer valid.',
        );
      }

      final List<Map<String, dynamic>>
          notifications =
          await _notificationService
              .getMyNotifications(
        token: token,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _notifications =
            notifications;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
            error
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                );
      });
    }
  }

  Future<void> _markAsRead(
    Map<String, dynamic> notification,
  ) async {
    final bool isRead =
        notification['read'] == true;

    if (isRead) {
      return;
    }

    final int notificationId =
        _asInt(
      notification['notificationId'],
    );

    if (notificationId <= 0) {
      return;
    }

    try {
      final String? token =
          await _authStorage.getToken();

      if (token == null ||
          token.isEmpty) {
        return;
      }

      await _notificationService.markAsRead(
        token: token,
        notificationId: notificationId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        notification['read'] = true;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update this notification.',
          ),
        ),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final String? token =
          await _authStorage.getToken();

      if (token == null ||
          token.isEmpty) {
        return;
      }

      await _notificationService
          .markAllAsRead(
        token: token,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        for (final notification
            in _notifications) {
          notification['read'] = true;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to mark notifications as read.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool hasUnread =
        _notifications.any(
      (notification) =>
          notification['read'] != true,
    );

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: primaryBlue,
          ),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: primaryBlue,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: primaryBlue,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadNotifications,
          child: _content(),
        ),
      ),
    );
  }

  Widget _content() {
    if (_isLoading) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 220),
          Center(
            child:
                CircularProgressIndicator(
              color: primaryBlue,
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.notifications_off_outlined,
            size: 48,
            color: primaryBlue,
          ),
          const SizedBox(height: 14),
          Text(
            _errorMessage!,
            textAlign:
                TextAlign.center,
            style: const TextStyle(
              color: textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed:
                  _loadNotifications,
              child: const Text(
                'Try again',
              ),
            ),
          ),
        ],
      );
    }

    if (_notifications.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(20),
        children: const [
          SizedBox(height: 100),
          Icon(
            Icons.notifications_none_rounded,
            size: 52,
            color: primaryBlue,
          ),
          SizedBox(height: 14),
          Text(
            'No notifications yet',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w800,
              color: textPrimary,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Important journey and disruption updates will appear here.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: textSecondary,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding:
          const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        30,
      ),
      itemCount:
          _notifications.length,
      separatorBuilder:
          (_, _) =>
              const SizedBox(
        height: 10,
      ),
      itemBuilder: (
        BuildContext context,
        int index,
      ) {
        final notification =
            _notifications[index];

        return _notificationCard(
          notification,
        );
      },
    );
  }

  Widget _notificationCard(
    Map<String, dynamic> notification,
  ) {
    final bool isRead =
        notification['read'] == true;

    final String title =
        notification['title']
                ?.toString() ??
            'Link Ride update';

    final String message =
        notification['message']
                ?.toString() ??
            '';

    final String severity =
        notification['severity']
                ?.toString()
                .toUpperCase() ??
            'MEDIUM';

    final String eventType =
        notification[
                    'notificationType']
                ?.toString()
                .toUpperCase() ??
            '';

    final int routeId =
        _asInt(
      notification['routeId'],
    );

    final Color accent =
        eventType ==
                'DISRUPTION_RESOLVED'
            ? linkGreen
            : _severityColor(
                severity,
              );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            _markAsRead(
          notification,
        ),
        borderRadius:
            BorderRadius.circular(18),
        child: Ink(
          padding:
              const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isRead
                ? Colors.white
                : accent.withValues(
                    alpha: 0.055,
                  ),
            borderRadius:
                BorderRadius.circular(
              18,
            ),
            border: Border.all(
              color: isRead
                  ? cardBorder
                  : accent.withValues(
                      alpha: 0.24,
                    ),
            ),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration:
                    BoxDecoration(
                  color: accent
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius
                          .circular(13),
                ),
                child: Icon(
                  eventType ==
                          'DISRUPTION_RESOLVED'
                      ? Icons
                          .check_circle_outline_rounded
                      : Icons
                          .warning_amber_rounded,
                  color: accent,
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style:
                                const TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  FontWeight
                                      .w800,
                              color:
                                  textPrimary,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration:
                                BoxDecoration(
                              color:
                                  accent,
                              shape:
                                  BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    if (routeId > 0)
                      Text(
                        'Route #$routeId • $severity',
                        style:
                            TextStyle(
                          fontSize: 10.5,
                          fontWeight:
                              FontWeight
                                  .w700,
                          color: accent,
                        ),
                      ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      message,
                      style:
                          const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color:
                            textSecondary,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(
                      _formatDateTime(
                        notification[
                                'createdAt']
                            ?.toString(),
                      ),
                      style:
                          const TextStyle(
                        fontSize: 10.5,
                        color:
                            textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _severityColor(
    String severity,
  ) {
    switch (severity) {
      case 'LOW':
        return linkGreen;

      case 'HIGH':
        return const Color(
          0xFFD96A1D,
        );

      case 'CRITICAL':
        return const Color(
          0xFFD64545,
        );

      case 'MEDIUM':
      default:
        return const Color(
          0xFFE28A19,
        );
    }
  }

  int _asInt(
    dynamic value,
  ) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String _formatDateTime(
    String? raw,
  ) {
    if (raw == null ||
        raw.isEmpty) {
      return '';
    }

    final DateTime? parsed =
        DateTime.tryParse(raw);

    if (parsed == null) {
      return raw;
    }

    final String day =
        parsed.day
            .toString()
            .padLeft(2, '0');

    final String month =
        parsed.month
            .toString()
            .padLeft(2, '0');

    final String hour =
        parsed.hour
            .toString()
            .padLeft(2, '0');

    final String minute =
        parsed.minute
            .toString()
            .padLeft(2, '0');

    return '$day/$month/${parsed.year} • $hour:$minute';
  }
}
