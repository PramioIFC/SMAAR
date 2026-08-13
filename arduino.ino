/*
  SMAAR - Controlador de Porteira
  Versao corrigida (rodada 3)
 
  Correcoes desta rodada
    7. [MUDANCA DE LOGICA] A porteira agora trava sozinha em dois pontos
       fisicos diferentes, cada um com seu proprio ima e seu proprio servo
         - SENSOR_MAG1 detecta a porteira travada no BATENTE (posicao de
           casa/fechada). O servoTrava e quem segura essa trava.
         - SENSOR_MAG2 detecta a porteira travada no PALANQUE (posicao
           aberta). O servoAbertura e quem segura essa trava.
       'Abrir' (comando ou botao) destrava o lado do batente (servoTrava),
       deixando a porteira livre pra ir ate o palanque, onde ela trava
       sozinha via ima 2. 'Fechar' destrava o lado do palanque
       (servoAbertura), deixando a porteira voltar e travar sozinha no
       batente via ima 1. Os comandos NAO travam nada diretamente - eles
       so liberam o lado oposto ao que esta travado no momento.
    8. [CORRIGIDO] Antes, se um comando Wi-Fi chegasse num estado em que a
       acao nao podia ser executada (ex pediu abrir mas a porteira nao
       estava travada no batente), o Arduino nunca respondia ao Django -
       reintroduzindo o erro de timeout que a rodada 2 ja tinha corrigido.
       Agora ele SEMPRE responde se recebeu um comando neste ciclo, mesmo
       quando a acao e ignorada por estado incompativel.
    9. [A CALIBRAR] TEMPO_DESTRAVE_TRAVA e TEMPO_DESTRAVE_ABERTURA sao
       valores conservadores de partida (1500ms e 500ms). Eles definem
       quanto tempo o Arduino espera, segurando a resposta HTTP, depois de
       destravar o servo. Ajuste com base no teste fisico - mas fique de
       olho no timeout configurado no lado do Django/Flutter pra nao
       reintroduzir o erro do item 8.
 
  Correcoes de rodadas anteriores (mantidas)
    1. Canal TCP extraido dinamicamente do +IPD,canal - responderOK
       nao hardcoda mais o canal 0, evitando 502 no Django.
    2. Wi-Fi realmente conecta a rede (CWJAP descomentado).
    3. lerComandoWifi() nao bloqueia mais o loop usa buffer global e
       processa quando encontra fim de frame HTTP.
    4. aplicarEstadoTravado() coloca delay entre os dois servos no boot
       para evitar reset por pico de corrente.
    6. responderOK() calcula Content-Length dinamicamente.
*/

#include <Servo.h>
#include <SoftwareSerial.h>

// -- Wi-Fi ----------------------------------------------------------------
SoftwareSerial esp(10, 11);    // RX=10, TX=11

// -- Servos ---------------------------------------------------------------
Servo servoTrava;       // segura a trava no BATENTE (posicao fechada/casa)
Servo servoAbertura;    // segura a trava no PALANQUE (posicao aberta)

// -- Pinos ----------------------------------------------------------------
const int SENSOR_MAG1     = 2;   // ima do BATENTE - porteira travada em casa
const int SENSOR_MAG2     = 3;   // ima do PALANQUE - porteira travada aberta
const int BOTAO_ABRIR     = 5;   // antes BOTAO_DESTRAVAR
const int BOTAO_FECHAR    = 4;   // antes BOTAO_TRAVAR
const int LED_VERMELHO    = 6;
const int LED_VERDE       = 7;

// -- Angulos dos servos ---------------------------------------------------
const int SERVO_TRAVADO    = 85;
const int SERVO_DESTRAVADO = 0;

// -- Timing de destrave (item 9 - A CALIBRAR no hardware real) ------------
const unsigned long TEMPO_DESTRAVE_TRAVA    = 4000;  // ms - lado batente (abrir)
const unsigned long TEMPO_DESTRAVE_ABERTURA = 500;   // ms - lado palanque (fechar)

// -- Configuracao do Backend Django ---------------------------------------
const String DJANGO_IP   = "192.168.x.x";  // <-- IP LOCAL DO SEU PC (Wi-Fi)
const int    DJANGO_PORT = 8000;
const int    PORTEIRA_ID = 1;

// Buffer global para acumular bytes do ESP sem bloquear o loop.
String _bufferWifi = "";

// Canal TCP da ultima requisicao recebida pelo ESP8266.
// Extraido do prefixo +IPD,canal,tamanho de cada frame.
int _canalAtual = 0;

// Estado anterior dos sensores (para detectar movimento manual)
bool ultimoEstadoEmCasa = false;
bool ultimoEstadoNoPalanque = false;

// Temporizadores nao-bloqueantes para manter destravado
unsigned long ultimoDestraveTrava = 0;
unsigned long ultimoDestraveAbertura = 0;

// -------------------------------------------------------------------------
void setup() {
  Serial.begin(115200);

  /*
    Mantido em 115200 - testado na pratica pelo usuario, funcionando de
    forma consistente neste hardware especifico. Se notar comandos
    perdidos no futuro, 9600 e a alternativa mais segura (requer
    reconfigurar o ESP com AT+UART_DEF=9600,8,1,0,0).
  */
  esp.begin(115200);

  servoTrava.attach(9);
  servoAbertura.attach(8);

  pinMode(SENSOR_MAG1,  INPUT);
  pinMode(SENSOR_MAG2,  INPUT);
  pinMode(BOTAO_ABRIR,  INPUT_PULLUP);
  pinMode(BOTAO_FECHAR, INPUT_PULLUP);
  pinMode(LED_VERDE,    OUTPUT);
  pinMode(LED_VERMELHO, OUTPUT);

  /*
    Estado inicial seguro assume travado no batente, com delay entre os
    dois servos pra evitar pico de corrente que poderia resetar o Arduino.
  */
  servoTrava.write(SERVO_TRAVADO);
  delay(800);
  servoAbertura.write(SERVO_DESTRAVADO);
  digitalWrite(LED_VERDE, HIGH);
  digitalWrite(LED_VERMELHO, LOW);

  // -- Configuracao do ESP8266 --------------------------------------------
  Serial.println(F("Configurando ESP8266..."));

  enviarAT("AT+RST",      2000);
  enviarAT("AT+CWMODE=1", 500);

  Serial.println(F("Conectando ao Wi-Fi..."));
  enviarAT("AT+CWJAP=\"Nomerede\",\"Senharede\"", 10000);
  delay(2000);

  // Exibe o IP no Serial Monitor - anote para configurar no app
  Serial.println(F("IP do Arduino:"));
  enviarAT("AT+CIFSR", 2000);
  Serial.println(F("--- IP acima ---"));

  enviarAT("AT+CIPMUX=1",       500);
  enviarAT("AT+CIPSERVER=1,80", 1000);

  Serial.println(F("Sistema pronto. Aguardando comandos..."));
  Serial.println(F("-------------------------------------------"));
}

// -------------------------------------------------------------------------
void loop() {
  bool btnFisicoAbrir  = (digitalRead(BOTAO_ABRIR)  == LOW);
  bool btnFisicoFechar = (digitalRead(BOTAO_FECHAR) == LOW);

  bool comandoAbrir  = false;
  bool comandoFechar = false;
  lerComandoWifi(comandoAbrir, comandoFechar);

  bool emCasa     = (digitalRead(SENSOR_MAG1) == LOW);  // travada no batente
  bool noPalanque = (digitalRead(SENSOR_MAG2) == LOW);  // travada no palanque

  // Logica de Botao Unico (usando o botao do Pino 4)
  bool botaoAbrir = btnFisicoAbrir;
  bool botaoFechar = false;

  if (btnFisicoFechar) {
    if (emCasa) {
      // Se esta fechada no batente, o botao funciona como ABRIR
      botaoAbrir = true;
    } else if (noPalanque) {
      // Se esta aberta no palanque, o botao funciona como FECHAR
      botaoFechar = true;
    } else {
      // Se esta no meio do caminho, aciona os dois para resgate
      botaoAbrir = true;
      botaoFechar = true;
    }
  }

  if (emCasa && !ultimoEstadoEmCasa) {
    // Levanta a trava IMEDIATAMENTE antes de gastar 4s com a rede
    servoTrava.write(SERVO_TRAVADO);
    digitalWrite(LED_VERDE,    HIGH);
    digitalWrite(LED_VERMELHO, LOW);
    notificarBackend("fechado");
  }
  if (noPalanque && !ultimoEstadoNoPalanque) {
    // Levanta a trava IMEDIATAMENTE antes de gastar 4s com a rede
    servoAbertura.write(SERVO_TRAVADO);
    digitalWrite(LED_VERDE,    HIGH);
    digitalWrite(LED_VERMELHO, LOW);
    notificarBackend("aberto");
  }

  ultimoEstadoEmCasa = emCasa;
  ultimoEstadoNoPalanque = noPalanque;

  // =========================================================================
  // LOGICA DE OVERRIDE (BOTOES/APP SEMPRE FUNCIONAM COMO RESGATE)
  // =========================================================================
  
  if (botaoAbrir || comandoAbrir) {
    // Forca o destrave do batente independente dos sensores
    Serial.println(F("Acao: ABRIR (destrava batente forcado)"));
    servoTrava.write(SERVO_DESTRAVADO);
    digitalWrite(LED_VERMELHO, HIGH);
    digitalWrite(LED_VERDE,    LOW);
    ultimoDestraveTrava = millis(); // Inicia o tempo destravado sem congelar
    if (botaoAbrir) notificarBackend("aberto");
  } else if (emCasa) {
    // Se passou o tempo de destrave, trava novamente (SEGURO)
    if (millis() - ultimoDestraveTrava > TEMPO_DESTRAVE_TRAVA) {
      servoTrava.write(SERVO_TRAVADO);
      digitalWrite(LED_VERDE,    HIGH);
      digitalWrite(LED_VERMELHO, LOW);
    }
  }

  if (botaoFechar || comandoFechar) {
    // Forca o destrave do palanque independente dos sensores
    Serial.println(F("Acao: FECHAR (destrava palanque forcado)"));
    servoAbertura.write(SERVO_DESTRAVADO);
    digitalWrite(LED_VERMELHO, HIGH);
    digitalWrite(LED_VERDE,    LOW);
    ultimoDestraveAbertura = millis(); // Inicia o tempo destravado sem congelar
    if (botaoFechar) notificarBackend("fechado");
  } else if (noPalanque) {
    // Se passou o tempo de destrave, trava novamente (SEGURO)
    if (millis() - ultimoDestraveAbertura > TEMPO_DESTRAVE_ABERTURA) {
      servoAbertura.write(SERVO_TRAVADO);
      digitalWrite(LED_VERDE,    HIGH);
      digitalWrite(LED_VERMELHO, LOW);
    }
  }

  if (!emCasa && !noPalanque) {
    Serial.println(F("Porteira em transito (ou sensores desalinhados)..."));
  }

  /*
    Sempre responde ao Django se um comando Wi-Fi foi recebido neste
    ciclo, mesmo que a acao tenha sido ignorada por estado incompativel
    (ex pediu abrir com a porteira ja destravada). Evita timeout.
  */
  if (comandoAbrir || comandoFechar) {
    responderOK(_canalAtual);
  }

  delay(50);
}

void lerComandoWifi(bool &abrir, bool &fechar) {
  while (esp.available()) {
    char c = esp.read();
    _bufferWifi += c;
    
    // PROTECAO DE MEMORIA: Se o buffer ficar muito grande, corta a metade velha.
    // O Arduino Uno so tem 2KB de RAM; Strings grandes causam travamentos!
    if (_bufferWifi.length() > 150) {
      _bufferWifi = _bufferWifi.substring(50); 
    }
  }

  if (_bufferWifi.length() == 0) return;

  // Busca imediata (nao espera \r\n\r\n porque o SoftwareSerial perde bytes a 115200)
  bool achouAbrir = (_bufferWifi.indexOf("abrir") != -1);
  bool achouFechar = (_bufferWifi.indexOf("trancar") != -1 || _bufferWifi.indexOf("fechar") != -1);

  if (achouAbrir || achouFechar) {
    // Tenta extrair o canal TCP, se existir
    int ipdIdx = _bufferWifi.indexOf("+IPD,");
    if (ipdIdx != -1) {
      int virgula = _bufferWifi.indexOf(',', ipdIdx + 5);
      if (virgula != -1) {
        String canalStr = _bufferWifi.substring(ipdIdx + 5, virgula);
        _canalAtual = canalStr.toInt();
      }
    }

    if (achouAbrir) abrir = true;
    if (achouFechar) fechar = true;

    Serial.print(F("Comando validado pelo buffer: "));
    Serial.println(achouAbrir ? "ABRIR" : "FECHAR");
    
    // Limpa o buffer para o proximo comando
    _bufferWifi = ""; 
  } 
  // Limpeza de Lixo: se achou o fim da requisicao ou ta muito grande e sem utilidade
  else if (_bufferWifi.indexOf("\r\n\r\n") != -1 || _bufferWifi.length() > 140) {
    _bufferWifi = "";
  }
}

/*
  Recebe o canal correto como parametro - nao hardcoda 0.
  Content-Length calculado com corpo.length(), nunca um numero fixo.
*/
void responderOK(int canal) {
  String corpo = "{\"ok\": true}";

  String resposta =
    "HTTP/1.1 200 OK\r\n"
    "Content-Type: application/json\r\n"
    "Content-Length: " + String(corpo.length()) + "\r\n"
    "Connection: close\r\n"
    "\r\n" +
    corpo;

  String cmd = "AT+CIPSEND=" + String(canal) + "," + String(resposta.length());
  enviarAT(cmd, 500);
  esp.print(resposta);
  delayLendoWifi(100);
  enviarAT("AT+CIPCLOSE=" + String(canal), 300);
}

void enviarAT(const String &cmd, unsigned int espera) {
  esp.println(cmd);
  unsigned long t = millis();
  String resposta = "";
  while (millis() - t < espera) {
    if (esp.available()) {
      char c = esp.read();
      Serial.write(c);
      resposta += c;
      
      // O SEGREDO DO BUG: Se o ESP receber o comando do App de abrir/fechar 
      // BEM NA HORA que estiver ocupado mandando mensagem pro Django, o comando 
      // era lido para a variavel 'resposta' local e JOGADO FORA.
      // Agora nos salvamos tudo no buffer global enquanto esperamos!
      _bufferWifi += c;
      if (_bufferWifi.length() > 150) {
        _bufferWifi = _bufferWifi.substring(50);
      }

      // Sai imediatamente se o ESP8266 ja respondeu
      if (resposta.endsWith("OK\r\n") || resposta.endsWith("ERROR\r\n") || 
          resposta.endsWith("FAIL\r\n") || resposta.endsWith("CLOSED\r\n")) {
        break;
      }
    }
  }
}

// Substitui o delay() comum por um delay que nao para de ler o Wi-Fi
void delayLendoWifi(unsigned int ms) {
  unsigned long t = millis();
  while (millis() - t < ms) {
    if (esp.available()) {
      char c = esp.read();
      _bufferWifi += c;
      if (_bufferWifi.length() > 150) {
        _bufferWifi = _bufferWifi.substring(50);
      }
    }
  }
}

/*
  Envia HTTP POST ao backend Django para sincronizar o status da porteira
  quando o botao fisico e usado. Usa canal 4 para nao conflitar com
  conexoes de entrada (canais 0-3).
*/
void notificarBackend(String status) {
  String corpo = "{\"porteira_id\":" + String(PORTEIRA_ID) + ",\"status\":\"" + status + "\"}";

  String requisicao = "POST /api/arduino/sync-status/ HTTP/1.1\r\n";
  requisicao += "Host: " + DJANGO_IP + ":" + String(DJANGO_PORT) + "\r\n";
  requisicao += "Content-Type: application/json\r\n";
  requisicao += "Content-Length: " + String(corpo.length()) + "\r\n";
  requisicao += "Connection: close\r\n";
  requisicao += "\r\n";
  requisicao += corpo;

  Serial.print(F("Notificando backend: "));
  Serial.println(status);

  // Usar canal 4 (conexao de saida) para nao conflitar com o servidor (canais 0-3)
  String cmdStart = "AT+CIPSTART=4,\"TCP\",\"" + DJANGO_IP + "\"," + String(DJANGO_PORT);
  enviarAT(cmdStart, 2000);

  String cmdSend = "AT+CIPSEND=4," + String(requisicao.length());
  enviarAT(cmdSend, 1000);

  esp.print(requisicao);
  delayLendoWifi(500); // Antes era delay() e perdia comandos!

  enviarAT("AT+CIPCLOSE=4", 500);
  Serial.println(F("Backend notificado."));
}
