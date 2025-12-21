from django.db import models
from accounts.models import User

class Salon(models.Model):
    name = models.CharField(max_length=100)
    address = models.TextField()
    rating = models.FloatField(default=0.0)   # 👈 ADD THIS
    is_open = models.BooleanField(default=True)  # 👈 ADD THIS
    owner = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='owned_salons',
        limit_choices_to={'role': 'SALON_OWNER'}
    )

    def __str__(self):
        return self.name
