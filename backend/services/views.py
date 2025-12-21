from rest_framework.decorators import api_view, permission_classes
from accounts.permissions import IsSalonOwner
from rest_framework.response import Response
from rest_framework import status
from .models import Service
from .serializers import ServiceSerializer

@api_view(['GET'])
def service_list(request):
    services = Service.objects.filter(is_active=True)
    serializer = ServiceSerializer(services, many=True)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsSalonOwner])
def service_create(request):
    serializer = ServiceSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=201)
    return Response(serializer.errors, status=400)


@api_view(['GET', 'PUT', 'DELETE'])
@permission_classes([IsSalonOwner])
def service_detail(request, pk):
    try:
        service = Service.objects.get(pk=pk)
    except Service.DoesNotExist:
        return Response(status=404)

    # Optional safety: owner can only manage their salon’s services
    if service.salon.owner != request.user:
        return Response({'detail': 'Not allowed'}, status=403)

    if request.method == 'GET':
        serializer = ServiceSerializer(service)
        return Response(serializer.data)

    if request.method == 'PUT':
        serializer = ServiceSerializer(service, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=400)

    service.delete()
    return Response(status=204)
