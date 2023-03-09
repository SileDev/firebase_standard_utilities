import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SessionUtilities with ChangeNotifier {
  //Instancia para inicio de sesión con google
  final googleSignIn =
      GoogleSignIn(); //Inicializar instancia para hacer login con google

  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  //Instancia de FirebaseAuth para la sesión
  final FirebaseAuth _sessionInstance = FirebaseAuth.instance;

  //Variable que indica si hay una sesión
  bool _hasSession = false;

  //
  bool _hasInvalidRouteDispatched = false;

  //Escuchar si hay una sesión
  listenSession({
    required Function onValidSession,
    required Function onInvalidSession,
  }) {
    try {
      //*
      debugPrint("SessionUtilities: Se está escuchando la sesión");
      //Se intenta iniciar el Stream
      _sessionInstance.authStateChanges().listen((event) async {
        //Validar que haya una sesión
        if (event != null) {
          //
          if (!_hasSession) {
            //*
            debugPrint("SessionUtilities: Se inició sesión");

            //*
            debugPrint(
                "SessionUtilities: Se requiere navegar a la ruta definida");

            //
            _hasSession = true;

            //
            _hasInvalidRouteDispatched = true;

            //Ejecutae la acción definida para ser llamada en caso de tener una
            //sesión inválida
            onValidSession.call();

            //
            _hasInvalidRouteDispatched = true;

            //
            // _getSessionUser(fetchAndSetUserData: fetchAndSetUserData); //dentro del onvalidsession
          }
        } else {
          //

          //
          if (_hasSession) {
            //*
            debugPrint("SessionUtilities: Se cerró la sesión");

            //
            _hasSession = false;

            //Se limpia la data de todos los controllers
            /*Provider.of<UserUtilities>(Get.context!, listen: false)
                .clearUser();*/

            //*
            debugPrint("SessionUtilities: Se requiere navegar a Sign");

            //Ejecutae la acción definida para ser llamada en caso de tener una
            //sesión inválida
            onInvalidSession.call();

            //
            _hasInvalidRouteDispatched = true;
          } else {
            //1?
            if (!_hasInvalidRouteDispatched) {
              //*
              debugPrint("SessionUtilities: No se encontró una sesión activa");

              //*
              debugPrint("SessionUtilities: Se requiere navegar a Sign");

              //Ejecutae la acción definida para ser llamada en caso de tener una
              //sesión inválida
              onInvalidSession.call();

              //
              _hasInvalidRouteDispatched = true;
            }
          }
        }
      });
    } on FirebaseAuthException catch (e) {
      //*
      debugPrint("SessionUtilities: $e");
      /*Validar errores*/

      //Reintentar todo
      //rethrow;
    } catch (e) {
      //*
      debugPrint("SessionUtilities: $e");
      /*Validar errores*/
    }
  }

  //Registrar usuario con correo y contraseña
  registerUserWithEmailAndPassword(
      {required String email,
      required String password,
      required Map<String, dynamic> userData,
      Function? onRegisterCompleted}) {
    //
    _sessionInstance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then(
      (value) {
        onRegisterCompleted
            ?.call(value); // equivalente a esto onRegisterCompleted??(){}
      },
    );
  }

  //Iniciar sesión con correo y contraseña
  initSessionWithEmailAndPassword({
    required String email,
    required String password,
    String? destinationRouteName,
  }) async {
    //Se ejecuta un bloque que puede tener respuestas de error}
    try {
      //Se intenta ejecutar la petición de inicio de sesión
      await _sessionInstance.signInWithEmailAndPassword(
        email: email,
        password: password,
      ); //aquí, colocaríamos el .then,en caso de validación externa

      //
    } on FirebaseAuthException catch (e) {
      //*
      debugPrint(e.toString());
      /*Validar errores*/
    } catch (e) {
      //*
      debugPrint(e.toString());
      /*Validar errores*/
    }
  }

  //Cerrar sesión
  closeSession() async {
    //Se ejecuta un bloque que puede tener respuestas de error
    try {
      //Se intenta ejecutar la petición de cierre de sesión
      await _sessionInstance.signOut();

      //*Esto notifica a listenSession() y se ejecutan las acciones pertinentes
      //*dentro del método

    } on FirebaseAuthException catch (e) {
      //*
      debugPrint(e.toString());
      /*Validar errores*/
    } catch (e) {
      //*
      debugPrint(e.toString());
      /*Validar errores*/
    }
  }

  initSessionWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _user = googleUser;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken); //aquí se enlaza con firebase (?)

      await _sessionInstance.signInWithCredential(credential);
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
