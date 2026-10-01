import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login_1/main.dart';
import 'package:login_1/src/repositories/auth_repository.dart';
import 'package:login_1/src/screens/views/auth/login_screen.dart';

class FakeAuthRepository implements AuthRepository {
  int loginCalls = 0;
  int registerCalls = 0;

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    return 'Success';
  }

  @override
  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    registerCalls++;
    return 'Success';
  }
}

void main() {
  testWidgets('Login screen displays and toggles the password', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Intec App'), findsOneWidget);
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('User Email'), findsOneWidget);
    expect(find.text('User Password'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);

    EditableText passwordField = tester.widget<EditableText>(
      find.byType(EditableText).at(1),
    );
    expect(passwordField.obscureText, isTrue);

    await tester.tap(find.byIcon(Icons.remove_red_eye));
    await tester.pump();

    passwordField = tester.widget<EditableText>(
      find.byType(EditableText).at(1),
    );
    expect(passwordField.obscureText, isFalse);
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });

  testWidgets('Registration validates every field before submitting', (
    WidgetTester tester,
  ) async {
    final auth = FakeAuthRepository();
    await tester.pumpWidget(
      MaterialApp(home: LoginScreen(authService: auth)),
    );

    await tester.tap(find.text('Register Here'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('REGISTER'));
    await tester.pump();

    expect(find.text('El nombre es requerido'), findsOneWidget);
    expect(find.text('El correo es requerido'), findsOneWidget);
    expect(find.text('La contraseña es requerida'), findsOneWidget);
    expect(find.text('Debe confirmar la contraseña'), findsOneWidget);
    expect(auth.registerCalls, 0);
  });

  testWidgets('A valid registration returns to login', (
    WidgetTester tester,
  ) async {
    final auth = FakeAuthRepository();
    await tester.pumpWidget(
      MaterialApp(home: LoginScreen(authService: auth)),
    );

    await tester.tap(find.text('Register Here'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Axell Feliz');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'axell@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.enterText(find.byType(TextFormField).at(3), 'password123');
    await tester.tap(find.text('REGISTER'));
    await tester.pumpAndSettle();

    expect(auth.registerCalls, 1);
    expect(find.text('Welcome Back!'), findsOneWidget);
  });

  testWidgets('A valid login opens the main screen', (
    WidgetTester tester,
  ) async {
    final auth = FakeAuthRepository();
    await tester.pumpWidget(
      MaterialApp(home: LoginScreen(authService: auth)),
    );

    await tester.enterText(
        find.byType(TextFormField).at(0), 'axell@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();

    expect(auth.loginCalls, 1);
    expect(find.text('Welcome!'), findsOneWidget);
  });
}
