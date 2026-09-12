# SMAAR

> Sistema de Monitoramento de Abertura e Registro para controle e acompanhamento de porteiras rurais.

O SMAAR integra um aplicativo Flutter, uma API Django e um controlador Arduino com ESP8266. Pelo celular, é possível consultar o estado da porteira, enviar comandos e acompanhar o histórico de movimentações.

## Recursos

- Controle remoto de abertura e fechamento
- Atualização periódica do estado da porteira
- Histórico de eventos com visualização por calendário
- Cadastro de usuários e autenticação JWT
- Notificações push com Firebase
- Descoberta do servidor na rede local
- Acesso externo opcional por túnel Ngrok
- Sincronização de comandos físicos do Arduino com o backend

## Arquitetura

```text
Aplicativo Flutter ── HTTP/JWT ──► API Django ── HTTP ──► Arduino + ESP8266
       ▲                              │                         │
       └──── histórico e estado ──────┴──── eventos físicos ────┘
```

## Tecnologias

| Camada | Tecnologias |
|---|---|
| Aplicativo | Flutter e Dart |
| API | Django, Django REST Framework e Simple JWT |
| Banco de dados | PostgreSQL |
| Hardware | Arduino Uno, ESP8266, servos e sensores magnéticos |
| Integrações opcionais | Firebase Cloud Messaging e Ngrok |

## Pré-requisitos

- Flutter SDK
- Python 3.10 ou superior
- PostgreSQL
- Arduino IDE com as bibliotecas `Servo` e `SoftwareSerial`
- Ngrok e Firebase somente se os respectivos recursos forem utilizados

## Configuração segura

O repositório não contém senhas, tokens, endereços privados nem credenciais do Firebase. Não envie ao Git os arquivos locais criados nas etapas abaixo.

### 1. Backend

Crie o ambiente virtual, instale as dependências e copie o modelo de variáveis:

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
```

Edite `backend/.env` com valores próprios. Gere uma chave Django, por exemplo, com:

```powershell
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

Crie previamente o banco e o usuário informados no `.env`. Depois execute:

```powershell
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver 0.0.0.0:8000
```

Para popular dados de demonstração, defina `SMAAR_SEED_ADMIN_PASSWORD` no `.env` e rode `python manage.py seed`.

### 2. Arduino e ESP8266

Copie `config.example.h` para `config.h` na raiz do projeto:

```powershell
Copy-Item config.example.h config.h
```

Preencha no arquivo local:

- `SMAAR_WIFI_SSID`: nome da rede Wi-Fi
- `SMAAR_WIFI_PASSWORD`: senha da rede
- `SMAAR_DJANGO_IP`: IP do computador que executa o Django

Abra `arduino.ino` na Arduino IDE, conecte a placa e grave o firmware. O arquivo `config.h` está ignorado pelo Git.

### 3. Aplicativo Flutter

Instale os pacotes e execute o aplicativo:

```powershell
flutter pub get
flutter run
```

Para habilitar uma URL pública de fallback no aplicativo:

```powershell
flutter run --dart-define=SMAAR_PUBLIC_URL=https://seu-dominio.example
```

Sem essa opção, informe manualmente o endereço do servidor na tela de login ou use a descoberta pela rede local.

### 4. Acesso externo com Ngrok

Após instalar e autenticar o Ngrok, defina o domínio na sessão do terminal:

```powershell
$env:SMAAR_NGROK_DOMAIN = "seu-dominio.ngrok-free.app"
.\iniciar_servidor.bat
```

Adicione a URL completa também a `CSRF_TRUSTED_ORIGINS` no arquivo `.env`.

### 5. Firebase (opcional)

Para notificações push:

1. Cadastre o aplicativo Android no Firebase.
2. Salve `google-services.json` em `android/app/`.
3. Gere uma chave de conta de serviço.
4. Salve-a como `backend/firebase-credentials.json`.

Esses arquivos estão no `.gitignore` e nunca devem ser publicados.

## Ligações do hardware

| Componente | Pino do Arduino |
|---|---:|
| ESP8266 RX / TX | 11 / 10 |
| Servo do batente | 9 |
| Servo do palanque | 8 |
| Sensores magnéticos | 2 e 3 |
| Botões abrir / fechar | 5 / 4 |
| LEDs vermelho / verde | 6 / 7 |

> Alimente o ESP8266 com uma fonte externa de 3,3 V capaz de fornecer pelo menos 500 mA. O pino de 3,3 V do Arduino pode não fornecer corrente suficiente.

## Estrutura principal

```text
SMAAR/
├── android/, ios/, linux/, macos/, web/, windows/  # plataformas Flutter
├── lib/                                             # aplicativo
├── backend/                                         # API Django
├── arduino.ino                                      # firmware
├── config.example.h                                 # modelo sem credenciais
└── iniciar_servidor.bat                             # Django + Ngrok no Windows
```

## Boas práticas de segurança

- Mantenha `.env`, `config.h` e arquivos do Firebase fora do Git.
- Use senhas diferentes para banco, administrador, Wi-Fi e serviços externos.
- Troque imediatamente qualquer credencial que já tenha sido exposta.
- Restrinja `ALLOWED_HOSTS`, CORS e origens CSRF antes de colocar o sistema em produção.
- Use HTTPS para acesso fora da rede local.

## Licença

Defina uma licença antes de distribuir ou reutilizar o projeto publicamente.
