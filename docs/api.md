# API de Geo Adopt · Sprint 1

Diseño del backend y del CRUD. En este sprint **no se programa el CRUD**: se decide cómo será (rutas, datos y respuestas) para escribirlo en el Sprint 2.

Las historias de usuario (HU) y las reglas de negocio (RN) son las del documento de la primera entrega. Las entidades son las del modelo E/R: `USUARIO`, `REFUGIO`, `REPORTE`, `ANIMAL`, `FOTO` y `SOLICITUD_ADOPCION`.

---

## 1. Elección del backend

| Opción | Lenguaje | A favor | En contra |
|---|---|---|---|
| **Node.js + Express** | JavaScript | Mismo lenguaje que el frontend (React). Arranque rápido y poca configuración. JSON nativo, ideal para una API REST. Hay librerías maduras para JWT, bcrypt y PostgreSQL. | Hay que decidir a mano la estructura y las librerías. Sin tipado estricto. |
| Spring Boot | Java | Conocido de Programación. Muy robusto, con seguridad y validación integradas. | Más configuración inicial y más código para una API sencilla. Otro lenguaje distinto al del frontend. |
| Laravel | PHP | Trae casi todo hecho (rutas, ORM, autenticación). | Lenguaje nuevo para el equipo y sin relación con el resto del stack. |

**Decisión: Node.js + Express.**

Motivos:

1. Un solo lenguaje (JavaScript) en frontend y backend: el equipo reutiliza conocimientos y puede ayudarse entre capas.
2. Es lo que ya refleja el diagrama de arquitectura de la primera entrega (Node.js + Express, JWT + bcrypt, PostgreSQL + PostGIS).
3. El equipo es pequeño (2 desarrolladores) y necesita una API funcionando rápido; Express tiene muy poca configuración inicial.
4. Encaja con el resto del stack: JWT para sesiones sin estado, bcrypt para contraseñas, `pg` para PostgreSQL.

**Cambio respecto a la primera entrega.** La tabla 5.1 del documento indicaba Spring Boot, pero el diagrama de arquitectura del mismo documento ya mostraba Node.js + Express. Se unifica en **Node.js + Express** y se refleja en la tabla de cambios del documento corregido.

---

## 2. Convenciones de la API

- **Base:** `/api`. Formato **JSON** en peticiones y respuestas.
- **Autenticación:** cabecera `Authorization: Bearer <token>` (JWT). Las rutas públicas son `/api/estado`, `/api/auth/*` y la búsqueda de animales.
- **Roles** (campo `rol` de `USUARIO`): `usuario` (ciudadano y adoptante), `refugio` y `admin`. Los permisos se comprueban siempre en el servidor.
- **Ubicación:** `latitud` y `longitud` (números decimales).
- **Fotos:** no se envían en el JSON. La app las sube al almacenamiento de objetos y manda **las URLs** en el campo `fotos`.
- **Estados:**
  - Reporte: `enviado`, `asignado`, `en_rescate`, `rescatado`, `cerrado`.
  - Animal: `disponible`, `en_tramite`, `adoptado`.
  - Solicitud: `pendiente`, `aceptada`, `rechazada`.
  - Refugio: campo `verificado` (`false` hasta que lo apruebe un administrador).

**Códigos de respuesta**

| Código | Significado |
|---|---|
| 200 | Correcto |
| 201 | Recurso creado |
| 400 | Datos no válidos o incompletos |
| 401 | Sin sesión o credenciales incorrectas |
| 403 | Sin permisos para esa acción |
| 404 | No existe el recurso |
| 409 | Se incumple una regla de negocio (límites, capacidad, adopción en trámite…) |

**Formato de error** (igual en toda la API):

```json
{
  "error": "CODIGO_DEL_ERROR",
  "mensaje": "Explicación legible",
  "detalles": []
}
```

---

## 3. Tablas de rutas

### 3.1 Autenticación y usuarios

| Método | Ruta | Qué hace | Qué recibe | Devuelve | HU / RN |
|---|---|---|---|---|---|
| POST | `/api/auth/registro` | Crea una cuenta y envía el email de confirmación | `nombre`, `email`, `password`, `telefono` (opcional), `aceptaPrivacidad` | 201, 400 o 409 (email ya registrado) | HU-01 |
| GET | `/api/auth/confirmar/:token` | Activa la cuenta con el enlace del email | `token` en la ruta | 200 o 400 | HU-01 |
| POST | `/api/auth/login` | Inicia sesión | `email`, `password` | 200 + token, o 401 (sin decir qué dato falló) | HU-02 |
| GET | `/api/usuarios/me` | Muestra los datos del usuario autenticado | token | 200 o 401 | HU-15 |
| PUT | `/api/usuarios/me` | Edita nombre y teléfono | `nombre`, `telefono` | 200, 400 o 401 | HU-15 |
| GET | `/api/usuarios/me/datos` | Descarga todos sus datos en JSON | token | 200 o 401 | HU-15 |
| DELETE | `/api/usuarios/me` | Elimina la cuenta: borra datos personales y anonimiza los reportes | token | 200 o 401 | HU-15 |

### 3.2 Refugios

| Método | Ruta | Qué hace | Qué recibe | Devuelve | HU / RN |
|---|---|---|---|---|---|
| POST | `/api/refugios` | Da de alta un refugio (queda `verificado: false`) | `nombre`, `cif`, `direccion`, `latitud`, `longitud`, `capacidadMax` | 201 o 400 | HU-03 |
| GET | `/api/refugios` | Lista refugios. Con `?verificado=false` muestra los pendientes (solo admin) | `verificado` (opcional) | 200 o 403 | HU-04 |
| GET | `/api/refugios/:id` | Muestra un refugio | `id` en la ruta | 200 o 404 | HU-11 |
| PUT | `/api/refugios/:id` | Edita los datos y la capacidad | campos a cambiar | 200, 400, 403 o 404 | HU-03, RN-06 |
| PATCH | `/api/refugios/:id/verificar` | El administrador aprueba el refugio | `id` en la ruta | 200, 403 o 404 | HU-04, RN-05 |
| DELETE | `/api/refugios/:id` | Da de baja el refugio | `id` en la ruta | 200, 403 o 404 | HU-03 |

### 3.3 Reportes (entidad principal)

| Método | Ruta | Qué hace | Qué recibe | Devuelve | HU / RN |
|---|---|---|---|---|---|
| GET | `/api/reportes` | Lista los reportes del usuario autenticado | `estado` (opcional) | 200 + lista | HU-06 |
| GET | `/api/reportes/cercanos` | El refugio ve en el mapa los reportes pendientes cercanos | `lat`, `lng`, `radioKm`, `especie` y `urgencia` (opcionales) | 200 + lista (sin datos personales del ciudadano) o 403 | HU-07, RN-08 |
| GET | `/api/reportes/:id` | Muestra un reporte y su estado | `id` en la ruta | 200, 403 o 404 | HU-06, RN-08 |
| POST | `/api/reportes` | Crea un reporte y lo asigna al refugio más cercano con plazas | `especie`, `descripcion` (opcional), `latitud`, `longitud`, `fotos` | 201 (nuevo), 200 (vinculado a uno existente), 400 o 409 | HU-05, RN-01, RN-02, RN-03 |
| PUT | `/api/reportes/:id` | Cambia especie o descripción mientras esté en estado `enviado` | campos a cambiar | 200, 400, 403 o 404 | HU-05 |
| PATCH | `/api/reportes/:id/estado` | El refugio actualiza el estado (`en_rescate`, `rescatado`, `cerrado`) | `estado` | 200, 400, 403 o 404 | HU-06 |
| POST | `/api/reportes/:id/aceptar` | El refugio acepta el rescate y el ciudadano recibe un aviso | `id` en la ruta | 200, 403, 404 o 409 (sin plazas) | HU-08, RN-06 |
| POST | `/api/reportes/:id/rechazar` | El refugio rechaza y el reporte pasa al siguiente refugio | `id` en la ruta | 200, 403 o 404 | HU-08, RN-04 |
| DELETE | `/api/reportes/:id` | El ciudadano cancela su reporte (pasa a `cerrado`, no se borra) | `id` en la ruta | 200, 403 o 404 | HU-06 |

### 3.4 Animales

| Método | Ruta | Qué hace | Qué recibe | Devuelve | HU / RN |
|---|---|---|---|---|---|
| GET | `/api/animales` | Busca animales (solo `disponible`) | `especie`, `tamano`, `edadMax`, `lat`, `lng`, `radioKm` (todos opcionales) | 200 + lista (lista vacía si no hay resultados) | HU-10 |
| GET | `/api/animales/:id` | Muestra la ficha completa | `id` en la ruta | 200 o 404 | HU-11 |
| POST | `/api/animales` | El refugio publica la ficha de un animal | `especie`, `edadAprox`, `sexo`, `estadoSalud`, `vacunado`, `fotos` (mín. 1), `nombre`, `tamano`, `idReporte` (opcionales) | 201, 400, 403 (refugio no verificado) o 409 (capacidad llena) | HU-09, RN-05, RN-06 |
| PUT | `/api/animales/:id` | El refugio edita la ficha | campos a cambiar | 200, 400, 403 o 404 | HU-09 |
| DELETE | `/api/animales/:id` | El refugio retira la ficha | `id` en la ruta | 200, 403 o 404 | HU-09 |

### 3.5 Solicitudes de adopción

| Método | Ruta | Qué hace | Qué recibe | Devuelve | HU / RN |
|---|---|---|---|---|---|
| POST | `/api/solicitudes` | El adoptante envía una solicitud (queda `pendiente`) | `idAnimal`, `vivienda`, `experiencia`, `familia` | 201, 400, 404 o 409 (animal con adopción en trámite o ya tiene 2 pendientes) | HU-12, RN-07 |
| GET | `/api/solicitudes` | Adoptante: sus solicitudes. Refugio: las de sus animales | `estado` (opcional) | 200 + lista | HU-12, HU-13, RN-08 |
| GET | `/api/solicitudes/:id` | Muestra una solicitud | `id` en la ruta | 200, 403 o 404 | HU-13 |
| PATCH | `/api/solicitudes/:id` | El refugio acepta o rechaza. Al aceptar, el animal pasa a `en_tramite` | `estado` (`aceptada` o `rechazada`) | 200, 400, 403, 404 o 409 | HU-13, RN-07 |
| DELETE | `/api/solicitudes/:id` | El adoptante retira una solicitud pendiente | `id` en la ruta | 200, 403 o 404 | HU-12 |

### 3.6 Estado del servidor

| Método | Ruta | Qué hace | Qué recibe | Devuelve | HU / RN |
|---|---|---|---|---|---|
| GET | `/api/estado` | Comprueba que el servidor está funcionando | nada | 200 + `{ "ok": true }` | — |

---

## 4. Ejemplos JSON: `POST /api/reportes`

**Petición**

```http
POST /api/reportes
Authorization: Bearer <token>
Content-Type: application/json
```

```json
{
  "especie": "perro",
  "descripcion": "Perro mediano de pelo marrón, parece herido en una pata",
  "latitud": 37.3891,
  "longitud": -5.9845,
  "fotos": [
    "https://almacenamiento.ejemplo.eu/reportes/foto1.jpg"
  ]
}
```

**Respuesta 201** (reporte creado y asignado al refugio más cercano con plazas, RN-03)

```json
{
  "id": 12,
  "idUsuario": 5,
  "idRefugio": 3,
  "especie": "perro",
  "descripcion": "Perro mediano de pelo marrón, parece herido en una pata",
  "latitud": 37.3891,
  "longitud": -5.9845,
  "estado": "asignado",
  "fecha": "2026-11-23T10:15:00Z",
  "fotos": [
    "https://almacenamiento.ejemplo.eu/reportes/foto1.jpg"
  ]
}
```

**Respuesta 200** (ya existía un reporte a menos de 100 m en las últimas 48 h: se vincula al existente, HU-05)

```json
{
  "id": 9,
  "vinculado": true,
  "estado": "asignado",
  "mensaje": "Ya existe un reporte cercano. Se ha vinculado al existente."
}
```

**Respuesta 400** (falta la foto o la ubicación, RN-02)

```json
{
  "error": "VALIDACION",
  "mensaje": "Todo reporte necesita ubicación y al menos una foto",
  "detalles": ["fotos: se requiere al menos 1"]
}
```

**Respuesta 409** (el usuario ya tiene 3 reportes abiertos, RN-01)

```json
{
  "error": "LIMITE_REPORTES",
  "mensaje": "Ya tienes 3 reportes abiertos. Cierra alguno para crear otro."
}
```

---

## 5. Notas de diseño

- **RN-03 (asignación al refugio más cercano):** se resuelve dentro del `POST /api/reportes`, con una consulta de distancia sobre PostgreSQL + PostGIS.
- **RN-04 (reasignación a las 24 h):** no es una ruta, sino una tarea programada del servidor que mueve al siguiente refugio los reportes sin respuesta. Rechazar un reporte hace lo mismo al instante.
- **RN-08 (privacidad):** el teléfono y la ubicación exacta del usuario solo aparecen en las respuestas del refugio al que está asignado el caso.
- **RN-05 (refugio verificado):** las rutas de animales y de rescates devuelven 403 si el refugio tiene `verificado: false`.

---

## 6. Arrancar el backend

```bash
cd backend
npm install
cp .env.example .env
npm run dev
```

Comprobación:

```bash
curl http://localhost:3000/api/estado
# {"ok":true}
```
