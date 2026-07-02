
  SMAAR - Controlador de Porteira
  Versão corrigida (rodada 3)
 
  Correções desta rodada
    7. [MUDANÇA DE LÓGICA] A porteira agora trava sozinha em dois pontos
       físicos diferentes, cada um com seu próprio ímã e seu próprio servo
         - SENSOR_MAG1 detecta a porteira travada no BATENTE (posição de
           casafechada). O servoTrava é quem segura essa trava.
         - SENSOR_MAG2 detecta a porteira travada no PALANQUE (posição
           aberta). O servoAbertura é quem segura essa trava.
       'Abrir' (comando ou botão) destrava o lado do batente (servoTrava),
       deixando a porteira livre pra ir até o palanque, onde ela trava
       sozinha via ímã 2. 'Fechar' destrava o lado do palanque
       (servoAbertura), deixando a porteira voltar e travar sozinha no
       batente via ímã 1. Os comandos NÃO travam nada diretamente — eles
       só liberam o lado oposto ao que está travado no momento.
    8. [CORRIGIDO] Antes, se um comando Wi-Fi chegasse num estado em que a
       ação não podia ser executada (ex pediu abrir mas a porteira não
       estava travada no batente), o Arduino nunca respondia ao Django —
       reintroduzindo o erro de timeout que a rodada 2 já tinha corrigido.
       Agora ele SEMPRE responde se recebeu um comando neste ciclo, mesmo
       quando a ação é ignorada por estado incompatível.
    9. [A CALIBRAR] TEMPO_DESTRAVE_TRAVA e TEMPO_DESTRAVE_ABERTURA são
       valores conservadores de partida (1500ms e 500ms). Eles definem
       quanto tempo o Arduino espera, segurando a resposta HTTP, depois de
       destravar o servo. Ajuste com base no teste físico — mas fique de
       olho no timeout configurado no lado do DjangoFlutter pra não
       reintroduzir o erro do item 8.
 
  Correções de rodadas anteriores (mantidas)
    1. Canal TCP extraído dinamicamente do +IPD,canal — responderOK
       não hardcoda mais o canal 0, evitando 502 no Django.
    2. Wi-Fi realmente conecta à rede (CWJAP descomentado).
    3. lerComandoWifi() não bloqueia mais o loop usa buffer global e
       processa quando encontra fim de frame HTTP.
    4. aplicarEstadoTravado() coloca delay entre os dois servos no boot
       para evitar reset por pico de corrente.
    6. responderOK() calcula Content-Length dinamicamente.
 

#include Servo.h
#include SoftwareSerial.h

 ── Wi-Fi ──────────────────────────────────────────────────────────────────
SoftwareSerial esp(10, 11);    RX=10, TX=11

 ── Servos ─────────────────────────────────────────────────────────────────
Servo servoTrava;       segura a trava no BATENTE (posição fechadacasa)
Servo servoAbertura;    segura a trava no PALANQUE (posição aberta)

 ── Pinos ──────────────────────────────────────────────────────────────────
const int SENSOR_MAG1     = 2;   ímã do BATENTE — porteira travada em casa
const int SENSOR_MAG2     = 3;   ímã do PALANQUE — porteira travada aberta
const int BOTAO_ABRIR     = 5;   antes BOTAO_DESTRAVAR
const int BOTAO_FECHAR    = 4;   antes BOTAO_TRAVAR
const int LED_VERMELHO    = 6;
const int LED_VERDE       = 7;

 ── Ângulos dos servos ─────────────────────────────────────────────────────
const int SERVO_TRAVADO    = 85;
const int SERVO_DESTRAVADO = 0;

 ── Timing de destrave (item 9 — A CALIBRAR no hardware real) ─────────────
const unsigned long TEMPO_DESTRAVE_TRAVA    = 1500;  ms — lado batente (abrir)
const unsigned long TEMPO_DESTRAVE_ABERTURA = 500;   ms — lado palanque (fechar)

 Buffer global para acumular bytes do ESP sem bloquear o loop.
String _bufferWifi = ;

 Canal TCP da última requisição recebida pelo ESP8266.
 Extraído do prefixo +IPD,canal,tamanho de cada frame.
int _canalAtual = 0;

 ──────────────────────────────────────────────────────────────────────────
void setup() {
  Serial.begin(115200);

   Mantido em 115200 — testado na prática pelo usuário, funcionando de
   forma consistente neste hardware específico. Se notar comandos
   perdidos no futuro, 9600 é a alternativa mais segura (requer
   reconfigurar o ESP com AT+UART_DEF=9600,8,1,0,0).
  esp.begin(115200);

  servoTrava.attach(9);
  servoAbertura.attach(8);

  pinMode(SENSOR_MAG1,  INPUT);
  pinMode(SENSOR_MAG2,  INPUT);
  pinMode(BOTAO_ABRIR,  INPUT_PULLUP);
  pinMode(BOTAO_FECHAR, INPUT_PULLUP);
  pinMode(LED_VERDE,    OUTPUT);
  pinMode(LED_VERMELHO, OUTPUT);

   Estado inicial seguro assume travado no batente, com delay entre os
   dois servos pra evitar pico de corrente que poderia resetar o Arduino.
  servoTrava.write(SERVO_TRAVADO);
  delay(800);
  servoAbertura.write(SERVO_DESTRAVADO);
  digitalWrite(LED_VERDE, HIGH);
  digitalWrite(LED_VERMELHO, LOW);

   ── Configuração do ESP8266 ────────────────────────────────────────────
  Serial.println(F(Configurando ESP8266...));

  enviarAT(AT+RST,      2000);
  enviarAT(AT+CWMODE=1, 500);

  Serial.println(F(Conectando ao Wi-Fi...));
  enviarAT(AT+CWJAP=NOME_DA_REDE,SENHA_DA_REDE, 10000);
  delay(2000);

   Exibe o IP no Serial Monitor — anote para configurar no app
  Serial.println(F(IP do Arduino));
  enviarAT(AT+CIFSR, 2000);
  Serial.println(F( IP acima ));

  enviarAT(AT+CIPMUX=1,       500);
  enviarAT(AT+CIPSERVER=1,80, 1000);

  Serial.println(F(Sistema pronto. Aguardando comandos...));
  Serial.println(F(-------------------------------------------));
}

 ──────────────────────────────────────────────────────────────────────────
void loop() {
  bool botaoAbrir  = (digitalRead(BOTAO_ABRIR)  == LOW);
  bool botaoFechar = (digitalRead(BOTAO_FECHAR) == LOW);

  bool comandoAbrir  = false;
  bool comandoFechar = false;
  lerComandoWifi(comandoAbrir, comandoFechar);

  bool emCasa     = (digitalRead(SENSOR_MAG1) == LOW);  travada no batente
  bool noPalanque = (digitalRead(SENSOR_MAG2) == LOW);  travada no palanque

  if (emCasa) {
     Trava do batente engatada — mantém segura.
    servoTrava.write(SERVO_TRAVADO);
    digitalWrite(LED_VERDE,    HIGH);
    digitalWrite(LED_VERMELHO, LOW);

    if (botaoAbrir  comandoAbrir) {
      Serial.println(F(Acao ABRIR (destrava lado batente)));
      servoTrava.write(SERVO_DESTRAVADO);
      digitalWrite(LED_VERMELHO, HIGH);
      digitalWrite(LED_VERDE,    LOW);
      delay(TEMPO_DESTRAVE_TRAVA);
    }

  } else if (noPalanque) {
     Trava do palanque engatada — mantém segura.
    servoAbertura.write(SERVO_TRAVADO);
    digitalWrite(LED_VERDE,    HIGH);
    digitalWrite(LED_VERMELHO, LOW);

    if (botaoFechar  comandoFechar) {
      Serial.println(F(Acao FECHAR (destrava lado palanque)));
      servoAbertura.write(SERVO_DESTRAVADO);
      digitalWrite(LED_VERMELHO, HIGH);
      digitalWrite(LED_VERDE,    LOW);
      delay(TEMPO_DESTRAVE_ABERTURA);
    }

  } else {
     Porteira em trânsito saiu de um ímã e ainda não chegou no outro.
     Não faz nada além de esperar — o próximo ciclo vai detectar quando
     ela encostar em algum dos dois lados.
    Serial.println(F(Porteira em transito...));
  }

   Sempre responde ao Django se um comando Wi-Fi foi recebido neste
   ciclo, mesmo que a ação tenha sido ignorada por estado incompatível
   (ex pediu abrir com a porteira já destravada). Evita timeout.
  if (comandoAbrir  comandoFechar) {
    responderOK(_canalAtual);
  }

  delay(50);
}

 ──────────────────────────────────────────────────────────────────────────
 Lê bytes disponíveis no buffer do ESP sem bloquear.
 Acumula em _bufferWifi e só processa quando detecta o fim do frame HTTP
 (linha em branco rnrn = fim dos headers).

 Extrai o canal TCP do prefixo +IPD,canal,tamanho e salva em
 _canalAtual para que responderOK() use o canal correto.
 ──────────────────────────────────────────────────────────────────────────
void lerComandoWifi(bool &abrir, bool &fechar) {
  while (esp.available()) {
    _bufferWifi += (char)esp.read();
  }

  if (_bufferWifi.indexOf(rnrn) == -1) return;

  String dados = _bufferWifi;
  _bufferWifi  = ;

  Serial.print(F(Wi-Fi recebeu ));
  Serial.println(dados);

  int ipdIdx = dados.indexOf(+IPD,);
  if (ipdIdx != -1) {
    int virgula = dados.indexOf(',', ipdIdx + 5);
    if (virgula != -1) {
      String canalStr = dados.substring(ipdIdx + 5, virgula);
      _canalAtual = canalStr.toInt();
    }
  }

  if (dados.indexOf(GET abrir)   != -1) abrir  = true;
  if (dados.indexOf(GET trancar) != -1) fechar = true;

   Compatibilidade com versão anterior (palavras soltas)
  if (!abrir  && dados.indexOf(abrir)   != -1) abrir  = true;
  if (!fechar && dados.indexOf(trancar) != -1) fechar = true;
}

 ──────────────────────────────────────────────────────────────────────────
 Recebe o canal correto como parâmetro — não hardcoda 0.
 Content-Length calculado com corpo.length(), nunca um número fixo.
 ──────────────────────────────────────────────────────────────────────────
void responderOK(int canal) {
  String corpo = {ok true};

  String resposta =
    HTTP1.1 200 OKrn
    Content-Type applicationjsonrn
    Content-Length  + String(corpo.length()) + rn
    Connection closern
    rn +
    corpo;

  String cmd = AT+CIPSEND= + String(canal) + , + String(resposta.length());
  enviarAT(cmd, 500);
  esp.print(resposta);
  delay(100);
  enviarAT(AT+CIPCLOSE= + String(canal), 300);
}

 ──────────────────────────────────────────────────────────────────────────
void enviarAT(const String &cmd, unsigned int espera) {
  esp.println(cmd);
  unsigned long t = millis();
  while (millis() - t  espera) {
    if (esp.available()) Serial.write(esp.read());
  }
}
