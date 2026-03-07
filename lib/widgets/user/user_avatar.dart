import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/widgets/ui/loading_spinner.dart';

/// A reusable widget for displaying user avatars with Gravatar support
///
/// Displays Gravatar profile picture if available and enabled,
/// otherwise shows a nice initial-based avatar as fallback
class UserAvatar extends StatelessWidget {
  final String? userId;
  final String? displayName;
  final String? gravatarUrl;
  final bool? gravatarEnabled;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isOwner;

  const UserAvatar({
    super.key,
    this.userId,
    this.displayName,
    this.gravatarUrl,
    this.gravatarEnabled,
    this.radius = 20,
    this.backgroundColor,
    this.foregroundColor,
    this.isOwner = false,
  });

  /// Factory constructor that fetches user data from Firestore
  factory UserAvatar.fromUserId({
    required String userId,
    double radius = 20,
    Color? backgroundColor,
    Color? foregroundColor,
    bool isOwner = false,
  }) {
    return UserAvatar(
      userId: userId,
      radius: radius,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      isOwner: isOwner,
    );
  }

  /// Factory constructor that uses provided user data (no Firestore fetch)
  factory UserAvatar.fromUserData({
    required String displayName,
    String? gravatarUrl,
    bool gravatarEnabled = false,
    double radius = 20,
    Color? backgroundColor,
    Color? foregroundColor,
    bool isOwner = false,
  }) {
    return UserAvatar(
      displayName: displayName,
      gravatarUrl: gravatarUrl,
      gravatarEnabled: gravatarEnabled,
      radius: radius,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      isOwner: isOwner,
    );
  }

  /// Get initials from display name (max 2 characters)
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }

    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  /// Generate a color from string (consistent color for same name)
  Color _generateColorFromName(String name) {
    if (isOwner) {
      return Colors.amber[100]!;
    }

    if (backgroundColor != null) {
      return backgroundColor!;
    }

    final hash = name.hashCode;
    final colors = [
      Colors.green[100]!,
      Colors.blue[100]!,
      Colors.purple[100]!,
      Colors.pink[100]!,
      Colors.teal[100]!,
      Colors.orange[100]!,
      Colors.indigo[100]!,
    ];

    return colors[hash.abs() % colors.length];
  }

  /// Generate foreground icon color
  Color _generateForegroundColor(String name) {
    if (isOwner) {
      return Colors.amber[800]!;
    }

    if (foregroundColor != null) {
      return foregroundColor!;
    }

    final hash = name.hashCode;
    final colors = [
      Colors.green[800]!,
      Colors.blue[800]!,
      Colors.purple[800]!,
      Colors.pink[800]!,
      Colors.teal[800]!,
      Colors.orange[800]!,
      Colors.indigo[800]!,
    ];

    return colors[hash.abs() % colors.length];
  }

  Widget _buildAvatarContent({
    required String displayName,
    String? gravatarUrl,
    bool gravatarEnabled = false,
  }) {
    final effectiveBgColor = _generateColorFromName(displayName);
    final effectiveFgColor = _generateForegroundColor(displayName);

    // Show Gravatar if available and enabled
    if (gravatarEnabled && gravatarUrl != null && gravatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: effectiveBgColor,
        child: ClipOval(
          child: Image.network(
            gravatarUrl,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to initials if image fails to load
              return Container(
                width: radius * 2,
                height: radius * 2,
                color: effectiveBgColor,
                child: Center(
                  child: Text(
                    _getInitials(displayName),
                    style: TextStyle(
                      color: effectiveFgColor,
                      fontSize: radius * 0.8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return CircleAvatar(
                radius: radius,
                backgroundColor: effectiveBgColor,
                child: CustomLoadingSpinner(
                  size: radius * 1.2,
                  color: effectiveFgColor,
                ),
              );
            },
          ),
        ),
      );
    }

    // Fallback: Show initials with icon overlay
    return CircleAvatar(
      radius: radius,
      backgroundColor: effectiveBgColor,
      child: Stack(
        children: [
          // Initials as background
          Center(
            child: Text(
              _getInitials(displayName),
              style: TextStyle(
                color: effectiveFgColor.withValues(alpha: 0.3),
                fontSize: radius * 0.8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Icon overlay
          Center(
            child: Icon(
              isOwner ? Icons.star : Icons.person,
              color: effectiveFgColor,
              size: radius * 0.8,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If we have direct data, use it
    if (displayName != null) {
      return _buildAvatarContent(
        displayName: displayName!,
        gravatarUrl: gravatarUrl,
        gravatarEnabled: gravatarEnabled ?? false,
      );
    }

    // Otherwise, fetch from Firestore using userId
    if (userId != null) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return CircleAvatar(
              radius: radius,
              backgroundColor: Colors.grey[300],
              child: Icon(
                Icons.error_outline,
                color: Colors.grey[600],
                size: radius * 0.8,
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return CircleAvatar(
              radius: radius,
              backgroundColor: Colors.grey[300],
              child: Icon(
                Icons.person_outline,
                color: Colors.grey[600],
                size: radius * 0.8,
              ),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          final name = userData?['displayName'] as String? ?? 'User';
          final gravatar = userData?['gravatarUrl'] as String?;
          final enabled = userData?['gravatarEnabled'] as bool? ?? false;

          return _buildAvatarContent(
            displayName: name,
            gravatarUrl: gravatar,
            gravatarEnabled: enabled,
          );
        },
      );
    }

    // No data provided, show placeholder
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      child: Icon(
        Icons.person_outline,
        color: Colors.grey[600],
        size: radius * 0.8,
      ),
    );
  }
}
