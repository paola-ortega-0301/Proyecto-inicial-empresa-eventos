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
├── core/
│   ├── constants/       # Nombres de colecciones de Firebase y llaves API.
│   ├── theme/           # Configuración de colores (Morado/Rosa) y tipografías.
│   ├── routes/          # Configuración centralizada de navegación (GoRouter).
│   ├── utils/           # Formateadores de moneda ($) y validadores de formularios.
│   └── errors/          # Manejo de excepciones personalizadas.
│
├── data/
│   ├── models/          # DTOs (Data Transfer Objects) con métodos de/hacia JSON.
│   ├── repositories/    # Implementación de los contratos de datos.
│   └── services/        # Conexiones directas a Firebase Auth, Firestore y Storage.
│
├── domain/
│   ├── entities/        # Clases de datos puras (sin lógica de Firebase).
│   ├── repositories/    # Interfaces y contratos que definen el acceso a datos.
│   └── usecases/        # Lógica de negocio (ej. InscribirAsistente, CalcularPresupuesto).
│
├── providers/
│   ├── auth_provider.dart    # Estado de la sesión del usuario y roles.
│   ├── event_provider.dart   # Estado de la lista de eventos y filtros.
│   └── finance_provider.dart # Estado de cuentas, transacciones y presupuestos.
│
├── features/            # Módulos específicos por funcionalidad
│   ├── auth/            # Pantallas de Login, Registro y Recuperación.
│   ├── events/          # Pantallas de Catálogo, Detalles y Gestión de Cupos.
│   ├── finance/         # Pantallas de Cuentas, Historial y Gráficas de Gastos.
│   └── billing/         # Pantallas de Proveedores y Visualización de Facturas.
│
├── ui/
│   ├── shared/          # Widgets reutilizables (Botones Rosa, Cards Moradas).
│   └── layouts/         # Estructuras base para Móvil vs Web/Desktop.
│
└── assets/
    ├── images/          # Logotipos y fondos de la empresa.
    ├── icons/           # Iconografía para categorías de eventos.
    └── fonts/           # Archivos de fuentes (Montserrat, Poppins).

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
Entendido. He integrado la lógica de tus tablas originales de SQL (Proyecto, Categoría, Cuenta, Usuario, Transacción, Presupuesto, Proveedor y Factura) dentro de la arquitectura de **Providers** y la estructura de **Firestore**.

Aquí tienes el desglose detallado de cómo se conectan tus campos con la lógica de estado de la aplicación:

---

## 🗄️ 3.2. Diccionario de Datos (Estructura de Tablas)

A continuación, se detalla la transposición de tu lógica relacional a documentos de Firestore. Estas tablas representan el corazón de la base de datos de **Eventos Ortega**:

### **Módulo de Planificación y Usuarios**

| Entidad | Campos Principales | Propósito |
| --- | --- | --- |
| **Proyectos** | `id`, `nombre`, `descripcion`, `fecha_inicio`, `fecha_fin`, `estado`, `presupuesto_total` | La raíz de cada evento gestionado. |
| **Categorías** | `id`, `proyecto_id`, `nombre`, `tipo`, `color` | Clasificación interna (ej. Banquete, Sonido). |
| **Usuarios** | `id`, `nombre`, `email`, `rol` | Control de acceso (Admin/Organizador). |

### **Módulo Financiero y de Cuentas**

| Entidad | Campos Principales | Propósito |
| --- | --- | --- |
| **Cuentas** | `id`, `proyecto_id`, `nombre`, `tipo`, `moneda`, `saldo_inicial`, `saldo_actual` | Origen y destino de los fondos. |
| **Transacciones** | `id`, `cuenta_origen_id`, `cuenta_destino_id`, `categoria_id`, `usuario_id`, `monto`, `fecha`, `tipo`, `descripcion`, `estado` | Registro histórico de movimientos de dinero. |
| **Presupuestos** | `id`, `proyecto_id`, `categoria_id`, `monto_planificado`, `monto_ejecutado`, `periodo_inicio`, `periodo_fin` | Control de gastos vs. lo planeado. |

### **Módulo Administrativo y de Soporte**

| Entidad | Campos Principales | Propósito |
| --- | --- | --- |
| **Proveedores** | `id`, `nombre`, `rfc`, `contacto`, `moneda` | Directorio de empresas externas. |
| **Facturas** | `id`, `proveedor_id`, `transaccion_id`, `numero`, `fecha_emision`, `fecha_vencimiento`, `monto_total`, `estado` | Respaldo legal y fiscal de cada gasto. |

---

## 5. Planeación del Desarrollo (Paso a Paso). Gestion de estado con Providers

El **Provider** actuará como el motor que mantiene los datos actualizados en las pantallas moradas y rosas de la interfaz.

### **1. EventProvider (Gestión de Proyectos)**

Es el encargado de administrar la lógica de los eventos.

* **Funciones:** Listar proyectos activos, filtrar por fecha y actualizar el estado del evento (planeación, en curso, finalizado).
* **Uso en UI:** Alimenta el Dashboard principal con los nombres de los proyectos y sus fechas de inicio/fin.

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

Perfecto, entiendo. Vamos a transformar esa sección técnica en una descripción narrativa y estratégica, explicando la utilidad de cada herramienta sin usar el formato de archivo de configuración.

Aquí tienes la versión adaptada para tu plan profesional:

---

## 6. Recursos y Herramientas de Integración

## 📦 6. Dependencias Recomendadas (`pubspec.yaml`)

Para que el proyecto compile correctamente en todas las plataformas, añade estas librerías en tu archivo de configuración. He respetado los colores y el formato de código solicitado:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # --- NÚCLEO Y CONECTIVIDAD CLOUD ---
  firebase_core: ^2.24.0      # Inicialización de servicios Google
  firebase_auth: ^4.15.0      # Gestión de usuarios y sesiones
  cloud_firestore: ^4.13.0    # Base de datos NoSQL en tiempo real
  firebase_storage: ^11.5.0   # Almacenamiento de facturas y fotos
  
  # --- GESTIÓN DE ESTADO Y RUTAS ---
  provider: ^6.1.1            # Arquitecto de estado (MVVM)
  go_router: ^12.1.3          # Enrutador para Web, Móvil y Desktop
  
  # --- UTILIDADES Y FORMATO ---
  intl: ^0.18.1               # Formateo de moneda ($) y fechas
  google_fonts: ^6.1.0        # Tipografías Montserrat / Poppins
  cached_network_image: ^3.3.0 # Caché inteligente de imágenes
  fl_chart: ^0.65.0           # Gráficas financieras (Morado/Rosa)
  
  # --- ADICIONALES ---
  logger: ^2.0.2              # Depuración profesional en consola

```

---

Para que **Eventos Ortega** funcione con la fluidez y seguridad que requiere un negocio de logística, utilizaremos una selección de librerías especializadas que se dividen en cuatro pilares fundamentales:

### A. Núcleo y Conectividad Cloud

* **Conector Base de Firebase:** Es el cimiento que permite que la aplicación "hable" con los servicios de Google en la nube.
* **Gestor de Identidad:** Herramienta encargada de cifrar las contraseñas, manejar el inicio de sesión y asegurar que cada usuario sea quien dice ser.
* **Motor de Datos en Tiempo Real:** La base de datos que permite que, si un administrador registra un pago en la oficina, el organizador lo vea reflejado al instante en su móvil.
* **Almacén de Archivos Digitales:** Espacio seguro en la nube diseñado para guardar las fotos de los eventos y los archivos PDF de las facturas y contratos.

### B. Gestión de Inteligencia y Estado

* **Arquitecto de Estado (Provider):** Es el director de orquesta de la aplicación; se encarga de que la información (como el saldo de una cuenta) fluya entre pantallas sin perderse ni duplicarse.
* **Enrutador Avanzado:** Sistema que gestiona los caminos de la app, permitiendo crear rutas protegidas (que nadie entre al área de finanzas sin permiso) y facilitando la navegación entre el catálogo y el dashboard.

### C. Formateo y Profesionalización de Datos

* **Localización Internacional (Intl):** Vital para el negocio. Se encarga de transformar números simples en formato de moneda ($) y fechas legibles según el calendario del evento.
* **Gestor de Tipografía:** Integración de fuentes modernas (como *Poppins* o *Montserrat*) para que la app no parezca un sistema genérico, sino una herramienta de diseño de eventos.

### D. Optimización Visual y Rendimiento

* **Caché Inteligente de Imágenes:** Permite que las fotos de los salones o decoraciones se carguen una sola vez y se guarden en la memoria del teléfono, ahorrando datos móviles a los usuarios.
* **Librería de Gráficos:** Para el módulo financiero, utilizaremos herramientas que transforman las tablas de gastos en gráficas de pastel y barras, facilitando la toma de decisiones sobre los presupuestos.

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

