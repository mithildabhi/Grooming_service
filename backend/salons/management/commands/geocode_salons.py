from django.core.management.base import BaseCommand
from salons.models import Salon
from salons.views import geocode_address
from time import sleep

class Command(BaseCommand):
    help = 'Geocode all salons without coordinates'

    def handle(self, *args, **options):
        salons = Salon.objects.filter(
            latitude__isnull=True
        ) | Salon.objects.filter(
            longitude__isnull=True
        )
        
        count = 0
        for salon in salons:
            if salon.address or salon.city:
                address = f"{salon.address}, {salon.city}, {salon.state}"
                coords = geocode_address(address)
                
                if coords:
                    salon.latitude = coords['lat']
                    salon.longitude = coords['lon']
                    salon.save()
                    count += 1
                    self.stdout.write(
                        self.style.SUCCESS(
                            f'✅ Geocoded: {salon.name} - {coords}'
                        )
                    )
                else:
                    self.stdout.write(
                        self.style.WARNING(
                            f'⚠️ Could not geocode: {salon.name}'
                        )
                    )
                
                # Be respectful to Nominatim
                sleep(1)
        
        self.stdout.write(
            self.style.SUCCESS(
                f'\n✅ Geocoded {count} salons'
            )
        )