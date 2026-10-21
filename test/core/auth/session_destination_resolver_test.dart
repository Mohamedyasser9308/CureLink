import 'package:flutter_test/flutter_test.dart';
import 'package:curelink/core/auth/session_destination_resolver.dart';

void main() {
  group('SessionDestinationResolver', () {
    test('Unauthenticated user goes to login', () {
      final result = SessionDestinationResolver.resolve(isLoggedIn: false);

      expect(result, SessionDestination.login);
    });

    test('Incomplete profile goes to profile completion', () {
      final result = SessionDestinationResolver.resolve(
        isLoggedIn: true,
        profile: {'profileCompleted': false, 'role': 'Patient'},
      );

      expect(result, SessionDestination.completeProfile);
    });

    test('Patient goes to Patient Home', () {
      final result = SessionDestinationResolver.resolve(
        isLoggedIn: true,
        profile: {'profileCompleted': true, 'role': 'Patient'},
      );

      expect(result, SessionDestination.patientHome);
    });

    test('Caregiver goes to Caregiver Home', () {
      final result = SessionDestinationResolver.resolve(
        isLoggedIn: true,
        profile: {'profileCompleted': true, 'role': 'Caregiver'},
      );

      expect(result, SessionDestination.caregiverHome);
    });

    test('Both starts in Patient Mode', () {
      final result = SessionDestinationResolver.resolve(
        isLoggedIn: true,
        profile: {'profileCompleted': true, 'role': 'Both'},
      );

      expect(result, SessionDestination.patientHome);
    });

    test('Unknown role returns invalidProfile', () {
      final result = SessionDestinationResolver.resolve(
        isLoggedIn: true,
        profile: {'profileCompleted': true, 'role': 'Unknown'},
      );

      expect(result, SessionDestination.invalidProfile);
    });

    test('Missing profile returns invalidProfile', () {
      final result = SessionDestinationResolver.resolve(isLoggedIn: true);

      expect(result, SessionDestination.invalidProfile);
    });
  });
}
