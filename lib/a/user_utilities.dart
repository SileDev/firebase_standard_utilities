import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class UserUtilities with ChangeNotifier {
  //Nombre de la colección que usará la clase
  final String collectionName = "users";

  //Referencia de la colección de usuarios que usará la utilidad
  late final CollectionReference _userCollectionReference;

  //Constructor
  UserUtilities() {
    _userCollectionReference =
        FirebaseFirestore.instance.collection(collectionName);
  }

  //Variable que indica si el notificador tiene un usuario
  bool hasUser = false;

  //Variable que almacenará los datos del usuario de la sesión actual
  late dynamic _currentUser;

  //Obtener UserModel del usuario actual
  get currentUser {
    return _currentUser;
  }

  //Definir data del usuario
  /*Camibar nombre*/
  setUserData({
    required String userId,
    required List<String> chatIds,
    required String profilePhotoUrl,
    required String names,
    required String surnames,
  }) async {
    //
    await _userCollectionReference.add(
      {
        "userId": userId,
        "chatIds": chatIds,
        "profilePhotoUrl": profilePhotoUrl,
        "names": names,
        "surnames": surnames,
      },
    ).then(
      (value) {
        //
        // Provider.of<ChatUtilities>(Get.context!, listen: false)
        //     .registerUserInChat(
        //   chatId: chatIds.first, //*-
        //   userId: userId,
        //   profilePhotoUrl: profilePhotoUrl,
        //   name: names,
        // );
      },
    );
  }

  //Obtener la data del usuario desde la base de datos
  Future<Map<String, dynamic>> _fetchUserData({
    required userId,
  }) {
    //Esquema de la consulta que retorna la data obtenida
    return _userCollectionReference
        .where("userId", isEqualTo: userId)
        .get()
        .then(
          (value) => value.docs.first.data() as Map<String, dynamic>,
        );
  }

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
    //Se indica que el notificador no tiene usuario
    hasUser = false;

    //Se borra la data del usuario del notificador
    _currentUser = null;

    //Se actualiza el notificador sobre los cambios a los oyentes
    notifyListeners();

    //*
    debugPrint("UserUtilities: Se eliminó el usuario del notificador");
  }
}
