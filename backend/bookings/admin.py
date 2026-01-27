from django.contrib import admin
from django.utils.html import format_html
from django.urls import reverse
from .models import Booking, TimeSlot, BookingBlockout


@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = (
        'id',
        'customer_name_display',  # ✅ CHANGED
        'get_salon',
        'service',
        'booking_date',
        'booking_time',
        'price_display',
        'status',
        'staff'
    )
    
    list_filter = ('status', 'booking_date', 'salon')
    search_fields = (
        'user__email',
        'user__customer_profile__full_name',  # ✅ Search by customer name
        'customer_name',
        'customer_phone'
    )
    readonly_fields = ('created_at', 'updated_at', 'end_time', 'user_info_display')
    
    fieldsets = (
        ('Customer Information', {
            'fields': (
                'user',
                'user_info_display',  # ✅ Show customer details
                'customer_name',
                'customer_phone',
            )
        }),
        ('Booking Information', {
            'fields': (
                'salon',
                'service',
                'staff',
                'price',
            )
        }),
        ('Date & Time', {
            'fields': (
                'booking_date',
                'booking_time',
                'end_time',
            )
        }),
        ('Additional Information', {
            'fields': (
                'notes',
            )
        }),
        ('Status', {
            'fields': (
                'status',
            )
        }),
        ('Timestamps', {
            'fields': (
                'created_at',
                'updated_at',
            ),
            'classes': ('collapse',)
        }),
    )

    def customer_name_display(self, obj):
        """
        ✅ Display customer name with link to customer profile
        """
        customer_name = str(obj.user)
        
        # If user is a customer, link to customer profile
        if obj.user.role == 'CUSTOMER' and hasattr(obj.user, 'customer_profile'):
            customer_url = reverse('admin:customers_customer_change', args=[obj.user.customer_profile.pk])
            return format_html(
                '<a href="{}" style="font-weight: bold; color: #0c4b33;">{}</a>',
                customer_url,
                customer_name
            )
        
        return customer_name
    
    customer_name_display.short_description = 'Customer'
    customer_name_display.admin_order_field = 'user__customer_profile__full_name'
    
    def user_info_display(self, obj):
        """
        ✅ Show detailed customer information in booking detail
        """
        if obj.user.role == 'CUSTOMER' and hasattr(obj.user, 'customer_profile'):
            profile = obj.user.customer_profile
            customer_url = reverse('admin:customers_customer_change', args=[profile.pk])
            
            return format_html(
                '<div style="background: #f8f9fa; padding: 15px; border-radius: 5px; border-left: 4px solid #0c4b33;">'
                '<strong style="font-size: 16px; color: #0c4b33;">{}</strong><br>'
                '<span style="color: #666;">📧 {}</span><br>'
                '<span style="color: #666;">📱 {}</span><br>'
                '<span style="color: #666;">📍 {}</span><br>'
                '<a href="{}" style="color: #0c4b33; font-weight: bold; margin-top: 10px; display: inline-block;">View Full Profile →</a>'
                '</div>',
                profile.full_name or 'N/A',
                obj.user.email,
                profile.phone or 'N/A',
                f"{profile.city}, {profile.pincode}" if profile.city else 'N/A',
                customer_url
            )
        
        return format_html(
            '<div style="padding: 10px; color: #666;">'
            'Email: {}<br>'
            'Role: {}'
            '</div>',
            obj.user.email,
            obj.user.get_role_display()
        )
    
    user_info_display.short_description = 'Customer Details'
    
    def price_display(self, obj):
        """Display price with currency symbol"""
        return format_html(
            '<span style="font-weight: bold; color: #0c4b33;">₹{}</span>',
            f'{obj.price:,.2f}'
        )
    
    price_display.short_description = 'Price'
    price_display.admin_order_field = 'price'

    def get_salon(self, obj):
        return obj.salon.name
    get_salon.short_description = 'Salon'
    get_salon.admin_order_field = 'salon__name'
    
    def save_model(self, request, obj, form, change):
        # Auto-set price if not provided
        if not obj.price and obj.service:
            obj.price = obj.service.price
        super().save_model(request, obj, form, change)
    
    def get_queryset(self, request):
        """
        ✅ Optimize queries - load customer profiles
        """
        qs = super().get_queryset(request)
        return qs.select_related(
            'user',
            'user__customer_profile',
            'salon',
            'service',
            'staff'
        )


@admin.register(TimeSlot)
class TimeSlotAdmin(admin.ModelAdmin):
    list_display = ('salon', 'get_day_of_week_display', 'start_time', 'end_time', 'is_active')
    list_filter = ('salon', 'day_of_week', 'is_active')


@admin.register(BookingBlockout)
class BookingBlockoutAdmin(admin.ModelAdmin):
    list_display = ('salon', 'staff', 'start_date', 'end_date', 'reason', 'is_active')
    list_filter = ('salon', 'is_active', 'start_date')