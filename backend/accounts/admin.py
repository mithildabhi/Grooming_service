from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.utils.html import format_html
from django.urls import reverse
from .models import User


@admin.register(User)
class CustomUserAdmin(UserAdmin):
    model = User

    list_display = ('display_name_column', 'email', 'role', 'is_active', 'date_joined')
    list_filter = ('role', 'is_active', 'is_staff')
    search_fields = ('username', 'email', 'first_name', 'last_name')

    fieldsets = UserAdmin.fieldsets + (
        ('Role Information', {'fields': ('role', 'firebase_uid')}),
    )

    add_fieldsets = UserAdmin.add_fieldsets + (
        ('Role Information', {'fields': ('role',)}),
    )
    
    def display_name_column(self, obj):
        """
        ✅ Show proper display name in list view
        """
        name = str(obj)  # Uses the __str__ method we defined
        
        # Add link to related profile if exists
        if obj.role == 'CUSTOMER' and hasattr(obj, 'customer_profile'):
            customer_url = reverse('admin:customers_customer_change', args=[obj.customer_profile.pk])
            return format_html(
                '<a href="{}">{}</a> <a href="{}" style="color: #0c4b33;">(View Profile)</a>',
                reverse('admin:accounts_user_change', args=[obj.pk]),
                name,
                customer_url
            )
        
        return format_html(
            '<a href="{}">{}</a>',
            reverse('admin:accounts_user_change', args=[obj.pk]),
            name
        )
    
    display_name_column.short_description = 'Name'
    display_name_column.admin_order_field = 'email'
