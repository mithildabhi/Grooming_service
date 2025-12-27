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
        default='SALON_OWNER'  # Changed default to SALON_OWNER
    )
    
    # ADD THIS FIELD for better Firebase integration
    firebase_uid = models.CharField(
        max_length=128,
        unique=True,
        null=True,
        blank=True,
        help_text="Firebase UID"
    )

    def __str__(self):
        return f"{self.username} ({self.role})"
