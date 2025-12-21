from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    ROLE_CHOICES = (
        ('SUPER_ADMIN', 'Super Admin'),
        ('SALON_OWNER', 'Salon Owner'),
        ('EMPLOYEE', 'Employee'),
        ('CUSTOMER', 'Customer'),
    )

    role = models.CharField(
        max_length=20,
        choices=ROLE_CHOICES,
        default='CUSTOMER'
    )

    def __str__(self):
        return f"{self.username} ({self.role})"
