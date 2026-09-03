# Riqsi - Asistente de Visión Inteligente 👁️📱

Riqsi es un asistente inteligente de visión del entorno para personas con discapacidad visual. Esta versión utiliza una arquitectura híbrida de visión artificial: la cámara de la PC actúa como sensor remoto (usando OpenCV y YOLOv8 opcional) y envía las detecciones en tiempo real al teléfono móvil a través de WebSockets, donde el usuario escucha la descripción por voz (TTS real) y siente la vibración.

---

## 🛠️ Requisitos de Instalación (PC)

Para correr el servidor de visión que activa la cámara web y realiza las detecciones:

1. Asegúrate de tener instalado **Python 3.8+**.
2. Instala las dependencias requeridas en la consola de comandos de tu PC:
   ```bash
   pip install opencv-python websockets
   ```
   *(Opcional: Si deseas usar detección de objetos avanzada YOLOv8 en lugar del detector facial rápido por defecto, instala: `pip install ultralytics`)*.

---

## 🚀 Guía de Ejecución Paso a Paso

### 1. Iniciar el Servidor de Visión (PC)
Ejecuta el script de Python ubicado en la carpeta del proyecto:
```bash
python server/detector.py
```
Esto encenderá tu cámara web local y abrirá una ventana de video llamada **"Riqsi Vision Server"**.

* **Teclas rápidas en la ventana del servidor:**
  * `q`: Detener y cerrar el servidor.
  * `p`: Simular obstáculo `Puerta adelante`.
  * `e`: Simular obstáculo `Escalón adelante`.
  * `b`: Simular obstáculo `Bicicleta a la derecha`.
  * `a`: Simular obstáculo `Automóvil adelante` (Alerta Crítica).

---

### 2. Conectar el Cliente Móvil (Celular)
1. Conecta tu celular y tu PC a la **misma red Wi-Fi**.
2. Obtén la **dirección IP local** de tu PC (en Windows abre `cmd` y escribe `ipconfig`, busca la dirección IPv4, por ejemplo `192.168.1.15`).
3. En la aplicación Riqsi en tu teléfono móvil:
   * Ve a la pestaña **Perfil** (tercer icono abajo).
   * Selecciona la opción **Servidor IP** e ingresa la dirección IP de tu PC.
   * Guarda los cambios.
4. Regresa a la pestaña **Inicio** y presiona el gran botón de play central.
5. ¡Listo! La cámara de tu PC transmitirá la información visual. Cuando detecte una persona frente a la pantalla o simules un objeto presionando las teclas rápidas, el teléfono móvil **reproducirá el audio en voz alta en español** y **vibrará** al instante.
