import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SessionUtilities with ChangeNotifier {
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
      debugPrint("SessionController: Se está escuchando la sesión");
      //Se intenta iniciar el Stream
      _sessionInstance.authStateChanges().listen((event) async {
        //Validar que haya una sesión
        if (event != null) {
          //
          if (!_hasSession) {
            //*
            debugPrint("SessionController: Se inició sesión");

            //*
            debugPrint(
                "SessionController: Se requiere navegar a la ruta definida");

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
            _getSessionUser();
          }
        } else {
          //

          //
          if (_hasSession) {
            //*
            debugPrint("SessionController: Se cerró la sesión");

            //
            _hasSession = false;

            //Se limpia la data de todos los controllers
            /*****Provider.of<UserController>(Get.context!, listen: false)
                .clearUser();*****/

            //*
            debugPrint("SessionController: Se requiere navegar a Sign");

            //Ejecutae la acción definida para ser llamada en caso de tener una
            //sesión inválida
            onInvalidSession.call();

            //
            _hasInvalidRouteDispatched = true;
          } else {
            //1?
            if (!_hasInvalidRouteDispatched) {
              //*
              debugPrint("SessionController: No se encontró una sesión activa");

              //*
              debugPrint("SessionController: Se requiere navegar a Sign");

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
      debugPrint("SessionController: $e");
      /*Validar errores*/

      //Reintentar todo
      //rethrow;
    } catch (e) {
      //*
      debugPrint("SessionController: $e");
      /*Validar errores*/
    }
  }

  //Obtener la data del usuario de la sesión
  _getSessionUser() async {
    //Se consulta la data del usuario y se define en UserController

    /***** 
    await Provider.of<UserController>(Get.context!, listen: false)
        .fetchAndSetUserData(
      userId: _sessionInstance.currentUser!.uid,
    );*****/
  }

  //Registrar usuario con correo y contraseña
  registerUserWithEmailAndPassword({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) {
    //
    _sessionInstance
        .createUserWithEmailAndPassword(email: email, password: password)
        .then(
      (value) async {
        //Se define la data del usuario en el servidor

        /*****await Provider.of<UserController>(Get.context!, listen: false)
            .setUserData(
          userId: value.user!.uid,
          chatIds: userData["chatIds"],
          profilePhotoUrl:
              "https://images.vexels.com/media/users/3/140800/isolated/preview/86b482aaf1fec78a3c9c86b242c6ada8-perfil-de-hombre-avatar.png", //userData["profilePhotoUrl"],
          names: userData["names"],
          surnames: userData["surnames"],
        );*****/
      },
    );
  }

  //Iniciar sesión con correo y contraseña
  initSessionWithEmailAndPassword({
    required String email,
    required String password,
    String? destinationRouteName,
  }) async {
    //Se ejecuta un bloque que puede tener respuestas de error
    try {
      //Se intenta ejecutar la petición de inicio de sesión
      await _sessionInstance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

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
}
