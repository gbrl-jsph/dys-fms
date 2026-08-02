import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/business_sectors.dart';
import '../../../../core/utils/initials.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_error_container.dart';
import '../../../../core/widgets/app_field_label.dart';
import '../../../../core/widgets/app_success_container.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/loading_button.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/save_user_request.dart';
import '../../data/models/user_account.dart';
import '../../domain/users_state.dart';
import '../providers/users_provider.dart';

/// User Account Management screen per UI Style Guide (Screen 8) and
/// blueprint FR-003.
///
/// Business Owner only: user list table, Add/Edit form with Role and
/// Sector dropdowns, one-time temporary password display on creation,
/// and Deactivate/Activate workflow.
class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  int? _editingUserId;
  String? _selectedRole;
  int? _selectedSectorId;

  String? _nameError;
  String? _emailError;
  String? _roleError;
  String? _sectorError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersProvider>().loadUsers();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// The user currently being edited, derived from the loaded list so the
  /// form stays in sync after status updates.
  UserAccount? _editingUser(UsersProvider provider) {
    if (_editingUserId == null) return null;
    for (final UserAccount user in provider.state.users) {
      if (user.id == _editingUserId) return user;
    }
    return null;
  }

  void _startCreate() {
    setState(() {
      _editingUserId = null;
      _selectedRole = null;
      _selectedSectorId = null;
      _nameController.clear();
      _emailController.clear();
      _nameError = null;
      _emailError = null;
      _roleError = null;
      _sectorError = null;
    });
    context.read<UsersProvider>().clearSuccess();
  }

  void _startEdit(UserAccount user) {
    // The Business Owner's own account cannot be edited or deactivated
    // (BR-44); selecting the row is a no-op so the form never receives
    // the "Business Owner" role (not offered by the role dropdown).
    final int? currentUserId = context.read<AuthProvider>().state.user?.id;
    if (user.id == currentUserId) return;

    setState(() {
      _editingUserId = user.id;
      _nameController.text = user.name;
      _emailController.text = user.email;
      _selectedRole = user.role;
      _selectedSectorId = user.sectorId;
      _nameError = null;
      _emailError = null;
      _roleError = null;
      _sectorError = null;
    });
    context.read<UsersProvider>().clearSuccess();
  }

  bool _validate(List<UserAccount> users) {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();

    setState(() {
      _nameError = name.isEmpty
          ? 'Name is required.'
          : name.length > 255
          ? 'Name must not exceed 255 characters.'
          : null;
      _emailError = _validateEmail(email, users);
      _roleError = _selectedRole == null ? 'Role is required.' : null;
      _sectorError = _selectedSectorId == null ? 'Sector is required.' : null;
    });

    return _nameError == null &&
        _emailError == null &&
        _roleError == null &&
        _sectorError == null;
  }

  /// Email rules per the Validation Rules Matrix (UI layer):
  /// required, valid format, and unique except the editing user's own.
  String? _validateEmail(String email, List<UserAccount> users) {
    if (email.isEmpty) return 'Email is required.';
    final bool valid = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(email);
    if (!valid) return 'Enter a valid email address.';
    final bool duplicate = users.any(
      (UserAccount user) =>
          user.email.toLowerCase() == email.toLowerCase() &&
          user.id != _editingUserId,
    );
    return duplicate ? 'Email has already been taken.' : null;
  }

  void _submitSave(UsersProvider provider) {
    if (provider.state.isSubmitting) return;
    if (!_validate(provider.state.users)) return;

    provider.clearSuccess();

    final request = SaveUserRequest(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      role: _selectedRole!,
      sectorId: _selectedSectorId!,
    );

    final int? editingId = _editingUserId;
    if (editingId == null) {
      provider.createUser(request);
    } else {
      provider.updateUser(editingId, request);
    }
  }

  void _submitStatus(UsersProvider provider, UserAccount user) {
    if (provider.state.isSubmitting) return;
    provider.clearSuccess();
    provider.updateUserStatus(user.id, user.isActive ? 'Inactive' : 'Active');
  }

  void _submitResetPassword(UsersProvider provider) {
    final int? userId = _editingUserId;
    if (userId == null || provider.state.isSubmitting) return;
    provider.clearSuccess();
    provider.resetPassword(userId);
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = context.watch<AuthProvider>();
    final UsersProvider usersProvider = context.watch<UsersProvider>();
    final UsersState state = usersProvider.state;

    final UserAccount? editingUser = _editingUser(usersProvider);
    final bool isEditing = editingUser != null;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sp4,
            AppSpacing.sp3,
            AppSpacing.sp4,
            AppSpacing.sp4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AppBar(initials: initialsFor(authProvider.state.user?.name)),
              const SizedBox(height: AppSpacing.sp3),
              const SectionLabel('User List'),
              const SizedBox(height: AppSpacing.sp2),
              _UserListTable(
                state: state,
                editingUserId: _editingUserId,
                onSelect: _startEdit,
              ),
              const SizedBox(height: AppSpacing.sp3),
              ElevatedButton.icon(
                onPressed: state.isSubmitting ? null : _startCreate,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add User'),
              ),
              const SizedBox(height: AppSpacing.sp4),
              const SectionLabel('Add / Edit User'),
              const SizedBox(height: AppSpacing.sp2),
              _UserForm(
                isEditing: isEditing,
                isSubmitting: state.isSubmitting,
                editingUser: editingUser,
                nameController: _nameController,
                emailController: _emailController,
                selectedRole: _selectedRole,
                selectedSectorId: _selectedSectorId,
                nameError: _nameError,
                emailError: _emailError,
                roleError: _roleError,
                sectorError: _sectorError,
                onNameChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
                onEmailChanged: (_) {
                  if (_emailError != null) setState(() => _emailError = null);
                },
                onRoleChanged: (String? role) {
                  setState(() {
                    _selectedRole = role;
                    _roleError = null;
                  });
                },
                onSectorChanged: (int? sectorId) {
                  setState(() {
                    _selectedSectorId = sectorId;
                    _sectorError = null;
                  });
                },
                onGeneratePassword: isEditing
                    ? null
                    : () => _submitSave(usersProvider),
                onSave: () => _submitSave(usersProvider),
                onToggleStatus: isEditing
                    ? () => _submitStatus(usersProvider, editingUser)
                    : null,
                onResetPassword: isEditing
                    ? () => _submitResetPassword(usersProvider)
                    : null,
              ),
              if (state.successMessage != null ||
                  state.lastTemporaryPassword != null) ...[
                const SizedBox(height: AppSpacing.sp3),
                AppSuccessContainer(
                  message: state.successMessage ?? '',
                  temporaryPassword: state.lastTemporaryPassword,
                ),
              ],
              if (state.error != null) ...[
                const SizedBox(height: AppSpacing.sp3),
                AppErrorContainer(message: state.error!),
              ],
              const SizedBox(height: AppSpacing.sp3),
              Text(
                'Accounts are deactivated, not deleted. Only the Business Owner can manage users.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// App bar per UI Style Guide: centered "Manage Users" title + avatar.
class _AppBar extends StatelessWidget {
  const _AppBar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Manage Users',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall,
          ),
        ),
        AppAvatar(initials: initials),
      ],
    );
  }
}

/// User list table (wireframe `.data-table`): Name, Role, Sector, Status.
/// Tapping a row populates the Add/Edit form.
class _UserListTable extends StatelessWidget {
  const _UserListTable({
    required this.state,
    required this.editingUserId,
    required this.onSelect,
  });

  final UsersState state;
  final int? editingUserId;
  final ValueChanged<UserAccount> onSelect;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sp5),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: state.users.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(AppSpacing.sp4),
              child: Text(
                'No records yet',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(color: AppColors.inkMuted),
              ),
            )
          : DataTable(
              headingRowColor: WidgetStatePropertyAll(AppColors.surfaceSunken),
              horizontalMargin: AppSpacing.sp3,
              columnSpacing: AppSpacing.sp4,
              dataRowMinHeight: 44,
              dataRowMaxHeight: 52,
              columns: const [
                DataColumn(label: _HeaderText('Name')),
                DataColumn(label: _HeaderText('Role')),
                DataColumn(label: _HeaderText('Sector')),
                DataColumn(label: _HeaderText('Status')),
              ],
              rows: [
                for (final UserAccount user in state.users)
                  DataRow(
                    selected: editingUserId == user.id,
                    onSelectChanged: (_) => onSelect(user),
                    cells: [
                      DataCell(Text(user.name, style: textTheme.bodyLarge)),
                      DataCell(Text(user.role, style: textTheme.bodyLarge)),
                      DataCell(
                        Text(
                          user.sectorName ?? '—',
                          style: textTheme.bodyLarge,
                        ),
                      ),
                      DataCell(
                        Text(
                          user.accountStatus,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: user.isActive
                                ? AppColors.success
                                : AppColors.inkMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
    );
  }
}

/// Uppercase table header cell (wireframe `.data-table` thead).
class _HeaderText extends StatelessWidget {
  const _HeaderText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.inkSecondary,
        fontWeight: FontWeight.w700,
        letterSpacing: AppTypography.letterSpacingTableHeader,
      ),
    );
  }
}

/// Add/Edit form (wireframe `.card-flat`) with Name, Email, Role dropdown,
/// Sector dropdown, and the Save/Generate/Status actions.
class _UserForm extends StatelessWidget {
  const _UserForm({
    required this.isEditing,
    required this.isSubmitting,
    required this.editingUser,
    required this.nameController,
    required this.emailController,
    required this.selectedRole,
    required this.selectedSectorId,
    required this.nameError,
    required this.emailError,
    required this.roleError,
    required this.sectorError,
    required this.onNameChanged,
    required this.onEmailChanged,
    required this.onRoleChanged,
    required this.onSectorChanged,
    required this.onGeneratePassword,
    required this.onSave,
    required this.onToggleStatus,
    required this.onResetPassword,
  });

  final bool isEditing;
  final bool isSubmitting;
  final UserAccount? editingUser;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final String? selectedRole;
  final int? selectedSectorId;
  final String? nameError;
  final String? emailError;
  final String? roleError;
  final String? sectorError;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String?> onRoleChanged;
  final ValueChanged<int?> onSectorChanged;
  final VoidCallback? onGeneratePassword;
  final VoidCallback onSave;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onResetPassword;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sp4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Name',
            controller: nameController,
            enabled: !isSubmitting,
            hintText: 'Full name',
            errorText: nameError,
            onChanged: onNameChanged,
          ),
          const SizedBox(height: AppSpacing.sp4),
          AppTextField(
            label: 'Email',
            controller: emailController,
            enabled: !isSubmitting,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            hintText: 'Email address',
            errorText: emailError,
            onChanged: onEmailChanged,
          ),
          const SizedBox(height: AppSpacing.sp4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppFieldLabel('Role'),
                    DropdownButtonFormField<String>(
                      initialValue: selectedRole,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        hintText: 'Select role',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Event Manager',
                          child: Text('Event Manager'),
                        ),
                        DropdownMenuItem(
                          value: 'Employee/Staff',
                          child: Text('Employee/Staff'),
                        ),
                      ],
                      onChanged: isSubmitting ? null : onRoleChanged,
                    ),
                    if (roleError != null)
                      AppErrorContainer(message: roleError!),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sp3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppFieldLabel('Sector'),
                    DropdownButtonFormField<int>(
                      initialValue: selectedSectorId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        hintText: 'Select sector',
                      ),
                      items: [
                        for (final BusinessSectorData sector
                            in BusinessSectorsConfig.sectors)
                          DropdownMenuItem(
                            value: sector.id,
                            child: Text(sector.name),
                          ),
                      ],
                      onChanged: isSubmitting ? null : onSectorChanged,
                    ),
                    if (sectorError != null)
                      AppErrorContainer(message: sectorError!),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sp3),
          Text(
            'New accounts receive a temporary password. Employee may change on first login.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sp3),
          if (!isEditing) ...[
            OutlinedButton.icon(
              onPressed: isSubmitting ? null : onGeneratePassword,
              icon: const Icon(Icons.description_outlined, size: 16),
              label: const Text('Generate Temporary Password'),
            ),
            const SizedBox(height: AppSpacing.sp3),
          ],
          Row(
            children: [
              Expanded(
                child: LoadingButton(
                  label: 'Save Account',
                  loading: isSubmitting,
                  onPressed: onSave,
                ),
              ),
              if (isEditing) ...[
                const SizedBox(width: AppSpacing.sp3),
                Expanded(
                  child: _StatusButton(
                    isActive: editingUser?.isActive ?? false,
                    isSubmitting: isSubmitting,
                    onPressed: onToggleStatus,
                  ),
                ),
              ],
            ],
          ),
          if (isEditing) ...[
            const SizedBox(height: AppSpacing.sp3),
            OutlinedButton.icon(
              onPressed: isSubmitting ? null : onResetPassword,
              icon: const Icon(Icons.password, size: 16),
              label: const Text('Reset Temporary Password'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Deactivate (danger outline) / Activate (secondary) toggle button.
class _StatusButton extends StatelessWidget {
  const _StatusButton({
    required this.isActive,
    required this.isSubmitting,
    required this.onPressed,
  });

  final bool isActive;
  final bool isSubmitting;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final Color color = isActive ? AppColors.danger : AppColors.ink;

    return OutlinedButton(
      onPressed: isSubmitting ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 1.5),
      ),
      child: Text(isActive ? 'Deactivate' : 'Activate'),
    );
  }
}
