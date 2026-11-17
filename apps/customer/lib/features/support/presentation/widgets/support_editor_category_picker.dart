import 'package:flutter/material.dart';
import 'package:tam_customer/app/theme/app_tokens.dart';

import '../../domain/support_repository.dart';

/// The chosen category remains owned by SupportEditorCubit.
class SupportEditorCategoryPicker extends StatelessWidget {
  const SupportEditorCategoryPicker({
    super.key,
    required this.title,
    required this.categories,
    required this.selectedId,
    required this.enabled,
    required this.languageCode,
    required this.onSelected,
  });

  final String title;
  final List<SupportCategory> categories;
  final String? selectedId;
  final bool enabled;
  final String languageCode;
  final ValueChanged<String> onSelected;

  String _name(SupportCategory category) =>
      languageCode.startsWith('ar') ? category.nameAr : category.nameEn;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final active = categories.where((c) => c.id == selectedId).firstOrNull;

    return Semantics(
      label: '$title: ${active == null ? title : _name(active)}',
      button: true,
      enabled: enabled,
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: InkWell(
          key: const Key('support-category'),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          onTap: enabled
              ? () async {
                  final chosen = await showModalBottomSheet<String>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    showDragHandle: true,
                    backgroundColor: colors.surface,
                    barrierColor: colors.scrim.withValues(alpha: 0.30),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    builder: (sheetContext) => _CategorySheet(
                      title: title,
                      categories: categories,
                      currentId: selectedId,
                      name: _name,
                    ),
                  );
                  if (context.mounted &&
                      chosen != null &&
                      chosen != selectedId) {
                    onSelected(chosen);
                  }
                }
              : null,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    active == null ? title : _name(active),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.82),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colors.primary.withValues(alpha: 0.78),
                  size: 23,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySheet extends StatelessWidget {
  const _CategorySheet({
    required this.title,
    required this.categories,
    required this.currentId,
    required this.name,
  });

  final String title;
  final List<SupportCategory> categories;
  final String? currentId;
  final String Function(SupportCategory) name;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.80;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.86),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final category in categories) ...[
              Semantics(
                selected: category.id == currentId,
                button: true,
                child: Material(
                  color: category.id == currentId
                      ? colors.primaryContainer.withValues(alpha: 0.78)
                      : colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  child: InkWell(
                    key: Key('support-category-option-${category.id}'),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    onTap: () => Navigator.of(context).pop(category.id),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.lg,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              name(category),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: category.id == currentId
                                    ? colors.onPrimaryContainer
                                    : colors.onSurface.withValues(alpha: 0.80),
                                fontWeight: category.id == currentId
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (category.id == currentId)
                            Icon(
                              Icons.check_circle_rounded,
                              color: colors.primary,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ],
        ),
      ),
    );
  }
}
