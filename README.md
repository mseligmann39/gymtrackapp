GimFit - Tu App de Gimnasio Personal
GimFit es una aplicación móvil desarrollada con Flutter para registrar y planificar entrenamientos de gimnasio. Permite a los usuarios gestionar ejercicios, crear rutinas personalizadas, registrar series/repeticiones/peso y consultar su historial de entrenamientos.

🚀 Empezando
Esta guía te ayudará a configurar el entorno de desarrollo para clonar y ejecutar el proyecto en una nueva máquina.

Prerrequisitos
Asegúrate de tener instalado lo siguiente:

Flutter SDK: Versión 3.x o superior. Puedes seguir la guía oficial de instalación.

Un editor de código: Se recomienda Visual Studio Code con la extensión de Flutter.

Git: Para clonar el repositorio.

⚙️ Configuración del Proyecto
La configuración más importante de este proyecto es la conexión con Firebase. Sigue estos pasos cuidadosamente.

1. Clonar el Repositorio
git clone https://github.com/tu-usuario/gymtrack.git
cd gymtrack

2. Configuración de Firebase
Este proyecto no funcionará sin una configuración de Firebase propia. Deberás crear tu propio proyecto en Firebase y conectarlo.

Paso A: Instalar Firebase CLI
Si no la tienes, instala la interfaz de línea de comandos de Firebase.

npm install -g firebase-tools

Y luego inicia sesión:

firebase login

Paso B: Crear y Configurar tu Proyecto en Firebase
Ve a la Consola de Firebase y crea un nuevo proyecto.

Una vez creado, no necesitas añadir ninguna app desde la consola. Lo haremos desde la línea de comandos.

En la terminal, dentro de la carpeta de tu proyecto Flutter, ejecuta:

flutterfire configure

Sigue los pasos: selecciona tu proyecto de Firebase recién creado y elige la plataforma android. Esto generará automáticamente el archivo lib/firebase_options.dart y configurará tu app de Android.

Paso C: Ajustar la Versión Mínima de Android
Firebase requiere una versión mínima de Android. Es probable que necesites ajustar esto manualmente.

Abre el archivo android/app/build.gradle.kts.

Busca la sección defaultConfig.

Cambia la línea minSdkVersion para que sea 23 o superior.

// En android/app/build.gradle.kts
defaultConfig {
    // ...
    minSdkVersion = 23 // Asegúrate de que este valor sea 23
    // ...
}

Paso D: Crear Índices de Firestore (¡Muy Importante!)
Cuando intentes ver la pantalla de "Historial", la aplicación fallará con un error FAILED_PRECONDITION que pide un índice. Debes crearlo manualmente en la consola de Firebase:

Ve a tu proyecto en la Consola de Firebase -> Firestore Database -> Índices.

Haz clic en "Añadir índice compuesto".

Configúralo de la siguiente manera:

ID de colección: workout_sessions

Campos a indexar:

userId - Ascendente

date - Descendente

Haz clic en "Crear" y espera a que el estado cambie a "Habilitado".

3. Instalar Dependencias de Flutter
Una vez configurado Firebase, instala todas las dependencias del proyecto.

flutter pub get

4. Ejecutar la Aplicación
¡Todo listo! Ahora puedes ejecutar la aplicación en tu emulador o dispositivo físico.

flutter run
