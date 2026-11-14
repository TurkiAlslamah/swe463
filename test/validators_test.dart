import 'package:flutter_test/flutter_test.dart';
import 'package:laqait/utils/validators.dart';

void main() {
  group('Validators.kfupmEmail', () {
    test('rejects an empty email', () {
      expect(Validators.kfupmEmail(''), 'Enter your email');
      expect(Validators.kfupmEmail(null), 'Enter your email');
    });

    test('rejects emails from other domains', () {
      expect(Validators.kfupmEmail('omar@gmail.com'),
          'Use your @kfupm.edu.sa email');
      expect(Validators.kfupmEmail('@kfupm.edu.sa'),
          'Use your @kfupm.edu.sa email');
    });

    test('accepts a KFUPM email (any case, extra spaces)', () {
      expect(Validators.kfupmEmail('s202172030@kfupm.edu.sa'), isNull);
      expect(Validators.kfupmEmail('  Omar@KFUPM.edu.sa '), isNull);
    });
  });

  group('Password validators', () {
    test('sign in only needs a password', () {
      expect(Validators.password(''), 'Enter your password');
      expect(Validators.password('x'), isNull);
    });

    test('sign up needs at least 6 characters', () {
      expect(Validators.newPassword(''), 'Enter a password');
      expect(Validators.newPassword('12345'), 'Use at least 6 characters');
      expect(Validators.newPassword('123456'), isNull);
    });

    test('confirm password must match', () {
      expect(Validators.confirmPassword('', 'abcdef'), 'Repeat your password');
      expect(Validators.confirmPassword('abcdeg', 'abcdef'),
          'Passwords do not match');
      expect(Validators.confirmPassword('abcdef', 'abcdef'), isNull);
    });
  });

  group('Validators.name', () {
    test('needs at least 2 letters', () {
      expect(Validators.name('  '), 'Enter your name');
      expect(Validators.name('A'), 'Name is too short');
      expect(Validators.name('Naif'), isNull);
    });
  });
}
