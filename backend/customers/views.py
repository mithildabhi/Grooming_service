from rest_framework import generics, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404

from .models import Customer
from .serializers import (
    CustomerProfileSerializer,
    CustomerProfileUpdateSerializer,
    CustomerStatisticsSerializer,
    CustomerBookingSerializer,
    CustomerBookingDetailSerializer,
    CustomerDashboardSerializer,
)
from bookings.models import Booking


class CustomerProfileView(generics.RetrieveUpdateAPIView):
    """
    GET: Retrieve customer profile
    PUT/PATCH: Update customer profile
    
    Endpoints: 
        - /api/customers/me/  ✅ (Flutter uses this)
        - /api/customers/profile/
    """
    permission_classes = [IsAuthenticated]
    
    def get_serializer_class(self):
        if self.request.method in ['PUT', 'PATCH']:
            return CustomerProfileUpdateSerializer
        return CustomerProfileSerializer
    
    def get_object(self):
        """Get or create customer profile for authenticated user"""
        customer, created = Customer.objects.get_or_create(
            user=self.request.user,
            defaults={
                'full_name': self.request.user.get_full_name() or self.request.user.username
            }
        )
        
        if created:
            print(f"✅ Customer profile auto-created for {self.request.user.username}")
        
        return customer
    
    def retrieve(self, request, *args, **kwargs):
        """Override GET to return profile with statistics"""
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        
        return Response(serializer.data)
    
    def update(self, request, *args, **kwargs):
        """Override PUT/PATCH to handle profile updates properly"""
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        
        # Use update serializer
        serializer = CustomerProfileUpdateSerializer(
            instance, 
            data=request.data, 
            partial=partial
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        
        # Return full profile with statistics using GET serializer
        response_serializer = CustomerProfileSerializer(instance)
        
        return Response(response_serializer.data)
    
    def partial_update(self, request, *args, **kwargs):
        """Handle PATCH requests"""
        kwargs['partial'] = True
        return self.update(request, *args, **kwargs)


class CustomerStatisticsView(APIView):
    """
    GET: Retrieve customer statistics
    
    Endpoint: /api/customers/statistics/
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        """Get customer statistics"""
        try:
            customer = Customer.objects.get(user=request.user)
        except Customer.DoesNotExist:
            # Auto-create if doesn't exist
            customer = Customer.objects.create(
                user=request.user,
                full_name=request.user.get_full_name() or request.user.username
            )
        
        serializer = CustomerStatisticsSerializer(customer)
        return Response({
            'status': 'success',
            'data': serializer.data
        })


class CustomerBookingListView(generics.ListAPIView):
    """
    GET: List all bookings for customer
    Query params:
        - status: filter by booking status (PENDING, CONFIRMED, COMPLETED, CANCELLED)
        - limit: number of results to return
    
    Endpoint: /api/customers/bookings/
    """
    permission_classes = [IsAuthenticated]
    serializer_class = CustomerBookingSerializer
    
    def get_queryset(self):
        """Get bookings for authenticated customer"""
        queryset = Booking.objects.filter(
            user=self.request.user
        ).select_related(
            'salon', 'service', 'staff'
        ).order_by('-booking_date', '-booking_time')
        
        # Filter by status if provided
        status_filter = self.request.query_params.get('status', None)
        if status_filter:
            queryset = queryset.filter(status=status_filter.upper())
        
        # Limit results if specified
        limit = self.request.query_params.get('limit', None)
        if limit:
            try:
                queryset = queryset[:int(limit)]
            except ValueError:
                pass
        
        return queryset
    
    def list(self, request, *args, **kwargs):
        """Override to add custom response format"""
        queryset = self.get_queryset()
        serializer = self.get_serializer(queryset, many=True)
        
        return Response({
            'status': 'success',
            'count': queryset.count(),
            'data': serializer.data
        })


class CustomerUpcomingBookingsView(generics.ListAPIView):
    """
    GET: List upcoming bookings (PENDING or CONFIRMED)
    
    Endpoint: /api/customers/bookings/upcoming/
    """
    permission_classes = [IsAuthenticated]
    serializer_class = CustomerBookingSerializer
    
    def get_queryset(self):
        return Booking.objects.filter(
            user=self.request.user,
            status__in=['PENDING', 'CONFIRMED']
        ).select_related(
            'salon', 'service', 'staff'
        ).order_by('booking_date', 'booking_time')


class CustomerCompletedBookingsView(generics.ListAPIView):
    """
    GET: List completed bookings
    
    Endpoint: /api/customers/bookings/completed/
    """
    permission_classes = [IsAuthenticated]
    serializer_class = CustomerBookingSerializer
    
    def get_queryset(self):
        return Booking.objects.filter(
            user=self.request.user,
            status='COMPLETED'
        ).select_related(
            'salon', 'service', 'staff'
        ).order_by('-booking_date', '-booking_time')


class CustomerCancelledBookingsView(generics.ListAPIView):
    """
    GET: List cancelled bookings
    
    Endpoint: /api/customers/bookings/cancelled/
    """
    permission_classes = [IsAuthenticated]
    serializer_class = CustomerBookingSerializer
    
    def get_queryset(self):
        return Booking.objects.filter(
            user=self.request.user,
            status='CANCELLED'
        ).select_related(
            'salon', 'service', 'staff'
        ).order_by('-booking_date', '-booking_time')


class CustomerBookingDetailView(generics.RetrieveAPIView):
    """
    GET: Retrieve single booking details
    
    Endpoint: /api/customers/bookings/<id>/
    """
    permission_classes = [IsAuthenticated]
    serializer_class = CustomerBookingDetailSerializer
    
    def get_queryset(self):
        """Only allow customers to view their own bookings"""
        return Booking.objects.filter(
            user=self.request.user
        ).select_related('salon', 'service', 'staff')
    
    def retrieve(self, request, *args, **kwargs):
        """Override to add custom response format"""
        instance = self.get_object()
        serializer = self.get_serializer(instance)
        
        return Response({
            'status': 'success',
            'data': serializer.data
        })


class CustomerDashboardView(APIView):
    """
    GET: Complete dashboard with profile, statistics, and recent bookings
    
    Endpoint: /api/customers/dashboard/
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        """Get complete customer dashboard data"""
        # Get or create customer profile
        customer, created = Customer.objects.get_or_create(
            user=request.user,
            defaults={
                'full_name': request.user.get_full_name() or request.user.username
            }
        )
        
        if created:
            print(f"✅ Customer profile auto-created for {request.user.username}")
        
        serializer = CustomerDashboardSerializer(customer)
        return Response({
            'status': 'success',
            'data': serializer.data
        })


class CustomerProfilePictureUploadView(APIView):
    """
    POST: Upload profile picture
    DELETE: Remove profile picture
    
    Endpoint: /api/customers/profile/picture/
    """
    permission_classes = [IsAuthenticated]
    
    def post(self, request):
        """Upload profile picture"""
        # Get or create customer profile
        customer, created = Customer.objects.get_or_create(
            user=request.user,
            defaults={
                'full_name': request.user.get_full_name() or request.user.username
            }
        )
        
        if 'profile_picture' not in request.FILES:
            return Response(
                {
                    'status': 'error',
                    'message': 'No image file provided'
                },
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Delete old picture if exists
        if customer.profile_picture:
            customer.profile_picture.delete(save=False)
        
        # Save new picture
        customer.profile_picture = request.FILES['profile_picture']
        customer.save()
        
        return Response({
            'status': 'success',
            'message': 'Profile picture uploaded successfully',
            'profile_picture_url': customer.profile_picture.url if customer.profile_picture else None
        })
    
    def delete(self, request):
        """Delete profile picture"""
        try:
            customer = Customer.objects.get(user=request.user)
        except Customer.DoesNotExist:
            return Response(
                {
                    'status': 'error',
                    'message': 'Customer profile not found'
                },
                status=status.HTTP_404_NOT_FOUND
            )
        
        if customer.profile_picture:
            customer.profile_picture.delete(save=True)
            return Response({
                'status': 'success',
                'message': 'Profile picture deleted successfully'
            })
        
        return Response(
            {
                'status': 'error',
                'message': 'No profile picture to delete'
            },
            status=status.HTTP_400_BAD_REQUEST
        )