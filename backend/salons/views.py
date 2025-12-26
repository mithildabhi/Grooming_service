from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from accounts.permissions import IsSalonOwner
from .models import Salon
from .serializers import SalonSerializer


@api_view(['GET'])
def salon_list(request):
    """Public endpoint - list all salons"""
    salons = Salon.objects.filter(is_open=True)
    serializer = SalonSerializer(salons, many=True)
    return Response(serializer.data)


@api_view(['GET'])
@permission_classes([IsSalonOwner])
def my_salon(request):
    try:
        salon = Salon.objects.get(owner=request.user)
        return Response(SalonSerializer(salon).data)
    except Salon.DoesNotExist:
        return Response({'detail': 'No salon found'}, status=404)


@api_view(['POST'])
@permission_classes([IsSalonOwner])
def salon_create(request):
    """
    Create salon if not exists,
    otherwise update existing salon for this owner
    """
    try:
        salon = Salon.objects.get(owner=request.user)
        # 🔁 UPDATE
        serializer = SalonSerializer(salon, data=request.data, partial=True)
    except Salon.DoesNotExist:
        # ➕ CREATE
        serializer = SalonSerializer(data=request.data)

    if serializer.is_valid():
        serializer.save(owner=request.user)
        return Response(serializer.data, status=status.HTTP_200_OK)

    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['PUT', 'PATCH'])
@permission_classes([IsSalonOwner])
def salon_update(request):
    """Update salon profile"""
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
        return Response(serializer.data)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['DELETE'])
@permission_classes([IsSalonOwner])
def salon_delete(request):
    """Delete/deactivate salon"""
    try:
        django_user = get_django_user_from_firebase(request)
        salon = Salon.objects.get(owner=django_user)
        # Soft delete - just mark as closed
        salon.is_open = False
        salon.save()
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
