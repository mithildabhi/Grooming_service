from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.contrib.auth import get_user_model
from firebase_admin import auth as firebase_auth

User = get_user_model()

@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    """
    Register a new user or update existing user's role
    """
    try:
        email = request.data.get('email')
        password = request.data.get('password')
        role = request.data.get('role', 'user')  # 'user' or 'admin' from Flutter
        firebase_uid = request.data.get('firebase_uid')

        if not email or not password:
            return Response(
                {"error": "Email and password are required"},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Map Flutter role to Django role
        django_role = 'SALON_OWNER' if role == 'admin' else 'CUSTOMER'
        
        print(f"📝 Registration request:")
        print(f"  - Email: {email}")
        print(f"  - Flutter role: {role}")
        print(f"  - Django role: {django_role}")
        print(f"  - Firebase UID: {firebase_uid}")

        # Get Firebase UID from token if not provided
        if not firebase_uid:
            auth_header = request.headers.get('Authorization')
            if auth_header:
                try:
                    token = auth_header.split(' ')[1]
                    decoded = firebase_auth.verify_id_token(token)
                    firebase_uid = decoded['uid']
                    print(f"✅ Got Firebase UID from token: {firebase_uid}")
                except Exception as e:
                    print(f"⚠️ Could not extract Firebase UID from token: {e}")

        # ✅ CHECK 1: Check if user exists by Firebase UID
        if firebase_uid:
            try:
                user = User.objects.get(username=firebase_uid)
                # Update existing user
                user.email = email
                user.role = django_role
                if firebase_uid:
                    user.firebase_uid = firebase_uid
                user.save()
                
                print(f"✅ Updated existing user (by UID): {user.email}, Role: {user.role}")
                
                return Response(
                    {
                        "message": "User profile updated successfully",
                        "email": user.email,
                        "role": user.role,
                        "username": user.username,
                        "updated": True
                    },
                    status=status.HTTP_200_OK
                )
            except User.DoesNotExist:
                pass  # User doesn't exist, continue to creation

        # ✅ CHECK 2: Check if user exists by email
        try:
            user = User.objects.get(email=email)
            
            # ✅ IMPORTANT: Update role if different
            if user.role != django_role:
                print(f"📝 Updating user role from {user.role} to {django_role}")
                user.role = django_role
                if firebase_uid:
                    user.username = firebase_uid
                    user.firebase_uid = firebase_uid
                user.save()
                
                return Response(
                    {
                        "message": "User role updated successfully",
                        "email": user.email,
                        "role": user.role,
                        "username": user.username,
                        "updated": True
                    },
                    status=status.HTTP_200_OK
                )
            else:
                # Same role, just return success
                print(f"✅ User already exists with same role: {user.role}")
                return Response(
                    {
                        "message": "User already registered",
                        "email": user.email,
                        "role": user.role,
                        "username": user.username,
                        "updated": False
                    },
                    status=status.HTTP_200_OK
                )
                
        except User.DoesNotExist:
            pass  # User doesn't exist, continue to creation

        # ✅ CREATE NEW USER
        username = firebase_uid if firebase_uid else email.split('@')[0]
        
        user = User.objects.create_user(
            username=username,
            email=email,
            password=password,
            role=django_role
        )
        
        if firebase_uid:
            user.firebase_uid = firebase_uid
            user.save()
        
        print(f"✅ Created new user: {user.email}, Role: {user.role}")

        return Response(
            {
                "message": "User registered successfully",
                "email": user.email,
                "role": user.role,
                "username": user.username,
                "created": True
            },
            status=status.HTTP_201_CREATED
        )

    except Exception as e:
        print(f"❌ Registration error: {str(e)}")
        import traceback
        traceback.print_exc()
        return Response(
            {"error": f"Registration failed: {str(e)}"},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
        
                
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_user_profile(request):
    """Get current user profile with role"""
    user = request.user
    
    print(f"📤 Sending user profile: {user.email}, Role: {user.role}")
    
    return Response({
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'role': user.role,
        'firebase_uid': getattr(user, 'firebase_uid', None),
    })
