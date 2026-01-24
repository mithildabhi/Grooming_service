from django.contrib import admin
from .models import Booking, TimeSlot, BookingBlockout

@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = (
        'id',
        'user',
        'get_salon',
        'service',
        'booking_date',
        'booking_time',
        'price',  # ✅ SHOW PRICE
        'status',
        'staff'
    )
    
    list_filter = ('status', 'booking_date', 'salon')
    search_fields = ('user__email', 'customer_name', 'customer_phone')
    readonly_fields = ('created_at', 'updated_at', 'end_time')
    
    fieldsets = (
        ('Booking Information', {
            'fields': (
                'user',
                'salon',
                'service',
                'staff',
                'price',  # ✅ EDITABLE PRICE
            )
        }),
        ('Date & Time', {
            'fields': (
                'booking_date',
                'booking_time',
                'end_time',
            )
        }),
        ('Customer Details', {
            'fields': (
                'customer_name',
                'customer_phone',
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

    def get_salon(self, obj):
        return obj.salon.name
    get_salon.short_description = 'Salon'
    
    def save_model(self, request, obj, form, change):
        # Auto-set price if not provided
        if not obj.price and obj.service:
            obj.price = obj.service.price
        super().save_model(request, obj, form, change)


@admin.register(TimeSlot)
class TimeSlotAdmin(admin.ModelAdmin):
    list_display = ('salon', 'get_day_of_week_display', 'start_time', 'end_time', 'is_active')
    list_filter = ('salon', 'day_of_week', 'is_active')


@admin.register(BookingBlockout)
class BookingBlockoutAdmin(admin.ModelAdmin):
    list_display = ('salon', 'staff', 'start_date', 'end_date', 'reason', 'is_active')
    list_filter = ('salon', 'is_active', 'start_date')
