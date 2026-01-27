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
    ✅ NOW ALSO HANDLES: full_name, phone, gender for Customer profile
    """
    try:
        email = request.data.get('email')
        password = request.data.get('password')
        role = request.data.get('role', 'user')  # 'user' or 'admin' from Flutter
        firebase_uid = request.data.get('firebase_uid')
        
        # ✅ EXTRACT CUSTOMER PROFILE DATA
        full_name = request.data.get('full_name', '')
        phone = request.data.get('phone', '')
        gender = request.data.get('gender', 'NOT_SPECIFIED')

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
        print(f"  - Full Name: {full_name}")
        print(f"  - Phone: {phone}")
        print(f"  - Gender: {gender}")

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
        user_created = False
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
                
            except User.DoesNotExist:
                pass  # User doesn't exist, continue to check by email

        # ✅ CHECK 2: Check if user exists by email
        if not firebase_uid or not User.objects.filter(username=firebase_uid).exists():
            try:
                user = User.objects.get(email=email)
                
                # ✅ IMPORTANT: Update role if different
                if user.role != django_role:
                    print(f"🔄 Updating user role from {user.role} to {django_role}")
                    user.role = django_role
                    if firebase_uid:
                        user.username = firebase_uid
                        user.firebase_uid = firebase_uid
                    user.save()
                else:
                    print(f"✅ User already exists with same role: {user.role}")
                    
            except User.DoesNotExist:
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
                
                user_created = True
                print(f"✅ Created new user: {user.email}, Role: {user.role}")

        # ✅✅✅ CRITICAL FIX: Update Customer profile with registration data
        if django_role == 'CUSTOMER':
            from customers.models import Customer
            
            # Get or create customer profile
            customer, created = Customer.objects.get_or_create(
                user=user,
                defaults={
                    'full_name': full_name or user.username,
                    'phone': phone,
                    'gender': gender,
                }
            )
            
            if created:
                print(f"✅ Customer profile created with registration data")
            else:
                # Update existing customer profile with new data
                updated = False
                
                if full_name and full_name != customer.full_name:
                    customer.full_name = full_name
                    updated = True
                    print(f"✅ Updated customer full_name: {full_name}")
                
                if phone and phone != customer.phone:
                    customer.phone = phone
                    updated = True
                    print(f"✅ Updated customer phone: {phone}")
                
                if gender and gender != customer.gender:
                    customer.gender = gender
                    updated = True
                    print(f"✅ Updated customer gender: {gender}")
                
                if updated:
                    customer.save()
                    print(f"✅ Customer profile updated with registration data")
            
            print(f"📊 Final Customer Profile:")
            print(f"   - Full Name: {customer.full_name}")
            print(f"   - Phone: {customer.phone}")
            print(f"   - Gender: {customer.gender}")
            print(f"   - Email: {customer.email}")

        response_data = {
            "message": "User registered successfully" if user_created else "User profile updated successfully",
            "email": user.email,
            "role": user.role,
            "username": user.username,
            "created": user_created,
            "updated": not user_created
        }
        
        # Add customer profile data to response for CUSTOMER role
        if django_role == 'CUSTOMER':
            response_data['customer_profile'] = {
                'full_name': customer.full_name,
                'phone': customer.phone,
                'gender': customer.gender,
            }

        return Response(
            response_data,
            status=status.HTTP_201_CREATED if user_created else status.HTTP_200_OK
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
    
    response_data = {
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'role': user.role,
        'firebase_uid': getattr(user, 'firebase_uid', None),
    }
    
    # ✅ Add customer profile data if user is a customer
    if user.role == 'CUSTOMER' and hasattr(user, 'customer_profile'):
        customer = user.customer_profile
        response_data['customer_profile'] = {
            'full_name': customer.full_name,
            'phone': customer.phone,
            'gender': customer.gender,
            'address': customer.address,
            'city': customer.city,
            'pincode': customer.pincode,
        }
    
    return Response(response_data)