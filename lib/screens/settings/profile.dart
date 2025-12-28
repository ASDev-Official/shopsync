import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shopsync/services/platform/connectivity_service.dart';
import '/screens/auth/sign_out.dart';
import '/widgets/ui/loading_spinner.dart';
import '/widgets/common/advert.dart';
import '/services/auth/google_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class GridPainter extends CustomPainter {
  final bool isDark;

  GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1)
      ..strokeWidth = 1;

    for (var i = 0; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }

    for (var i = 0; i < size.height; i += 20) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final connectivityService = ConnectivityService();

  bool _isLoading = false;
  bool _isEditing = false;
  bool _isLinkingGoogle = false;
  String? _errorMessage;
  String? _successMessage;

  // Ad management
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
    );
    _nameController.text = _auth.currentUser?.displayName ?? '';
    _loadBannerAd();
  }

  void _loadBannerAd() {
    // Don't load ads on web platform
    if (kIsWeb) {
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-6149170768233698/8182035869',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() {
            _bannerAd = null;
            _isBannerAdLoaded = false;
          });
        },
      ),
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    _nameController.dispose();
    if (!kIsWeb) {
      _bannerAd?.dispose();
    }
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _auth.currentUser?.updateDisplayName(_nameController.text.trim());
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({'displayName': _nameController.text.trim()});

      setState(() => _isEditing = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Send error to Sentry
      await Sentry.captureException(
        e,
        stackTrace: StackTrace.current,
        hint: Hint.withMap({'action': 'updating_profile'}),
      );
      setState(() => _errorMessage = 'Error updating profile: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    final shouldSignOut = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              ButtonM3E(
                onPressed: () => Navigator.pop(context, false),
                label: const Text('Cancel'),
                style: ButtonM3EStyle.text,
                size: ButtonM3ESize.md,
              ),
              ButtonM3E(
                onPressed: () => Navigator.pop(context, true),
                label: const Text('Sign Out'),
                style: ButtonM3EStyle.text,
                size: ButtonM3ESize.md,
              ),
            ],
          ),
        ) ??
        false;

    if (shouldSignOut) {
      try {
        if (await connectivityService.checkConnectivityAndShowDialog(context,
            feature: 'the sign out option')) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignOutScreen()),
          );
        }
      } catch (e) {
        // Send sign out errors to Sentry
        await Sentry.captureException(
          e,
          stackTrace: StackTrace.current,
          hint: Hint.withMap({'action': 'signing_out'}),
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _linkGoogleAccount() async {
    setState(() {
      _isLinkingGoogle = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final userCredential = await GoogleAuthService.linkGoogleAccount();

      if (userCredential == null) {
        // User canceled
        setState(() {
          _isLinkingGoogle = false;
        });
        return;
      }

      setState(() {
        _successMessage =
            'Google account linked successfully! You can now sign in with Google.';
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google account linked successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e, stackTrace) {
      setState(() {
        _errorMessage =
            e.message ?? 'An error occurred while linking your Google account.';
      });
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        hint: Hint.withMap({'action': 'linking_google_account'}),
      );
    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = 'An error occurred while linking your Google account.';
      });
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        hint: Hint.withMap({'action': 'linking_google_account'}),
      );
    } finally {
      setState(() {
        _isLinkingGoogle = false;
      });
    }
  }

  Future<void> _unlinkGoogleAccount() async {
    final shouldUnlink = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Unlink Google Account'),
            content: const Text(
              'Are you sure you want to unlink your Google account? '
              'You will no longer be able to sign in with Google unless you link it again.',
            ),
            actions: [
              ButtonM3E(
                onPressed: () => Navigator.pop(context, false),
                label: const Text('Cancel'),
                style: ButtonM3EStyle.text,
                size: ButtonM3ESize.md,
              ),
              ButtonM3E(
                onPressed: () => Navigator.pop(context, true),
                label: const Text('Unlink'),
                style: ButtonM3EStyle.text,
                size: ButtonM3ESize.md,
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldUnlink) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await GoogleAuthService.unlinkGoogleAccount();

      setState(() {
        _successMessage = 'Google account unlinked successfully.';
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google account unlinked successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e, stackTrace) {
      setState(() {
        _errorMessage = e.message ??
            'An error occurred while unlinking your Google account.';
      });
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        hint: Hint.withMap({'action': 'unlinking_google_account'}),
      );
    } catch (e, stackTrace) {
      setState(() {
        _errorMessage =
            'An error occurred while unlinking your Google account.';
      });
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
        hint: Hint.withMap({'action': 'unlinking_google_account'}),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final email = user?.email ?? 'No email';
    final displayName = user?.displayName ?? 'User';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green[700]!, width: 2),
          ),
          // Add shadow effect
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              expandedHeight: 280,
              // Increased height
              pinned: true,
              backgroundColor: isDark ? Colors.grey[800] : Colors.green[800],
              elevation: 0,
              leading: !_isEditing
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Go Back',
                    )
                  : null,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Gradient background with pattern
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [Colors.grey[900]!, Colors.grey[850]!]
                            : [Colors.green[800]!, Colors.green[700]!],
                      ).createShader(bounds),
                      blendMode: BlendMode.dstIn,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [Colors.grey[900]!, Colors.grey[850]!]
                                : [Colors.green[800]!, Colors.green[600]!],
                          ),
                        ),
                      ),
                    ),
                    // Animated pattern overlay
                    Opacity(
                      opacity: 0.05,
                      child: CustomPaint(
                        painter: GridPainter(isDark: isDark),
                      ),
                    ),
                    // Profile content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 32),
                          // Enhanced avatar with gradient border
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [Colors.grey[800]!, Colors.grey[600]!]
                                    : [Colors.green[400]!, Colors.green[600]!],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Hero(
                              tag: 'profile-avatar',
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor:
                                    isDark ? Colors.grey[800] : Colors.white,
                                child: Text(
                                  displayName.isNotEmpty
                                      ? displayName[0].toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.green[800],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Enhanced name display
                          Text(
                            displayName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Enhanced edit button
              actions: [
                if (!_isEditing)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey[800]!.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.grey[700]!
                              : Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () => setState(() => _isEditing = true),
                        tooltip: 'Edit Profile',
                      ),
                    ),
                  ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  children: [
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.red[900]!.withValues(alpha: 0.2)
                              : Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.red[800]! : Colors.red[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.cancel,
                                color:
                                    isDark ? Colors.red[300] : Colors.red[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.red[300]
                                      : Colors.red[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Profile Information Card
                    Card(
                      elevation: isDark ? 0 : 2,
                      color: isDark ? Colors.grey[850] : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Account Information',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDark ? Colors.white : Colors.green[800],
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Display Name',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _isEditing
                                  ? TextFormField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter your name',
                                        suffixIcon: Icon(Icons.person,
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.green[800]),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Please enter a display name';
                                        }
                                        return null;
                                      },
                                    )
                                  : ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        backgroundColor: isDark
                                            ? Colors.green[900]
                                            : Colors.green[50],
                                        child: Icon(Icons.person,
                                            color: isDark
                                                ? Colors.green[200]
                                                : Colors.green[800]),
                                      ),
                                      title: Text(
                                        displayName,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? Colors.white : null,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Display Name',
                                        style: TextStyle(
                                          color: isDark ? Colors.white60 : null,
                                        ),
                                      ),
                                    ),
                              const Divider(height: 32),
                              Text(
                                'Email Address',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: isDark
                                      ? Colors.blue[900]
                                      : Colors.blue[50],
                                  child: Icon(Icons.email,
                                      color: isDark
                                          ? Colors.blue[200]
                                          : Colors.blue[800]),
                                ),
                                title: Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white : null,
                                  ),
                                ),
                                subtitle: Text(
                                  'Email (cannot be changed)',
                                  style: TextStyle(
                                    color: isDark ? Colors.white60 : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Success message
                    if (_successMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.green[900]!.withValues(alpha: 0.2)
                              : Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.green[800]!
                                : Colors.green[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: isDark
                                    ? Colors.green[300]
                                    : Colors.green[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _successMessage!,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.green[300]
                                      : Colors.green[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Linked Accounts Card
                    Card(
                      elevation: isDark ? 0 : 2,
                      color: isDark ? Colors.grey[850] : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Linked Accounts',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDark ? Colors.white : Colors.green[800],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Manage how you sign in to ShopSync',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    isDark ? Colors.white70 : Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Email/Password Provider
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor:
                                    isDark ? Colors.blue[900] : Colors.blue[50],
                                child: Icon(Icons.email,
                                    color: isDark
                                        ? Colors.blue[200]
                                        : Colors.blue[800]),
                              ),
                              title: Text(
                                'Email & Password',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : null,
                                ),
                              ),
                              subtitle: Text(
                                (FirebaseAuth.instance.currentUser?.providerData
                                            .any((p) =>
                                                p.providerId == 'password') ??
                                        false)
                                    ? 'Sign in with email and password'
                                    : 'Not configured',
                                style: TextStyle(
                                  color: isDark ? Colors.white60 : null,
                                ),
                              ),
                              trailing: (FirebaseAuth
                                          .instance.currentUser?.providerData
                                          .any((p) =>
                                              p.providerId == 'password') ??
                                      false)
                                  ? Icon(
                                      Icons.check_circle,
                                      color: Colors.green[600],
                                    )
                                  : Icon(
                                      Icons.cancel,
                                      color: Colors.grey[400],
                                    ),
                            ),

                            // Set Password Button (if email/password not configured)
                            if (!(FirebaseAuth
                                    .instance.currentUser?.providerData
                                    .any((p) => p.providerId == 'password') ??
                                false))
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ButtonM3E(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, '/forgot-password',
                                          arguments: true);
                                    },
                                    icon: const Icon(Icons.lock_reset),
                                    label: const Text('Set Password'),
                                    style: ButtonM3EStyle.outlined,
                                    size: ButtonM3ESize.md,
                                  ),
                                ),
                              ),

                            const Divider(height: 24),

                            // Google Provider
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor:
                                    isDark ? Colors.red[900] : Colors.red[50],
                                child: Image.asset(
                                  'assets/badges/google/web/png@4x/light/web_light_rd_na@4x.png',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              title: Text(
                                'Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : null,
                                ),
                              ),
                              subtitle: Text(
                                (FirebaseAuth.instance.currentUser?.providerData
                                            .any((p) =>
                                                p.providerId == 'google.com') ??
                                        false)
                                    ? 'Sign in with Google account'
                                    : 'Not linked',
                                style: TextStyle(
                                  color: isDark ? Colors.white60 : null,
                                ),
                              ),
                              trailing: (FirebaseAuth
                                          .instance.currentUser?.providerData
                                          .any((p) =>
                                              p.providerId == 'google.com') ??
                                      false)
                                  ? Icon(
                                      Icons.check_circle,
                                      color: Colors.green[600],
                                    )
                                  : Icon(
                                      Icons.cancel,
                                      color: Colors.grey[400],
                                    ),
                            ),
                            const SizedBox(height: 20),

                            // Link/Unlink Button
                            if (FirebaseAuth.instance.currentUser?.providerData
                                    .any((p) => p.providerId == 'google.com') ??
                                false)
                              SizedBox(
                                width: double.infinity,
                                child: ButtonM3E(
                                  onPressed:
                                      _isLoading ? null : _unlinkGoogleAccount,
                                  enabled: !_isLoading,
                                  icon: const Icon(Icons.link_off),
                                  label: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CustomLoadingSpinner(
                                            color: Colors.white,
                                            size: 20.0,
                                          ),
                                        )
                                      : const Text('Unlink Google Account'),
                                  style: ButtonM3EStyle.outlined,
                                  size: ButtonM3ESize.md,
                                ),
                              )
                            else
                              SizedBox(
                                width: double.infinity,
                                child: ButtonM3E(
                                  onPressed: _isLinkingGoogle
                                      ? null
                                      : _linkGoogleAccount,
                                  enabled: !_isLinkingGoogle,
                                  icon: _isLinkingGoogle
                                      ? null
                                      : Image.asset(
                                          isDark
                                              ? 'assets/badges/google/web/png@4x/dark/web_dark_rd_na@4x.png'
                                              : 'assets/badges/google/web/png@4x/light/web_light_rd_na@4x.png',
                                          height: 20,
                                          width: 20,
                                        ),
                                  label: _isLinkingGoogle
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CustomLoadingSpinner(
                                            color: Colors.white,
                                            size: 20.0,
                                          ),
                                        )
                                      : const Text('Link Google Account'),
                                  style: ButtonM3EStyle.filled,
                                  size: ButtonM3ESize.md,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Activity Card
                    Card(
                      elevation: isDark ? 0 : 2,
                      color: isDark ? Colors.grey[850] : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Activity',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color:
                                    isDark ? Colors.white : Colors.green[800],
                              ),
                            ),
                            const SizedBox(height: 16),
                            StreamBuilder<QuerySnapshot>(
                              stream: _firestore
                                  .collection('lists')
                                  .where('members', arrayContains: user?.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                int listCount = snapshot.hasData
                                    ? snapshot.data!.docs.length
                                    : 0;
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: isDark
                                        ? Colors.amber[900]
                                        : Colors.amber[50],
                                    child: Icon(Icons.list,
                                        color: isDark
                                            ? Colors.amber[200]
                                            : Colors.amber[800]),
                                  ),
                                  title: Text(
                                    '$listCount shopping lists',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white : null,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Lists you have access to',
                                    style: TextStyle(
                                      color: isDark ? Colors.white60 : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_isEditing) ...[
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: ButtonM3E(
                              onPressed: () =>
                                  setState(() => _isEditing = false),
                              label: const Text('Cancel'),
                              style: ButtonM3EStyle.outlined,
                              size: ButtonM3ESize.lg,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ButtonM3E(
                              onPressed: _isLoading ? null : _updateProfile,
                              enabled: !_isLoading,
                              label: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CustomLoadingSpinner(
                                        color: Colors.white,
                                        size: 24.0,
                                      ),
                                    )
                                  : const Text('Save Changes'),
                              style: ButtonM3EStyle.filled,
                              size: ButtonM3ESize.lg,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Sign Out Button
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ButtonM3E(
                        onPressed: () => {_signOut()},
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign Out'),
                        style: ButtonM3EStyle.outlined,
                        size: ButtonM3ESize.lg,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Advertisement at the bottom
                    if (_isBannerAdLoaded && _bannerAd != null)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom,
                        ),
                        child: Center(
                          child: BannerAdvertWidget(
                            bannerAd: _bannerAd,
                            backgroundColor:
                                isDark ? Colors.grey[800]! : Colors.white,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
