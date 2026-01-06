# bookings/management/commands/auto_complete_bookings.py
from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import datetime, timedelta
from bookings.models import Booking

class Command(BaseCommand):
    help = 'Auto-complete past bookings'

    def handle(self, *args, **kwargs):
        now = timezone.now()
        
        # Find all confirmed bookings that have passed
        past_bookings = Booking.objects.filter(
            status='CONFIRMED',
            booking_date__lte=now.date()
        )
        
        completed_count = 0
        for booking in past_bookings:
            booking_datetime = datetime.combine(
                booking.booking_date,
                booking.booking_time
            )
            end_time = booking_datetime + timedelta(minutes=booking.service.duration)
            
            if end_time < now:
                booking.status = 'COMPLETED'
                booking.save()
                completed_count += 1
        
        self.stdout.write(
            self.stdout.style.SUCCESS(
                f'✅ Auto-completed {completed_count} bookings'
            )
        )