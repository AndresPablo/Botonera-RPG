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
  {
    '1',
    '2',
    '3',
    'A'
  },
  {
    '4',
    '5',
    '6',
    'B'
  },
  {
    '7',
    '8',
    '9',
    'C'
  },
  {
    '*',
    '0',
    '#',
    'D'
  }
};

byte rowPins[ROWS] = {
  4,
  5,
  6,
  7
}; // R1, R2, R3, R4
byte colPins[COLS] = {
  8,
  9,
  10,
  11
}; // C1, C2, C3, C4

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
