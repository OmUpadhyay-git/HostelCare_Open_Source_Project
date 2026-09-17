import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/student/dashboard/student_home_screen.dart';
import '../../features/warden/dashboard/warden_home_screen.dart';
import '../../features/staff/dashboard/staff_home_screen.dart';
import '../../features/admin/dashboard/admin_home_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/auth/login',
    routes: [
      // Auth routes
      GoRoute(
        path: '/auth',
        builder: (context, state) => const _PlaceholderScreen(title: 'Auth'),
        routes: [
          GoRoute(
            path: 'login',
            builder: (context, state) => const _PlaceholderScreen(title: 'Login'),
          ),
        ],
      ),

      // Student routes
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentHomeScreen(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (context, state) => const StudentHomeScreen(),
          ),
          GoRoute(
            path: 'complaints',
            builder: (context, state) => const _PlaceholderScreen(title: 'My Complaints'),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const _PlaceholderScreen(title: 'Notifications'),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const _PlaceholderScreen(title: 'Profile'),
          ),
        ],
      ),

      // Warden routes
      GoRoute(
        path: '/warden',
        builder: (context, state) => const WardenHomeScreen(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (context, state) => const WardenHomeScreen(),
          ),
          GoRoute(
            path: 'complaints',
            builder: (context, state) => const _PlaceholderScreen(title: 'Complaint Queue'),
          ),
          GoRoute(
            path: 'students',
            builder: (context, state) => const _PlaceholderScreen(title: 'Students'),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const _PlaceholderScreen(title: 'Notifications'),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const _PlaceholderScreen(title: 'Profile'),
          ),
        ],
      ),

      // Staff routes
      GoRoute(
        path: '/staff',
        builder: (context, state) => const StaffHomeScreen(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (context, state) => const StaffHomeScreen(),
          ),
          GoRoute(
            path: 'assignments',
            builder: (context, state) => const _PlaceholderScreen(title: 'My Assignments'),
          ),
          GoRoute(
            path: 'complaints',
            builder: (context, state) => const _PlaceholderScreen(title: 'Complaint Details'),
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const _PlaceholderScreen(title: 'Notifications'),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const _PlaceholderScreen(title: 'Profile'),
          ),
        ],
      ),

      // Admin routes
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminHomeScreen(),
        routes: [
          GoRoute(
            path: 'dashboard',
            builder: (context, state) => const AdminHomeScreen(),
          ),
          GoRoute(
            path: 'students',
            builder: (context, state) => const _PlaceholderScreen(title: 'Manage Students'),
          ),
          GoRoute(
            path: 'wardens',
            builder: (context, state) => const _PlaceholderScreen(title: 'Manage Wardens'),
          ),
          GoRoute(
            path: 'staff',
            builder: (context, state) => const _PlaceholderScreen(title: 'Manage Staff'),
          ),
          GoRoute(
            path: 'hostels',
            builder: (context, state) => const _PlaceholderScreen(title: 'Manage Hostels'),
          ),
          GoRoute(
            path: 'blocks',
            builder: (context, state) => const _PlaceholderScreen(title: 'Manage Blocks'),
          ),
          GoRoute(
            path: 'rooms',
            builder: (context, state) => const _PlaceholderScreen(title: 'Manage Rooms'),
          ),
          GoRoute(
            path: 'categories',
            builder: (context, state) => const _PlaceholderScreen(title: 'Manage Categories'),
          ),
          GoRoute(
            path: 'complaints',
            builder: (context, state) => const _PlaceholderScreen(title: 'All Complaints'),
          ),
          GoRoute(
            path: 'reports',
            builder: (context, state) => const _PlaceholderScreen(title: 'Reports'),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const _PlaceholderScreen(title: 'Settings'),
          ),
        ],
      ),
    ],
  );
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming in a future phase',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
