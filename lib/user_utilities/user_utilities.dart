import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserUtilities with ChangeNotifier {
  //Nombre de la colección que usará UserUtilities, esto puede ser sobreescrito
  //en caso de requerir que se use una colección diferente en el proyecto
  final String collectionName = "users";

  //Referencia de la colección de usuarios que usará UserUtilities
  late final CollectionReference _userCollectionReference;

  //Constructor
  UserUtilities() {
    //Se inicializa la referencia de la colección
    _userCollectionReference =
        FirebaseFirestore.instance.collection(collectionName);
  }

  //Variable que indica si UserUtilities tiene un usuario
  bool hasUser = false;

  //Variable que almacenará los datos del usuario de la sesión actual
  late dynamic _currentUser;

  //Obtener data del usuario actual
  get currentUser {
    return _currentUser;
  }

  //Crear un usuario con la data indicada en la colección
  createUser({
    required String userId,
    String? profilePhotoUrl,
    String? names,
    String? surnames,
    String? countryCode,
    int? phonePrefix,
    int? phoneNumber,
    Map<String, dynamic>? data,
    Function? onComplete,
  }) {
    //Se ejecuta un bloque que puede tener errores de ejecución
    try {
      //Se ejecuta la consulta
      _userCollectionReference.add(
        {
          "userId": userId,
          if (profilePhotoUrl != null) "profilePhotoUrl": profilePhotoUrl,
          if (names != null) "names": names,
          if (surnames != null) "surnames": surnames,
          if (countryCode != null) "countryCode": countryCode,
          if (phonePrefix != null) "countryPrefix": phonePrefix,
          if (phoneNumber != null) "phoneNumber": phoneNumber,
          if (data != null) "data": data,
        },
      ).then(
        (value) {
          //*
          debugPrint("UserUtilities: Se creó el usuario requerido");

          //Se comprueba si se debe realizar alguna acción
          if (onComplete != null) {
            //En caso de que se haya definido una función se le hace callback
            //pasándole la data del usuario
            onComplete.call(value);
          }
        },
      );
    } catch (e) {
      //Se notifica el error
      //*
      debugPrint("UserUtilities: No se pudo crear el usuario requerido");
      debugPrint(e.toString());
    }
  }

  //Obtener la data del usuario desde la base de datos, este método tiene 2
  //tipos de ejecución
  //1. si no se define onComplete retornará la data del usuario
  //2. si se define onComplete se ejecutará el callback con la data del usuario
  getUser({
    required userId,
    Function? onComplete,
  }) {
    //Se ejecuta un bloque que puede tener errores de ejecución
    try {
      //Se ejecuta la consulta
      return _userCollectionReference
          .where("userId", isEqualTo: userId)
          .get()
          .then(
        (response) {
          //*
          debugPrint("UserUtilities: Se obtuvo la data del usuario requerido");

          //Se retorna la data del usuario como un mapa de datos
          return response.docs.first.data() as Map<String, dynamic>;
        },
      ).then(
        //Una vez finalizado el paso anterior se recibe la data del usuario,
        //por lo cual podemos ejecutar alguna acción, así que evaluamos si
        (userData) {
          if (onComplete != null) {
            //En caso de que se haya definido una función en onComplete se hará
            //un callback pasándole la data del usuario
            onComplete.call(userData);
          } else {
            //En caso contrario se retornará la data del usuario como un mapa de
            //datos
            return userData;
          }
        },
      );
    } catch (e) {
      //Se notifica el error
      //*
      debugPrint("UserUtilities: No se pudo obtener el usuario requerido");
      debugPrint(e.toString());
    }
  }

  updateUser() {}

  //Obtener la data del usuario de la base de datos y asignarla al
  //almacenamiento persistente y al Utilities
  /*estará*/
  // fetchAndSetUserData({
  //   required String userId,
  // }) async {
  //   //Se ejecuta un bloque que puede tener respuestas de error
  //   try {
  //     //Se define la variable que almacenará la data del usuario y se intenta
  //     //ejecutar la consulta que obtiene la data de la base de datos, luego se
  //     //asigna la data que se obtuvo a la variable
  //     Map<String, dynamic> newUserData = await _fetchUserData(userId: userId);

  //     //En caso de fallar la consulta, el compilador pasará al catch de este try,
  //     //en caso contrario continuará a partir de acá

  //     /*Falta hacer validaciones a la data obtenida*/
  //     //debugPrint(newUserData.toString());
  //     debugPrint(
  //         "UserUtilities: Se obtuvo la data del usuario desde la base de datos");

  //     //
  //     _currentUser = UserModel(
  //       userId: newUserData["userId"],
  //       profilePhotoUrl: newUserData["profilePhotoUrl"],
  //       names: newUserData["names"],
  //       surnames: newUserData["surnames"],
  //       chatIds: List<String>.generate(
  //         newUserData["chatIds"].length,
  //         (index) => newUserData["chatIds"][index],
  //       ),
  //     );

  //     //Se indica que el notificador tiene un usuario
  //     if (!hasUser) {
  //       hasUser = true;
  //     }

  //     //Se actualiza el notificador y se notifican los cambios a los oyentes
  //     notifyListeners();

  //     //*
  //     debugPrint("UserUtilities: Se asignó el usuario del Utilities");
  //   } on FirebaseException catch (e) {
  //     //*
  //     debugPrint("UserUtilities: $e");
  //     /*Validar errores*/
  //   } catch (e) {
  //     //*
  //     debugPrint("UserUtilities: Error obteniendo data del usuario");
  //     /*Validar errores*/
  //   }
  // }

  //Eliminar la data del usuario actual
  clearUser() {
    //Se indica que el UserUtilities no tiene usuario
    hasUser = false;

    //Se borra la data del usuario de UserUtilities
    _currentUser = null;

    //Se actualiza notifica sobre los cambios a los oyentes
    notifyListeners();

    //*
    debugPrint("UserUtilities: Se eliminó el usuario del notificador");
  }
}
