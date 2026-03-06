from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny
from accounts.permissions import IsSalonOwner
from accounts.models import User
from .models import Employee
from .serializers import EmployeeSerializer


@api_view(['GET'])
@permission_classes([IsSalonOwner])
def staff_list(request):
    """Get all staff for the salon owner"""
    salon = request.user.salon
    employees = Employee.objects.filter(salon=salon)
    serializer = EmployeeSerializer(employees, many=True)
    return Response(serializer.data)


@api_view(['GET'])
@permission_classes([AllowAny])
def staff_public_list(request):
    """
    Get all active staff for a specific salon (Public access)
    Usage: /staff/public/?salon_id=1
    """
    salon_id = request.query_params.get('salon_id')
    if not salon_id:
        return Response(
            {'error': 'salon_id is required'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
        
    try:
        # Only show active staff
        employees = Employee.objects.filter(salon_id=salon_id, is_active=True)
        serializer = EmployeeSerializer(employees, many=True)
        return Response(serializer.data)
    except Exception as e:
        return Response(
            {'error': str(e)}, 
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['POST'])
@permission_classes([IsSalonOwner])
def staff_create(request):
    """Create a new staff member"""
    data = request.data.copy()
    
    # Auto-create a User for the employee
    try:
        # Create user with email as username
        user = User.objects.create_user(
            username=data.get('email'),
            email=data.get('email'),
            role='EMPLOYEE'
        )
        
        data['user'] = user.id
        data['salon'] = request.user.salon.id
        
        print(f"📥 Creating staff with data: {data}")
        
        serializer = EmployeeSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            print(f"✅ Staff created: {serializer.data}")
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        
        # If validation fails, delete the created user
        user.delete()
        print(f"❌ Validation errors: {serializer.errors}")
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
    except Exception as e:
        print(f"❌ Error creating staff: {e}")
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET', 'PUT', 'PATCH', 'DELETE'])
@permission_classes([IsSalonOwner])
def staff_detail(request, pk):
    """Manage individual staff member"""
    try:
        employee = Employee.objects.get(pk=pk)
    except Employee.DoesNotExist:
        return Response(
            {'detail': 'Staff member not found'},
            status=status.HTTP_404_NOT_FOUND
        )

    # Security: owner can only manage their salon's staff
    if employee.salon.owner != request.user:
        return Response(
            {'detail': 'You do not have permission to modify this staff member'},
            status=status.HTTP_403_FORBIDDEN
        )

    if request.method == 'GET':
        serializer = EmployeeSerializer(employee)
        return Response(serializer.data)

    if request.method in ['PUT', 'PATCH']:
        partial = request.method == 'PATCH'
        
        data = request.data.copy()
        
        # Ensure salon and user fields are set
        if 'salon' not in data:
            data['salon'] = employee.salon.id
        if 'user' not in data:
            data['user'] = employee.user.id
        
        print(f"🔄 Update request data: {data}")
        
        serializer = EmployeeSerializer(employee, data=data, partial=partial)
        if serializer.is_valid():
            serializer.save()
            print(f"✅ Staff updated successfully")
            return Response(serializer.data)
        
        print(f"❌ Validation errors: {serializer.errors}")
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    if request.method == 'DELETE':
        employee.user.delete()  # This will cascade delete the employee
        return Response(
            {'detail': 'Staff member deleted successfully'},
            status=status.HTTP_200_OK
        )