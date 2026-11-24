# ElectroVault

Aplicación multiplataforma desarrollada con Flutter y Dart para administrar un inventario personal de componentes electrónicos. Usa Firebase Authentication para el acceso, Cloud Firestore como base de datos y Riverpod para el estado.

## Funciones

- Registro e inicio de sesión con correo electrónico y contraseña.
- Inventario privado por usuario con actualización en tiempo real.
- Alta, consulta, modificación y eliminación de componentes.
- Datos de identificación, especificaciones, tensión, corriente, cantidad, ubicación, precio, imagen externa y enlace a datasheet.
- Temas claro y oscuro según la configuración del dispositivo.

## Estructura

- `lib/domain/component.dart`: modelo y conversión de datos de Firestore.
- `lib/datasource/component_datasource.dart`: acceso a la colección privada del usuario.
- `lib/presentation/providers/`: sesión y estado del inventario con Riverpod.
- `lib/presentation/screens/`: acceso, registro, lista, detalle y formulario.
- `lib/core/app_theme.dart`: colores y componentes del tema.

La estructura sigue el patrón sencillo de modelo, datasource, provider y pantallas del material del curso. La autenticación, las reglas por usuario, la suscripción en vivo y la edición y baja completas se implementan como adaptaciones, porque el repositorio de referencia no incluye esos ejemplos con Firestore.

## Configuración de Firebase

La aplicación requiere un proyecto Firebase propio. No se incluyen credenciales ni archivos de configuración para evitar publicar secretos y datos asociados a una cuenta.

1. Crear o seleccionar un proyecto en Firebase Console.
2. En **Authentication**, habilitar el proveedor **Correo electrónico/Contraseña**.
3. Crear la base **Cloud Firestore**.
4. Registrar las aplicaciones Android (`com.tp5.electrovault`) y Web, y generar `firebase_options.dart` con FlutterFire CLI después de autorizar Firebase CLI en Google.
5. Desplegar `firestore.rules` en el proyecto.

Las reglas limitan perfiles y componentes a la persona autenticada cuyo UID coincide con el segmento de la ruta. La colección de componentes es `users/{uid}/components/{componentId}`. La aplicación no usa Firebase Storage; las imágenes se guardan como URL externas.

`firebase_options.dart`, `google-services.json` y los archivos de servicio quedan excluidos del control de versiones local. Después de configurar las plataformas, ejecutar `flutter pub get` y `flutter run`. Sin las opciones generadas por FlutterFire, el inicio muestra la pantalla de configuración pendiente.

## Prueba local con emuladores

Para probar Authentication y Firestore sin crear datos en el proyecto real:

```sh
firebase emulators:start --only auth,firestore --project demo-electrovault
flutter run -d chrome --dart-define=USE_FIREBASE_EMULATORS=true
```

La bandera conecta la app a los emuladores locales; en Android usa `10.0.2.2` y en Web `127.0.0.1`.

## Dependencias principales

- Flutter y Dart.
- `firebase_core`, `firebase_auth` y `cloud_firestore`.
- `flutter_riverpod`.

## Ejecución local

```sh
flutter pub get
flutter analyze
flutter run
```
