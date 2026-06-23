from .settings import *
DATABASES = {'default': {'ENGINE': 'django.db.backends.sqlite3', 'NAME': '/tmp/smaar_seed.sqlite3'}}
SECRET_KEY = 'tmp-key-for-migration-check'
