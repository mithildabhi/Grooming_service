from rest_framework.decorators import api_view, permission_classes, authentication_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from authentication.firebase_auth import FirebaseAuthentication
from .models import Salon
from .serializers import SalonSerializer
import json


@api_view(['GET'])
def salon_list(request):
    """Public endpoint - list all salons"""
    salons = Salon.objects.filter(is_open=True)
    serializer = SalonSerializer(salons, many=True)
    return Response(serializer.data)


@api_view(['GET'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def my_salon(request):
    """Get authenticated user's salon"""
    try:
        salon = Salon.objects.get(owner=request.user)
        serializer = SalonSerializer(salon)
        return Response(serializer.data)
    except Salon.DoesNotExist:
        return Response(
            {'detail': 'No salon found for this user'},
            status=status.HTTP_404_NOT_FOUND
        )


@api_view(['POST'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def salon_create(request):
    """
    Create salon if not exists, otherwise update existing salon
    """
    print("\n" + "="*60)
    print("🔥 SALON CREATE/UPDATE REQUEST")
    print("="*60)
    print(f"📦 Request Data: {json.dumps(request.data, indent=2)}")
    print(f"👤 User: {request.user.email}")
    print(f"🎭 Role: {request.user.role}")
    print(f"🔑 User ID: {request.user.id}")
    
    try:
        # Check if salon already exists for this user
        salon = Salon.objects.get(owner=request.user)
        print(f"✏️ UPDATING existing salon: {salon.name} (ID: {salon.id})")
        
        # UPDATE existing salon
        serializer = SalonSerializer(salon, data=request.data, partial=True)
        
    except Salon.DoesNotExist:
        print("➕ CREATING new salon")
        
        # CREATE new salon
        serializer = SalonSerializer(data=request.data)

    if serializer.is_valid():
        # Save with owner
        saved_salon = serializer.save(owner=request.user)
        
        print(f"✅ SUCCESS! Salon saved: {saved_salon.name}")
        print(f"📍 ID: {saved_salon.id}")
        print(f"📞 Phone: {saved_salon.phone}")
        print(f"🏠 Address: {saved_salon.address}")
        print(f"🎨 Type: {saved_salon.salon_type}")
        print("="*60 + "\n")
        
        return Response(
            SalonSerializer(saved_salon).data,
            status=status.HTTP_201_CREATED
        )
    
    print(f"❌ VALIDATION ERRORS:")
    print(json.dumps(serializer.errors, indent=2))
    print("="*60 + "\n")
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['PUT', 'PATCH'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def salon_update(request):
    """Update salon profile"""
    print(f"\n🔄 UPDATE REQUEST from {request.user.email}")
    print(f"📦 Data: {request.data}")
    
    try:
        salon = Salon.objects.get(owner=request.user)
    except Salon.DoesNotExist:
        return Response(
            {'detail': 'No salon found. Please create one first.'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    # Partial update allows updating only specific fields
    serializer = SalonSerializer(salon, data=request.data, partial=True)
    
    if serializer.is_valid():
        serializer.save()
        print(f"✅ Salon updated: {salon.name}")
        return Response(serializer.data)
    
    print(f"❌ Validation errors: {serializer.errors}")
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['DELETE'])
@authentication_classes([FirebaseAuthentication])
@permission_classes([IsAuthenticated])
def salon_delete(request):
    """Delete/deactivate salon"""
    try:
        salon = Salon.objects.get(owner=request.user)
        # Soft delete - just mark as closed
        salon.is_open = False
        salon.save()
        
        print(f"🗑️ Salon deactivated: {salon.name}")
        
        return Response(
            {'detail': 'Salon deactivated successfully'},
            status=status.HTTP_200_OK
        )
    except Salon.DoesNotExist:
        return Response(
            {'detail': 'No salon found'},
            status=status.HTTP_404_NOT_FOUND
        )


@api_view(['GET'])
def salon_detail(request, pk):
    """Get single salon by ID (public)"""
    try:
        salon = Salon.objects.get(pk=pk, is_open=True)
        serializer = SalonSerializer(salon)
        return Response(serializer.data)
    except Salon.DoesNotExist:
        return Response(
            {'detail': 'Salon not found'},
            status=status.HTTP_404_NOT_FOUND
        )