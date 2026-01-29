# salons/signals.py
"""
Django signals for automatic geocoding
This ensures coordinates are always up-to-date when address changes
"""

from django.db.models.signals import pre_save
from django.dispatch import receiver
from .models import Salon
import logging

logger = logging.getLogger(__name__)


@receiver(pre_save, sender=Salon)
def auto_geocode_salon_address(sender, instance, **kwargs):
    """
    Automatically geocode salon address before saving
    
    Triggers geocoding when:
    1. New salon is created without coordinates
    2. Address/city/state/pincode is changed on existing salon
    """
    
    # Skip if this is being called from a save() that already has coordinates
    if hasattr(instance, '_skip_geocoding'):
        return
    
    should_geocode = False
    
    # NEW SALON: Geocode if no coordinates exist
    if not instance.pk:  # New object
        if not instance.latitude or not instance.longitude:
            should_geocode = True
            logger.info(f"🆕 New salon without coordinates: {instance.name}")
    
    # EXISTING SALON: Check if address changed
    else:
        try:
            old_salon = Salon.objects.get(pk=instance.pk)
            
            # Check if any address component changed
            address_changed = (
                old_salon.address != instance.address or
                old_salon.city != instance.city or
                old_salon.state != instance.state or
                old_salon.pincode != instance.pincode
            )
            
            if address_changed:
                should_geocode = True
                logger.info(f"📍 Address changed for salon: {instance.name}")
                logger.info(f"   Old: {old_salon.full_address}")
                logger.info(f"   New: {instance.full_address}")
            
        except Salon.DoesNotExist:
            pass
    
    # Perform geocoding if needed
    if should_geocode:
        from .views import geocode_address
        
        full_address = instance.full_address
        logger.info(f"🗺️ Geocoding: {full_address}")
        
        coords = geocode_address(full_address)
        
        if coords:
            instance.latitude = coords['lat']
            instance.longitude = coords['lon']
            logger.info(f"✅ Geocoded to: ({coords['lat']}, {coords['lon']})")
        else:
            logger.warning(f"⚠️ Failed to geocode: {full_address}")