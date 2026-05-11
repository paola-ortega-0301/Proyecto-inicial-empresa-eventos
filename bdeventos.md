## actúa como un administrador de base de datos: proyecto empresa de eventos, que entidades se necesitan para su gestion

<img width="948" height="595" alt="image" src="https://github.com/user-attachments/assets/4df8d24f-859c-498e-aeb8-4cbca185d037" />


Aquí tienes el modelo de entidades para una empresa de eventos. Te explico el razonamiento detrás de cada una:

**Núcleo del negocio**

`EVENTO` es la entidad central. De ella depende todo: sesiones, inscripciones, venues y los recursos asignados. Un evento puede ser una conferencia de un día o un festival de varios días.

`SESION` representa los bloques o tracks dentro de un evento (charlas, talleres, paneles). Tiene su propio espacio físico y ponentes.

**Logística de lugar**

`VENUE` es el recinto general (hotel, centro de convenciones), mientras que `ESPACIO` son sus subdivisiones (sala A, sala B, auditorio). Esta separación es importante porque un venue puede albergar varios eventos simultáneos.

**Participantes y facturación**

`CLIENTE` puede inscribirse a múltiples eventos. `INSCRIPCION` captura el tipo de ticket y monto, y `PAGO` registra el método y estado de cobro — están separadas porque un cliente podría pagar en cuotas o por distintos medios.

**Recursos humanos y externos**

`PONENTE` es quien presenta en sesiones (distinto del staff operativo). `STAFF` es el personal interno asignado al evento. `PROVEEDOR` cubre servicios externos: catering, audiovisual, seguridad, etc.

---

Dependiendo del alcance del proyecto, podrías agregar entidades adicionales como `PATROCINADOR`, `CATEGORIA_EVENTO`, `CERTIFICADO` (para eventos académicos), o `CHECKIN` para control de acceso en tiempo real. ¿Quieres profundizar en alguna entidad o agregar alguna de estas?

## las entidades con sus atributos y tipo en forma de tabla para cada una de las entidades
## TABLAS
<img width="658" height="733" alt="image" src="https://github.com/user-attachments/assets/765f97bc-52be-42e3-b5da-2a3ab24ea5d9" />
<img width="660" height="627" alt="image" src="https://github.com/user-attachments/assets/1514de9c-37d8-4528-941a-a659eb7ba72b" />
<img width="648" height="669" alt="image" src="https://github.com/user-attachments/assets/8303ccaa-1c57-4d14-bc4a-03fdac97eafb" />
<img width="655" height="674" alt="image" src="https://github.com/user-attachments/assets/48574561-df39-48ac-8b3c-d4918096b2b4" />
<img width="665" height="644" alt="image" src="https://github.com/user-attachments/assets/93506e22-8bcc-4945-8e4c-52185e8b32da" />


Ahí están las 10 entidades con todos sus atributos. Algunos criterios de diseño que apliqué:

`INT` para todas las claves primarias y foráneas — eficiente para índices y joins. `DECIMAL(10,2)` para montos monetarios en lugar de `FLOAT`, para evitar errores de redondeo. `ENUM` donde los valores son un conjunto cerrado y conocido (estado, tipo, método de pago), lo que garantiza integridad a nivel de base de datos. `TEXT` para campos de longitud variable e impredecible como bio o descripción.

También hay tres **tablas de relación** que se necesitan para las asociaciones muchos-a-muchos que no aparecen aquí como entidades independientes, pero que deberían existir en el esquema físico: `SESION_PONENTE` (una sesión puede tener varios ponentes y viceversa), `EVENTO_STAFF` (staff asignado a múltiples eventos), y `EVENTO_PROVEEDOR` (proveedores contratados por evento).

¿Quieres que genere el script DDL en SQL para crear estas tablas, o pasamos a definir las relaciones con cardinalidades?

## de acuerdo a tu respuesta anterior puedes generar un script en sql para descargar con el nombre de bdeventos.sql para las 10 entidades con sus relaciones

El script está listo para descargar. Aquí un resumen de lo que incluye:

**Estructura (13 tablas en total)**
- 10 tablas principales: `venue`, `espacio`, `evento`, `sesion`, `cliente`, `inscripcion`, `pago`, `ponente`, `staff`, `proveedor`
- 3 tablas de relación: `sesion_ponente`, `evento_staff`, `evento_proveedor`

**Características del script**
- Compatible con MySQL 8.0+, motor InnoDB
- Todas las claves foráneas con `ON UPDATE CASCADE` y políticas de borrado apropiadas (`RESTRICT` donde hay riesgo de pérdida de datos, `CASCADE` en relaciones dependientes)
- Restricciones `CHECK` para validar que `fecha_fin >= fecha_inicio` en eventos y sesiones
- Índices adicionales en columnas de búsqueda frecuente (estado, fechas, claves foráneas)
- `UNIQUE` en todos los campos de email para evitar duplicados
- Datos de prueba (seed) con 2 venues, 2 eventos, 3 sesiones, 3 clientes, 3 inscripciones y pagos de ejemplo

Para ejecutarlo: `mysql -u root -p < bdeventos.sql`
