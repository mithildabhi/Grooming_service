"""
Management command to sync all existing CUSTOMER users to Customer model
This ensures all users with role='CUSTOMER' have a Customer profile

Usage:
    python manage.py sync_customers
"""

from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from customers.models import Customer

User = get_user_model()


class Command(BaseCommand):
    help = 'Sync all existing CUSTOMER users to Customer profiles'

    def add_arguments(self, parser):
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Show what would be created without actually creating',
        )

    def handle(self, *args, **options):
        dry_run = options['dry_run']
        
        self.stdout.write(self.style.SUCCESS('=' * 70))
        self.stdout.write(self.style.SUCCESS('🔄 SYNCING CUSTOMER PROFILES'))
        self.stdout.write(self.style.SUCCESS('=' * 70))
        
        # Get all users with CUSTOMER role
        customer_users = User.objects.filter(role='CUSTOMER')
        total_users = customer_users.count()
        
        self.stdout.write(f'\n📊 Found {total_users} users with CUSTOMER role\n')
        
        if total_users == 0:
            self.stdout.write(self.style.WARNING('⚠️  No customer users found!'))
            return
        
        created_count = 0
        existing_count = 0
        errors = []
        
        for user in customer_users:
            try:
                # Check if customer profile exists
                if hasattr(user, 'customer_profile'):
                    existing_count += 1
                    self.stdout.write(
                        self.style.WARNING(
                            f'  ⏭️  {user.username} ({user.email}) - Profile already exists'
                        )
                    )
                else:
                    if not dry_run:
                        # Create customer profile
                        customer = Customer.objects.create(
                            user=user,
                            full_name=user.get_full_name() or user.username,
                        )
                        created_count += 1
                        self.stdout.write(
                            self.style.SUCCESS(
                                f'  ✅ {user.username} ({user.email}) - Profile created'
                            )
                        )
                    else:
                        created_count += 1
                        self.stdout.write(
                            self.style.NOTICE(
                                f'  🔍 {user.username} ({user.email}) - Would be created'
                            )
                        )
                        
            except Exception as e:
                errors.append((user.username, str(e)))
                self.stdout.write(
                    self.style.ERROR(
                        f'  ❌ {user.username} ({user.email}) - Error: {str(e)}'
                    )
                )
        
        # Summary
        self.stdout.write('\n' + '=' * 70)
        self.stdout.write(self.style.SUCCESS('📊 SUMMARY'))
        self.stdout.write('=' * 70)
        
        if dry_run:
            self.stdout.write(self.style.NOTICE('\n🔍 DRY RUN MODE - No changes made\n'))
        
        self.stdout.write(f'Total customer users: {total_users}')
        self.stdout.write(f'Profiles already existed: {existing_count}')
        self.stdout.write(
            self.style.SUCCESS(f'New profiles {"would be " if dry_run else ""}created: {created_count}')
        )
        
        if errors:
            self.stdout.write(self.style.ERROR(f'Errors encountered: {len(errors)}'))
            self.stdout.write('\nError details:')
            for username, error in errors:
                self.stdout.write(self.style.ERROR(f'  - {username}: {error}'))
        else:
            self.stdout.write(self.style.SUCCESS('\n✅ All operations completed successfully!'))
        
        if dry_run:
            self.stdout.write(
                self.style.NOTICE('\n💡 Run without --dry-run to actually create profiles')
            )
        else:
            self.stdout.write(
                self.style.SUCCESS('\n🎉 Customer profiles synced! Check Django admin.')
            )
        
        self.stdout.write('\n' + '=' * 70 + '\n')