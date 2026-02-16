from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    fcm_token = models.TextField(null=True, blank=True)

    ROLE_CHOICES = (
        ('SUPER_ADMIN', 'Super Admin'),
        ('SALON_OWNER', 'Salon Owner'),
        ('EMPLOYEE', 'Employee'),
        ('CUSTOMER', 'Customer'),
    )

    role = models.CharField(
        max_length=20,
        choices=ROLE_CHOICES,
        default='SALON_OWNER'
    )
    
    firebase_uid = models.CharField(
        max_length=128,
        unique=True,
        null=True,
        blank=True,
        help_text="Firebase UID"
    )

    def __str__(self):
        """
        ✅ CRITICAL FIX: Show meaningful names instead of username
        This affects EVERYWHERE in admin panel
        """
        # For customers, show their full name from customer profile
        if self.role == 'CUSTOMER':
            if hasattr(self, 'customer_profile') and self.customer_profile.full_name:
                return self.customer_profile.full_name
            # Fallback to email if no customer profile
            return self.email or self.username
        
        # For salon owners, show salon name
        if self.role == 'SALON_OWNER':
            if hasattr(self, 'salon_profile') and self.salon_profile.name:
                return f"{self.salon_profile.name} (Owner)"
            return self.email or self.username
        
        # For employees, show their name
        if self.role == 'EMPLOYEE':
            if hasattr(self, 'employee_profile') and self.employee_profile.full_name:
                return f"{self.employee_profile.full_name} (Staff)"
            return self.email or self.username
        
        # For super admin
        if self.role == 'SUPER_ADMIN':
            return f"{self.email or self.username} (Admin)"
        
        # Fallback
        return self.email or self.username
    
    @property
    def display_name(self):
        """
        Get display name for use in templates and serializers
        """
        return str(self)
    
    def get_full_name(self):
        """
        Override Django's get_full_name to return proper names
        """
        if self.role == 'CUSTOMER' and hasattr(self, 'customer_profile'):
            return self.customer_profile.full_name or self.email
        
        if self.role == 'EMPLOYEE' and hasattr(self, 'employee_profile'):
            return self.employee_profile.full_name or self.email
        
        if self.first_name and self.last_name:
            return f"{self.first_name} {self.last_name}"
        
        return self.email or self.username
    
    def get_short_name(self):
        """
        Override Django's get_short_name
        """
        if self.role == 'CUSTOMER' and hasattr(self, 'customer_profile'):
            full_name = self.customer_profile.full_name
            if full_name:
                return full_name.split()[0]  # Return first name
        
        if self.role == 'EMPLOYEE' and hasattr(self, 'employee_profile'):
            full_name = self.employee_profile.full_name
            if full_name:
                return full_name.split()[0]
        
        return self.first_name or self.email or self.username

    class Meta:
        verbose_name = 'User'
        verbose_name_plural = 'Users'
