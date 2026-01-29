from django.contrib import admin
from .models import Salon

@admin.register(Salon)
class SalonAdmin(admin.ModelAdmin):
    list_display = ['name', 'city', 'salon_type', 'phone', 'is_open', 'created_at']
    list_filter = ['city', 'state', 'salon_type', 'is_open']
    search_fields = ['name', 'address', 'city', 'phone']
    
    fieldsets = (
        ('Basic Information', {
            'fields': ('owner', 'name', 'salon_type', 'phone', 'about', 'image_url')
        }),
        ('Location', {
            'fields': ('address', 'city', 'state', 'pincode', 'latitude', 'longitude')
        }),
        ('Hours & Status', {
            'fields': ('hours', 'rating', 'is_open')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    readonly_fields = ['created_at', 'updated_at']