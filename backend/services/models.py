from django.db import models
from salons.models import Salon
from django.utils import timezone

class Service(models.Model):
    CATEGORY_CHOICES = [
        ('hair', 'Hair'),
        ('spa', 'Spa'),
        ('nails', 'Nails'),
        ('facial', 'Facial'),
        ('massage', 'Massage'),
        ('waxing', 'Waxing'),
        ('makeup', 'Makeup'),
        ('other', 'Other'),
    ]
    
    salon = models.ForeignKey(Salon, on_delete=models.CASCADE, related_name='services')
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, default='')  # NEW
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES, default='other')  # NEW
    price = models.DecimalField(max_digits=8, decimal_places=2)
    duration = models.IntegerField(help_text="Duration in minutes")
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(default=timezone.now)  # NEW - useful for sorting
    updated_at = models.DateTimeField(auto_now=True)  # NEW

    class Meta:
        ordering = ['category', 'name']  # Group by category
        indexes = [
            models.Index(fields=['salon', 'is_active']),
            models.Index(fields=['category']),
        ]

    def __str__(self):
        return f"{self.name} - {self.salon.name}"