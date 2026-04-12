import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:shopsync/l10n/app_localizations.dart';
import '/widgets/user/user_avatar.dart';
import '/screens/auth/login.dart';
import '/screens/settings/restarting_screen.dart';
import '/services/auth/google_auth.dart';
import '/services/auth/android_system_accounts_service.dart';

class AndroidAccountManagerScreen extends StatefulWidget {
  const AndroidAccountManagerScreen({super.key});

  @override
  State<AndroidAccountManagerScreen> createState() =>
      _AndroidAccountManagerScreenState();
}

class _AndroidAccountManagerScreenState
    extends State<AndroidAccountManagerScreen> {
  bool _isSwitching = false;
  bool _isAddingAccount = false;
  bool _isAddingGoogleAccount = false;
  bool _isRemoving = false;
  bool _isLoadingAccounts = false;
  String? _errorMessage;
  List<Map<String, String>> _systemAccounts = const [];
  bool _switchingDialogVisible = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadSystemAccounts();
  }

  Future<void> _loadSystemAccounts() async {
    setState(() {
      _isLoadingAccounts = true;
    });

    try {
      final accounts =
          await AndroidSystemAccountsService.listSystemAccountsDetailed();
      if (!mounted) return;
      setState(() {
        _systemAccounts = accounts
            .where((account) => (account['name'] ?? '').isNotEmpty)
            .toList(growable: false);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAccounts = false;
        });
      }
    }
  }

  String _accountProvider(Map<String, String> account) {
    final hasPassword =
        (account['hasPassword'] ?? 'false').toLowerCase() == 'true';
    if (hasPassword) {
      return 'password';
    }

    final provider = AndroidSystemAccountsService.normalizeProvider(
      account['provider'],
    );
    if (provider == 'google') {
      return provider;
    }

    return 'password';
  }

  Future<void> _showSwitchingDialog() async {
    if (_switchingDialogVisible || !mounted) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    _switchingDialogVisible = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor:
                isDark ? Colors.green.shade900 : Colors.green.shade100,
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: AlertDialog(
                  title: Text(AppLocalizations.of(context)!.switchAccount),
                  content: Row(
                    children: [
                      const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.switchAccount,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    _switchingDialogVisible = false;
  }

  void _closeSwitchingDialog() {
    if (!_switchingDialogVisible || !mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    _switchingDialogVisible = false;
  }

  Future<void> _switchAccount() async {
    if (_systemAccounts.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.noSavedAccounts;
      });
      return;
    }

    final selectedAccount = await showModalBottomSheet<Map<String, String>>(
      context: context,
      builder: (context) {
        final currentEmail = _user?.email;
        final l10n = AppLocalizations.of(context)!;
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _systemAccounts.length,
            itemBuilder: (context, index) {
              final account = _systemAccounts[index];
              final email = account['name'] ?? '';
              final displayName = account['displayName'] ?? '';
              final provider = _accountProvider(account);
              final isCurrent = currentEmail != null &&
                  currentEmail.toLowerCase() == email.toLowerCase();

              return ListTile(
                leading: UserAvatar.fromUserId(
                  userId: account['uid'] ?? '',
                  radius: 20,
                  isOwner: isCurrent,
                ),
                title: Text(displayName.isNotEmpty ? displayName : email),
                subtitle: Text(
                  provider == 'google' ? l10n.google : l10n.email,
                ),
                trailing: _buildProviderBadge(provider, l10n),
                onTap: () => Navigator.pop(context, account),
              );
            },
          ),
        );
      },
    );

    if (selectedAccount == null) {
      return;
    }

    final selectedEmail = selectedAccount['name'] ?? '';
    final provider = _accountProvider(selectedAccount);

    setState(() {
      _isSwitching = true;
      _errorMessage = null;
    });

    try {
      final currentEmail = _user?.email;
      if (currentEmail != null &&
          currentEmail.toLowerCase() == selectedEmail.toLowerCase()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context)!.accountSwitched)),
          );
        }
        return;
      }

      final shouldShowSwitchingDialog = provider != 'google';

      if (shouldShowSwitchingDialog) {
        unawaited(_showSwitchingDialog());
      }

      if (provider == 'google') {
        final userCredential =
            await GoogleAuthService.signInWithGoogleCredentialManager();
        if (userCredential == null) {
          _closeSwitchingDialog();
          return;
        }
      } else {
        final password =
            await AndroidSystemAccountsService.getStoredPasswordForAccount(
                selectedEmail);
        if (password == null || password.isEmpty) {
          throw StateError('Saved password not found for this account');
        }

        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: selectedEmail,
          password: password,
        );

        await AndroidSystemAccountsService.addCurrentUserToSystemAccounts(
          password: password,
          provider: 'password',
        );
      }

      if (shouldShowSwitchingDialog) {
        _closeSwitchingDialog();
      }
      await _loadSystemAccounts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.accountSwitched)),
        );
      }
    } catch (e) {
      _closeSwitchingDialog();
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      _closeSwitchingDialog();
      if (mounted) {
        setState(() {
          _isSwitching = false;
        });
      }
    }
  }

  Future<void> _addAccount() async {
    setState(() {
      _isAddingAccount = true;
      _errorMessage = null;
    });

    try {
      await AndroidSystemAccountsService.openSystemAddAccountFlow();
      final shouldOpenLogin =
          await AndroidSystemAccountsService.consumePendingAddAccountRequest();

      if (!mounted) return;

      if (shouldOpenLogin) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
        if (!mounted) return;
        await _loadSystemAccounts();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAddingAccount = false;
        });
      }
    }
  }

  Future<bool> _confirmOwnAccountRemoval() async {
    final l10n = AppLocalizations.of(context)!;
    final shouldRestart = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.restartRequiredTitle),
            content: Text(l10n.removeOwnAccountRestartWarning),
            actions: [
              ButtonM3E(
                onPressed: () => Navigator.pop(context, false),
                label: Text(l10n.cancel),
                style: ButtonM3EStyle.text,
                size: ButtonM3ESize.md,
              ),
              ButtonM3E(
                onPressed: () => Navigator.pop(context, true),
                label: Text(l10n.restartText),
                style: ButtonM3EStyle.text,
                size: ButtonM3ESize.md,
              ),
            ],
          ),
        ) ??
        false;

    return shouldRestart;
  }

  Future<void> _openRemoveAccountsModal() async {
    if (_systemAccounts.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.noSavedAccounts;
      });
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext)!;
        final removingEmails = <String>{};

        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            Future<void> removeAccount(Map<String, String> account) async {
              final email = account['name'] ?? '';
              if (email.isEmpty) {
                return;
              }

              final currentEmail = _user?.email ?? '';
              final isCurrent = currentEmail.isNotEmpty &&
                  currentEmail.toLowerCase() == email.toLowerCase();

              if (isCurrent) {
                final shouldContinue = await _confirmOwnAccountRemoval();
                if (!shouldContinue) {
                  return;
                }
              }

              setModalState(() {
                removingEmails.add(email.toLowerCase());
              });

              setState(() {
                _isRemoving = true;
                _errorMessage = null;
              });

              try {
                await AndroidSystemAccountsService.removeSystemAccountByEmail(
                  email,
                );

                if (!mounted) return;
                await _loadSystemAccounts();
                if (!mounted) return;

                final removed = !_systemAccounts.any(
                  (account) =>
                      (account['name'] ?? '').trim().toLowerCase() ==
                      email.toLowerCase(),
                );

                if (!removed) {
                  setState(() {
                    _errorMessage =
                        AppLocalizations.of(context)!.removeAccountDetails;
                  });
                  return;
                }

                if (isCurrent) {
                  if (Navigator.of(modalContext).canPop()) {
                    Navigator.of(modalContext).pop();
                  }
                  await Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const RestartingScreen(),
                    ),
                  );
                  return;
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.removeAccountSuccess)),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                setState(() {
                  _errorMessage = e.toString();
                });
              } finally {
                if (mounted) {
                  setState(() {
                    _isRemoving = false;
                  });
                }
                setModalState(() {
                  removingEmails.remove(email.toLowerCase());
                });
              }
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.removeAccounts,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.removeAccountsDescription,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _systemAccounts.length,
                        itemBuilder: (context, index) {
                          final account = _systemAccounts[index];
                          final email = account['name'] ?? '';
                          final displayName = account['displayName'] ?? '';
                          final provider = _accountProvider(account);
                          final isCurrent = _user?.email != null &&
                              _user!.email!.toLowerCase() ==
                                  email.toLowerCase();
                          final isRemovingThis =
                              removingEmails.contains(email.toLowerCase());

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: UserAvatar.fromUserId(
                              userId: account['uid'] ?? '',
                              radius: 20,
                              isOwner: isCurrent,
                            ),
                            title: Text(
                              displayName.isNotEmpty ? displayName : email,
                            ),
                            subtitle: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildProviderBadge(provider, l10n),
                              ],
                            ),
                            trailing: isRemovingThis
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                    ),
                                  )
                                : IconButton(
                                    tooltip: l10n.removeAccounts,
                                    onPressed: _isRemoving
                                        ? null
                                        : () => removeAccount(account),
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addGoogleAccount() async {
    setState(() {
      _isAddingGoogleAccount = true;
      _errorMessage = null;
    });

    try {
      final userCredential =
          await GoogleAuthService.signInWithGoogleCredentialManager();
      if (userCredential == null) {
        return;
      }

      if (!mounted) return;
      await _loadSystemAccounts();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.googleAccountAdded)),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            e.message ?? AppLocalizations.of(context)!.googleSignInGeneric;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.googleSignInGeneric;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isAddingGoogleAccount = false;
        });
      }
    }
  }

  Widget _buildProviderBadge(String provider, AppLocalizations l10n) {
    final isGoogle = provider == 'google';
    final label = isGoogle ? l10n.google : l10n.email;
    final backgroundColor = isGoogle
        ? Colors.green.withValues(alpha: 0.12)
        : Colors.blueGrey.withValues(alpha: 0.12);
    final foregroundColor =
        isGoogle ? Colors.green[800]! : Colors.blueGrey[800]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.green[800],
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.accountManager),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.accountManagerSubtitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.manageAccountsDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
          ),
          const SizedBox(height: 24),
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.accountManagerSubtitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (_isLoadingAccounts)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_systemAccounts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(l10n.noSavedAccounts),
                    )
                  else
                    ..._systemAccounts.map((account) {
                      final email = account['name'] ?? '';
                      final displayName = account['displayName'] ?? '';
                      final provider = _accountProvider(account);
                      final isCurrent = _user?.email != null &&
                          _user!.email!.toLowerCase() == email.toLowerCase();

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: UserAvatar.fromUserId(
                          userId: account['uid'] ?? '',
                          radius: 20,
                          isOwner: isCurrent,
                        ),
                        title:
                            Text(displayName.isNotEmpty ? displayName : email),
                        subtitle: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildProviderBadge(provider, l10n),
                          ],
                        ),
                        trailing: isCurrent
                            ? Icon(
                                Icons.check_circle,
                                color: Colors.green[600],
                              )
                            : null,
                      );
                    }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ButtonM3E(
            onPressed: _isSwitching ? null : _switchAccount,
            label: Text(l10n.switchAccount),
            style: ButtonM3EStyle.filled,
            size: ButtonM3ESize.md,
          ),
          const SizedBox(height: 12),
          ButtonM3E(
            onPressed: _isAddingAccount ? null : _addAccount,
            label: Text(l10n.addEmailPasswordAccount),
            style: ButtonM3EStyle.outlined,
            size: ButtonM3ESize.md,
          ),
          const SizedBox(height: 12),
          ButtonM3E(
            onPressed: _isAddingGoogleAccount ? null : _addGoogleAccount,
            label: Text(l10n.addGoogleAccount),
            style: ButtonM3EStyle.outlined,
            size: ButtonM3ESize.md,
          ),
          const SizedBox(height: 20),
          ButtonM3E(
            onPressed: _isRemoving ? null : _openRemoveAccountsModal,
            label: Text(l10n.removeAccounts),
            style: ButtonM3EStyle.text,
            size: ButtonM3ESize.md,
          ),
        ],
      ),
    );
  }
}
