from django.apps import AppConfig


class CustomersConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'customers'
    verbose_name = 'Customer Management'
    
    def ready(self):
        """Import signals when app is ready"""
        import customers.models  # This imports the signals