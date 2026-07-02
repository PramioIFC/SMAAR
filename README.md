# SMAAR — Sistema de Monitoramento de Abertura e Registro

App Flutter + backend Django para controle de porteiras rurais, com acionamento físico via Arduino + ESP8266.

---

## Requisitos

- Python 3.10+
- PostgreSQL instalado e rodando
- Flutter SDK instalado
- Celular Android na mesma rede Wi-Fi que o computador
- Arduino Uno + módulo ESP8266 (para acionamento físico das porteiras)

---

## 1. Configurar o banco de dados (PostgreSQL)

Abra o **psql** ou o pgAdmin e execute:

```sql
CREATE DATABASE smaar;
CREATE USER smaar_user WITH PASSWORD 'smaar1234';
GRANT ALL PRIVILEGES ON DATABASE smaar TO smaar_user;
```

---

## 2. Configurar o backend

Entre na pasta `backend`:

```
cd backend
```

Instale as dependências:

```
pip install -r requirements.txt
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

Crie as tabelas no banco:

```
python manage.py migrate
```

---

## 3. Rodar o backend

Descubra o IP do computador na rede Wi-Fi:

- **Windows:** abra o terminal e rode `ipconfig` → olhe "Adaptador de Rede sem Fio Wi-Fi" → **Endereço IPv4**
- **Mac/Linux:** `ifconfig` ou `ip a` → interface Wi-Fi (en0 / wlan0)

Inicie o servidor aceitando conexões de qualquer dispositivo na rede:

```
python manage.py runserver 0.0.0.0:8000
```

O backend estará rodando em `http://<SEU_IP>:8000`.

> Deixe esse terminal aberto enquanto usar o app.

---

## 4. Criar usuário administrador (opcional)

Para acessar o painel admin em `http://localhost:8000/admin`:

```
python manage.py createsuperuser
```

Informe nome e senha quando solicitado. No admin você consegue ver a configuração de IP do Arduino em **"Configuração do Arduino"**.

---

## 5. Instalar e configurar o app

Com o celular conectado ao computador via USB (modo desenvolvedor ativado), rode na pasta raiz do projeto:

```
flutter run
```

Ou gere o APK para instalar sem cabo:

```
flutter build apk --release
```

O APK gerado fica em `build/app/outputs/flutter-apk/app-release.apk`.

---

## 6. Primeira vez usando o app

1. Abra o app no celular
2. Na tela de login, toque em **"Servidor"**
3. Digite o IP do computador (ex: `192.168.3.100`)
4. Crie uma conta tocando em **"Cadastre-se"** ou faça login se já tiver conta
5. Pronto — o IP fica salvo, não precisa digitar de novo

> O celular precisa estar na **mesma rede Wi-Fi** que o computador.

---

## 7. Configurar o Arduino

O Arduino funciona como servidor HTTP na rede local. O Django chama ele diretamente quando você aperta ABRIR ou FECHAR no app.

### Circuito

| Componente | Pino Arduino |
|---|---|
| ESP8266 RX | 11 (TX do Arduino via SoftwareSerial) |
| ESP8266 TX | 10 (RX do Arduino via SoftwareSerial) |
| Servo trava | 9 |
| Servo abertura | 8 |
| Sensor magnético 1 | 2 |
| Sensor magnético 2 | 3 |
| Botão destravar | 5 |
| Botão travar | 4 |
| LED vermelho | 6 |
| LED verde | 7 |

> **Alimentação do ESP8266:** use uma fonte 3.3V externa com pelo menos 500mA (ex: módulo AMS1117 3.3V com capacitor de 100µF). Alimentar pelo pino 3.3V do Arduino causa resets e comportamento intermitente porque o Arduino fornece no máximo 50mA nesse pino.

### Configurar a rede Wi-Fi no firmware

Abra o arquivo `smaar_arduino_v3.ino` e edite a linha com o nome e senha da sua rede:

```cpp
enviarAT("AT+CWJAP=\"NomeDaRede\",\"SenhaDaRede\"", 10000);
```

Grave o firmware no Arduino via Arduino IDE.

### Descobrir o IP do Arduino

Após gravar, abra o **Monitor Serial** (115200 baud, "Nova linha e retorno de linha"). O IP aparece na inicialização:

```
IP do Arduino:
+CIFSR:STAIP,"10.115.234.105"
>>> IP acima <<<
```

Anote esse IP.

### Configurar o IP no app

1. Abra o app e entre na porteira
2. Toque no ícone de **configurações** (engrenagem, canto superior direito)
3. Digite o IP do Arduino e a porta (padrão: 80)
4. Toque em **Salvar**

A partir daí, ABRIR e FECHAR no app acionam fisicamente o servo.

---

## 8. Trocar de rede (escola, fazenda, casa)

Quando mudar de local:

1. Na tela de login, toque em **"Servidor"** e atualize o IP do computador
2. Abra a configuração da porteira (engrenagem) e atualize o IP do Arduino
3. Faça login normalmente

Os dados (porteiras, histórico, usuários) ficam todos no banco — nada é perdido ao trocar de rede.

---

## Fluxo de comunicação

```
Celular (Flutter)
      │  POST /api/arduino/comando/ {"comando": "abrir"}
      ▼
Backend Django
      │  GET http://<IP_ARDUINO>:80/abrir
      ▼
Arduino (ESP8266 servidor HTTP)
      │  aciona servo
      │  responde 200 OK
      ▼
Backend Django
      │  responde 200 OK pro celular
      ▼
Celular — status atualizado
```

---

## Estrutura do projeto

```
smaar-porteira/
├── backend/                  # API Django (Python)
│   ├── .env                  # Configurações do banco e chave secreta
│   ├── manage.py
│   ├── requirements.txt
│   ├── smaarback/            # Configurações gerais do Django
│   ├── usuarios/             # Cadastro e autenticação JWT
│   ├── porteiras/            # CRUD de porteiras e registros
│   └── arduino_api/          # Endpoint de comando e config do Arduino
│       ├── models.py         # ConfiguracaoArduino (IP + porta)
│       ├── views.py          # /comando/ e /config/
│       └── admin.py          # Visível no painel admin
├── lib/                      # App Flutter
│   ├── main.dart
│   ├── services/
│   │   └── api_client.dart   # Cliente HTTP com URL dinâmica
│   ├── pages/
│   ├── models/
│   ├── repositories/
│   └── widgets/
└── smaar_arduino_v3.ino      # Firmware do Arduino
```

---

## Resumo rápido (do zero ao funcionando)

```
# 1. Banco
psql -U postgres -c "CREATE DATABASE smaar;"
psql -U postgres -c "CREATE USER smaar_user WITH PASSWORD 'smaar1234';"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE smaar TO smaar_user;"

# 2. Backend
cd backend
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver 0.0.0.0:8000

# 3. App (em outro terminal, na raiz do projeto)
flutter run
```

Depois de rodar: configurar o IP do servidor no app → configurar o IP do Arduino na engrenagem da porteira → pronto.