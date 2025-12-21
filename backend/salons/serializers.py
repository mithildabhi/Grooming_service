from rest_framework import serializers
from .models import Salon

class SalonSerializer(serializers.ModelSerializer):
    admin = serializers.StringRelatedField(read_only=True)

    class Meta:
        model = Salon
        fields = ['id', 'name', 'address', 'rating', 'is_open', 'admin']
