# bookings/management/commands/setup_timeslots.py
# Create this file structure:
# bookings/
#   management/
#     __init__.py
#     commands/
#       __init__.py
#       setup_timeslots.py

from django.core.management.base import BaseCommand
from bookings.models import TimeSlot
from salons.models import Salon
from datetime import time

class Command(BaseCommand):
    help = 'Set up default operating hours for all salons'

    def handle(self, *args, **kwargs):
        salons = Salon.objects.all()
        
        if not salons.exists():
            self.stdout.write(self.style.ERROR('No salons found. Create a salon first.'))
            return
        
        # Default schedule
        schedule = [
            # Monday to Friday: 9 AM - 8 PM
            (0, time(9, 0), time(20, 0)),  # Monday
            (1, time(9, 0), time(20, 0)),  # Tuesday
            (2, time(9, 0), time(20, 0)),  # Wednesday
            (3, time(9, 0), time(20, 0)),  # Thursday
            (4, time(9, 0), time(20, 0)),  # Friday
            # Saturday: 10 AM - 6 PM
            (5, time(10, 0), time(18, 0)), # Saturday
            # Sunday: 10 AM - 6 PM
            (6, time(10, 0), time(18, 0)), # Sunday
        ]
        
        created_count = 0
        for salon in salons:
            self.stdout.write(f'Setting up time slots for: {salon.name}')
            
            for day, start, end in schedule:
                slot, created = TimeSlot.objects.get_or_create(
                    salon=salon,
                    day_of_week=day,
                    start_time=start,
                    defaults={'end_time': end}
                )
                
                if created:
                    created_count += 1
                    day_name = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][day]
                    self.stdout.write(
                        self.style.SUCCESS(
                            f'  ✅ Created: {day_name} {start.strftime("%H:%M")} - {end.strftime("%H:%M")}'
                        )
                    )
                else:
                    day_name = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][day]
                    self.stdout.write(
                        self.style.WARNING(
                            f'  ⏭️  Exists: {day_name} {start.strftime("%H:%M")} - {end.strftime("%H:%M")}'
                        )
                    )
        
        self.stdout.write(
            self.style.SUCCESS(f'\n✅ Setup complete! Created {created_count} new time slots.')
        )