from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from accounts.permissions import IsSalonOwner
from rest_framework.response import Response
from rest_framework import status
from django.db.models import Q
from .models import Service
from .serializers import ServiceSerializer


@api_view(['GET'])
def service_list(request):
    """Public endpoint - list all active services, optionally filtered"""
    services = Service.objects.filter(is_active=True).select_related('salon')
    
    # Optional filters
    salon_id = request.query_params.get('salon')
    category = request.query_params.get('category')
    search = request.query_params.get('search')
    
    if salon_id:
        services = services.filter(salon_id=salon_id)
    if category:
        services = services.filter(category=category)
    if search:
        services = services.filter(
            Q(name__icontains=search) | 
            Q(description__icontains=search)
        )
    
    serializer = ServiceSerializer(services, many=True)
    return Response(serializer.data)


@api_view(['GET'])
@permission_classes([IsSalonOwner])
def my_services(request):
    """Owner's view - see all their services including inactive ones"""
    salon = request.user.salon  # Assuming one salon per owner
    services = Service.objects.filter(salon=salon).select_related('salon')
    
    serializer = ServiceSerializer(services, many=True)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsSalonOwner])
def service_create(request):
    """Create a new service"""
    data = request.data.copy()
    data['salon'] = request.user.salon.id  # Auto-assign to owner's salon
    
    serializer = ServiceSerializer(data=data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
@permission_classes([IsSalonOwner])
def service_detail(request, pk):
    """Manage individual service"""
    try:
        service = Service.objects.select_related('salon').get(pk=pk)
    except Service.DoesNotExist:
        return Response(
            {'detail': 'Service not found'}, 
            status=status.HTTP_404_NOT_FOUND
        )

    # Security: owner can only manage their salon's services
    if service.salon.owner != request.user:
        return Response(
            {'detail': 'You do not have permission to modify this service'}, 
            status=status.HTTP_403_FORBIDDEN
        )

    if request.method == 'GET':
        serializer = ServiceSerializer(service)
        return Response(serializer.data)

    if request.method in ['PUT', 'PATCH']:
        partial = request.method == 'PATCH'
        serializer = ServiceSerializer(service, data=request.data, partial=partial)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    if request.method == 'DELETE':
        # Soft delete - just deactivate instead of deleting
        service.is_active = False
        service.save()
        return Response(
            {'detail': 'Service deactivated successfully'}, 
            status=status.HTTP_200_OK
        )