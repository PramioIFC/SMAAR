# SMAAR — Sistema de Monitoramento de Abertura e Registro

App Flutter + backend Django para controle de porteiras rurais.

---

## Requisitos

- Python 3.10+
- PostgreSQL instalado e rodando
- Flutter SDK instalado
- Celular Android na mesma rede Wi-Fi que o computador

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

Informe nome e senha quando solicitado.

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

## 7. Trocar de rede (escola, fazenda, casa)

Quando mudar de local e o IP do computador mudar:

1. Na tela de login, toque em **"Servidor"**
2. Atualize o IP
3. Faça login normalmente

Os dados (porteiras, histórico, usuários) ficam todos no banco de dados do computador — nada é perdido ao trocar o IP.

---

## Estrutura do projeto

```
smaar-porteira/
├── backend/          # API Django (Python)
│   ├── .env          # Configurações do banco e chave secreta
│   ├── manage.py
│   ├── requirements.txt
│   ├── smaarback/    # Configurações gerais do Django
│   ├── usuarios/     # Cadastro e autenticação JWT
│   ├── porteiras/    # CRUD de porteiras e registros
│   └── core/
└── lib/              # App Flutter
    ├── main.dart
    ├── services/
    │   └── api_client.dart   # Cliente HTTP com URL dinâmica
    ├── pages/
    ├── models/
    ├── repositories/
    └── widgets/
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
