from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework import status
from accounts.permissions import IsSuperAdmin
from .models import Salon
from .serializers import SalonSerializer


@api_view(['GET'])
def salon_list(request):
    salons = Salon.objects.all()
    serializer = SalonSerializer(salons, many=True)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsSuperAdmin])
def salon_create(request):
    serializer = SalonSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(owner=request.user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET', 'PUT', 'DELETE'])
@permission_classes([IsSuperAdmin])
def salon_detail(request, pk):
    try:
        salon = Salon.objects.get(pk=pk)
    except Salon.DoesNotExist:
        return Response({"detail": "Not found"}, status=404)

    if request.method == 'GET':
        return Response(SalonSerializer(salon).data)

    if request.method == 'PUT':
        serializer = SalonSerializer(salon, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=400)

    salon.delete()
    return Response(status=204)
