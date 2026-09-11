# Graph Report - Vault  (2026-09-11)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 2480 nodes · 4202 edges · 148 communities (110 shown, 25 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 19 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `63aadbb0`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Community 0
- Community 1
- Community 2
- Community 3
- Community 4
- Community 5
- Community 6
- Community 7
- Community 8
- Community 9
- Community 10
- Community 11
- Community 12
- Community 13
- Community 14
- Community 15
- Community 16
- Community 17
- Community 18
- Community 19
- Community 20
- Community 21
- Community 22
- Community 23
- Community 24
- Community 25
- Community 26
- Community 27
- Community 28
- Community 29
- Community 30
- Community 31
- Community 32
- Community 33
- Community 34
- Community 35
- Community 36
- Community 37
- Community 38
- Community 39
- Community 40
- Community 41
- Community 42
- Community 43
- Community 44
- Community 45
- Community 46
- Community 47
- Community 48
- Community 49
- Community 50
- Community 51
- Community 52
- Community 53
- Community 54
- Community 55
- Community 56
- Community 57
- Community 58
- Community 59
- Community 60
- Community 61
- Community 62
- Community 63
- Community 64
- Community 65
- Community 66
- Community 67
- Community 68
- Community 69
- Community 70
- Community 71
- Community 72
- Community 73
- Community 74
- Community 75
- Community 76
- Community 77
- Community 78
- Community 79
- Community 80
- Community 81
- Community 82
- Community 83
- Community 84
- Community 85
- Community 86
- Community 87
- Community 88
- Community 89
- Community 90
- Community 91
- Community 92
- Community 93
- Community 94
- Community 95
- Community 96
- Community 97
- Community 98
- Community 99
- Community 100
- Community 101
- Community 102
- Community 103
- Community 104
- Community 105
- Community 106
- Community 107
- Community 108
- Community 109
- Community 110
- Community 111
- Community 112
- Community 113
- Community 114
- Community 115
- Community 116
- Community 117
- Community 118
- Community 119
- Community 120
- Community 121
- Community 122
- Community 123
- Community 124
- Community 125
- Community 126
- Community 127
- Community 128
- Community 129
- Community 130
- Community 131
- Community 132
- Community 146
- Community 147

## God Nodes (most connected - your core abstractions)
1. `AuthProvider` - 80 edges
2. `User` - 71 edges
3. `BusinessSector` - 35 edges
4. `UserManagementTest` - 28 edges
5. `PayrollManagementTest` - 26 edges
6. `Expense` - 26 edges
7. `ExpenseManagementTest` - 25 edges
8. `Win32Window` - 24 edges
9. `SalesManagementTest` - 23 edges
10. `AuthenticationTest` - 21 edges

## Surprising Connections (you probably didn't know these)
- `OnCreate` --calls--> `RegisterPlugins()`  [INFERRED]
  flutter_app/windows/runner/flutter_window.h → flutter_app/windows/flutter/generated_plugin_registrant.cc
- `Win32Window::Win32Window()` --calls--> `Destroy`  [INFERRED]
  flutter_app/windows/runner/win32_window.cpp → flutter_app/windows/runner/win32_window.h
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  flutter_app/windows/runner/main.cpp → flutter_app/windows/runner/utils.cpp
- `_submit` --references--> `AuthProvider`  [EXTRACTED]
  flutter_app/lib/features/auth/presentation/screens/forgot_password_screen.dart → flutter_app/lib/features/auth/presentation/providers/auth_provider.dart
- `_submit` --references--> `AuthProvider`  [EXTRACTED]
  flutter_app/lib/features/auth/presentation/screens/login_screen.dart → flutter_app/lib/features/auth/presentation/providers/auth_provider.dart

## Import Cycles
- None detected.

## Communities (148 total, 25 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.04
Nodes (62): dart:async, AppTheme, build, AuthRepository, main, fakeRepository, main, provider (+54 more)

### Community 1 - "Community 1"
Cohesion: 0.04
Nodes (58): ../../../auth/presentation/providers/auth_provider.dart, core/constants/app_colors.dart, ../../../../core/constants/app_radius.dart, ../../../../core/constants/app_shadows.dart, ../../../../core/constants/app_spacing.dart, ../../../../core/widgets/app_error_container.dart, ../../../../core/widgets/app_screen_header.dart, ../../../../core/widgets/app_success_container.dart (+50 more)

### Community 2 - "Community 2"
Cohesion: 0.05
Nodes (41): AppColors, border, borderStrong, brightness, danger, dangerContainer, darkPalette, ink (+33 more)

### Community 3 - "Community 3"
Cohesion: 0.06
Nodes (27): Any, Cocoa, Flutter, AppDelegate, Bool, SceneDelegate, RunnerTests, RegisterGeneratedPlugins() (+19 more)

### Community 4 - "Community 4"
Cohesion: 0.06
Nodes (39): PayrollProvider, build, createState, dispose, _employeeError, _formatDecimal, _hoursController, _hoursError (+31 more)

### Community 5 - "Community 5"
Cohesion: 0.06
Nodes (36): SectorsRepository, authProvider, buildForbiddenException, buildUnauthenticatedException, dashboardProvider, employeeUserJson, eventManagerUserJson, fakeAuthRepository (+28 more)

### Community 6 - "Community 6"
Cohesion: 0.11
Nodes (14): BusinessSector, User, TestCase, Illuminate\Database\Eloquent\Relations\HasMany, Illuminate\Foundation\Auth\User, Illuminate\Foundation\Testing\RefreshDatabase, Illuminate\Foundation\Testing\TestCase, Illuminate\Notifications\Notifiable (+6 more)

### Community 7 - "Community 7"
Cohesion: 0.06
Nodes (38): ../../../../core/widgets/app_field_label.dart, ../../../../core/widgets/app_report_charts.dart, ReportsProvider, autoLoad, build, createState, _dateFrom, _dateFromController (+30 more)

### Community 8 - "Community 8"
Cohesion: 0.05
Nodes (38): _amountController, _amountError, assignedSectorId, createState, _descriptionController, dispose, _editingTransaction, _filteredSales (+30 more)

### Community 9 - "Community 9"
Cohesion: 0.05
Nodes (37): AndroidOptions get, adapter, aOptions, buildApp, buildAuthProvider, buildBackendAdapter, containsKey, delete (+29 more)

### Community 10 - "Community 10"
Cohesion: 0.05
Nodes (37): _amountController, _amountError, assignedSectorId, createState, _descriptionController, dispose, _editingRecord, _filteredExpenses (+29 more)

### Community 11 - "Community 11"
Cohesion: 0.05
Nodes (36): app.dart, core/theme/theme_mode_store.dart, data/api/api_client.dart, features/auth/data/repositories/auth_repository.dart, features/auth/data/storage/secure_storage.dart, features/dashboard/data/repositories/dashboard_repository.dart, features/expenses/data/repositories/expenses_repository.dart, features/payroll/data/repositories/payroll_repository.dart (+28 more)

### Community 12 - "Community 12"
Cohesion: 0.06
Nodes (34): AuthState get, ../data/models/login_response.dart, ../data/models/user_model.dart, ../../data/repositories/auth_repository.dart, ../../domain/auth_state.dart, DefaultSector, fromJson, id (+26 more)

### Community 13 - "Community 13"
Cohesion: 0.05
Nodes (35): autoload, autoload-dev, psr-4, psr-4, config, optimize-autoloader, preferred-install, sort-packages (+27 more)

### Community 14 - "Community 14"
Cohesion: 0.07
Nodes (33): DioException, PayrollRepository, adapter, main, provider, repository, adapter, main (+25 more)

### Community 15 - "Community 15"
Cohesion: 0.07
Nodes (30): ElevatedButton, failLoad, failSave, load, main, save, stored, main (+22 more)

### Community 16 - "Community 16"
Cohesion: 0.07
Nodes (33): DashboardRepository, adapter, main, provider, repository, sampleSummary, adapter, main (+25 more)

### Community 17 - "Community 17"
Cohesion: 0.08
Nodes (9): PayrollController, StorePayrollRequest, AuditLog, PayrollRecord, PayrollService, Illuminate\Database\Eloquent\Model, Illuminate\Database\Eloquent\Relations\BelongsTo, Illuminate\Database\Eloquent\Relations\HasOne (+1 more)

### Community 18 - "Community 18"
Cohesion: 0.09
Nodes (3): Illuminate\Database\Migrations\Migration, Illuminate\Database\Schema\Blueprint, Illuminate\Support\Facades\Schema

### Community 19 - "Community 19"
Cohesion: 0.06
Nodes (35): ../../../../core/constants/app_typography.dart, createState, dispose, editingUser, _editingUserId, _emailController, _emailError, initials (+27 more)

### Community 20 - "Community 20"
Cohesion: 0.06
Nodes (33): double?, _asDouble, FinancialSummary, fromJson, isCrossSector, netBalance, payrollExpenses, sectorId (+25 more)

### Community 21 - "Community 21"
Cohesion: 0.07
Nodes (32): ../../../../core/widgets/app_loading_indicator.dart, DashboardProvider, createState, DashboardScreen, _DashboardScreenState, initState, isBusinessOwner, isEventManager (+24 more)

### Community 22 - "Community 22"
Cohesion: 0.14
Nodes (14): EnsureBusinessOwner, EnsureExpenseAccess, EnsurePayrollAccess, EnsureReportsAccess, EnsureSalesAccess, EnsureSectorAccess, Closure, Illuminate\Auth\AuthenticationException (+6 more)

### Community 23 - "Community 23"
Cohesion: 0.10
Nodes (31): ChangeNotifier, AuthProvider, build, build, build, build, _showTransactionChoice, ExpensesProvider (+23 more)

### Community 24 - "Community 24"
Cohesion: 0.08
Nodes (29): ../../../auth/data/models/login_response.dart, ../../../auth/domain/auth_state.dart, ../../../../core/utils/sector_context.dart, ../../../../core/widgets/app_empty_state.dart, ../../../../core/widgets/sector_logo.dart, ../../../dashboard/presentation/providers/dashboard_provider.dart, build, SectorsProvider (+21 more)

### Community 25 - "Community 25"
Cohesion: 0.08
Nodes (27): Repository, ExpensesRepository, adapter, main, provider, repository, adapter, main (+19 more)

### Community 26 - "Community 26"
Cohesion: 0.08
Nodes (27): SalesRepository, adapter, main, provider, repository, adapter, main, repository (+19 more)

### Community 27 - "Community 27"
Cohesion: 0.08
Nodes (7): AuthController, ForgotPasswordRequest, LoginRequest, ResetPasswordRequest, UpdateProfileRequest, AuthService, Illuminate\Support\Facades\Password

### Community 28 - "Community 28"
Cohesion: 0.08
Nodes (28): ../../../../core/constants/app_info.dart, ThemeController, _AppearanceTile, build, createState, currentMode, didChangeDependencies, dispose (+20 more)

### Community 29 - "Community 29"
Cohesion: 0.09
Nodes (25): ReportsRepository, main, adapter, main, provider, repository, adapter, main (+17 more)

### Community 30 - "Community 30"
Cohesion: 0.17
Nodes (27): MarkItDown, compute_hash(), convert_file(), discover_documents(), _find_content(), _gen_client_interview(), _gen_concept_paper(), _gen_consistency_review() (+19 more)

### Community 31 - "Community 31"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, fl_register_plugins(), main(), first_frame_cb(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init() (+14 more)

### Community 32 - "Community 32"
Cohesion: 0.09
Nodes (24): UsersRepository, buildBadResponseException, fakeRepository, main, provider, adapter, main, repository (+16 more)

### Community 33 - "Community 33"
Cohesion: 0.08
Nodes (23): AppRadius, full, lg, md, sm, xl, AppSpacing, sp1 (+15 more)

### Community 34 - "Community 34"
Cohesion: 0.09
Nodes (5): UserController, StoreUserRequest, UpdateUserRequest, UpdateUserStatusRequest, Illuminate\Validation\Rule

### Community 35 - "Community 35"
Cohesion: 0.09
Nodes (19): ../api/api_client.dart, api_config.dart, auth_interceptor.dart, Dio, Dio get, ApiClient, _dio, init (+11 more)

### Community 36 - "Community 36"
Cohesion: 0.08
Nodes (23): app_error_container.dart, app_field_label.dart, AppTextField, autocorrect, build, controller, enabled, errorText (+15 more)

### Community 37 - "Community 37"
Cohesion: 0.08
Nodes (24): _AvatarMenu, _QuickActions, _RecentTransactionRow, _DateTimeSelector, _ExpenseRow, _ExpensesList, _RecordExpenseForm, _PayrollList (+16 more)

### Community 38 - "Community 38"
Cohesion: 0.10
Nodes (4): ExpensesController, IndexExpenseRequest, StoreExpenseRequest, UpdateExpenseRequest

### Community 40 - "Community 40"
Cohesion: 0.09
Nodes (22): ApiConfig, baseUrl, businessSectorsEndpoint, businessSectorsSwitchEndpoint, changePasswordEndpoint, expenseEndpoint, expensesEndpoint, forgotPasswordEndpoint (+14 more)

### Community 41 - "Community 41"
Cohesion: 0.10
Nodes (20): DashboardState get, ../data/models/financial_summary.dart, ../data/models/recent_transaction.dart, ../../data/repositories/dashboard_repository.dart, ../../domain/dashboard_state.dart, copyWith, DashboardState, error (+12 more)

### Community 44 - "Community 44"
Cohesion: 0.12
Nodes (16): ../../../../core/utils/formatters.dart, ../../../../data/api/api_config.dart, ../../../../data/repositories/repository_base.dart, getRecentTransactions, getSummary, calculatePayroll, getPayroll, getReport (+8 more)

### Community 45 - "Community 45"
Cohesion: 0.15
Nodes (4): SalesController, IndexSaleRequest, StoreSaleRequest, Illuminate\Http\JsonResponse

### Community 46 - "Community 46"
Cohesion: 0.12
Nodes (15): ../constants/app_colors.dart, ../constants/app_typography.dart, AppAvatar, build, initials, AppLoadingIndicator, build, label (+7 more)

### Community 47 - "Community 47"
Cohesion: 0.11
Nodes (18): core/theme/app_theme.dart, authProvider, build, createState, dashboardProvider, dispose, expensesProvider, initState (+10 more)

### Community 48 - "Community 48"
Cohesion: 0.11
Nodes (17): ../../../../data/api/api_error_mapper.dart, ../data/models/report_data.dart, ../../data/repositories/reports_repository.dart, ../../domain/reports_state.dart, ReportData, copyWith, error, isLoading (+9 more)

### Community 49 - "Community 49"
Cohesion: 0.11
Nodes (17): ../data/models/business_sector.dart, ../../data/repositories/sectors_repository.dart, ../../domain/sectors_state.dart, copyWith, error, isLoading, isSwitching, sectors (+9 more)

### Community 50 - "Community 50"
Cohesion: 0.13
Nodes (4): ChangePasswordRequest, IndexPayrollRequest, UpdateSaleRequest, Illuminate\Foundation\Http\FormRequest

### Community 53 - "Community 53"
Cohesion: 0.11
Nodes (17): ../../../../core/constants/business_sectors.dart, ../../../../core/utils/initials.dart, ../../../../core/widgets/app_avatar.dart, ../../../../core/widgets/section_label.dart, createState, didChangeDependencies, dispose, initState (+9 more)

### Community 54 - "Community 54"
Cohesion: 0.11
Nodes (17): ../core/widgets/app_shell.dart, features/auth/presentation/providers/auth_provider.dart, ../features/auth/presentation/screens/forgot_password_screen.dart, ../features/auth/presentation/screens/login_screen.dart, ../features/auth/presentation/screens/reset_password_screen.dart, ../features/dashboard/presentation/screens/dashboard_screen.dart, ../features/expenses/presentation/screens/expenses_screen.dart, ../features/payroll/presentation/screens/payroll_screen.dart (+9 more)

### Community 55 - "Community 55"
Cohesion: 0.11
Nodes (17): ../../features/reports/data/models/report_data.dart, barColor, build, _EmptyChart, height, _interval, message, _pieColors (+9 more)

### Community 56 - "Community 56"
Cohesion: 0.12
Nodes (15): DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow, flutter_controller_ (+7 more)

### Community 57 - "Community 57"
Cohesion: 0.18
Nodes (14): wchar_t, Scale(), Create, Destroy, SetQuitOnClose, Show, UpdateTheme, Win32Window::Win32Window() (+6 more)

### Community 58 - "Community 58"
Cohesion: 0.12
Nodes (15): core/events/financial_events.dart, ../../data/models/save_payroll_request.dart, ../../data/repositories/payroll_repository.dart, ../../domain/payroll_state.dart, FinancialEvents, notifyDataChanged, calculatePayroll, clearError (+7 more)

### Community 59 - "Community 59"
Cohesion: 0.12
Nodes (16): accountStatus, createdAt, email, fromJson, id, isActive, isBusinessOwner, isEmployee (+8 more)

### Community 60 - "Community 60"
Cohesion: 0.16
Nodes (16): App, App, _AppState, ForgotPasswordScreen, _ForgotPasswordScreenState, LoginScreen, _LoginScreenState, ResetPasswordScreen (+8 more)

### Community 61 - "Community 61"
Cohesion: 0.15
Nodes (4): BusinessSectorController, SwitchSectorRequest, BusinessSectorService, Illuminate\Support\Facades\Route

### Community 63 - "Community 63"
Cohesion: 0.13
Nodes (13): ../constants/app_radius.dart, ../constants/app_spacing.dart, AppErrorContainer, build, centered, message, AppFieldLabel, build (+5 more)

### Community 64 - "Community 64"
Cohesion: 0.12
Nodes (15): adapter, clearAuth, clearAuthCalled, deleteToken, getToken, getUserData, isLoggedIn, loginResponseBody (+7 more)

### Community 65 - "Community 65"
Cohesion: 0.12
Nodes (15): buildLoginResponse, buildUnauthorizedException, changePassword, dio, forgotPassword, getStoredUser, isAuthenticated, login (+7 more)

### Community 66 - "Community 66"
Cohesion: 0.21
Nodes (5): UserService, Illuminate\Support\Carbon, Illuminate\Support\Collection, Illuminate\Support\Facades\Log, Illuminate\Support\Facades\Mail

### Community 67 - "Community 67"
Cohesion: 0.13
Nodes (14): Color, accent, accentContainer, accentFor, BusinessSectorData, BusinessSectorsConfig, description, iconFor (+6 more)

### Community 68 - "Community 68"
Cohesion: 0.13
Nodes (14): ../../data/models/save_expense_request.dart, ../../data/repositories/expenses_repository.dart, ../../domain/expenses_state.dart, ExpensesState get, clearError, clearSuccess, deleteExpense, _expensesRepository (+6 more)

### Community 69 - "Community 69"
Cohesion: 0.13
Nodes (14): ../../data/models/save_sale_request.dart, ../../data/repositories/sales_repository.dart, ../../domain/sales_state.dart, clearError, clearSuccess, deleteSale, _financialEvents, loadSales (+6 more)

### Community 71 - "Community 71"
Cohesion: 0.14
Nodes (13): CustomPainter, dart:math, dart:ui, AppChartPlaceholder, build, color, _DashedBorderPainter, height (+5 more)

### Community 72 - "Community 72"
Cohesion: 0.14
Nodes (12): ../data/models/payroll_record.dart, initialsFor, parts, copyWith, error, isLoading, isSubmitting, PayrollState (+4 more)

### Community 73 - "Community 73"
Cohesion: 0.14
Nodes (13): ../../data/models/save_user_request.dart, ../../data/repositories/users_repository.dart, ../../domain/users_state.dart, clearError, clearSuccess, createUser, loadUsers, resetPassword (+5 more)

### Community 74 - "Community 74"
Cohesion: 0.14
Nodes (13): changePassword, forgotPassword, getStoredUser, isAuthenticated, login, logout, resetPassword, _secureStorage (+5 more)

### Community 75 - "Community 75"
Cohesion: 0.14
Nodes (13): amount, createdAt, description, ExpenseRecord, fromJson, id, payrollRecordId, recordedAt (+5 more)

### Community 76 - "Community 76"
Cohesion: 0.14
Nodes (13): calculatedAt, computedSalary, employeeId, employeeName, expenseId, fromJson, hourlyRate, hoursWorked (+5 more)

### Community 77 - "Community 77"
Cohesion: 0.15
Nodes (12): app_colors.dart, AppShadows, shadow1, _shadow1Dark, _shadow1Light, shadow2, _shadow2Dark, _shadow2Light (+4 more)

### Community 79 - "Community 79"
Cohesion: 0.15
Nodes (11): AppInfo, appName, appVersion, load, save, _storage, _themeModeKey, _InMemoryFlutterSecureStorage (+3 more)

### Community 80 - "Community 80"
Cohesion: 0.15
Nodes (12): handlePlatformBrightnessChanged, initialize, _mode, resolve, setMode, _store, ThemeModeStore, _FakeThemeModeStore (+4 more)

### Community 81 - "Community 81"
Cohesion: 0.15
Nodes (12): clearAuth, deleteToken, getToken, getUserData, isLoggedIn, saveToken, saveUserData, SecureStorage (+4 more)

### Community 82 - "Community 82"
Cohesion: 0.15
Nodes (12): amount, createdAt, description, fromJson, id, recordedAt, recordedById, recordedByName (+4 more)

### Community 83 - "Community 83"
Cohesion: 0.24
Nodes (8): TemporaryPasswordMail, Content, Envelope, Illuminate\Bus\Queueable, Illuminate\Mail\Mailable, Illuminate\Mail\Mailables\Content, Illuminate\Mail\Mailables\Envelope, Illuminate\Queue\SerializesModels

### Community 84 - "Community 84"
Cohesion: 0.17
Nodes (11): bool get, accountStatus, email, fromJson, id, isBusinessOwner, isEmployee, isEventManager (+3 more)

### Community 85 - "Community 85"
Cohesion: 0.17
Nodes (10): AppScreenHeader, build, onBack, title, build, label, loading, LoadingButton (+2 more)

### Community 86 - "Community 86"
Cohesion: 0.17
Nodes (11): AppShell, branchIndex, build, icon, label, navigationShell, _NavItem, _navItemsFor (+3 more)

### Community 87 - "Community 87"
Cohesion: 0.24
Nodes (9): wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16(), _In_, _In_opt_ (+1 more)

### Community 88 - "Community 88"
Cohesion: 0.22
Nodes (3): ReportsController, Controller, ReportRequest

### Community 91 - "Community 91"
Cohesion: 0.25
Nodes (5): BusinessSectorSeeder, DatabaseSeeder, UserSeeder, Illuminate\Database\Seeder, Illuminate\Support\Facades\DB

### Community 92 - "Community 92"
Cohesion: 0.18
Nodes (10): ../data/models/user_account.dart, copyWith, error, isLoading, isSubmitting, lastTemporaryPassword, successMessage, _unset (+2 more)

### Community 93 - "Community 93"
Cohesion: 0.18
Nodes (10): DateTime get, amount, description, expense, id, isSale, localRecordedAt, RecentTransaction (+2 more)

### Community 94 - "Community 94"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 95 - "Community 95"
Cohesion: 0.20
Nodes (9): core/theme/theme_controller.dart, features/dashboard/presentation/providers/dashboard_provider.dart, features/expenses/presentation/providers/expenses_provider.dart, features/payroll/presentation/providers/payroll_provider.dart, features/reports/presentation/providers/reports_provider.dart, features/sales/presentation/providers/sales_provider.dart, features/sectors/presentation/providers/sectors_provider.dart, features/users/presentation/providers/users_provider.dart (+1 more)

### Community 96 - "Community 96"
Cohesion: 0.20
Nodes (8): dart:html, null, sectorIdFor, null, readXsrfToken, package:dys_fms/core/constants/business_sectors.dart, package:dys_fms/features/auth/domain/auth_state.dart, return

### Community 97 - "Community 97"
Cohesion: 0.20
Nodes (9): ../data/models/expense_record.dart, copyWith, error, expenses, ExpensesState, isLoading, isSubmitting, successMessage (+1 more)

### Community 98 - "Community 98"
Cohesion: 0.20
Nodes (9): ../data/models/sales_transaction.dart, copyWith, error, isLoading, isSubmitting, sales, SalesState, successMessage (+1 more)

### Community 99 - "Community 99"
Cohesion: 0.20
Nodes (9): createUser, getUser, getUsers, resetPassword, updateUser, updateUserStatus, ../models/save_user_request.dart, ../models/update_user_status_request.dart (+1 more)

### Community 100 - "Community 100"
Cohesion: 0.29
Nodes (10): OnCreate, HWND, Win32Window, child_content_, GetClientArea, OnCreate, quit_on_close_, SetChildContent (+2 more)

### Community 101 - "Community 101"
Cohesion: 0.36
Nodes (10): HWND, LPARAM, LRESULT, UINT, WPARAM, EnableFullDpiSupportIfAvailable(), GetHandle, GetThisFromHandle (+2 more)

### Community 102 - "Community 102"
Cohesion: 0.22
Nodes (8): deleteExpense, getExpense, getExpenses, recordExpense, searchExpenses, updateExpense, ../models/expense_record.dart, ../models/save_expense_request.dart

### Community 103 - "Community 103"
Cohesion: 0.22
Nodes (8): deleteSale, getSale, getSales, recordSale, searchSales, updateSale, ../models/sales_transaction.dart, ../models/save_sale_request.dart

### Community 104 - "Community 104"
Cohesion: 0.22
Nodes (8): BusinessSector, currentSector, description, fromJson, id, name, previousSector, SectorSwitchResult

### Community 105 - "Community 105"
Cohesion: 0.25
Nodes (7): DateTime, hourlyRate, hoursWorked, payPeriod, SavePayrollRequest, toJson, userId

### Community 106 - "Community 106"
Cohesion: 0.25
Nodes (7): formatApiDate, formatCurrency, formatDate, Formatters, formatTime, _months, static const List

### Community 107 - "Community 107"
Cohesion: 0.25
Nodes (7): amount, description, recordedAt, SaveExpenseRequest, sectorId, toJson, int?

### Community 108 - "Community 108"
Cohesion: 0.25
Nodes (8): _CalculatePayrollForm, UsersProvider, build, initState, _startCreate, _startEdit, UsersScreen, _UsersScreenState

### Community 109 - "Community 109"
Cohesion: 0.25
Nodes (8): SalesProvider, _cancelEdit, _confirmDelete, _loadSales, onSectorChanged, SalesScreen, _SalesScreenState, _startEdit

### Community 110 - "Community 110"
Cohesion: 0.21
Nodes (6): Point, x, y, Size, height, width

### Community 112 - "Community 112"
Cohesion: 0.29
Nodes (6): ../constants/business_sectors.dart, build, _iconFallback, sectorId, SectorLogo, size

### Community 113 - "Community 113"
Cohesion: 0.29
Nodes (6): dart:convert, dart:typed_data, close, fetch, fromBytes, jsonResponse

### Community 114 - "Community 114"
Cohesion: 0.29
Nodes (6): AppEmptyState, build, icon, message, title, IconData

### Community 115 - "Community 115"
Cohesion: 0.29
Nodes (6): amount, description, recordedAt, SaveSaleRequest, sectorId, toJson

### Community 116 - "Community 116"
Cohesion: 0.29
Nodes (6): email, name, role, SaveUserRequest, sectorId, toJson

### Community 117 - "Community 117"
Cohesion: 0.47
Nodes (5): add_related_block(), main(), process_extracted(), Path, Add cross-link metadata to all memory/ Markdown files.

### Community 119 - "Community 119"
Cohesion: 0.40
Nodes (4): AuthInterceptor, onError, onRequest, QueuedInterceptor

### Community 120 - "Community 120"
Cohesion: 0.40
Nodes (4): email, LoginRequest, password, toJson

### Community 121 - "Community 121"
Cohesion: 0.50
Nodes (3): accountStatus, toJson, UpdateUserStatusRequest

## Knowledge Gaps
- **1145 isolated node(s):** `AppTheme`, `build`, `main`, `fakeRepository`, `main` (+1140 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1479 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **25 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `BusinessSector` connect `Community 6` to `Community 70`, `Community 39`, `Community 42`, `Community 43`, `Community 78`, `Community 17`, `Community 52`, `Community 61`, `Community 62`?**
  _High betweenness centrality (0.165) - this node is a cross-community bridge._
- **Why does `AuthProvider` connect `Community 23` to `Community 0`, `Community 1`, `Community 4`, `Community 5`, `Community 7`, `Community 8`, `Community 10`, `Community 11`, `Community 12`, `Community 14`, `Community 15`, `Community 16`, `Community 19`, `Community 21`, `Community 24`, `Community 28`, `Community 47`, `Community 53`, `Community 60`, `Community 86`, `Community 108`, `Community 109`?**
  _High betweenness centrality (0.065) - this node is a cross-community bridge._
- **Why does `User` connect `Community 6` to `Community 66`, `Community 38`, `Community 70`, `Community 39`, `Community 42`, `Community 43`, `Community 45`, `Community 78`, `Community 17`, `Community 83`, `Community 52`, `Community 88`, `Community 89`, `Community 90`, `Community 62`?**
  _High betweenness centrality (0.046) - this node is a cross-community bridge._
- **What connects `AppTheme`, `build`, `main` to the rest of the system?**
  _1145 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.043058350100603625 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.0449497620306716 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.047619047619047616 - nodes in this community are weakly interconnected._