from django.db import models

class Service(models.Model):
    name = models.CharField(max_length=100)
    price = models.DecimalField(max_digits=8, decimal_places=2)
    duration = models.IntegerField(help_text="Duration in minutes")

    def __str__(self):
        return self.name


class Booking(models.Model):
    customer_name = models.CharField(max_length=100)
    service = models.ForeignKey(Service, on_delete=models.CASCADE)
    booking_date = models.DateField()
    booking_time = models.TimeField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.customer_name

class AppUser(models.Model):
    firebase_uid = models.CharField(max_length=128, unique=True)
    email = models.EmailField()
    role = models.CharField(max_length=20, default='user')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.email

class AppUser(models.Model):
    """
    Separate model for API user sync
    Links Firebase UID to Django User
    """
    firebase_uid = models.CharField(max_length=128, unique=True)
    email = models.EmailField()
    role = models.CharField(
        max_length=20,
        choices=[
            ('SALON_OWNER', 'Salon Owner'),
            ('CUSTOMER', 'Customer'),
            ('STAFF', 'Staff'),
        ],
        default='SALON_OWNER'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.email} ({self.role})"
