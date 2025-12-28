from django.db import models
from accounts.models import User
from salons.models import Salon
from django.utils import timezone

class Employee(models.Model):
    ROLE_CHOICES = [
        ('stylist', 'Stylist'),
        ('barber', 'Barber'),
        ('specialist', 'Specialist'),
        ('manager', 'Manager'),
        ('receptionist', 'Receptionist'),
    ]
    
    SKILL_CHOICES = [
        ('hair_styling', 'Hair Styling'),
        ('hair_cutting', 'Hair Cutting'),
        ('beard_trim', 'Beard Trim'),
        ('coloring', 'Coloring'),
        ('spa', 'Spa'),
        ('massage', 'Massage'),
        ('nails', 'Nails'),
        ('makeup', 'Makeup'),
    ]
    
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    salon = models.ForeignKey(Salon, on_delete=models.CASCADE, related_name='employees')
    
    # Fields with defaults for migration
    full_name = models.CharField(max_length=100, default='Staff Member')
    email = models.EmailField(default='staff@example.com')
    phone = models.CharField(max_length=20, default='0000000000')
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='stylist')
    primary_skill = models.CharField(max_length=30, choices=SKILL_CHOICES, default='hair_styling')
    working_days = models.JSONField(default=list, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(default=timezone.now)  # Use timezone.now (not timezone.now())
    
    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['salon']),
            models.Index(fields=['role']),
        ]

    def __str__(self):
        return f"{self.full_name} - {self.salon.name}"