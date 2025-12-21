from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import get_user_model

User = get_user_model()

@api_view(['POST'])
def register(request):
    username = request.data.get('username')
    email = request.data.get('email')
    password = request.data.get('password')
    role = request.data.get('role', 'user')

    if not password or not (username or email):
        return Response(
            {"error": "Username or email and password are required"},
            status=status.HTTP_400_BAD_REQUEST
        )

    # If username not provided, use email as username
    if not username:
        username = email

    if User.objects.filter(username=username).exists():
        return Response(
            {"error": "User already exists"},
            status=status.HTTP_400_BAD_REQUEST
        )

    if email and User.objects.filter(email=email).exists():
        return Response(
            {"error": "Email already exists"},
            status=status.HTTP_400_BAD_REQUEST
        )

    user = User.objects.create_user(
        username=username,
        email=email,
        password=password
    )
    # ✅ FORCE DEFAULT ROLE
    user.role = 'customer'
    user.save()
    # Save role if your custom user has it
    # if hasattr(user, 'role'):
    #     user.role = role
    #     user.save()

    return Response(
        {
            "message": "User registered successfully",
            "username": user.username,
            "email": user.email,
            "role": getattr(user, 'role', 'user')
        },
        status=status.HTTP_201_CREATED
    )
