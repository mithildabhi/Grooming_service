from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import Booking
from .serializers import BookingSerializer
from staff.models import Employee


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def booking_list(request):
    user = request.user

    if user.role == 'CUSTOMER':
        bookings = Booking.objects.filter(user=user)

    elif user.role == 'EMPLOYEE':
        employee = Employee.objects.get(user=user)
        bookings = Booking.objects.filter(salon=employee.salon)

    elif user.role == 'SALON_OWNER':
        bookings = Booking.objects.filter(salon__owner=user)

    else:  # SUPER_ADMIN
        bookings = Booking.objects.all()

    serializer = BookingSerializer(bookings, many=True)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_booking(request):
    serializer = BookingSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save(user=request.user)
        return Response(serializer.data, status=201)
    return Response(serializer.errors, status=400)


@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_booking_status(request, pk):
    try:
        booking = Booking.objects.get(pk=pk)
    except Booking.DoesNotExist:
        return Response(status=404)

    if request.user.role not in ['EMPLOYEE', 'SALON_OWNER', 'SUPER_ADMIN']:
        return Response({'detail': 'Not allowed'}, status=403)

    booking.status = request.data.get('status', booking.status)
    booking.save()
    return Response({'status': booking.status})
