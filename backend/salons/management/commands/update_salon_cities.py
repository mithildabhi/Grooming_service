from django.core.management.base import BaseCommand
from salons.models import Salon

class Command(BaseCommand):
    help = 'Update city field for existing salons'

    def handle(self, *args, **options):
        salons = Salon.objects.filter(city='')
        count = 0
        
        for salon in salons:
            if salon.address:
                # Extract city from address
                parts = [p.strip() for p in salon.address.split(',')]
                if len(parts) >= 2:
                    salon.city = parts[1]
                    salon.save()
                    count += 1
                    self.stdout.write(
                        self.style.SUCCESS(
                            f'Updated {salon.name}: {salon.city}'
                        )
                    )
        
        self.stdout.write(
            self.style.SUCCESS(
                f'Successfully updated {count} salons'
            )
        )