import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tam_customer/app/locale/app_locale_controller.dart';
import 'package:tam_customer/app/router/customer_navigation.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_state.dart';
import 'package:tam_customer/features/settings/presentation/widgets/settings_account_links.dart';
import 'package:tam_customer/features/settings/presentation/widgets/settings_bottom_actions.dart';
import 'package:tam_customer/features/settings/presentation/widgets/settings_language_sheet.dart';
import 'package:tam_customer/features/settings/presentation/widgets/settings_preferences_section.dart';
import 'package:tam_customer/features/settings/presentation/widgets/settings_profile_section.dart';
import 'package:tam_customer/l10n/app_localizations.dart';
import 'package:tam_customer/shared/widgets/tam_button.dart';
import 'package:tam_customer/shared/widgets/tam_loading_indicator.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.navigation,
    required this.locale,
    required this.logout,
    this.phoneE164,
    this.onBack,
  });

  final CustomerNavigation navigation;
  final AppLocaleController locale;
  final Future<void> Function() logout;
  final String? phoneE164;
  final VoidCallback? onBack;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _name = TextEditingController();
  bool _initialized = false;
  bool _editing = false;
  bool _allowPop = false;
  bool _loggingOut = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<bool> _confirmDiscard() async {
    final t = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.settingsUnsavedTitle),
        content: Text(t.settingsUnsavedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t.settingsKeepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(t.settingsDiscard),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _navigate(VoidCallback action) async {
    if (_loggingOut) return;
    final cubit = context.read<SettingsCubit>();
    if (cubit.state.isBusy) return;
    if (cubit.state.hasUnsavedChanges) {
      if (!await _confirmDiscard() || !mounted) return;
      cubit.discardChanges();
      _name.text = cubit.state.draftName;
    }
    if (mounted) action();
  }

  Future<void> _handlePop(SettingsState state) async {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    if (state.hasUnsavedChanges && await _confirmDiscard() && mounted) {
      setState(() => _allowPop = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
    }
  }

  Future<void> _updateNotifications(bool enabled) async {
    final changed = await context
        .read<SettingsCubit>()
        .updateNotificationsImmediately(enabled);
    if (!changed && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).settingsSaveError)),
      );
    }
  }

  Future<void> _pickLanguage() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SettingsLanguageSheet(
        languageCode: widget.locale.value.languageCode,
        onSelected: (code) {
          widget.locale.setLocale(Locale(code));
          Navigator.pop(sheetContext);
        },
      ),
    );
  }

  Future<void> _logout() async {
    if (_loggingOut) return;
    if (context.read<SettingsCubit>().state.hasUnsavedChanges &&
        !await _confirmDiscard()) {
      return;
    }
    if (!mounted) return;
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.settingsLogout),
        content: Text(t.settingsLogoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t.settingsCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(t.settingsLogout),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _loggingOut = true);
    try {
      await widget.logout();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).settingsLogoutError),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state.isReady && !_initialized) {
          _name.text = state.draftName;
          _initialized = true;
        }
        if (state.successAction == 'name') {
          _name.text = state.draftName;
        }
        if (state.successAction == 'name') {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.settingsSaved)));
        }
      },
      listenWhen: (previous, current) =>
          (current.isReady && !previous.isReady) ||
          (current.successAction != previous.successAction &&
              current.successAction != null),
      builder: (context, state) => PopScope(
        canPop:
            widget.onBack == null &&
            (_allowPop || (!state.hasUnsavedChanges && !_loggingOut)),
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && !_loggingOut) _handlePop(state);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              t.settingsTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton.filledTonal(
                tooltip: t.settingsNotifications,
                icon: const Icon(Icons.notifications_none_outlined),
                onPressed: () => _navigate(widget.navigation.openNotifications),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: AbsorbPointer(
                  absorbing: _loggingOut,
                  child: _body(state),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(SettingsState state) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    if (!state.isReady) {
      return Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: state.activity == SettingsActivity.loading
              ? TamLoadingIndicator(semanticLabel: t.settingsLoading)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: colors.error, size: 36),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      t.settingsServiceUnavailable,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TamButton.secondary(
                      label: t.settingsRetry,
                      onPressed: context.read<SettingsCubit>().load,
                    ),
                  ],
                ),
        ),
      );
    }
    final cubit = context.read<SettingsCubit>();
    return ListView(
      key: const Key('settings-content'),
      padding: AppSpacing.pagePadding,
      children: [
        SettingsProfileSection(
          state: state,
          phoneE164: widget.phoneE164,
          nameController: _name,
          isEditing: _editing,
          onToggleEdit: () => setState(() => _editing = !_editing),
          onNameChanged: cubit.nameChanged,
          onSave: cubit.saveName,
        ),
        const SizedBox(height: AppSpacing.xl),
        SettingsPreferencesSection(
          state: state,
          languageCode: widget.locale.value.languageCode,
          onNotificationsChanged: _updateNotifications,
          onLanguageTap: _pickLanguage,
        ),
        const SizedBox(height: AppSpacing.xl),
        SettingsAccountLinks(
          enabled: !state.isBusy,
          onAddresses: () => _navigate(widget.navigation.openAddresses),
          onSupport: () => _navigate(() => widget.navigation.openSupport()),
          onTerms: () => _navigate(widget.navigation.openTerms),
          onPrivacy: () => _navigate(widget.navigation.openPrivacy),
          onChangePhone: () => _navigate(widget.navigation.openAccountPhone),
          onDeleteAccount: () =>
              _navigate(widget.navigation.openAccountDeletion),
        ),
        const SizedBox(height: AppSpacing.xl),
        SettingsBottomActions(
          busy: state.isBusy,
          loggingOut: _loggingOut,
          onLogout: _logout,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
