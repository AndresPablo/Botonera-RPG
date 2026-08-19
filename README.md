# Documentación del Proyecto: Botonera de Sonido para Rol (TTRPG Soundboard)

Un dispositivo físico y portátil diseñado para Directores de Juego (Game Masters) y jugadores de rol de mesa (D&D, Pathfinder, Call of Cthulhu, etc.). Permite disparar efectos de sonido inmediatos y pistas de ambientación mediante un teclado matricial físico, con salida a parlante integrado para la mesa y conector Jack 3.5 mm para sistemas de sonido externos.

---

## 1. Especificaciones del Sistema

- **Controlador:** Arduino Nano (ATmega328P, 16 MHz, 5V).
- **Módulo de Audio:** DFPlayer Mini (decodificador MP3/WAV por hardware, DAC estéreo de 24 bits).
- **Almacenamiento:** Tarjeta MicroSD (hasta 32 GB, formateada en FAT32).
- **Interfaz de Entrada:** Teclado matricial 4x4 (16 teclas con soporte de 4 bancos = 48 sonidos directos + controles de función).
- **Salidas de Audio:**
- Altavoz interno mono de 3W (4Ω u 8Ω) accionado por el amplificador interno del DFPlayer.
- Salida de línea estéreo Jack 3.5 mm (TRS) para auriculares o conexión a parlante amplificado de mesa.

- **Alimentación:** 5V vía puerto USB (Powerbank) o batería recargable Li-ion 3.7V (18650) con módulo cargador TP4056 y elevador de tensión (Step-Up a 5V).

---

## 2. Lista de Materiales (Bill of Materials - BOM)

| Componente                           | Cantidad | Descripción                                                                           |
| ------------------------------------ | -------- | ------------------------------------------------------------------------------------- |
| **Arduino Nano V3**                  | 1        | Microcontrolador principal (ATmega328P con conector Mini-USB o USB-C).                |
| **Módulo DFPlayer Mini**             | 1        | Reproductor de audio MP3/WAV con slot MicroSD integrado.                              |
| **Teclado Matricial 4x4**            | 1        | Teclado de membrana o matricial rígido (8 pines de conexión).                         |
| **Parlante Miniatura**               | 1        | 3W de potencia, impedancia de 4Ω u 8Ω (diámetro sugerido 30 mm a 50 mm).              |
| **Conector Jack 3.5 mm Hembra**      | 1        | Tipo TRS para montaje en chasis/panel.                                                |
| **Tarjeta MicroSD**                  | 1        | Capacidad de 8 GB a 32 GB (Clase 10, formato FAT32).                                  |
| **Resistencia 1 kΩ (1/4W)**          | 1        | Resistencia en serie para filtrar ruido serial en la línea `RX` del DFPlayer.         |
| **Módulo TP4056 + Elevador Step-Up** | 1        | Módulo de carga USB-C con protección + elevador a 5V (opcional para batería interna). |
| **Interruptor ON/OFF**               | 1        | Interruptor deslizante o balancín para corte de energía.                              |
| **Cables y Placa de Prototipado**    | -        | Cables jumper, tira de pines hembra y placa PCB universal o protoboard.               |

---

## 3. Diagrama Esquemático y Asignación de Pines

### 3.1. Esquema de Conexiones

```
                 +-----------------------------------+
                 |           ARDUINO NANO            |
                 |                                   |
 (R1) Fila 1 <---| D4                             5V |---> +5V Bus VCC
 (R2) Fila 2 <---| D5                            GND |---> GND Masa Común
 (R3) Fila 3 <---| D6                                |
 (R4) Fila 4 <---| D7                        D2 (RX) |<-----------+ (TX DFPlayer)
 (C1) Col 1  <---| D8                        D3 (TX) |--[1kΩ]--+   |
 (C2) Col 2  <---| D9                                |        |   |
 (C3) Col 3  <---| D10                               |        |   |
 (C4) Col 4  <---| D11                               |        |   |
                 +-----------------------------------+        |   |
                                                              |   |
                 +-----------------------------------+        |   |
                 |          DFPLAYER MINI            |        |   |
                 |                                   |        |   |
 +5V (VCC) ----->| Pin 1 (VCC)           Pin 16 (BUSY|        |   |
                 | Pin 2 (RX) <-------------------------------+   |
                 | Pin 3 (TX) ------------------------------------+
                 | Pin 4 (DAC_R) --------+           |
                 | Pin 5 (DAC_L) ----+   |           |
 (Parlante +) <--| Pin 6 (SPK_1)     |   |           |
 GND (Masa) ---->| Pin 7 (GND)       |   |           |
 (Parlante -) <--| Pin 8 (SPK_2)     |   |           |
                 +-------------------|---|-----------+
                                     |   |
       +-----------------------------+   |
       |     +---------------------------+
       |     |     +---------------------------------+ GND
       v     v     v
   +--------------------+
   |  JACK 3.5mm HEMBRA |
   | Tip   Ring  Sleeve |
   | (L)   (R)   (GND)  |
   +--------------------+

```

### 3.2. Tabla de Conexiones Pin a Pin

#### Comunicación y Audio

- **Arduino `5V**`$\rightarrow$ **DFPlayer`Pin 1 (VCC)\*\*`
- **Arduino `GND**`$\rightarrow$ **DFPlayer`Pin 7 (GND)**` y **`Pin 10 (GND)`\*\*
- **Arduino `D2**`$\rightarrow$ **DFPlayer`Pin 3 (TX)\*\*` (SoftwareSerial RX)
- **Arduino `D3**`$\rightarrow$ **Resistencia 1 kΩ** $\rightarrow$ **DFPlayer`Pin 2 (RX)\*\*` (SoftwareSerial TX)
- **Parlante (+)** $\rightarrow$ **DFPlayer `Pin 6 (SPK_1)**`
- **Parlante (-)** $\rightarrow$ **DFPlayer `Pin 8 (SPK_2)**` _(No conectar a GND)_
- **Jack 3.5 mm Tip (L)** $\rightarrow$ **DFPlayer `Pin 5 (DAC_L)**`
- **Jack 3.5 mm Ring (R)** $\rightarrow$ **DFPlayer `Pin 4 (DAC_R)**`
- **Jack 3.5 mm Sleeve (GND)** $\rightarrow$ **DFPlayer `Pin 10 (GND)**`

#### Teclado 4x4

- **Fila 1 (R1)** $\rightarrow$ **Arduino `D4**`
- **Fila 2 (R2)** $\rightarrow$ **Arduino `D5**`
- **Fila 3 (R3)** $\rightarrow$ **Arduino `D6**`
- **Fila 4 (R4)** $\rightarrow$ **Arduino `D7**`
- **Columna 1 (C1)** $\rightarrow$ **Arduino `D8**`
- **Columna 2 (C2)** $\rightarrow$ **Arduino `D9**`
- **Columna 3 (C3)** $\rightarrow$ **Arduino `D10**`
- **Columna 4 (C4)** $\rightarrow$ **Arduino `D11**`

---

## 4. Preparación de la Tarjeta MicroSD

1. **Formato:** Formatear la tarjeta en **FAT32** (tamaño de unidad de asignación estándar: 32 KB).
2. **Estructura de Carpetas y Archivos:**

- Crear una carpeta llamada `mp3` en la raíz de la tarjeta SD.
- Nombrar los archivos de audio con números correlativos de 4 dígitos: `0001.mp3`, `0002.mp3`, `0003.mp3`, etc.
- Frecuencia de muestreo recomendada: 44.1 kHz, tasa de bits: 128 kbps o 320 kbps (CBR o VBR).

### Organización de Bancos Sugerida

- **Banco A (Tracks 0001 a 0010) — Combate:**
- `0001.mp3`: Espadazo / Golpe físico
- `0002.mp3`: Disparo de flecha / ballesta
- `0003.mp3`: Golpe crítico / Fanfarria de victoria
- `0004.mp3`: Pifia crítica / Sonido cómico de fallo
- `0005.mp3`: Rugido de dragón / monstruo
- `0006.mp3` a `0010.mp3`: Efectos de daño, escudo, etc.

- **Banco B (Tracks 0011 a 0020) — Ambiente:**
- `0011.mp3`: Taberna concurrida
- `0012.mp3`: Lluvia y truenos
- `0013.mp3`: Mazmorra / Viento lúgubre
- `0014.mp3`: Bosque pacífico
- `0015.mp3` a `0020.mp3`: Mercados, fogata, campamento.

- **Banco C (Tracks 0021 a 0030) — Magia:**
- `0021.mp3`: Bola de fuego / Explosión
- `0022.mp3`: Hechizo de curación
- `0023.mp3`: Teletransporte / Portal
- `0024.mp3`: Rayo eléctrico
- `0025.mp3` a `0030.mp3`: Encantamientos, ilusiones.

- **Banco D (Tracks 0031 a 0040) — Eventos Especiales:**
- `0031.mp3`: Trampa activada
- `0032.mp3`: Puerta pesada de piedra abriéndose
- `0033.mp3`: Cofre / Monedas de oro
- `0034.mp3`: Suspenso / Tensión
- `0035.mp3` a `0040.mp3`: Campanas, susurros oscuros.

---

## 5. Código Firmware para Arduino

Instalar previamente desde el _Gestor de Librerías_ de Arduino IDE:

1. `Keypad` por Mark Stanley & Alexander Brevig.
2. `DFRobotDFPlayerMini` por DFRobot.

```cpp
#include <SoftwareSerial.h>
#include <DFRobotDFPlayerMini.h>
#include <Keypad.h>

// Definición de pines para SoftwareSerial
#define PIN_RX 2
#define PIN_TX 3

SoftwareSerial dfSerial(PIN_RX, PIN_TX);
DFRobotDFPlayerMini dfPlayer;

// Configuración del Teclado Matricial 4x4
const byte ROWS = 4;
const byte COLS = 4;
char keys[ROWS][COLS] = {
  {'1', '2', '3', 'A'},
  {'4', '5', '6', 'B'},
  {'7', '8', '9', 'C'},
  {'*', '0', '#', 'D'}
};

byte rowPins[ROWS] = {4, 5, 6, 7};     // R1, R2, R3, R4
byte colPins[COLS] = {8, 9, 10, 11};   // C1, C2, C3, C4

Keypad keypad = Keypad(makeKeymap(keys), rowPins, colPins, ROWS, COLS);

// Variables de estado
int currentBankOffset = 0; // 0 = Banco A, 10 = Banco B, 20 = Banco C, 30 = Banco D
uint8_t currentVolume = 24; // Nivel de volumen (0 a 30)

void setup() {
  dfSerial.begin(9600);
  Serial.begin(115200);

  Serial.println(F("[INFO] Inicializando DFPlayer Mini..."));

  if (!dfPlayer.begin(dfSerial)) {
    Serial.println(F("[ERROR] No se pudo comunicar con DFPlayer."));
    Serial.println(F("1. Verifique que la tarjeta SD esté insertada."));
    Serial.println(F("2. Verifique la resistencia de 1k entre D3 y RX."));
    Serial.println(F("3. Verifique la alimentación de 5V."));
    while (true) {
      delay(500);
    }
  }

  Serial.println(F("[OK] DFPlayer Mini listo."));
  dfPlayer.volume(currentVolume);
  dfPlayer.EQ(DFPLAYER_EQ_NORMAL);
}

void loop() {
  char key = keypad.getKey();

  if (key) {
    handleKeyPress(key);
  }
}

void handleKeyPress(char key) {
  switch (key) {
    // Selección de Bancos
    case 'A':
      currentBankOffset = 0;
      Serial.println(F("Banco seleccionado: A (Combate)"));
      break;
    case 'B':
      currentBankOffset = 10;
      Serial.println(F("Banco seleccionado: B (Ambiente)"));
      break;
    case 'C':
      currentBankOffset = 20;
      Serial.println(F("Banco seleccionado: C (Magia)"));
      break;
    case 'D':
      currentBankOffset = 30;
      Serial.println(F("Banco seleccionado: D (Especiales)"));
      break;

    // Control de Reproducción
    case '*':
      dfPlayer.stop();
      Serial.println(F("Reproducción detenida."));
      break;

    case '#':
      // Pausar o reanudar
      dfPlayer.pause();
      Serial.println(F("Pausa / Play alternado."));
      break;

    // Disparo de Pistas Numéricas
    default:
      if (key >= '1' && key <= '9') {
        int track = (key - '0') + currentBankOffset;
        playTrack(track);
      } else if (key == '0') {
        int track = 10 + currentBankOffset;
        playTrack(track);
      }
      break;
  }
}

void playTrack(int trackNumber) {
  Serial.print(F("Reproduciendo pista MP3 #"));
  Serial.println(trackNumber);
  dfPlayer.playMp3Folder(trackNumber);
}

```

---

## 6. Guía de Uso Rápido en Mesa

| Tecla         | Acción en el Modo Predeterminado                                                             |
| ------------- | -------------------------------------------------------------------------------------------- |
| **`A`**       | Selecciona **Banco A (Combate)**. Las teclas 1–0 disparan pistas `0001.mp3` a `0010.mp3`.    |
| **`B`**       | Selecciona **Banco B (Ambiente)**. Las teclas 1–0 disparan pistas `0011.mp3` a `0020.mp3`.   |
| **`C`**       | Selecciona **Banco C (Magia)**. Las teclas 1–0 disparan pistas `0021.mp3` a `0030.mp3`.      |
| **`D`**       | Selecciona **Banco D (Especiales)**. Las teclas 1–0 disparan pistas `0031.mp3` a `0040.mp3`. |
| **`1` a `9**` | Dispara el efecto del slot 1 al 9 correspondiente al banco activo.                           |
| **`0`**       | Dispara el efecto del slot 10 correspondiente al banco activo.                               |
| **`*`**       | **Stop:** Detiene inmediatamente cualquier sonido en reproducción.                           |
| **`#`**       | **Pausa / Reanudar:** Pausa o continúa la reproducción de la pista actual.                   |

---

## 7. Diagnóstico y Solución de Problemas (Troubleshooting)

1. **Zumbido o ruido digital en el altavoz:**
   1. Asegurarse de haber colocado la **resistencia de 1 kΩ en serie entre el pin D3 del Arduino y el pin RX (Pin 2) del DFPlayer**.
   2. Agregar un capacitor electrolítico de $100\,\mu\text{F}$ a $470\,\mu\text{F}$ entre `VCC` y `GND` cerca del módulo DFPlayer para estabilizar la línea de alimentación.
2. **El DFPlayer no inicia (`[ERROR] No se pudo comunicar`):**
   1. Verificar que la tarjeta MicroSD esté formateada en **FAT32** y no en exFAT o NTFS.
   2. Comprobar que la carpeta se llame exactamente `mp3` (en minúsculas) y los archivos tengan nombres numéricos de cuatro dígitos (`0001.mp3`).
   3. Verificar que las líneas RX y TX no estén invertidas (`D2` $\rightarrow$ `TX`, `D3` $\rightarrow$ `RX`).
3. **Distorsión o reinicio del Arduino al subir el volumen:**
   1. El altavoz consume hasta 600 mA en picos de volumen alto. Si se alimenta por el puerto USB de una computadora, puede causar caídas de tensión. Utilizar una fuente USB independiente de al menos 5V / 1A o un Powerbank.
4. **Conexión a parlante externo o auriculares:**
   1. Al conectar un cable al Jack 3.5 mm, utilizar siempre las salidas de línea `DAC_L` y `DAC_R` con masa `GND`. Nunca conectar las salidas amplificadas `SPK_1` o `SPK_2` a la entrada de un amplificador externo.
