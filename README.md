StudyAI 🎓✨
Una aplicación inteligente de gestión de estudio desarrollada en Flutter con integración de IA para análisis de documentos, generación automática de cuestionarios y chat interactivo sobre PDFs.

Características
📝 Gestión de Notas: Crea, edita y organiza tus notas de estudio

🤖 Chat con IA: Conversa con una IA para resolver dudas sobre tus apuntes

📄 Análisis de PDFs: Sube documentos PDF y haz preguntas sobre su contenido

❓ Generación de Quiz: Crea cuestionarios automáticamente desde tus notas

📊 Historial de Actividad: Rastrea tu progreso de estudio

☁️ Almacenamiento en la nube: Todos tus datos sincronizados con Supabase

📱 Multiplataforma: Funciona en Web, Android e iOS

Tecnologías Utilizadas
Flutter: Framework de desarrollo multiplataforma

GetX: Gestión de estado y navegación

Supabase: Base de datos y almacenamiento en la nube

Groq AI: Inteligencia artificial para generación de contenido

Dart: Lenguaje de programación

Configuración del Proyecto
1. Clonar el Repositorio
bash
git clone https://github.com/tuusuario/studyai.git
cd studyai
2. Configurar Variables de Entorno
Crea un archivo .env en la raíz del proyecto con las siguientes variables:

text
SUPABASE_URL=tu_url_de_supabase_aqui
SUPABASE_ANON_KEY=tu_clave_anonima_de_supabase_aqui
GROQ_API_KEY=tu_api_key_de_groq_aqui
GROQ_BASE_URL=https://api.groq.com/openai/v1
Cómo Obtener las Claves
Supabase:

Crea una cuenta en supabase.com

Crea un nuevo proyecto

Ve a Settings → API

Copia el URL y el anon public key

Groq AI:

Crea una cuenta en console.groq.com

Ve a API Keys

Genera una nueva API Key

Copia la clave generada

3. Instalar Dependencias
bash
flutter pub get
4. Ejecutar la Aplicación
bash
flutter run
Arquitectura del Proyecto
El proyecto sigue Clean Architecture con separación de responsabilidades:

text
lib/
├── core/
│   ├── config/          # Configuración de Supabase
│   ├── constants/       # Constantes de la aplicación
│   ├── services/        # Servicios (AI, File Upload)
│   └── providers/       # Proveedores de datos
├── data/
│   ├── models/          # Modelos de datos
│   └── repositories/    # Implementación de repositorios
├── domain/
│   ├── entities/        # Entidades del dominio
│   ├── repositories/    # Interfaces de repositorios
│   └── usecases/        # Casos de uso
└── presentation/
    ├── controllers/     # Controladores GetX
    ├── pages/           # Páginas de la aplicación
    └── widgets/         # Widgets reutilizables
Funcionalidades Principales
Gestión de Notas con IA
Crear notas con títulos, materias y contenido

Chat con IA directamente sobre tus apuntes

Generar cuestionarios automáticamente desde el contenido

Organizar por materias para mejor estructuración

Análisis de Documentos PDF
Subir PDFs desde tu dispositivo

Extraer contenido automáticamente

Hacer preguntas sobre el contenido del PDF

Chat interactivo con respuestas basadas en el documento

Cuestionarios Inteligentes
Generación automática de preguntas desde notas

Múltiples tipos de preguntas (opción múltiple, verdadero/falso)

Explicaciones detalladas para cada respuesta

Revisión de resultados al finalizar

Historial de Actividad
Registro cronológico de todas tus acciones

Filtrado por tipo de actividad

Seguimiento de progreso de estudio

Modelos de IA Disponibles
La aplicación utiliza varios modelos de Groq:

llama-3.1-8b-instant: Chat general y análisis de texto

mixtral-8x7b-32768: Respuestas complejas y contextuales

llama-3.2-90b-vision-preview: Análisis de imágenes y PDFs

Requisitos del Sistema
Flutter SDK 3.0 o superior

Dart 3.0 o superior

Android Studio / Xcode (para desarrollo móvil)

Conexión a internet

Dependencias Principales
text
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  supabase_flutter: ^2.0.0
  flutter_dotenv: ^5.1.0
  http: ^1.2.0
  file_picker: ^6.1.1
  intl: ^0.18.1


Contacto
Autor: Julian Escobar-Je82443@gmail.com

¡Hecho con ❤️ y Flutter!