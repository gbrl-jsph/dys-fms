# Graph Report - Vault  (2026-09-11)

## Corpus Check
- 362 files · ~404,900 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 3316 nodes · 4975 edges · 206 communities (165 shown, 27 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 20 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `2436b144`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- package:flutter/material.dart
- reset_password_screen.dart
- app_colors.dart
- AppDelegate
- payroll_screen.dart
- package:flutter_test/flutter_test.dart
- Illuminate\Foundation\Testing\RefreshDatabase
- reports_screen.dart
- sales_screen.dart
- app_integration_test.dart
- expenses_screen.dart
- main.dart
- auth_provider.dart
- composer.json
- payroll_screen_test.dart
- login_screen_test.dart
- dashboard_provider_test.dart
- Illuminate\Database\Eloquent\Relations\BelongsTo
- Illuminate\Database\Migrations\Migration
- users_screen.dart
- report_data.dart
- dashboard_screen.dart
- Illuminate\Http\Request
- sector_switcher_screen_test.dart
- sector_switcher_screen.dart
- expenses_screen_test.dart
- sales_provider_test.dart
- Illuminate\Http\JsonResponse
- settings_screen.dart
- DYS Financial Management System – User Flow Documentation
- extract-docs.py
- my_application.cc
- fake_users_repository.dart
- app_spacing.dart
- StorePayrollRequest
- auth_repository_test.dart
- app_text_field.dart
- DYS FMS AI Context
- ExpensesController
- UserManagementTest
- api_config.dart
- dashboard_provider.dart
- PayrollManagementTest
- ExpenseManagementTest
- ../../../../data/api/api_config.dart
- Security and Hardening
- main
- app.dart
- reports_provider.dart
- sectors_provider.dart
- ChangePasswordRequest
- AuthenticationTest
- SalesManagementTest
- AuthProvider
- app_router.dart
- app_report_charts.dart
- FlutterWindow
- win32_window.cpp
- payroll_provider.dart
- user_account.dart
- ExpenseService
- BusinessSectorController
- ReportsManagementTest
- Code Review and Quality
- sales_state.dart
- Test-Driven Development
- User
- business_sectors.dart
- expenses_provider.dart
- sales_provider.dart
- ReportsService
- app_chart_placeholder.dart
- Class Diagram Documentation — Proposed System
- users_provider.dart
- auth_repository.dart
- expense_record.dart
- payroll_record.dart
- app_shadows.dart
- BusinessSectorManagementTest
- theme_mode_store.dart
- theme_controller.dart
- secure_storage.dart
- sales_transaction.dart
- TemporaryPasswordMail
- user_model.dart
- VoidCallback?
- Context Engineering
- wWinMain
- SalesController
- Git Workflow and Versioning
- Shipping and Launch
- Illuminate\Database\Seeder
- package:dio/dio.dart
- recent_transaction.dart
- manifest.json
- app_empty_state.dart
- sector_context.dart
- C. Updated System Environment
- List
- users_repository.dart
- Win32Window
- MessageHandler
- expenses_repository.dart
- sales_repository.dart
- BusinessSector
- DateTime?
- formatters.dart
- Use Case Diagram Documentation — Proposed System
- Illuminate\Foundation\Http\FormRequest
- API and Interface Design
- Point
- Activity Diagram Documentation — Current Business Process (As-Is)
- int?
- fake_http_adapter.dart
- ../constants/app_spacing.dart
- save_sale_request.dart
- save_user_request.dart
- add-crosslinks.py
- AppServiceProvider
- auth_interceptor.dart
- login_request.dart
- update_user_status_request.dart
- RegisterPlugins
- MainActivity.kt
- vercel.json
- opencode.json
- graphify.js
- cache.php
- entrypoint.sh
- http_adapter_config.dart
- xsrf_token_reader.dart
- xsrf_token_reader_stub.dart
- idea-refine.sh
- bool?
- String?
- Browser Testing with DevTools
- What You Must Do When Invoked
- Performance Optimization
- CI/CD and Automation
- Constraint-Driven Development
- Deprecation and Migration
- Frontend UI Engineering
- Incremental Implementation
- Code Simplification
- Debugging and Error Recovery
- Documentation and ADRs
- Planning and Task Breakdown
- ReOrder: Keep Your Regulars Ordering Direct
- Interview Me
- Doubt-Driven Development
- Process
- Idea Refine
- Using Agent Skills
- Spec-Driven Development
- Source-Driven Development
- auth_state.dart
- financial_summary.dart
- Refinement & Evaluation Criteria
- TestCase
- theme_controller_test.dart
- graphify reference: extra exports and benchmark
- Ideation Frameworks Reference
- users_state.dart
- State
- graphify reference: query, path, explain
- DYS FMS Agent Context
- app_theme.dart
- app_providers.dart
- payroll_state.dart
- graphify reference: add a URL and watch a folder
- graphify reference: commit hook and native CLAUDE.md integration
- graphify reference: incremental update and cluster-only
- graphify reference: GitHub clone and cross-repo merge
- graphify reference: transcribe video and audio
- extraction-spec.md
- Path
- app_info.dart
- dashboard_repository.dart
- payroll_repository.dart
- DYS Financial Management System (DYS FMS) — Current Project Baseline
- login_response.dart
- SalesProvider
- save_expense_request.dart
- DYS FMS Documentation Index and Authority Map
- ForgotPasswordRequest
- LoginRequest
- Final Design Authority
- ../constants/app_colors.dart
- app_error_container.dart
- app_success_container.dart
- DYS FMS Documentation Library
- DYS Financial Management System (DYS FMS)

## God Nodes (most connected - your core abstractions)
1. `User` - 76 edges
2. `AuthProvider` - 54 edges
3. `UserManagementTest` - 29 edges
4. `PayrollManagementTest` - 27 edges
5. `ExpenseManagementTest` - 25 edges
6. `Win32Window` - 24 edges
7. `SalesManagementTest` - 23 edges
8. `AuthenticationTest` - 21 edges
9. `ReportsManagementTest` - 21 edges
10. `BusinessSector` - 19 edges

## Surprising Connections (you probably didn't know these)
- `OnCreate` --calls--> `RegisterPlugins()`  [INFERRED]
  flutter_app/windows/runner/flutter_window.h → flutter_app/windows/flutter/generated_plugin_registrant.cc
- `Win32Window::Win32Window()` --calls--> `Destroy`  [INFERRED]
  flutter_app/windows/runner/win32_window.cpp → flutter_app/windows/runner/win32_window.h
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  flutter_app/windows/runner/main.cpp → flutter_app/windows/runner/utils.cpp
- `FlutterWindow` --inherits--> `Win32Window`  [EXTRACTED]
  flutter_app/windows/runner/flutter_window.h → flutter_app/windows/runner/win32_window.h
- `MessageHandler` --references--> `Win32Window`  [EXTRACTED]
  flutter_app/windows/runner/flutter_window.h → flutter_app/windows/runner/win32_window.h

## Import Cycles
- None detected.

## Communities (206 total, 27 thin omitted)

### Community 0 - "package:flutter/material.dart"
Cohesion: 0.05
Nodes (48): FakeAuthRepository, FakeDashboardRepository, FakeReportsRepository, FinancialSummary, main, main, wrap, authProvider (+40 more)

### Community 1 - "reset_password_screen.dart"
Cohesion: 0.05
Nodes (54): ../../../../core/constants/app_colors.dart, ../../../../core/constants/app_radius.dart, ../../../../core/constants/app_shadows.dart, ../../../../core/constants/app_spacing.dart, ../../../../core/widgets/app_error_container.dart, ../../../../core/widgets/app_screen_header.dart, ../../../../core/widgets/app_success_container.dart, ../../../../core/widgets/app_text_field.dart (+46 more)

### Community 2 - "app_colors.dart"
Cohesion: 0.05
Nodes (41): AppColors, border, borderStrong, brightness, danger, dangerContainer, darkPalette, ink (+33 more)

### Community 3 - "AppDelegate"
Cohesion: 0.06
Nodes (27): Any, Cocoa, Flutter, AppDelegate, Bool, SceneDelegate, RunnerTests, RegisterGeneratedPlugins() (+19 more)

### Community 4 - "payroll_screen.dart"
Cohesion: 0.06
Nodes (42): ../../../../core/widgets/app_field_label.dart, PayrollProvider, build, _CalculatePayrollForm, createState, dispose, _employeeError, _formatDecimal (+34 more)

### Community 5 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.07
Nodes (33): DioException, main, main, main, adapter, main, provider, repository (+25 more)

### Community 6 - "Illuminate\Foundation\Testing\RefreshDatabase"
Cohesion: 0.14
Nodes (16): App\Mail\TemporaryPasswordMail, App\Models\BusinessSector, App\Models\Expense, App\Models\PayrollRecord, App\Models\SalesTransaction, Illuminate\Foundation\Testing\RefreshDatabase, Illuminate\Routing\Route, Illuminate\Support\Carbon (+8 more)

### Community 7 - "reports_screen.dart"
Cohesion: 0.06
Nodes (38): ../../../../core/widgets/app_report_charts.dart, autoLoad, build, createState, _dateFrom, _dateFromController, _dateTo, _dateToController (+30 more)

### Community 8 - "sales_screen.dart"
Cohesion: 0.05
Nodes (37): _amountController, _amountError, assignedSectorId, createState, _descriptionController, dispose, _editingTransaction, _filteredSales (+29 more)

### Community 9 - "app_integration_test.dart"
Cohesion: 0.05
Nodes (42): AndroidOptions get, adapter, aOptions, buildApp, buildAuthProvider, buildBackendAdapter, containsKey, delete (+34 more)

### Community 10 - "expenses_screen.dart"
Cohesion: 0.04
Nodes (60): AuthProvider, ExpenseRecord?, ExpensesProvider, ExpensesState, AppShell, branchIndex, build, icon (+52 more)

### Community 11 - "main.dart"
Cohesion: 0.05
Nodes (36): app.dart, core/theme/theme_mode_store.dart, data/api/api_client.dart, features/auth/data/repositories/auth_repository.dart, features/auth/data/storage/secure_storage.dart, features/dashboard/data/repositories/dashboard_repository.dart, features/expenses/data/repositories/expenses_repository.dart, features/payroll/data/repositories/payroll_repository.dart (+28 more)

### Community 12 - "auth_provider.dart"
Cohesion: 0.13
Nodes (14): AuthState get, ../../data/repositories/auth_repository.dart, ../../domain/auth_state.dart, _authRepository, changePassword, checkAuthStatus, clearError, forgotPassword (+6 more)

### Community 13 - "composer.json"
Cohesion: 0.05
Nodes (35): autoload, autoload-dev, psr-4, psr-4, config, optimize-autoloader, preferred-install, sort-packages (+27 more)

### Community 14 - "payroll_screen_test.dart"
Cohesion: 0.07
Nodes (33): PayrollRepository, adapter, main, provider, repository, adapter, main, repository (+25 more)

### Community 15 - "login_screen_test.dart"
Cohesion: 0.08
Nodes (31): dart:async, LoginResponse, AuthRepository, fakeRepository, main, provider, fakeRepository, main (+23 more)

### Community 16 - "dashboard_provider_test.dart"
Cohesion: 0.09
Nodes (23): DashboardRepository, adapter, main, provider, repository, sampleSummary, adapter, main (+15 more)

### Community 17 - "Illuminate\Database\Eloquent\Relations\BelongsTo"
Cohesion: 0.17
Nodes (7): AuditLog, Expense, PayrollRecord, Illuminate\Database\Eloquent\Model, Illuminate\Database\Eloquent\Relations\BelongsTo, Illuminate\Database\Eloquent\Relations\HasOne, Illuminate\Database\Eloquent\SoftDeletes

### Community 18 - "Illuminate\Database\Migrations\Migration"
Cohesion: 0.08
Nodes (3): Illuminate\Database\Migrations\Migration, Illuminate\Database\Schema\Blueprint, Illuminate\Support\Facades\Schema

### Community 19 - "users_screen.dart"
Cohesion: 0.05
Nodes (44): ../../../../core/constants/app_typography.dart, build, createState, dispose, editingUser, _editingUserId, _emailController, _emailError (+36 more)

### Community 20 - "report_data.dart"
Cohesion: 0.09
Nodes (22): _asDouble, ChartPoint, crossSectorBreakdown, expenseBreakdown, fromJson, hasCharts, id, isCrossSector (+14 more)

### Community 21 - "dashboard_screen.dart"
Cohesion: 0.04
Nodes (60): ../../../../core/widgets/app_loading_indicator.dart, DashboardProvider, DashboardState, _AvatarMenu, createState, DashboardScreen, _DashboardScreenState, initState (+52 more)

### Community 22 - "Illuminate\Http\Request"
Cohesion: 0.11
Nodes (17): AuthController, EnsureBusinessOwner, EnsureExpenseAccess, EnsurePayrollAccess, EnsureReportsAccess, EnsureSalesAccess, EnsureSectorAccess, AuthService (+9 more)

### Community 23 - "sector_switcher_screen_test.dart"
Cohesion: 0.07
Nodes (28): ElevatedButton, SectorsRepository, main, authProvider, buildForbiddenException, buildUnauthenticatedException, dashboardProvider, employeeUserJson (+20 more)

### Community 24 - "sector_switcher_screen.dart"
Cohesion: 0.07
Nodes (33): ../../../auth/data/models/login_response.dart, ../../../auth/domain/auth_state.dart, ChangeNotifier, ../../../../core/utils/sector_context.dart, ../../../../core/widgets/app_empty_state.dart, ../../../../core/widgets/sector_logo.dart, ../../../dashboard/presentation/providers/dashboard_provider.dart, DashboardProvider (+25 more)

### Community 25 - "expenses_screen_test.dart"
Cohesion: 0.07
Nodes (33): ExpensesRepository, adapter, main, provider, repository, adapter, main, repository (+25 more)

### Community 26 - "sales_provider_test.dart"
Cohesion: 0.09
Nodes (25): SalesRepository, adapter, main, provider, repository, adapter, main, repository (+17 more)

### Community 27 - "Illuminate\Http\JsonResponse"
Cohesion: 0.13
Nodes (6): ReportsController, UserController, Controller, ReportRequest, Illuminate\Http\JsonResponse, Illuminate\Support\Facades\Route

### Community 28 - "settings_screen.dart"
Cohesion: 0.08
Nodes (27): ../../../auth/presentation/providers/auth_provider.dart, ../../../../core/constants/app_info.dart, ThemeController, _AppearanceTile, build, createState, currentMode, didChangeDependencies (+19 more)

### Community 29 - "DYS Financial Management System – User Flow Documentation"
Cohesion: 0.11
Nodes (18): 1. Authentication & Role Routing Flow, 1. Purpose, 1. Purpose, 1. Purpose, 1. Purpose, 1. Purpose, 2. Actor(s), 2. Available Actions (+10 more)

### Community 30 - "extract-docs.py"
Cohesion: 0.16
Nodes (26): MarkItDown, compute_hash(), convert_file(), discover_documents(), _find_content(), _gen_client_interview(), _gen_concept_paper(), _gen_consistency_review() (+18 more)

### Community 31 - "my_application.cc"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, fl_register_plugins(), main(), first_frame_cb(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init() (+14 more)

### Community 32 - "fake_users_repository.dart"
Cohesion: 0.09
Nodes (24): UsersRepository, buildBadResponseException, fakeRepository, main, provider, adapter, main, repository (+16 more)

### Community 33 - "app_spacing.dart"
Cohesion: 0.08
Nodes (23): AppRadius, full, lg, md, sm, xl, AppSpacing, sp1 (+15 more)

### Community 34 - "StorePayrollRequest"
Cohesion: 0.13
Nodes (5): PayrollController, IndexPayrollRequest, StorePayrollRequest, PayrollService, PayrollRecord

### Community 35 - "auth_repository_test.dart"
Cohesion: 0.06
Nodes (34): adapter, clearAuth, clearAuthCalled, deleteToken, getToken, getUserData, isLoggedIn, loginResponseBody (+26 more)

### Community 36 - "app_text_field.dart"
Cohesion: 0.08
Nodes (23): app_error_container.dart, app_field_label.dart, AppTextField, autocorrect, build, controller, enabled, errorText (+15 more)

### Community 37 - "DYS FMS AI Context"
Cohesion: 0.15
Nodes (13): Current Architecture, Current Runtime RBAC (Implementation Snapshot), Current Verification, Data Model, DYS FMS AI Context, Historical and UML Rules, Identity, Implemented Modules (+5 more)

### Community 38 - "ExpensesController"
Cohesion: 0.10
Nodes (4): ExpensesController, IndexExpenseRequest, StoreExpenseRequest, UpdateExpenseRequest

### Community 40 - "api_config.dart"
Cohesion: 0.09
Nodes (22): ApiConfig, baseUrl, businessSectorsEndpoint, businessSectorsSwitchEndpoint, changePasswordEndpoint, expenseEndpoint, expensesEndpoint, forgotPasswordEndpoint (+14 more)

### Community 41 - "dashboard_provider.dart"
Cohesion: 0.10
Nodes (20): DashboardState get, ../../data/models/financial_summary.dart, ../../data/models/recent_transaction.dart, ../../data/repositories/dashboard_repository.dart, ../../domain/dashboard_state.dart, copyWith, DashboardState, error (+12 more)

### Community 42 - "PayrollManagementTest"
Cohesion: 0.16
Nodes (3): PayrollManagementTest, BusinessSector, PayrollRecord

### Community 43 - "ExpenseManagementTest"
Cohesion: 0.16
Nodes (3): ExpenseManagementTest, BusinessSector, Expense

### Community 44 - "../../../../data/api/api_config.dart"
Cohesion: 0.22
Nodes (8): ../../../../core/utils/formatters.dart, ../../../../data/api/api_config.dart, ../../../../data/repositories/repository_base.dart, getReport, getSectors, switchSector, ../models/business_sector.dart, ../models/report_data.dart

### Community 45 - "Security and Hardening"
Cohesion: 0.06
Nodes (31): Always Do (No Exceptions), Ask First (Requires Human Approval), Broken Access Control, Broken Authentication, Common Rationalizations, Cross-Site Scripting (XSS), Data Privacy & Compliance, Destructive Operations on Derived Paths (+23 more)

### Community 46 - "main"
Cohesion: 0.27
Nodes (10): build, _showTransactionChoice, main, Route /expenses, Route /payroll, Route /reports, Route /sales, Route /sector-switcher (+2 more)

### Community 47 - "app.dart"
Cohesion: 0.11
Nodes (18): core/theme/app_theme.dart, authProvider, build, createState, dashboardProvider, dispose, expensesProvider, initState (+10 more)

### Community 48 - "reports_provider.dart"
Cohesion: 0.11
Nodes (17): ../../data/models/report_data.dart, ../../data/repositories/reports_repository.dart, ../../domain/reports_state.dart, ReportData, copyWith, error, isLoading, report (+9 more)

### Community 49 - "sectors_provider.dart"
Cohesion: 0.11
Nodes (17): ../../../../data/api/api_error_mapper.dart, ../data/models/business_sector.dart, ../../data/repositories/sectors_repository.dart, ../../domain/sectors_state.dart, copyWith, error, isLoading, isSwitching (+9 more)

### Community 53 - "AuthProvider"
Cohesion: 0.07
Nodes (36): ../../../../core/constants/business_sectors.dart, ../../../../core/utils/initials.dart, ../../../../core/widgets/app_avatar.dart, ../../../../core/widgets/section_label.dart, AuthProvider, build, _submit, build (+28 more)

### Community 54 - "app_router.dart"
Cohesion: 0.11
Nodes (17): ../core/widgets/app_shell.dart, ../features/auth/presentation/providers/auth_provider.dart, ../features/auth/presentation/screens/forgot_password_screen.dart, ../features/auth/presentation/screens/login_screen.dart, ../features/auth/presentation/screens/reset_password_screen.dart, ../features/dashboard/presentation/screens/dashboard_screen.dart, ../features/expenses/presentation/screens/expenses_screen.dart, ../features/payroll/presentation/screens/payroll_screen.dart (+9 more)

### Community 55 - "app_report_charts.dart"
Cohesion: 0.11
Nodes (17): ../../features/reports/data/models/report_data.dart, barColor, build, _EmptyChart, height, _interval, message, _pieColors (+9 more)

### Community 56 - "FlutterWindow"
Cohesion: 0.12
Nodes (15): DartProject, HWND, LPARAM, LRESULT, UINT, WPARAM, FlutterWindow, flutter_controller_ (+7 more)

### Community 57 - "win32_window.cpp"
Cohesion: 0.18
Nodes (14): wchar_t, Scale(), Create, Destroy, SetQuitOnClose, Show, UpdateTheme, Win32Window::Win32Window() (+6 more)

### Community 58 - "payroll_provider.dart"
Cohesion: 0.12
Nodes (15): core/events/financial_events.dart, ../../data/models/save_payroll_request.dart, ../../data/repositories/payroll_repository.dart, ../../domain/payroll_state.dart, FinancialEvents, notifyDataChanged, calculatePayroll, clearError (+7 more)

### Community 59 - "user_account.dart"
Cohesion: 0.12
Nodes (16): accountStatus, createdAt, email, fromJson, id, isActive, isBusinessOwner, isEmployee (+8 more)

### Community 61 - "BusinessSectorController"
Cohesion: 0.18
Nodes (3): BusinessSectorController, SwitchSectorRequest, BusinessSectorService

### Community 62 - "ReportsManagementTest"
Cohesion: 0.22
Nodes (4): BusinessSector, Expense, ReportsManagementTest, SalesTransaction

### Community 63 - "Code Review and Quality"
Cohesion: 0.07
Nodes (29): 1. Correctness, 2. Readability & Simplicity, 3. Architecture, 4. Security, 5. Performance, Change Descriptions, Change Sizing, Code Review and Quality (+21 more)

### Community 64 - "sales_state.dart"
Cohesion: 0.20
Nodes (9): ../data/models/sales_transaction.dart, copyWith, error, isLoading, isSubmitting, sales, SalesState, successMessage (+1 more)

### Community 65 - "Test-Driven Development"
Cohesion: 0.07
Nodes (29): Browser Testing with DevTools, Common Rationalizations, DAMP Over DRY in Tests, Decision Guide, Discover the Stack First, Name Tests Descriptively, One Assertion Per Concept, Overview (+21 more)

### Community 66 - "User"
Cohesion: 0.18
Nodes (7): SalesTransaction, User, SalesService, UserService, Illuminate\Foundation\Auth\User, Illuminate\Notifications\Notifiable, Laravel\Sanctum\HasApiTokens

### Community 67 - "business_sectors.dart"
Cohesion: 0.13
Nodes (14): Color, accent, accentContainer, accentFor, BusinessSectorData, BusinessSectorsConfig, description, iconFor (+6 more)

### Community 68 - "expenses_provider.dart"
Cohesion: 0.13
Nodes (14): ../../data/models/save_expense_request.dart, ../../data/repositories/expenses_repository.dart, ../../domain/expenses_state.dart, ExpensesState get, clearError, clearSuccess, deleteExpense, _expensesRepository (+6 more)

### Community 69 - "sales_provider.dart"
Cohesion: 0.13
Nodes (14): ../../data/models/save_sale_request.dart, ../../data/repositories/sales_repository.dart, ../../domain/sales_state.dart, clearError, clearSuccess, deleteSale, _financialEvents, loadSales (+6 more)

### Community 71 - "app_chart_placeholder.dart"
Cohesion: 0.14
Nodes (13): CustomPainter, dart:math, dart:ui, AppChartPlaceholder, build, color, _DashedBorderPainter, height (+5 more)

### Community 72 - "Class Diagram Documentation — Proposed System"
Cohesion: 0.11
Nodes (18): 1. Purpose & Objective, 2. Mandatory Three-Diagram Traceability Chain, 3. Inventory of Domain Classes & Enumerations, 4.1 `User`, 4.2 `BusinessSector`, 4.3 `SalesTransaction`, 4.4 `Expense`, 4.5 `PayrollRecord` (+10 more)

### Community 73 - "users_provider.dart"
Cohesion: 0.14
Nodes (13): ../../data/models/save_user_request.dart, ../../data/repositories/users_repository.dart, ../../domain/users_state.dart, clearError, clearSuccess, createUser, loadUsers, resetPassword (+5 more)

### Community 74 - "auth_repository.dart"
Cohesion: 0.12
Nodes (15): changePassword, forgotPassword, getStoredUser, isAuthenticated, login, logout, resetPassword, _secureStorage (+7 more)

### Community 75 - "expense_record.dart"
Cohesion: 0.14
Nodes (13): amount, createdAt, description, ExpenseRecord, fromJson, id, payrollRecordId, recordedAt (+5 more)

### Community 76 - "payroll_record.dart"
Cohesion: 0.14
Nodes (13): calculatedAt, computedSalary, employeeId, employeeName, expenseId, fromJson, hourlyRate, hoursWorked (+5 more)

### Community 77 - "app_shadows.dart"
Cohesion: 0.15
Nodes (12): app_colors.dart, AppShadows, shadow1, _shadow1Dark, _shadow1Light, shadow2, _shadow2Dark, _shadow2Light (+4 more)

### Community 79 - "theme_mode_store.dart"
Cohesion: 0.25
Nodes (7): load, save, _storage, _themeModeKey, _InMemoryFlutterSecureStorage, FlutterSecureStorage, package:flutter_secure_storage/flutter_secure_storage.dart

### Community 80 - "theme_controller.dart"
Cohesion: 0.22
Nodes (8): handlePlatformBrightnessChanged, initialize, _mode, resolve, setMode, _store, theme_mode_store.dart, ThemeMode get

### Community 81 - "secure_storage.dart"
Cohesion: 0.18
Nodes (10): clearAuth, deleteToken, getToken, getUserData, isLoggedIn, saveToken, saveUserData, _storage (+2 more)

### Community 82 - "sales_transaction.dart"
Cohesion: 0.15
Nodes (12): amount, createdAt, description, fromJson, id, recordedAt, recordedById, recordedByName (+4 more)

### Community 83 - "TemporaryPasswordMail"
Cohesion: 0.24
Nodes (8): TemporaryPasswordMail, Content, Envelope, Illuminate\Bus\Queueable, Illuminate\Mail\Mailable, Illuminate\Mail\Mailables\Content, Illuminate\Mail\Mailables\Envelope, Illuminate\Queue\SerializesModels

### Community 84 - "user_model.dart"
Cohesion: 0.15
Nodes (12): bool get, accountStatus, email, fromJson, id, isBookkeeper, isBusinessOwner, isEmployee (+4 more)

### Community 85 - "VoidCallback?"
Cohesion: 0.17
Nodes (10): AppScreenHeader, build, onBack, title, build, label, loading, LoadingButton (+2 more)

### Community 86 - "Context Engineering"
Cohesion: 0.07
Nodes (27): Anti-Patterns, Common Rationalizations, Compress before dropping, Confusion Management, Context Budget Management, Context Engineering, Context Packing Strategies, Level 1: Rules Files (+19 more)

### Community 87 - "wWinMain"
Cohesion: 0.24
Nodes (9): wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16(), _In_, _In_opt_ (+1 more)

### Community 88 - "SalesController"
Cohesion: 0.09
Nodes (4): SalesController, IndexSaleRequest, StoreSaleRequest, UpdateSaleRequest

### Community 89 - "Git Workflow and Versioning"
Cohesion: 0.07
Nodes (26): 1. Commit Early, Commit Often, 2. Atomic Commits, 3. Descriptive Messages, 4. Keep Concerns Separate, 5. Size Your Changes, Branch Naming, Branching Strategy, Change Summaries (+18 more)

### Community 90 - "Shipping and Launch"
Cohesion: 0.08
Nodes (25): Accessibility, Code Quality, Common Rationalizations, Documentation, Error Budget Release Gate, Error Reporting, Feature Flag Strategy, Infrastructure (+17 more)

### Community 91 - "Illuminate\Database\Seeder"
Cohesion: 0.25
Nodes (5): BusinessSectorSeeder, DatabaseSeeder, UserSeeder, Illuminate\Database\Seeder, Illuminate\Support\Facades\DB

### Community 92 - "package:dio/dio.dart"
Cohesion: 0.06
Nodes (31): ../api/api_client.dart, api_config.dart, auth_interceptor.dart, Dio, Dio get, ApiClient, _dio, init (+23 more)

### Community 93 - "recent_transaction.dart"
Cohesion: 0.18
Nodes (10): DateTime get, amount, description, expense, id, isSale, localRecordedAt, RecentTransaction (+2 more)

### Community 94 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 95 - "app_empty_state.dart"
Cohesion: 0.29
Nodes (6): AppEmptyState, build, icon, message, title, IconData

### Community 96 - "sector_context.dart"
Cohesion: 0.20
Nodes (8): dart:html, null, sectorIdFor, null, readXsrfToken, package:dys_fms/core/constants/business_sectors.dart, package:dys_fms/features/auth/domain/auth_state.dart, return

### Community 97 - "C. Updated System Environment"
Cohesion: 0.13
Nodes (14): 1. Software Requirements, 2. Backend / Server Requirements, 3. Database Requirements, 4. Mobile / Client Requirements, 5. Hardware Requirements, A. System Architecture / System Framework, A. Updated Use Case Diagram, B. Discussion of the Use Case Diagram (+6 more)

### Community 98 - "List"
Cohesion: 0.14
Nodes (12): ../../data/models/expense_record.dart, initialsFor, parts, copyWith, error, expenses, ExpensesState, isLoading (+4 more)

### Community 99 - "users_repository.dart"
Cohesion: 0.20
Nodes (9): createUser, getUser, getUsers, resetPassword, updateUser, updateUserStatus, ../models/save_user_request.dart, ../models/update_user_status_request.dart (+1 more)

### Community 100 - "Win32Window"
Cohesion: 0.29
Nodes (10): OnCreate, HWND, Win32Window, child_content_, GetClientArea, OnCreate, quit_on_close_, SetChildContent (+2 more)

### Community 101 - "MessageHandler"
Cohesion: 0.36
Nodes (10): HWND, LPARAM, LRESULT, UINT, WPARAM, EnableFullDpiSupportIfAvailable(), GetHandle, GetThisFromHandle (+2 more)

### Community 102 - "expenses_repository.dart"
Cohesion: 0.22
Nodes (8): deleteExpense, getExpense, getExpenses, recordExpense, searchExpenses, updateExpense, ../models/expense_record.dart, ../models/save_expense_request.dart

### Community 103 - "sales_repository.dart"
Cohesion: 0.22
Nodes (8): deleteSale, getSale, getSales, recordSale, searchSales, updateSale, ../models/sales_transaction.dart, ../models/save_sale_request.dart

### Community 104 - "BusinessSector"
Cohesion: 0.11
Nodes (10): BusinessSector, BusinessSector, currentSector, description, fromJson, id, name, previousSector (+2 more)

### Community 105 - "DateTime?"
Cohesion: 0.25
Nodes (7): DateTime?, hourlyRate, hoursWorked, payPeriod, SavePayrollRequest, toJson, userId

### Community 106 - "formatters.dart"
Cohesion: 0.25
Nodes (7): formatApiDate, formatCurrency, formatDate, Formatters, formatTime, _months, static const List

### Community 107 - "Use Case Diagram Documentation — Proposed System"
Cohesion: 0.15
Nodes (12): Actor Access Summary, Actors, Authentication & Core, Business Rules & Constraints, Financial Transactions & Operations, Management & Administration, Purpose, Reports & Analytics (+4 more)

### Community 108 - "Illuminate\Foundation\Http\FormRequest"
Cohesion: 0.08
Nodes (7): ResetPasswordRequest, UpdateProfileRequest, StoreUserRequest, UpdateUserRequest, UpdateUserStatusRequest, Illuminate\Foundation\Http\FormRequest, Illuminate\Validation\Rule

### Community 109 - "API and Interface Design"
Cohesion: 0.08
Nodes (24): 1. Contract First, 2. Consistent Error Semantics, 3. Validate at Boundaries, 4. Prefer Addition Over Modification, 5. Predictable Naming, 6. Honouring an Idempotency Key, API and Interface Design, Common Rationalizations (+16 more)

### Community 110 - "Point"
Cohesion: 0.21
Nodes (6): Point, x, y, Size, height, width

### Community 111 - "Activity Diagram Documentation — Current Business Process (As-Is)"
Cohesion: 0.17
Nodes (11): 1. Overview & Objective, 2. Swimlanes (Actors Involved — 4 Levels), 3. End-to-End Workflow & Process Steps, 4.1 Decision and Merge Nodes, 4.2 Grouped Cross-Swimlane Handoffs (short, adjacent only), 4.3 Notes Without Interference, 4. UML 2.x Semantics & Diagram Structure, 5. Verification & Consistency Audit (+3 more)

### Community 112 - "int?"
Cohesion: 0.25
Nodes (7): ../constants/business_sectors.dart, build, _iconFallback, sectorId, SectorLogo, size, int?

### Community 113 - "fake_http_adapter.dart"
Cohesion: 0.29
Nodes (6): dart:convert, dart:typed_data, close, fetch, fromBytes, jsonResponse

### Community 114 - "../constants/app_spacing.dart"
Cohesion: 0.22
Nodes (7): ../constants/app_spacing.dart, AppFieldLabel, build, text, AppLoadingIndicator, build, label

### Community 115 - "save_sale_request.dart"
Cohesion: 0.29
Nodes (6): amount, description, recordedAt, SaveSaleRequest, sectorId, toJson

### Community 116 - "save_user_request.dart"
Cohesion: 0.29
Nodes (6): email, name, role, SaveUserRequest, sectorId, toJson

### Community 117 - "add-crosslinks.py"
Cohesion: 0.47
Nodes (5): add_related_block(), main(), process_extracted(), Path, Add cross-link metadata to all memory/ Markdown files.

### Community 119 - "auth_interceptor.dart"
Cohesion: 0.40
Nodes (4): AuthInterceptor, onError, onRequest, QueuedInterceptor

### Community 120 - "login_request.dart"
Cohesion: 0.40
Nodes (4): email, LoginRequest, password, toJson

### Community 121 - "update_user_status_request.dart"
Cohesion: 0.50
Nodes (3): accountStatus, toJson, UpdateUserStatusRequest

### Community 148 - "Browser Testing with DevTools"
Cohesion: 0.08
Nodes (24): Accessibility Verification with DevTools, Available Tools, Browser Testing with DevTools, Clean Console Standard, Common Rationalizations, Console Analysis Patterns, Content Boundary Markers, For Network Issues (+16 more)

### Community 149 - "What You Must Do When Invoked"
Cohesion: 0.08
Nodes (24): For /graphify add and --watch, For /graphify query, For the commit hook and native CLAUDE.md integration, For --update and --cluster-only, /graphify, Honesty Rules, Interpreter guard for subcommands, Part A - Structural extraction for code files (+16 more)

### Community 150 - "Performance Optimization"
Cohesion: 0.08
Nodes (24): Common Rationalizations, Connection Pool Exhaustion, Core Web Vitals Targets, Large Bundle Size, Log every attempt, including the reverted ones, Missing Caching (Backend), Missing Image Optimization (Frontend), N+1 Queries (Backend) (+16 more)

### Community 151 - "CI/CD and Automation"
Cohesion: 0.08
Nodes (23): Automation Beyond CI, Basic CI Pipeline, Build Cop Role, CI/CD and Automation, CI Optimization, Common Rationalizations, Dependabot / Renovate, Deployment Strategies (+15 more)

### Community 152 - "Constraint-Driven Development"
Cohesion: 0.08
Nodes (22): Adapting it, Contract, Floor guard: reference implementation, Reference (Node, ~stack-agnostic patterns), Common Rationalizations, Constraint-Driven Development, Escalation Path, Loading Constraints (+14 more)

### Community 153 - "Deprecation and Migration"
Cohesion: 0.08
Nodes (23): Adapter Pattern, Code Is a Liability, Common Rationalizations, Compulsory vs Advisory Deprecation, Core Principles, Database Schema Migrations (Expand/Contract), Deprecation and Migration, Deprecation Planning Starts at Design Time (+15 more)

### Community 154 - "Frontend UI Engineering"
Cohesion: 0.08
Nodes (23): Accessibility (WCAG 2.1 AA), ARIA Labels, Avoid the AI Aesthetic, Color, Common Rationalizations, Component Architecture, Component Patterns, Design System Adherence (+15 more)

### Community 155 - "Incremental Implementation"
Cohesion: 0.09
Nodes (22): Common Rationalizations, Contract-First Slicing, Implementation Rules, Increment Checklist, Incremental Implementation, Overview, Red Flags, Risk-First Slicing (+14 more)

### Community 156 - "Code Simplification"
Cohesion: 0.09
Nodes (21): 1. Preserve Behavior Exactly, 2. Follow Project Conventions, 3. Prefer Clarity Over Cleverness, 4. Maintain Balance, 5. Scope to What Changed, Code Simplification, Common Rationalizations, Language-Specific Guidance (+13 more)

### Community 157 - "Debugging and Error Recovery"
Cohesion: 0.09
Nodes (21): Build Failure Triage, Common Rationalizations, Debugging and Error Recovery, Error-Specific Patterns, Instrumentation Guidelines, Overview, Red Flags, Runtime Error Triage (+13 more)

### Community 158 - "Documentation and ADRs"
Cohesion: 0.09
Nodes (21): ADR Lifecycle, ADR Template, API Documentation, Architecture Decision Records (ADRs), Changelog Maintenance, Common Rationalizations, Document Known Gotchas, Documentation and ADRs (+13 more)

### Community 159 - "Planning and Task Breakdown"
Cohesion: 0.11
Nodes (18): Common Rationalizations, Output Files, Overview, Parallelization Opportunities, Plan Document Template, Planning and Task Breakdown, Red Flags, See Also (+10 more)

### Community 160 - "ReOrder: Keep Your Regulars Ordering Direct"
Cohesion: 0.11
Nodes (17): Example 1: Vague Early-Stage Concept (Full 3-Phase Session), Example 2: Feature Idea Within an Existing Product (Codebase-Aware), Example 3: Process/Workflow Idea (Non-Product), Ideation Session Examples, Key Assumptions to Validate, MVP Scope, Not Doing (and Why), Open Questions (+9 more)

### Community 161 - "Interview Me"
Cohesion: 0.11
Nodes (17): Common Rationalizations, Example, Interaction with Other Skills, Interview Me, Loading Constraints, Output, Overview, Red Flags (+9 more)

### Community 162 - "Doubt-Driven Development"
Cohesion: 0.12
Nodes (15): Common Rationalizations, Cross-model escalation, Doubt-Driven Development, Interaction with Other Skills, Loading Constraints, Overview, Red Flags, Step 1: CLAIM — Surface what stands (+7 more)

### Community 163 - "Process"
Cohesion: 0.12
Nodes (15): 1. Define "working" before instrumenting, 2. Pick the right signal for each question, 3. Structured logging, 4. Metrics, 5. Distributed tracing, 6. Alerting, 7. Verify the telemetry itself, Common Rationalizations (+7 more)

### Community 164 - "Idea Refine"
Cohesion: 0.13
Nodes (14): Anti-patterns to Avoid, Detailed Instructions, How It Works, Idea Refine, Output, Phase 1: Understand & Expand (Divergent), Phase 2: Evaluate & Converge, Phase 3: Sharpen & Ship (+6 more)

### Community 165 - "Using Agent Skills"
Cohesion: 0.13
Nodes (14): 1. Surface Assumptions, 2. Manage Confusion Actively, 3. Push Back When Warranted, 4. Enforce Simplicity, 5. Maintain Scope Discipline, 6. Verify, Don't Assume, Core Operating Behaviors, Failure Modes to Avoid (+6 more)

### Community 166 - "Spec-Driven Development"
Cohesion: 0.14
Nodes (13): Common Rationalizations, Keeping the Spec Alive, Overview, Phase 0: Scope Check, Phase 1: Specify, Phase 2: Plan, Phase 3: Tasks, Phase 4: Implement (+5 more)

### Community 167 - "Source-Driven Development"
Cohesion: 0.15
Nodes (12): Common Rationalizations, Overview, Red Flags, Retrieval Safety: Treat Fetched Content as Data, Source-Driven Development, Step 1: Detect Stack and Versions, Step 2: Fetch Official Documentation, Step 3: Implement Following Documented Patterns (+4 more)

### Community 168 - "auth_state.dart"
Cohesion: 0.17
Nodes (11): ../data/models/login_response.dart, ../data/models/user_model.dart, AuthState, copyWith, defaultSector, error, isAuthenticated, isLoading (+3 more)

### Community 169 - "financial_summary.dart"
Cohesion: 0.17
Nodes (11): double?, _asDouble, FinancialSummary, fromJson, isCrossSector, netBalance, payrollExpenses, sectorId (+3 more)

### Community 170 - "Refinement & Evaluation Criteria"
Cohesion: 0.17
Nodes (11): 1. User Value, 2. Feasibility, 3. Differentiation, Assumption Audit, Core Evaluation Dimensions, Decision Framework, Might Be True (Nice to Have), Must Be True (Dealbreakers) (+3 more)

### Community 171 - "TestCase"
Cohesion: 0.27
Nodes (3): DatabaseTlsConfigurationTest, TestCase, Illuminate\Foundation\Testing\TestCase

### Community 172 - "theme_controller_test.dart"
Cohesion: 0.18
Nodes (10): ThemeModeStore, failLoad, failSave, _FakeThemeModeStore, load, main, save, stored (+2 more)

### Community 173 - "graphify reference: extra exports and benchmark"
Cohesion: 0.22
Nodes (8): graphify reference: extra exports and benchmark, Step 6b - Wiki (only if --wiki flag), Step 7 - Neo4j export (only if --neo4j or --neo4j-push flag), Step 7a - FalkorDB export (only if --falkordb or --falkordb-push flag), Step 7b - SVG export (only if --svg flag), Step 7c - GraphML export (only if --graphml flag), Step 7d - MCP server (only if --mcp flag), Step 8 - Token reduction benchmark (only if total_words > 5000)

### Community 174 - "Ideation Frameworks Reference"
Cohesion: 0.22
Nodes (8): Analogous Inspiration, Constraint-Based Ideation, First Principles Thinking, How Might We (HMW), Ideation Frameworks Reference, Jobs to Be Done (JTBD), Pre-mortem, SCAMPER

### Community 175 - "users_state.dart"
Cohesion: 0.18
Nodes (10): ../../data/models/user_account.dart, copyWith, error, isLoading, isSubmitting, lastTemporaryPassword, successMessage, _unset (+2 more)

### Community 176 - "State"
Cohesion: 0.18
Nodes (14): App, App, _AppState, ForgotPasswordScreen, _ForgotPasswordScreenState, LoginScreen, _LoginScreenState, ResetPasswordScreen (+6 more)

### Community 177 - "graphify reference: query, path, explain"
Cohesion: 0.33
Nodes (5): For /graphify explain, For /graphify path, graphify reference: query, path, explain, Step 0 — Constrained query expansion (REQUIRED before traversal), Step 1 — Traversal

### Community 178 - "DYS FMS Agent Context"
Cohesion: 0.40
Nodes (4): Agent Skills, Authority And Scope, DYS FMS Agent Context, graphify

### Community 179 - "app_theme.dart"
Cohesion: 0.20
Nodes (8): ../constants/app_radius.dart, ../constants/app_typography.dart, AppTheme, build, build, SectionLabel, text, package:flutter/services.dart

### Community 180 - "app_providers.dart"
Cohesion: 0.20
Nodes (9): core/theme/theme_controller.dart, features/dashboard/presentation/providers/dashboard_provider.dart, features/expenses/presentation/providers/expenses_provider.dart, features/payroll/presentation/providers/payroll_provider.dart, features/reports/presentation/providers/reports_provider.dart, features/sales/presentation/providers/sales_provider.dart, features/sectors/presentation/providers/sectors_provider.dart, features/users/presentation/providers/users_provider.dart (+1 more)

### Community 181 - "payroll_state.dart"
Cohesion: 0.20
Nodes (9): ../data/models/payroll_record.dart, copyWith, error, isLoading, isSubmitting, PayrollState, records, successMessage (+1 more)

### Community 182 - "graphify reference: add a URL and watch a folder"
Cohesion: 0.50
Nodes (3): For /graphify add, For --watch, graphify reference: add a URL and watch a folder

### Community 183 - "graphify reference: commit hook and native CLAUDE.md integration"
Cohesion: 0.50
Nodes (3): For git commit hook, For native CLAUDE.md integration, graphify reference: commit hook and native CLAUDE.md integration

### Community 184 - "graphify reference: incremental update and cluster-only"
Cohesion: 0.50
Nodes (3): For --cluster-only, For --update (incremental re-extraction), graphify reference: incremental update and cluster-only

### Community 189 - "app_info.dart"
Cohesion: 0.40
Nodes (4): AppInfo, appName, appVersion, static const String

### Community 190 - "dashboard_repository.dart"
Cohesion: 0.40
Nodes (4): getRecentTransactions, getSummary, ../models/financial_summary.dart, ../models/recent_transaction.dart

### Community 191 - "payroll_repository.dart"
Cohesion: 0.40
Nodes (4): calculatePayroll, getPayroll, ../models/payroll_record.dart, ../models/save_payroll_request.dart

### Community 192 - "DYS Financial Management System (DYS FMS) — Current Project Baseline"
Cohesion: 0.20
Nodes (10): Authentication and Deployment, Current Functional State, Current Role Access (Implementation Snapshot), Current Test and Release Status, Data Model, Documentation Authority, DYS Financial Management System (DYS FMS) — Current Project Baseline, Identity and Scope (+2 more)

### Community 193 - "login_response.dart"
Cohesion: 0.22
Nodes (8): DefaultSector, fromJson, id, name, token, user, UserModel, user_model.dart

### Community 194 - "SalesProvider"
Cohesion: 0.25
Nodes (8): SalesProvider, _cancelEdit, _confirmDelete, _loadSales, onSectorChanged, SalesScreen, _SalesScreenState, _startEdit

### Community 195 - "save_expense_request.dart"
Cohesion: 0.29
Nodes (6): amount, description, recordedAt, SaveExpenseRequest, sectorId, toJson

### Community 196 - "DYS FMS Documentation Index and Authority Map"
Cohesion: 0.29
Nodes (7): Academic UML and Case Study Material, Active Current References, Authority Order, Current Implementation Deltas to Remember, DYS FMS Documentation Index and Authority Map, Frozen or Historical Design References, Generated and Non-Authoritative Material

### Community 200 - "Final Design Authority"
Cohesion: 0.33
Nodes (6): Agent Procedure, Current Context-Only Phase, Final Design Authority, Historical Material, Source Priority, Status

### Community 201 - "../constants/app_colors.dart"
Cohesion: 0.40
Nodes (4): ../constants/app_colors.dart, AppAvatar, build, initials

### Community 202 - "app_error_container.dart"
Cohesion: 0.40
Nodes (4): AppErrorContainer, build, centered, message

### Community 203 - "app_success_container.dart"
Cohesion: 0.40
Nodes (4): AppSuccessContainer, build, message, temporaryPassword

### Community 204 - "DYS FMS Documentation Library"
Cohesion: 0.40
Nodes (5): DYS FMS Documentation Library, Important Distinction, Refreshing Raw Extractions, Start Here, Structure

### Community 205 - "DYS Financial Management System (DYS FMS)"
Cohesion: 0.50
Nodes (4): Current Status, DYS Financial Management System (DYS FMS), Repository Map, Start Here

## Knowledge Gaps
- **1761 isolated node(s):** `A. System Architecture / System Framework`, `B. Technology Stack with Discussion`, `1. Software Requirements`, `2. Backend / Server Requirements`, `3. Database Requirements` (+1756 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 2154 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **27 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `User` connect `User` to `Illuminate\Foundation\Testing\RefreshDatabase`, `Illuminate\Database\Eloquent\Relations\BelongsTo`, `Illuminate\Http\Request`, `Illuminate\Http\JsonResponse`, `StorePayrollRequest`, `ExpensesController`, `UserManagementTest`, `PayrollManagementTest`, `TestCase`, `ExpenseManagementTest`, `AuthenticationTest`, `SalesManagementTest`, `ExpenseService`, `ReportsManagementTest`, `ReportsService`, `BusinessSectorManagementTest`, `TemporaryPasswordMail`, `BusinessSector`, `Illuminate\Foundation\Http\FormRequest`?**
  _High betweenness centrality (0.106) - this node is a cross-community bridge._
- **Why does `BusinessSector` connect `BusinessSector` to `User`, `Illuminate\Foundation\Testing\RefreshDatabase`, `TestCase`, `BusinessSectorManagementTest`, `Illuminate\Database\Eloquent\Relations\BelongsTo`, `AuthenticationTest`, `SalesManagementTest`, `Illuminate\Http\Request`, `BusinessSectorController`?**
  _High betweenness centrality (0.092) - this node is a cross-community bridge._
- **Why does `SalesTransaction` connect `User` to `Illuminate\Database\Eloquent\Relations\BelongsTo`, `SalesManagementTest`?**
  _High betweenness centrality (0.044) - this node is a cross-community bridge._
- **What connects `A. System Architecture / System Framework`, `B. Technology Stack with Discussion`, `1. Software Requirements` to the rest of the system?**
  _1761 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `package:flutter/material.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0496156533892383 - nodes in this community are weakly interconnected._
- **Should `reset_password_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.04900181488203267 - nodes in this community are weakly interconnected._
- **Should `app_colors.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.047619047619047616 - nodes in this community are weakly interconnected._