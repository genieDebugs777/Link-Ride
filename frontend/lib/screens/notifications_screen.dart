import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/notification_service.dart';
import '../theme/link_ride_theme.dart';

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

        _errorMessage = error
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

      await _notificationService
          .markAsRead(
        token: token,
        notificationId:
            notificationId,
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

  Future<void> _markAllAsRead()
      async {
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
          notification['read'] =
              true;
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
  Widget build(BuildContext context) {
    final bool hasUnread =
        _notifications.any(
      (notification) =>
          notification['read'] != true,
    );

    final int unreadCount =
        _notifications.where(
      (notification) =>
          notification['read'] != true,
    ).length;

    return Scaffold(
      backgroundColor:
          LinkRideColors.background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
        title: const Text(
          'Notifications',
        ),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed:
                  _markAllAsRead,
              child: const Text(
                'Mark all read',
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh:
              _loadNotifications,
          color:
              LinkRideColors
                  .primaryBlue,
          child: _content(
            unreadCount,
          ),
        ),
      ),
    );
  }

  Widget _content(
    int unreadCount,
  ) {
    if (_isLoading) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 110),
          _loadingState(),
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
          const SizedBox(height: 70),
          _errorState(),
        ],
      );
    }

    if (_notifications.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 80),
          _emptyState(),
        ],
      );
    }

    return ListView.separated(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding:
          const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        30,
      ),
      itemCount:
          _notifications.length + 1,
      separatorBuilder:
          (_, _) =>
              const SizedBox(
        height: 10,
      ),
      itemBuilder: (
        BuildContext context,
        int index,
      ) {
        if (index == 0) {
          return _summaryCard(
            unreadCount,
          );
        }

        final notification =
            _notifications[index - 1];

        return _notificationCard(
          notification,
        );
      },
    );
  }

  Widget _summaryCard(
    int unreadCount,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient:
            LinkRideGradients
                .primarySoft,
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.large,
        ),
        border: Border.all(
          color:
              LinkRideColors
                  .primaryBlue
                  .withValues(
            alpha: 0.08,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration:
                const BoxDecoration(
              color: Colors.white,
              shape:
                  BoxShape.circle,
            ),
            child: const Icon(
              Icons
                  .notifications_rounded,
              size: 22,
              color:
                  LinkRideColors
                      .primaryBlue,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Activity feed',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        LinkRideColors
                            .textPrimary,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  unreadCount == 0
                      ? 'You are all caught up.'
                      : '$unreadCount unread notification${unreadCount == 1 ? '' : 's'}',
                  style:
                      const TextStyle(
                    fontSize: 12,
                    color:
                        LinkRideColors
                            .textSecondary,
                  ),
                ),
              ],
            ),
          ),

          if (unreadCount > 0)
            Container(
              constraints:
                  const BoxConstraints(
                minWidth: 34,
              ),
              height: 34,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              alignment:
                  Alignment.center,
              decoration:
                  BoxDecoration(
                color:
                    LinkRideColors
                        .primaryBlue,
                borderRadius:
                    BorderRadius.circular(
                  LinkRideRadius.pill,
                ),
              ),
              child: Text(
                unreadCount > 99
                    ? '99+'
                    : '$unreadCount',
                style:
                    const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
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
            ? LinkRideColors
                .linkGreen
            : _severityColor(
                severity,
              );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _markAsRead(
            notification,
          );
        },
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.large,
        ),
        child: Ink(
          padding:
              const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isRead
                ? LinkRideColors
                    .surface
                : accent.withValues(
                    alpha: 0.055,
                  ),
            borderRadius:
                BorderRadius.circular(
              LinkRideRadius.large,
            ),
            border: Border.all(
              color: isRead
                  ? LinkRideColors
                      .border
                  : accent.withValues(
                      alpha: 0.24,
                    ),
            ),
            boxShadow:
                isRead
                    ? const []
                    : LinkRideShadows
                        .soft,
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration:
                    BoxDecoration(
                  color:
                      accent.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  _iconForNotification(
                    eventType,
                  ),
                  color: accent,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style:
                                TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isRead
                                      ? FontWeight
                                          .w700
                                      : FontWeight
                                          .w800,
                              color:
                                  LinkRideColors
                                      .textPrimary,
                            ),
                          ),
                        ),

                        if (!isRead) ...[
                          const SizedBox(
                            width: 8,
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            margin:
                                const EdgeInsets
                                    .only(
                              top: 5,
                            ),
                            decoration:
                                BoxDecoration(
                              color: accent,
                              shape:
                                  BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 6),

                    Wrap(
                      spacing: 7,
                      runSpacing: 6,
                      children: [
                        _metadataChip(
                          label:
                              _eventLabel(
                            eventType,
                          ),
                          accent: accent,
                        ),

                        if (routeId > 0)
                          _metadataChip(
                            label:
                                'ROUTE #$routeId',
                            accent:
                                LinkRideColors
                                    .primaryBlue,
                          ),

                        _metadataChip(
                          label:
                              severity,
                          accent:
                              _severityColor(
                            severity,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      message,
                      style:
                          const TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color:
                            LinkRideColors
                                .textSecondary,
                      ),
                    ),

                    const SizedBox(height: 9),

                    Row(
                      children: [
                        const Icon(
                          Icons
                              .schedule_rounded,
                          size: 14,
                          color:
                              LinkRideColors
                                  .textMuted,
                        ),

                        const SizedBox(width: 5),

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
                                LinkRideColors
                                    .textMuted,
                          ),
                        ),

                        const Spacer(),

                        if (!isRead)
                          Text(
                            'Tap to mark read',
                            style:
                                TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              color:
                                  accent,
                            ),
                          ),
                      ],
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

  Widget _metadataChip({
    required String label,
    required Color accent,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color:
            accent.withValues(
          alpha: 0.08,
        ),
        borderRadius:
            BorderRadius.circular(
          LinkRideRadius.pill,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight:
              FontWeight.w800,
          letterSpacing: 0.25,
          color: accent,
        ),
      ),
    );
  }

  Widget _loadingState() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(28),
      decoration:
          LinkRideDecorations.card(),
      child: const Column(
        children: [
          CircularProgressIndicator(
            strokeWidth: 2.3,
            color:
                LinkRideColors
                    .primaryBlue,
          ),

          SizedBox(height: 13),

          Text(
            'Loading notifications...',
            style: TextStyle(
              fontSize: 12.5,
              color:
                  LinkRideColors
                      .textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(24),
      decoration:
          LinkRideDecorations.card(),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration:
                const BoxDecoration(
              color:
                  LinkRideColors
                      .dangerSoft,
              shape:
                  BoxShape.circle,
            ),
            child: const Icon(
              Icons
                  .notifications_off_outlined,
              size: 30,
              color:
                  LinkRideColors
                      .danger,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Unable to load notifications',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w800,
              color:
                  LinkRideColors
                      .textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            _errorMessage!,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color:
                  LinkRideColors
                      .textSecondary,
            ),
          ),

          const SizedBox(height: 15),

          OutlinedButton.icon(
            onPressed:
                _loadNotifications,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 18,
            ),
            label: const Text(
              'Try Again',
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(26),
      decoration:
          LinkRideDecorations.card(),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration:
                const BoxDecoration(
              color:
                  LinkRideColors
                      .softBlue,
              shape:
                  BoxShape.circle,
            ),
            child: const Icon(
              Icons
                  .notifications_none_rounded,
              size: 32,
              color:
                  LinkRideColors
                      .primaryBlue,
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'No notifications yet',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w800,
              color:
                  LinkRideColors
                      .textPrimary,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Important journey and disruption updates will appear here.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color:
                  LinkRideColors
                      .textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForNotification(
    String eventType,
  ) {
    switch (eventType) {
      case 'DISRUPTION_RESOLVED':
        return Icons
            .check_circle_outline_rounded;

      case 'DISRUPTION_CREATED':
      case 'DISRUPTION_UPDATED':
        return Icons
            .warning_amber_rounded;

      default:
        return Icons
            .notifications_none_rounded;
    }
  }

  String _eventLabel(
    String eventType,
  ) {
    switch (eventType) {
      case 'DISRUPTION_RESOLVED':
        return 'RESOLVED';

      case 'DISRUPTION_CREATED':
        return 'NEW DISRUPTION';

      case 'DISRUPTION_UPDATED':
        return 'UPDATED';

      default:
        if (eventType.isEmpty) {
          return 'UPDATE';
        }

        return eventType
            .replaceAll(
              '_',
              ' ',
            );
    }
  }

  Color _severityColor(
    String severity,
  ) {
    switch (severity) {
      case 'LOW':
        return LinkRideColors.linkGreen;

      case 'HIGH':
        return const Color(
          0xFFD96A1D,
        );

      case 'CRITICAL':
        return LinkRideColors.danger;

      case 'MEDIUM':
      default:
        return LinkRideColors.warning;
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
            .padLeft(
              2,
              '0',
            );

    final String month =
        parsed.month
            .toString()
            .padLeft(
              2,
              '0',
            );

    final String hour =
        parsed.hour
            .toString()
            .padLeft(
              2,
              '0',
            );

    final String minute =
        parsed.minute
            .toString()
            .padLeft(
              2,
              '0',
            );

    return '$day/$month/${parsed.year} • $hour:$minute';
  }
}