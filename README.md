# 💖 My Heart - Aplicación para Parejas

Una aplicación integral y moderna creada para conectar a parejas, combinando las mejores características de aplicaciones líderes (*Paired, SumOne, Between, Lovewick, Locket*) en una sola experiencia interactiva con sincronización en tiempo real.

---

## 🌟 Características Principales

1. 🏠 **"Nuestro Rincón" (Dashboard Central):**
   * **Contador de amor en vivo:** Muestra los días, horas, minutos y segundos exactos juntos, actualizándose cada segundo.
   * **Avatares duales con estados de ánimo en tiempo real:** Cambia cómo te sientes (*"Pensando en ti 💭"*, *"Enamorado/a 🥰"*, *"Listo/a para una cita 🍷"*) y mira el estado de tu pareja al instante.
   * **Botón de Latido Háptico (*Heartbeat*):** Toca el botón para enviar un latido que vibra en el teléfono de tu pareja con una animación en pantalla completa.
   * **Mascota Virtual ("Corazoncito 🐾"):** Sube de nivel y gana puntos de experiencia (XP) al responder preguntas y completar citas juntos.

2. 💬 **"Daily Sparks" (Preguntas Diarias):**
   * Una pregunta diaria sorpresa con **mecanismo de revelación bloqueada**: no puedes ver la respuesta de tu pareja hasta que no respondas la tuya.

3. 📸 **Bóveda de Recuerdos & Momentos:**
   * Línea de tiempo cronológica privada con fotos, fechas especiales y lugares visitados.

4. 🎯 **Bucket List & Ruleta de Citas:**
   * Lista compartida de metas y sueños juntos (+50 XP al tachar una).
   * **Ruleta de citas aleatorias** para decidir planes sorpresa.

5. 💌 **Cápsulas del Tiempo & Cartas Secretas:**
   * Escribe cartas hoy que permanecen selladas y solo se desbloquean en una fecha elegida o aniversario.

6. 📱 **Soporte para Widgets de Pantalla de Inicio:**
   * Arquitectura lista para conectar con `home_widget` y mostrar fotos en vivo y contadores en la pantalla de inicio del celular.

---

## 🏗️ Arquitectura Técnica

```text
My-Heart/
├── app/                  # Frontend móvil en Flutter (Android / iOS)
├── server/               # Backend API en Node.js / TypeScript + WebSockets (Render)
└── database/             # Esquema PostgreSQL optimizado para Neon
    └── schema.sql
```

---

## 🚀 Guía de Inicio Rápido

### 1. Base de Datos en Neon (PostgreSQL)
1. Crea una base de datos gratuita en [Neon.tech](https://neon.tech).
2. Copia tu cadena de conexión `DATABASE_URL` (ej. `postgresql://usuario:pass@ep-xxxx.neon.tech/neondb?sslmode=require`).
3. Ejecuta el script de creación de tablas:
   * Puedes pegar directamente el contenido de `database/schema.sql` en la consola SQL de Neon, o
   * Ejecutar desde `server/`: `npm run db:init` con tu `DATABASE_URL` configurado en el archivo `.env`.

### 2. Backend en Render
1. Sube este repositorio a GitHub.
2. En [Render.com](https://render.com), crea un nuevo **Web Service** o usa el archivo `server/render.yaml` (Blueprint).
3. Añade la variable de entorno `DATABASE_URL` con tu URL de Neon.
4. ¡Render desplegará tu backend con HTTPS y WebSockets automáticamente!

### 3. Aplicación Móvil (Flutter)
1. Entra a la carpeta de la app:
   ```bash
   cd app
   ```
2. Instala dependencias:
   ```bash
   flutter pub get
   ```
3. Ejecuta en tu dispositivo o emulador:
   ```bash
   flutter run
   ```
   *(Para conectar con el backend de producción en Render, actualiza la URL en `lib/core/constants/api_constants.dart`).*
