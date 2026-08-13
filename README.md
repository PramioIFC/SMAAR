# SMAAR — Sistema de Monitoramento de Abertura e Registro

App Flutter + backend Django para controle de porteiras rurais, com acionamento físico via Arduino + ESP8266.

**Funcionalidades principais:**
- Abrir/fechar porteiras pelo celular (Wi-Fi local ou 4G via Ngrok)
- Monitoramento em tempo real (status atualiza a cada 3s)
- Histórico completo de aberturas e fechamentos com calendário
- Notificações push no celular (abertura manual, alerta fora de horário)
- Conexão automática: o app encontra o servidor sozinho (rede local) ou usa Ngrok (4G)
- Captura automática do IP do Arduino pelo backend

---

## ⚡ Execução Rápida (após tudo instalado)

> Use isso no dia a dia, toda vez que for usar o sistema.

### No computador (servidor):

**Dê dois cliques em:**
```
iniciar_servidor.bat
```
Isso abre automaticamente o **Django** + **Ngrok** juntos. Pronto.

### No celular (app):

1. Abra o **SMAAR**
2. Digite seu **usuário** e **senha**
3. Toque em **Entrar**

O app se conecta sozinho — sem digitar IP ou URL. Se estiver na mesma rede Wi-Fi do computador, usa a rede local. Se estiver no 4G, usa o túnel Ngrok automaticamente.

> **Requisito:** O computador precisa estar ligado e com o `iniciar_servidor.bat` rodando.

---

## Requisitos

| Componente | Requisito |
|---|---|
| Python | 3.10+ |
| Banco de dados | PostgreSQL instalado e rodando |
| Flutter SDK | Instalado e no PATH |
| Ngrok | Instalado e autenticado (`winget install ngrok.ngrok`) |
| Firebase | Projeto criado + `google-services.json` + `firebase-credentials.json` |
| Dispositivo | Celular Android (qualquer rede — funciona no 4G via Ngrok) |
| Hardware | Arduino Uno + módulo ESP8266 (para acionamento físico) |

---

## Guia Completo (do zero ao funcionando)

### 1. Banco de dados (PostgreSQL)

Abra o **psql** ou o pgAdmin e execute:

```sql
CREATE DATABASE smaar;
CREATE USER smaar_user WITH PASSWORD 'smaar1234';
GRANT ALL PRIVILEGES ON DATABASE smaar TO smaar_user;
```

### 2. Backend Django

```bash
cd backend
pip install -r requirements.txt
python manage.py migrate
```

O arquivo `.env` já está configurado com as credenciais acima. Se você usou outros valores no banco, edite o `.env`:

```
SECRET_KEY=qualquer-string-longa-aqui
DB_ENGINE=django.db.backends.postgresql
DB_NAME=smaar
DB_USER=smaar_user
DB_PASSWORD=smaar1234
DB_HOST=localhost
DB_PORT=5432
```

### 3. Ngrok (acesso remoto / 4G)

Instale e configure uma única vez:

```powershell
# Instalar
winget install ngrok.ngrok

# Autenticar com sua conta (gratuita em ngrok.com)
ngrok config add-authtoken SEU_TOKEN_AQUI
```

> Seu token está em: https://dashboard.ngrok.com/get-started/your-authtoken

Se você tiver um domínio estático diferente de `seu-dominio.ngrok-free.app`, edite a linha no `iniciar_servidor.bat` e no topo do `lib/pages/login_page.dart` (`_kNgrokUrl`).

### 4. App Flutter

Com o celular conectado via USB (modo desenvolvedor ativado):

```bash
flutter run
```

Ou gere o APK para instalar sem cabo:

```bash
flutter build apk --release
```

O APK fica em `build/app/outputs/flutter-apk/app-release.apk`.

### 5. Arduino

1. Abra o arquivo `arduino.ino` na Arduino IDE
2. Edite a linha com o nome e senha da sua rede Wi-Fi:
   ```cpp
   enviarAT("AT+CWJAP=\"NomeDaRede\",\"SenhaDaRede\"", 10000);
   ```
3. Edite o IP do seu computador (onde o Django está rodando):
   ```cpp
   const String DJANGO_IP = "192.168.1.100";
   ```
4. Grave o firmware no Arduino
5. Abra o **Monitor Serial** (115200 baud) para verificar o IP atribuído

---

## Como testar a conexão (sem Arduino)

Para testar apenas a comunicação celular ↔ servidor:

1. Dê dois cliques em `iniciar_servidor.bat`
2. Abra o app no celular
3. Faça login

Se a tela principal carregar com suas porteiras → **conexão funcionando!**

Ao apertar os botões ABRIR/FECHAR sem Arduino conectado, o app vai atualizar a tela e registrar no banco, mas vai exibir um aviso: *"Status salvo, mas o Arduino não respondeu."* — isso é o comportamento esperado.

---

## Configuração do Firebase (Notificações Push)

As notificações push exigem uma configuração única no Firebase:

### No console do Firebase (https://console.firebase.google.com):

1. Crie um projeto (ou use um existente)
2. Adicione um app Android com o package name `com.example.smaar`
3. Baixe o `google-services.json` e coloque em `android/app/`
4. Vá em **Configurações do Projeto > Contas de serviço**
5. Clique em **"Gerar nova chave privada"**
6. Salve o arquivo como `firebase-credentials.json` dentro da pasta `backend/`

> **⚠️ IMPORTANTE:** Esses dois arquivos contêm chaves sensíveis e já estão no `.gitignore`. Nunca suba eles para o GitHub!

---

## Circuito do Arduino

| Componente | Pino Arduino |
|---|---|
| ESP8266 RX | 11 (TX do Arduino via SoftwareSerial) |
| ESP8266 TX | 10 (RX do Arduino via SoftwareSerial) |
| Servo trava (batente) | 9 |
| Servo abertura (palanque) | 8 |
| Sensor magnético 1 (batente) | 2 |
| Sensor magnético 2 (palanque) | 3 |
| Botão abrir | 5 |
| Botão fechar/toggle | 4 |
| LED vermelho | 6 |
| LED verde | 7 |

> **Alimentação do ESP8266:** use uma fonte 3.3V externa com pelo menos 500mA (ex: módulo AMS1117 3.3V com capacitor de 100µF). O pino 3.3V do Arduino fornece no máximo 50mA e causa resets.

---

## Trocar de rede (escola, fazenda, casa)

### O que muda automaticamente:
- **IP do servidor Django no app:** Auto-discovery via UDP (rede local) ou Ngrok (4G)
- **IP do Arduino no backend:** Capturado automaticamente quando o Arduino envia o primeiro `sync-status`

### O que precisa configurar manualmente:
- **Wi-Fi do Arduino:** Edite o nome/senha da rede no `arduino.ino` e regrave na placa
- **IP do Django no Arduino:** Edite `DJANGO_IP` no `arduino.ino` e regrave

Os dados (porteiras, histórico, usuários) ficam no banco PostgreSQL — nada é perdido ao trocar de rede.

---

## Fluxo de comunicação

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLUXO PELO APP (4G via Ngrok)                │
│                                                                 │
│  Celular (Flutter) ──[4G]──► Ngrok ──► Django (local)          │
│       │  POST /api/porteiras/{id}/abrir/                        │
│       ▼                                                         │
│  Django ──► GET http://<IP_ARDUINO>:80/abrir  (rede local)      │
│       ▼                                                         │
│  Arduino aciona servo → responde 200 OK                         │
│       ▼                                                         │
│  Django → 200 OK → Ngrok → Celular                              │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                 FLUXO PELO BOTÃO FÍSICO                         │
│                                                                 │
│  Botão físico / Sensor magnético                                │
│       │  Arduino detecta mudança                                │
│       ▼                                                         │
│  Arduino                                                        │
│       │  POST /api/arduino/sync-status/  (rede local)           │
│       │  {"porteira_id": 1, "status": "aberto"}                 │
│       ▼                                                         │
│  Backend Django                                                 │
│       │  Atualiza banco + captura IP do Arduino                 │
│       │  Envia push notification (Firebase)                     │
│       ▼                                                         │
│  Celular — recebe notificação com vibração                      │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              CONEXÃO AUTOMÁTICA DO APP                          │
│                                                                 │
│  1) Tenta UDP broadcast "DISCOVER_SMAAR" na rede local          │
│       Se encontrar → usa IP local (ex: 192.168.x.x:8000)       │
│                                                                 │
│  2) Após 3s sem resposta → usa Ngrok automaticamente            │
│       seu-dominio.ngrok-free.app                   │
│                                                                 │
│  O usuário não precisa configurar nada.                         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Estrutura do projeto

```
smaar-porteira/
├── iniciar_servidor.bat           # ⚡ Clique duplo para iniciar tudo
├── backend/                       # API Django (Python)
│   ├── .env                       # Configurações do banco e chave secreta
│   ├── manage.py
│   ├── requirements.txt
│   ├── firebase-credentials.json  # Chave do Firebase (NÃO committar!)
│   ├── smaarback/                 # Configurações gerais do Django
│   ├── usuarios/                  # Cadastro e autenticação JWT
│   ├── porteiras/                 # CRUD de porteiras e registros
│   ├── core/                      # Push notifications + Auto-Discovery UDP
│   │   ├── apps.py                # Servidor UDP para discovery
│   │   ├── push.py                # Lógica de envio de push notifications
│   │   └── models.py              # FCMToken (tokens de dispositivos)
│   └── arduino_api/               # Endpoint de comando e config do Arduino
│       ├── models.py              # ConfiguracaoArduino (IP + porta)
│       ├── views.py               # /comando/, /config/, /sync-status/
│       └── admin.py               # Visível no painel admin
├── lib/                           # App Flutter
│   ├── main.dart
│   ├── app_state.dart             # Estado global do app
│   ├── services/
│   │   ├── api_client.dart        # Cliente HTTP com URL dinâmica
│   │   └── notification_service.dart  # Push notifications local
│   ├── pages/
│   │   ├── login_page.dart        # Login + Auto-Discovery + fallback Ngrok
│   │   ├── main_page.dart         # Lista de porteiras
│   │   ├── gate_page.dart         # Controle da porteira
│   │   ├── calendar_page.dart     # Histórico por calendário
│   │   └── ...
│   ├── models/
│   ├── repositories/
│   └── widgets/
├── android/
│   └── app/
│       └── google-services.json   # Config Firebase Android (NÃO committar!)
└── arduino.ino                    # Firmware do Arduino
```

---

## Usuário administrador (opcional)

Para acessar o painel admin em `http://localhost:8000/admin`:

```bash
cd backend
python manage.py createsuperuser
```

No admin você consegue ver e editar:
- Configuração do IP do Arduino
- Porteiras cadastradas
- Registros de abertura/fechamento
- Tokens FCM dos dispositivos
