from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from accounts.permissions import IsSalonOwner
from .models import Employee
from .serializers import EmployeeSerializer


@api_view(['GET'])
def staff_list(request):
    employees = Employee.objects.all()
    serializer = EmployeeSerializer(employees, many=True)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsSalonOwner])
def staff_create(request):
    serializer = EmployeeSerializer(data=request.data)
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data, status=201)
    return Response(serializer.errors, status=400)


@api_view(['GET', 'PUT', 'DELETE'])
@permission_classes([IsSalonOwner])
def staff_detail(request, pk):
    try:
        employee = Employee.objects.get(pk=pk)
    except Employee.DoesNotExist:
        return Response(status=404)

    if request.method == 'GET':
        return Response(EmployeeSerializer(employee).data)

    if request.method == 'PUT':
        serializer = EmployeeSerializer(employee, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=400)

    employee.delete()
    return Response(status=204)
