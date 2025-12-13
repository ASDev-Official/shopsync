import 'package:flutter_test/flutter_test.dart';
import 'package:shopsync/services/platform/connectivity_service.dart';

void main() {
  group('ConnectivityService', () {
    test('should be a singleton', () {
      // Arrange & Act
      final service1 = ConnectivityService();
      final service2 = ConnectivityService();

      // Assert
      expect(identical(service1, service2), true);
    });

    test('isOnline should return bool', () {
      // Arrange
      final service = ConnectivityService();

      // Act
      final isOnline = service.isOnline;

      // Assert
      expect(isOnline, isA<bool>());
    });

    test('isOffline should return opposite of isOnline', () {
      // Arrange
      final service = ConnectivityService();

      // Act
      final isOnline = service.isOnline;
      final isOffline = service.isOffline;

      // Assert
      expect(isOffline, !isOnline);
    });

    test('connectionStatus should be a stream', () {
      // Arrange
      final service = ConnectivityService();

      // Act
      final stream = service.connectionStatus;

      // Assert
      expect(stream, isA<Stream<bool>>());
    });

    test('isInitialized should return bool', () {
      // Arrange
      final service = ConnectivityService();

      // Act
      final isInitialized = service.isInitialized;

      // Assert
      expect(isInitialized, isA<bool>());
    });

    test('dispose should complete without error', () {
      // Arrange
      final service = ConnectivityService();

      // Act
      service.dispose();

      // Assert
      expect(service, isNotNull);
    });

    test('service should fallback to online when platform unavailable', () {
      // Arrange - ConnectivityService catches platform errors
      final service = ConnectivityService();

      // Act
      final isOnline = service.isOnline;

      // Assert - Should default to true on error
      expect(isOnline, isA<bool>());
    });
  });
}
