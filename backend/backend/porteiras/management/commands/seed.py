"""
python manage.py seed
"""
from datetime import date, timedelta, time

from django.contrib.auth.models import User
from django.core.management.base import BaseCommand

from porteiras.models import Porteira, RegistroPorteira


PORTEIRAS_SEED = [
    {'nome': 'Porteira Principal', 'status': 'fechado',
     'limite_abertura': '06:00', 'limite_fechamento': '23:00'},
    {'nome': 'Porteira do Gado', 'status': 'aberto',
     'limite_abertura': '09:00', 'limite_fechamento': '22:00'},
    {'nome': 'Porteira do Pasto', 'status': 'fechado',
     'limite_abertura': '07:00', 'limite_fechamento': '20:00'},
]

EVENTOS = {
    'Porteira Principal': [('06:15', 'aberto'), ('18:45', 'fechado')],
    'Porteira do Gado':   [('09:00', 'aberto'), ('13:30', 'fechado'), ('14:00', 'aberto'), ('22:00', 'fechado')],
    'Porteira do Pasto':  [('07:00', 'aberto'), ('11:00', 'fechado'), ('15:00', 'aberto'), ('20:00', 'fechado')],
}


def _criar_registros(porteira, eventos, dia):
    objs = []
    for hora_str, status in eventos:
        h, m = map(int, hora_str.split(':'))
        objs.append(RegistroPorteira(porteira=porteira, status=status, data=dia, hora=time(h, m)))
    RegistroPorteira.objects.bulk_create(objs)


class Command(BaseCommand):
    help = 'Popula o banco com dados de exemplo.'

    def handle(self, *args, **options):
        user, criado = User.objects.get_or_create(username='admin')
        if criado:
            user.set_password('ALTERE_ESTA_SENHA')
            user.is_staff = True
            user.save()
            self.stdout.write(self.style.SUCCESS("Usuário 'admin' criado (senha: ALTERE_ESTA_SENHA)"))
        else:
            self.stdout.write("Usuário 'admin' já existe.")

        hoje = date.today()

        for dados in PORTEIRAS_SEED:
            porteira, criada = Porteira.objects.get_or_create(
                nome=dados['nome'],
                proprietario=user,
                defaults={
                    'status': dados['status'],
                    'limite_abertura': dados['limite_abertura'],
                    'limite_fechamento': dados['limite_fechamento'],
                },
            )

            if not criada and porteira.registros.exists():
                self.stdout.write(f"  '{porteira.nome}' já tem registros — pulando.")
                continue

            self.stdout.write(f"  Gerando histórico para '{porteira.nome}'...")
            eventos = EVENTOS.get(porteira.nome, [('08:00', 'aberto'), ('18:00', 'fechado')])

            for i in range(6, -1, -1):
                _criar_registros(porteira, eventos, hoje - timedelta(days=i))

            self.stdout.write(f"    → {porteira.registros.count()} registros criados.")

        self.stdout.write(self.style.SUCCESS('\nSeed concluído! Login: admin / ALTERE_ESTA_SENHA'))