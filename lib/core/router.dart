import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/auth/auth_repository.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/patients/patients_list_screen.dart';
import '../features/patients/patient_form_screen.dart';
import '../features/patients/patient_detail_screen.dart';
import '../features/appointments/appointments_screen.dart';
import '../features/appointments/appointment_form_screen.dart';
import '../features/treatments/treatment_form_screen.dart';
import '../features/payments/payment_form_screen.dart';
import '../features/prescriptions/prescription_form_screen.dart';
import '../features/settings/settings_screen.dart';
import 'app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthRepository authRepo) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: authRepo.isLoggedIn ? '/' : '/login',
    refreshListenable: authRepo,
    redirect: (context, state) {
      final loggedIn = authRepo.isLoggedIn;
      final loggingIn = state.matchedLocation == '/login';
      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/patients',
            builder: (context, state) => const PatientsListScreen(),
          ),
          GoRoute(
            path: '/appointments',
            builder: (context, state) => const AppointmentsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      // Full-screen routes (outside shell / bottom nav)
      GoRoute(
        path: '/patients/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PatientFormScreen(),
      ),
      GoRoute(
        path: '/patients/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PatientDetailScreen(patientId: id);
        },
      ),
      GoRoute(
        path: '/patients/:id/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PatientFormScreen(patientId: id);
        },
      ),
      GoRoute(
        path: '/appointments/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final patientId = state.uri.queryParameters['patientId'];
          return AppointmentFormScreen(
            preselectedPatientId:
                patientId != null ? int.parse(patientId) : null,
          );
        },
      ),
      GoRoute(
        path: '/patients/:id/treatments/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final tooth = state.uri.queryParameters['tooth'];
          return TreatmentFormScreen(
            patientId: id,
            initialToothNumber: tooth,
          );
        },
      ),
      GoRoute(
        path: '/patients/:id/payments/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PaymentFormScreen(patientId: id);
        },
      ),
      GoRoute(
        path: '/patients/:id/prescriptions/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return PrescriptionFormScreen(patientId: id);
        },
      ),
    ],
  );
}
