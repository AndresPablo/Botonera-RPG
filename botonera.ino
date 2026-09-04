#include <SoftwareSerial.h>
#include <DFRobotDFPlayerMini.h>
#include <Keypad.h>

#define PIN_RX 2
#define PIN_TX 3

SoftwareSerial dfSerial(PIN_RX, PIN_TX);
DFRobotDFPlayerMini dfPlayer;

const byte ROWS = 4;
const byte COLS = 4;
char keys[ROWS][COLS] = {
  {'1', '2', '3', 'A'},
  {'4', '5', '6', 'B'},
  {'7', '8', '9', 'C'},
  {'*', '0', '#', 'D'}
};

byte rowPins[ROWS] = {4, 5, 6, 7};
byte colPins[COLS] = {8, 9, 10, 11};
Keypad keypad = Keypad(makeKeymap(keys), rowPins, colPins, ROWS, COLS);

uint8_t currentFolder = 1;
uint8_t currentVolume = 30;

void setup() {
  dfSerial.begin(9600);
  Serial.begin(115200);

  Serial.println(F("\n========================================"));
  Serial.println(F("  DIAGNÓSTICO DE AUDIO - DFPLAYER"));
  Serial.println(F("========================================"));

  // 1. Inicializar DFPlayer con reintentos
  delay(2000);
  if (!dfPlayer.begin(dfSerial, true, true)) {
    Serial.println(F("[ERROR] No se pudo iniciar DFPlayer."));
    while (true);
  }
  
  Serial.println(F("[OK] DFPlayer iniciado."));

  // 2. SUBIR VOLUMEN POR CÓDIGO (ignora la perilla física)
  dfPlayer.volume(currentVolume);
  Serial.print(F("[VOL] Volumen fijado en: "));
  Serial.println(currentVolume);
  Serial.println(F("[INFO] Si no hay sonido, gira la perilla azul del DFPlayer."));

  // 3. PRUEBA DE REPRODUCCIÓN DESDE LA RAÍZ (archivo /001.mp3)
  Serial.println(F("\n--- PRUEBA 1: Buscando /001.mp3 en la RAÍZ ---"));
  dfPlayer.playMp3Folder(1); // Intenta reproducir 001.mp3 en raíz
  delay(300); // Pequeña pausa para que el DFPlayer procese
  // Leer posibles mensajes de error desde el DFPlayer
  if (dfPlayer.available()) {
    uint8_t type = dfPlayer.readType();
    uint8_t value = dfPlayer.read();
    if (type == DFPlayerError) {
      Serial.print(F("[ERROR] Código de error: "));
      Serial.println(value);
    } else {
      Serial.println(F("[OK] Comando enviado (¿Se oye algo?)"));
    }
  } else {
    Serial.println(F("[OK] Comando enviado (sin respuesta inmediata)."));
  }
  delay(1500);
  dfPlayer.stop();
  delay(500);

  // 4. PRUEBA DE REPRODUCCIÓN DESDE SUBCARPETA (archivo /01/001.mp3)
  Serial.println(F("\n--- PRUEBA 2: Buscando /01/001.mp3 en CARPETA 01 ---"));
  dfPlayer.playFolder(1, 1);
  delay(300);
  if (dfPlayer.available()) {
    uint8_t type = dfPlayer.readType();
    uint8_t value = dfPlayer.read();
    if (type == DFPlayerError) {
      Serial.print(F("[ERROR] Código de error: "));
      Serial.println(value);
      Serial.println(F("       Posibles causas:"));
      Serial.println(F("       - La carpeta no existe o no se llama '01'"));
      Serial.println(F("       - El archivo no existe o no se llama '001.mp3'"));
      Serial.println(F("       - La SD no está formateada en FAT32"));
    } else {
      Serial.println(F("[OK] Comando enviado correctamente."));
    }
  } else {
    Serial.println(F("[OK] Comando enviado (sin respuesta inmediata)."));
  }

  Serial.println(F("\n========================================"));
  Serial.println(F("SISTEMA LISTO. Presiona teclas 1-9, A-D."));
  Serial.println(F("========================================\n"));
}

void loop() {
  char key = keypad.getKey();
  if (key) {
    handleKeyPress(key);
  }
}

void handleKeyPress(char key) {
  switch (key) {
    case 'A': currentFolder = 1; Serial.println(F("Banco: 01")); break;
    case 'B': currentFolder = 2; Serial.println(F("Banco: 02")); break;
    case 'C': currentFolder = 3; Serial.println(F("Banco: 03")); break;
    case 'D': currentFolder = 4; Serial.println(F("Banco: 04")); break;
    case '*': dfPlayer.stop(); Serial.println(F("Stop")); break;
    case '#': dfPlayer.pause(); Serial.println(F("Pausa")); break;
    default:
      if (key >= '1' && key <= '9') {
        playSound(currentFolder, key - '0');
      } else if (key == '0') {
        playSound(currentFolder, 10);
      }
      break;
  }
}

void playSound(uint8_t folder, uint8_t file) {
  Serial.print(F("Reproduciendo /"));
  Serial.print(folder);
  Serial.print(F("/00"));
  Serial.print(file);
  Serial.println(F(".mp3..."));

  // Enviar comando (no devuelve nada)
  dfPlayer.playFolder(folder, file);
  
  // Pequeña pausa para que el DFPlayer procese y podamos leer su estado
  delay(100);
  
  // Verificar si hay algún mensaje de error del DFPlayer
  if (dfPlayer.available()) {
    uint8_t type = dfPlayer.readType();
    uint8_t value = dfPlayer.read();
    if (type == DFPlayerError) {
      Serial.print(F("  ❌ ERROR DFPlayer (código "));
      Serial.print(value);
      Serial.println(F(")"));
      Serial.println(F("     El archivo NO EXISTE o la carpeta es incorrecta."));
      Serial.println(F("     Verifica: carpeta '01', archivo '001.mp3'."));
    } else {
      Serial.println(F("  ✅ Comando enviado (sin errores reportados)."));
    }
  } else {
    Serial.println(F("  ✅ Comando enviado (sin respuesta inmediata)."));
  }
}
