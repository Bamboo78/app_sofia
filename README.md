# 👵 Sofía - App para Personas Mayores

> 🌟 **Una aplicación diseñada con amor para facilitar la vida diaria de nuestros mayores**

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?style=flat-square&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.7.2-blue?style=flat-square&logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android-green?style=flat-square&logo=android)

## 📋 Descripción

**Sofía** es una aplicación móvil desarrollada con Flutter diseñada especialmente para personas mayores. Ofrece una interfaz intuitiva y accesible con funcionalidades essenciales para facilitar su día a día.

---

## ✨ Características Principales

### 📱 **Páginas Disponibles**

| Característica | Descripción | Icono |
|---|---|---|
| 🚨 **Avisos** | Sistema inteligente de recordatorios y alertas por WhatsApp | `error_outline` |
| ⭐ **Favoritos** | Acceso rápido a 6 contactos favoritos | `public` |
| 📅 **Agenda** | Calendario mensual con eventos | `calendar_month` |
| 💊 **Medicación** | Control diario de medicamentos | `medication_outlined` |
| 👥 **Contactos** | Gestión de contactos de emergencia | `person_outline` |
| ✍️ **Frases** | Frases motivacionales diarias | `text_fields` |
| 👤 **Usuario** | Perfil personal y configuración | `person` |

### 🎯 **Funcionalidades Especiales**

- ✅ **Base de datos SQLite** - Almacenamiento seguro de datos offline
- 📞 **Integración WhatsApp** - Envío automático de mensajes de alerta
- 📸 **Galería de Fotos** - Selecciona fotos para contactos
- 🔔 **Monitoreo en Background** - Sistema de alertas continuo
- 🎨 **Interfaz Accesible** - Diseño amigable para usuarios mayores
- 🌐 **Navegación Intuitiva** - Botones grandes y claros

---

## 🛠️ **Tecnologías Utilizadas**

### Framework & Lenguaje

- **Flutter 3.x** - Framework multiplataforma
- **Dart 3.7.2** - Lenguaje de programación

### Dependencias Principales

```yaml
✓ sqflite ^2.3.3 - Base de datos SQLite
✓ image_picker ^1.x - Selección de imágenes
✓ url_launcher ^6.2.6 - Abrir URLs y WhatsApp
✓ http ^1.2.1 - Peticiones HTTP
✓ path_provider ^2.1.2 - Rutas de almacenamiento
```

---

## 📁 **Estructura del Proyecto**

```text
lib/
├── main.dart                 # Punto de entrada
├── pages/                    # Pantallas de la app
│   ├── agenda_page.dart
│   ├── avisos_page.dart
│   ├── contactos_page.dart
│   ├── favoritos_page.dart
│   ├── frases_page.dart
│   ├── medicacion_*.dart
│   └── usuario_page.dart
├── db/                       # Bases de datos
│   ├── agenda_database.dart
│   ├── avisos_database.dart
│   ├── contactos_database.dart
│   ├── favoritos_database.dart
│   ├── medicacion_database.dart
│   └── usuario_database.dart
└── services/                 # Servicios
    └── avisos_service.dart
```

---

## 🚀 **Empezar**

### Requisitos

- Flutter 3.x instalado
- Android SDK configurado
- Un dispositivo Android o emulador

### Instalación

1. **Clonar el repositorio**

```bash
git clone https://github.com/Bamboo78/app_sofia.git
cd app_sofia
```

1. **Instalar dependencias**

```bash
flutter pub get
```

1. **Ejecutar la app**

```bash
flutter run
```

1. **Compilar APK**

```bash
flutter build apk --release
```

---

## 🎨 **Paleta de Colores**

- 🎭 **Color Principal**: `#197A89` (Teal)
- 🎨 **Color de Fondo**: `#D1E4EA` (Light Teal)
- ⚪ **Fondo**: Blanco puro
- ⚫ **Texto**: Gris oscuro/Negro

---

## 💾 **Base de Datos**

Sofía utiliza SQLite para almacenar de forma segura:

- 👤 Información del usuario
- 📞 Contactos de emergencia
- ⭐ Favoritos personalizados
- 📅 Eventos de la agenda
- 💊 Medicamentos y horarios
- 🚨 Avisos y recordatorios

---

## 📞 **Contacto & Soporte**

Para más información sobre Flutter:

- 📚 [Documentación Flutter](https://docs.flutter.dev/)
- 🎓 [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- 💬 [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
