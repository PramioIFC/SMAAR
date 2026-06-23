from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Porteira',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('nome', models.CharField(max_length=100)),
                ('status', models.CharField(choices=[('aberto', 'Aberto'), ('fechado', 'Fechado')], default='fechado', max_length=10)),
                ('limite_abertura', models.CharField(blank=True, default='', max_length=5)),
                ('limite_fechamento', models.CharField(blank=True, default='', max_length=5)),
                ('criada_em', models.DateTimeField(auto_now_add=True)),
                ('proprietario', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='porteiras', to=settings.AUTH_USER_MODEL)),
            ],
            options={'ordering': ['id']},
        ),
        migrations.CreateModel(
            name='RegistroPorteira',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('status', models.CharField(choices=[('aberto', 'Aberto'), ('fechado', 'Fechado')], max_length=10)),
                ('data', models.DateField(auto_now_add=True)),
                ('hora', models.TimeField(auto_now_add=True)),
                ('porteira', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='registros', to='porteiras.porteira')),
            ],
            options={'ordering': ['-data', '-hora', '-id']},
        ),
    ]
