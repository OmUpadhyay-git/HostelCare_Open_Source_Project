import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hostelcare/app/hostelcare_app.dart';
import 'package:hostelcare/shared/components/components.dart';
import 'package:hostelcare/shared/widgets/widgets.dart';
import 'package:hostelcare/core/constants/complaint_status.dart';
import 'package:hostelcare/core/constants/complaint_priority.dart';

void main() {
  group('AppButton', () {
    testWidgets('renders primary button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.primary(
              label: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('renders disabled button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.primary(
              label: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.primary(
              label: 'Loading',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders destructive button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.destructive(
              label: 'Delete',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Delete'), findsOneWidget);
    });
  });

  group('StatusBadge', () {
    testWidgets('renders status label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              label: 'PENDING',
              color: Colors.amber,
            ),
          ),
        ),
      );

      expect(find.text('PENDING'), findsOneWidget);
    });

    testWidgets('renders ComplaintStatusBadge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComplaintStatusBadge(
              status: ComplaintStatus.inProgress,
            ),
          ),
        ),
      );

      expect(find.text('IN PROGRESS'), findsOneWidget);
    });

    testWidgets('renders PriorityBadge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PriorityBadge(
              priority: ComplaintPriority.urgent,
            ),
          ),
        ),
      );

      expect(find.text('URGENT'), findsOneWidget);
    });
  });

  group('ComplaintCard', () {
    testWidgets('renders complaint information', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComplaintCard(
              complaintNumber: 'HC-2026-00124',
              title: 'Bathroom water leakage',
              category: 'Plumbing',
              priority: ComplaintPriority.high,
              status: ComplaintStatus.inProgress,
              createdAt: DateTime.now(),
            ),
          ),
        ),
      );

      expect(find.text('HC-2026-00124'), findsOneWidget);
      expect(find.text('Bathroom water leakage'), findsOneWidget);
      expect(find.text('Plumbing'), findsOneWidget);
      expect(find.text('HIGH'), findsOneWidget);
      expect(find.text('IN PROGRESS'), findsOneWidget);
    });
  });

  group('EmptyState', () {
    testWidgets('renders empty state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'No Complaints',
              message: 'You haven\'t raised any complaints yet.',
              actionLabel: 'Raise Complaint',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.text('No Complaints'), findsOneWidget);
      expect(find.text('You haven\'t raised any complaints yet.'), findsOneWidget);
      expect(find.text('Raise Complaint'), findsOneWidget);
    });
  });

  group('ErrorState', () {
    testWidgets('renders error state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorState(
              message: 'Something went wrong',
              actionLabel: 'Try Again',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });

  group('LoadingIndicator', () {
    testWidgets('renders loading indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders loading indicator with message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(message: 'Loading...'),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
    });
  });

  group('Timeline', () {
    testWidgets('renders timeline events', (tester) async {
      final events = [
        TimelineEvent(
          actionType: TimelineActionType.created,
          performerName: 'John Doe',
          performerRole: 'Student',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        TimelineEvent(
          actionType: TimelineActionType.accepted,
          performerName: 'Jane Smith',
          performerRole: 'Warden',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Timeline(events: events),
          ),
        ),
      );

      expect(find.text('Complaint Created'), findsOneWidget);
      expect(find.text('Complaint Accepted'), findsOneWidget);
    });
  });

  group('SectionHeader', () {
    testWidgets('renders section header', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SectionHeader(
              title: 'Recent Complaints',
              subtitle: 'Last 7 days',
            ),
          ),
        ),
      );

      expect(find.text('Recent Complaints'), findsOneWidget);
      expect(find.text('Last 7 days'), findsOneWidget);
    });
  });

  group('App', () {
    testWidgets('renders app with theme', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: HostelCareApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
