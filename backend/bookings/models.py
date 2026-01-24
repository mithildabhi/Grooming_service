from django.db import models
from django.conf import settings
from django.core.exceptions import ValidationError
from salons.models import Salon
from services.models import Service
from staff.models import Employee
from datetime import datetime, timedelta, time
from django.utils import timezone

class Booking(models.Model):
    STATUS_CHOICES = [
        ('PENDING', 'Pending'),
        ('CONFIRMED', 'Confirmed'),
        ('COMPLETED', 'Completed'),
        ('CANCELLED', 'Cancelled'),
        ('NO_SHOW', 'No Show'),
    ]

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='bookings'
    )

    salon = models.ForeignKey(
        Salon,
        on_delete=models.CASCADE,
        related_name='bookings'
    )

    service = models.ForeignKey(
        Service,
        on_delete=models.CASCADE,
        related_name='bookings'
    )
    
    staff = models.ForeignKey(
        Employee,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='bookings',
        help_text="Assigned staff member"
    )

    booking_date = models.DateField()
    booking_time = models.TimeField()
    end_time = models.TimeField(null=True, blank=True)

    # ✅ NEW: Store the price at booking time
    price = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0,
        help_text="Service price at booking time"
    )

    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='CONFIRMED'
    )
    
    customer_name = models.CharField(max_length=100, blank=True)
    customer_phone = models.CharField(max_length=20, blank=True)
    notes = models.TextField(blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-booking_date', '-booking_time']
        indexes = [
            models.Index(fields=['salon', 'booking_date', 'status']),
            models.Index(fields=['staff', 'booking_date']),
            models.Index(fields=['user', 'booking_date']),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=['staff', 'booking_date', 'booking_time'],
                condition=models.Q(status__in=['CONFIRMED', 'PENDING']),
                name='unique_staff_booking_slot'
            )
        ]

    def __str__(self):
        return f"{self.user} - {self.service} on {self.booking_date} at {self.booking_time} - ₹{self.price}"

    def save(self, *args, **kwargs):
        # ✅ Auto-set price from service if not already set
        if not self.price and self.service:
            self.price = self.service.price
        
        # Auto-calculate end time
        if not self.end_time and self.service:
            start_datetime = datetime.combine(
                datetime.today(),
                self.booking_time
            )
            end_datetime = start_datetime + timedelta(minutes=self.service.duration)
            self.end_time = end_datetime.time()
        
        self.clean()
        super().save(*args, **kwargs)

    def clean(self):
        """Validate booking doesn't overlap with existing ones"""
        if not self.booking_date or not self.booking_time or not self.service:
            return
        
        if not self.end_time:
            start_datetime = datetime.combine(datetime.today(), self.booking_time)
            end_datetime = start_datetime + timedelta(minutes=self.service.duration)
            self.end_time = end_datetime.time()
        
        if self.staff:
            overlapping = Booking.objects.filter(
                staff=self.staff,
                booking_date=self.booking_date,
                status__in=['CONFIRMED', 'PENDING']
            ).exclude(pk=self.pk if self.pk else None)
            
            for booking in overlapping:
                if self._times_overlap(
                    self.booking_time, self.end_time,
                    booking.booking_time, booking.end_time
                ):
                    raise ValidationError(
                        f"Time slot conflicts with existing booking for {self.staff.full_name}. "
                        f"Existing booking: {booking.booking_time} - {booking.end_time}"
                    )
    
    def _times_overlap(self, start1, end1, start2, end2):
        """Check if two time ranges overlap"""
        return not (end1 <= start2 or end2 <= start1)
    
    @property
    def duration_minutes(self):
        """Get booking duration in minutes"""
        return self.service.duration if self.service else 0
    
    @property
    def is_past(self):
        """Check if booking is in the past"""
        booking_datetime = datetime.combine(self.booking_date, self.booking_time)
        return booking_datetime < timezone.now()


class TimeSlot(models.Model):
    """Define available time slots for the salon"""
    salon = models.ForeignKey(
        Salon,
        on_delete=models.CASCADE,
        related_name='time_slots'
    )
    
    day_of_week = models.IntegerField(
        choices=[
            (0, 'Monday'),
            (1, 'Tuesday'),
            (2, 'Wednesday'),
            (3, 'Thursday'),
            (4, 'Friday'),
            (5, 'Saturday'),
            (6, 'Sunday'),
        ],
        help_text="0=Monday, 6=Sunday"
    )
    
    start_time = models.TimeField()
    end_time = models.TimeField()
    is_active = models.BooleanField(default=True)
    
    class Meta:
        ordering = ['day_of_week', 'start_time']
        unique_together = ['salon', 'day_of_week', 'start_time']
    
    def __str__(self):
        return f"{self.salon.name} - {self.get_day_of_week_display()}: {self.start_time} - {self.end_time}"


class BookingBlockout(models.Model):
    """Block specific dates/times when bookings are not available"""
    salon = models.ForeignKey(
        Salon,
        on_delete=models.CASCADE,
        related_name='blockouts'
    )
    
    staff = models.ForeignKey(
        Employee,
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='blockouts',
        help_text="Leave blank to block for entire salon"
    )
    
    start_date = models.DateField()
    end_date = models.DateField()
    start_time = models.TimeField(null=True, blank=True)
    end_time = models.TimeField(null=True, blank=True)
    reason = models.CharField(max_length=200)
    is_active = models.BooleanField(default=True)
    
    class Meta:
        ordering = ['-start_date']
    
    def __str__(self):
        if self.staff:
            return f"{self.staff.full_name} - {self.start_date} to {self.end_date}"
        return f"{self.salon.name} - {self.start_date} to {self.end_date}"
