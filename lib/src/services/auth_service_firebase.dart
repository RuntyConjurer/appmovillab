import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:login_1/src/repositories/auth_repository.dart';

class AuthServiceFirebase implements AuthRepository {
  // Instancias de Firebase para acceder a sus métodos.
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<String> login(
      {required String email, required String password}) async {
    String res = 'Ocurrió un error. Inténtelo nuevamente';
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Success';
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') {
        res = 'El usuario no existe';
      } else if (error.code == 'wrong-password' ||
          error.code == 'invalid-credential') {
        res = 'Correo o contraseña incorrectos';
      } else if (error.code == 'invalid-email') {
        res = 'El correo no es válido';
      } else if (error.code == 'user-disabled') {
        res = 'Esta cuenta está deshabilitada';
      } else if (error.code == 'too-many-requests') {
        res = 'Demasiados intentos. Espere un momento';
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint(error.toString());
      }
    }
    return res;
  }

  @override
  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    String res = 'Ocurrió un error. Inténtelo nuevamente';
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return res;
      }

      await user.updateDisplayName(name);
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'email': email,
        'phone': '',
        'creationDate': FieldValue.serverTimestamp(),
      });
      res = 'Success';
    } on FirebaseAuthException catch (error) {
      if (error.code == 'weak-password') {
        res = 'La contraseña es demasiado débil';
      } else if (error.code == 'email-already-in-use') {
        res = 'Ya existe una cuenta con este correo';
      } else if (error.code == 'invalid-email') {
        res = 'El correo no es válido';
      } else if (error.code == 'operation-not-allowed') {
        res = 'El registro por correo no está habilitado en Firebase';
      } else if (error.code == 'network-request-failed') {
        res = 'No se pudo conectar con Firebase';
      }
    } on FirebaseException catch (error) {
      res = 'No se pudo guardar el perfil: ${error.message ?? error.code}';
    } catch (error) {
      if (kDebugMode) {
        debugPrint(error.toString());
      }
    }
    return res;
  }
}
