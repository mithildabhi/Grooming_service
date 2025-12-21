from django.contrib import admin
from .models import Booking

@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'get_salon', 'service', 'booking_date', 'status')

    def get_salon(self, obj):
        return obj.service.salon.name
