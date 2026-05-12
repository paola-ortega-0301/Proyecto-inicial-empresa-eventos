# 📋 Prompt Profesional: Aplicación "Eventos Ortega"

Este documento constituye la hoja de ruta técnica y estratégica para el desarrollo de la plataforma **Eventos Ortega**, una solución integral para la gestión de eventos, control de asistentes y administración financiera de servicios logísticos.

---

## 1. Descripción General del Sistema

**Eventos Ortega** no es solo una agenda; es un ecosistema de gestión diseñado para transformar la logística compleja en flujos de trabajo simplificados. El sistema permite a los administradores y organizadores coordinar desde la conceptualización de un evento (proyectos y categorías) hasta la ejecución financiera (cuentas, transacciones y facturación).

El objetivo principal es centralizar la operación para evitar fugas de presupuesto, asegurar el cupo óptimo en cada evento y profesionalizar la relación con proveedores y clientes mediante un control estricto de facturación y pagos.

---

## 2. Arquitectura del Proyecto

Para garantizar la escalabilidad en Android, iOS, Web y Desktop, utilizaremos una arquitectura **Layered MVVM (Model-View-ViewModel)** combinada con **Clean Architecture** simplificada.

### Organización de Carpetas

```text
lib/
├── core/            # Constantes, temas, utilidades y rutas.
├── data/            # Repositorios, fuentes de datos (Firebase) y DTOs.
├── domain/          # Entidades puras y casos de uso (reglas de negocio).
├── providers/       # Gestión de estado (ViewModels).
└── ui/              # Capa de presentación (Screens y Widgets).

```

### Estrategia Técnica

* **Separación Frontend/Backend:** Firebase actúa como un Backend-as-a-Service (BaaS), desacoplado mediante servicios en Dart.
* **Manejo de Estados:** Utilizaremos `Provider` por su eficiencia en el manejo de flujos de datos de Firebase.
* **Escalabilidad:** Implementación de "Feature-first" para que añadir nuevas funcionalidades (ej. Módulo de inventario) no rompa el núcleo del sistema.

---

## 3. Tecnologías Necesarias

* **Flutter & Dart:** Framework y lenguaje base para el desarrollo nativo multiplataforma.
* **Firebase Authentication:** Control de acceso seguro para administradores y clientes.
* **Cloud Firestore:** Base de datos NoSQL en tiempo real para sincronización instantánea de eventos y pagos.
* **Firebase Storage:** Almacenamiento de comprobantes de pago y galerías de eventos.
* **Provider:** Inyección de dependencias y gestión del estado reactivo.
* **Dependencias Clave:** `cloud_firestore`, `firebase_auth`, `intl` (fechas/monedas), `google_fonts`, `fl_chart` (gráficas financieras).

---

## 4. Diseño UI/UX

La identidad visual de **Eventos Ortega** debe transmitir creatividad y profesionalismo.

* **Paleta de Colores:**
* **Primario:** Morado Profundo (`#673AB7`) - Representa elegancia y creatividad.
* **Secundario:** Rosa Vibrante (`#E91E63`) - Representa energía y pasión por los eventos.
* **Acento:** Blanco/Gris claro para fondos, asegurando legibilidad.


* **Estilo Visual:** Neomorfismo suave o Glassmorphism en tarjetas de eventos, bordes redondeados y tipografía moderna (tipo *Montserrat* o *Poppins*).
* **Responsive:** Diseño adaptativo que utiliza `LayoutBuilder` para mostrar paneles laterales en escritorio y barras inferiores en móviles.

---

## 5. Planeación del Desarrollo (Paso a Paso)

### Fase 1 — Configuración del Entorno

* **Objetivo:** Preparar el espacio de trabajo.
* **Actividades:** Instalación de Flutter SDK, configuración de extensiones en VS Code y creación del repositorio en GitHub.

### Fase 2 — Configuración de Firebase

* **Objetivo:** Vincular la app con la nube.
* **Actividades:** Creación del proyecto en Firebase Console, configuración de `google-services.json` y `GoogleService-Info.plist`.

### Fase 3 — Diseño de Base de Datos Firestore

* **Objetivo:** Estructurar la información.
* **Actividades:** Mapear las entidades (Proyecto, Evento, Transacción, Factura) a colecciones y subcolecciones.

### Fase 4 — Sistema de Autenticación

* **Objetivo:** Seguridad de entrada.
* **Actividades:** Flujos de Login y Registro. Implementación de roles (Admin/Organizador/Cliente).

### Fase 5 — Pantallas Principales

* **Objetivo:** Maquetado base.
* **Actividades:** Dashboard con resumen de presupuesto, lista de eventos y perfil de usuario.

### Fase 6 — CRUD de Entidades

* **Objetivo:** Gestión de datos.
* **Actividades:** Formularios para crear proyectos, cuentas y proveedores.

### Fase 7 — Gestión de Transacciones

* **Objetivo:** El núcleo financiero.
* **Actividades:** Lógica para mover saldo entre cuentas y afectar el presupuesto ejecutado.

### Fase 8 — Facturación y Presupuestos

* **Objetivo:** Control administrativo.
* **Actividades:** Generación de registros de facturas vinculados a transacciones y alertas de presupuesto excedido.

### Fase 9 — Testing Multiplataforma

* **Objetivo:** Calidad técnica.
* **Actividades:** Pruebas en emuladores Android, navegadores Chrome y ejecutables de Windows.

### Fase 10 — Implantación Estándar

* **Objetivo:** Entrega del producto.
* **Actividades:** Generación de ejecutables y despliegue en Firebase Hosting para la versión web.

---

## 6. Dependencias Recomendadas

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^latest      # Conexión base
  firebase_auth: ^latest      # Usuarios
  cloud_firestore: ^latest    # Base de datos
  firebase_storage: ^latest   # Archivos/Facturas
  provider: ^latest           # Estado
  intl: ^latest               # Formato de dinero ($) y fechas
  google_fonts: ^latest       # Tipografía profesional
  cached_network_image: ^latest # Optimización de fotos de eventos
  go_router: ^latest          # Navegación avanzada

```

---

## 7. Seguridad y Autenticación

* **Manejo de Sesiones:** Persistencia de usuario mediante `StreamBuilder` conectado a `authStateChanges`.
* **Seguridad Firestore:** Reglas granulares. Por ejemplo:



* **Validación:** Limpieza de datos en el lado del cliente y reglas de validación en el lado del servidor para evitar montos negativos.

---

## 8. Flujo de Navegación

1. **Splash Screen:** Carga de marca (Morado/Rosa).
2. **Auth:** Login/Registro.
3. **Dashboard:** Vista general (Presupuesto total vs Ejecutado).
4. **Módulo Eventos:** Proyectos → Categorías → Eventos específicos.
5. **Módulo Financiero:** Cuentas → Transacciones → Facturas vinculadas.
6. **Configuración:** Gestión de proveedores y perfil.

---

## 9. Plan de Implantación (Modo Estándar)

* **Control de Versiones:** Uso de Git con ramas `main` y `develop`.
* **Compilación:**
* **Android:** `flutter build apk --split-per-abi` para optimizar peso.
* **Web:** `flutter build web` y despliegue rápido en Firebase Hosting.
* **Windows:** `flutter build windows` para uso administrativo en oficina.



---

## 10. Recomendaciones Profesionales (Senior Tips)

1. **Optimización Firestore:** No descargues toda la lista de transacciones; usa `limit()` y `startAfter()` para paginación.
2. **UI/UX:** El contraste entre el morado y el rosa es alto; usa el rosa solo para botones de acción importantes (CTAs) para no fatigar la vista.
3. **Clean Code:** Mantén los modelos de datos (`EventModel`, `TransactionModel`) en archivos separados con métodos `fromMap` y `toMap`.
4. **Error Handling:** Implementa un `SnackBar` global para errores de Firebase (ej. "Fondos insuficientes" o "Error de red").

---

✅ **Documento Finalizado.** Este plan sirve como contrato técnico para iniciar el desarrollo de la Fase 1. ¿Deseas que profundicemos en alguna fase o entidad específica?


### Edna Paola Ortega Rodriguez 6J
