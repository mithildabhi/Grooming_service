# salons/apps.py

from django.apps import AppConfig


class SalonsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'salons'
    
    def ready(self):
        """
        Import signals when app is ready
        This enables automatic geocoding on salon save
        """
        import salons.signals  # noqa