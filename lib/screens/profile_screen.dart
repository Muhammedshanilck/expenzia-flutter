import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../app_scope.dart';
import '../core/constants/app_assets.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/utils/validators.dart';
import '../repositories/repository_exception.dart';
import '../widgets/app_header.dart';
import '../widgets/dialogs.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  Future<void> _editName(BuildContext context) async {
    final profile = AppScope.of(context).profile;
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _EditNameDialog(initialName: profile.name),
    );
    if (newName == null || !context.mounted) return;
    try {
      await profile.updateName(newName);
    } on RepositoryException catch (e) {
      if (context.mounted) showMessage(context, e.message);
    }
  }

  Future<void> _clearStorage(BuildContext context) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Clear storage?',
      message:
          'All transactions, saved credits and your profile name '
          'will be permanently deleted.',
      confirmLabel: 'Clear',
    );
    if (!confirmed || !context.mounted) return;

    final scope = AppScope.of(context);
    try {
      await scope.expenses.deleteAll();
      await scope.credits.deleteAll();
      await scope.profile.clear();
      if (context.mounted) showMessage(context, 'All data cleared');
    } on RepositoryException catch (e) {
      if (context.mounted) showMessage(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = AppScope.of(context).profile;

    return Column(
      children: [
        AppHeader(title: 'Profile', onBack: onBack),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: 203,
              bottom: MediaQuery.paddingOf(context).bottom + 16,
            ),
            child: Center(
              child: Column(
                children: [
                  const _Avatar(),
                  const SizedBox(height: 20),
                  ListenableBuilder(
                    listenable: profile,
                    builder: (context, _) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Balances the edit icon so the name stays centred.
                        const SizedBox(width: 24),
                        Flexible(
                          child: Text(
                            profile.name,
                            style: AppTextStyles.profileName,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkResponse(
                          onTap: () => _editName(context),
                          radius: 18,
                          child: SvgPicture.asset(
                            AppAssets.profileEdit,
                            width: 16,
                            height: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 134,
                    height: 38,
                    child: OutlinedButton(
                      onPressed: () => _clearStorage(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: const BorderSide(color: AppColors.pillBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      child: const Text(
                        'Clear Storage',
                        style: AppTextStyles.clearStorage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 120 px round photo with the teal camera badge.
class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: Container(
              width: 120,
              height: 120,
              color: AppColors.white,
              child: OverflowBox(
                maxWidth: 156,
                maxHeight: 156,
                child: Image.asset(AppAssets.avatar, width: 156, height: 156),
              ),
            ),
          ),
          Positioned(
            left: 81,
            top: 75,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    AppAssets.avatarBadge,
                    width: 44,
                    height: 44,
                  ),
                  SvgPicture.asset(
                    AppAssets.cameraFilled,
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.initialName});

  final String initialName;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _controller = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Edit name', style: AppTextStyles.sectionTitle),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          style: AppTextStyles.fieldValue,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Your name'),
          validator: (value) => Validators.requiredText(value, field: 'Name'),
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
