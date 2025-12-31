from firebase_admin import auth
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from django.contrib.auth import get_user_model

User = get_user_model()

class FirebaseAuthentication(BaseAuthentication):
    def authenticate(self, request):
        auth_header = request.headers.get('Authorization')

        if not auth_header:
            return None

        try:
            token = auth_header.split(' ')[1]
            decoded = auth.verify_id_token(token)

            uid = decoded['uid']
            email = decoded.get('email', '')

            # Attach firebase_user to request
            request.firebase_user = {
                'uid': uid,
                'email': email,
                'email_verified': decoded.get('email_verified', False),
                'phone_number': decoded.get('phone_number'),
                'name': decoded.get('name'),
                'picture': decoded.get('picture'),
            }

            # ✅ FIXED: Check if user exists first
            try:
                user = User.objects.get(username=uid)
                print(f"✅ Existing user found: {user.email}, Role: {user.role}")
            except User.DoesNotExist:
                # ✅ NEW: Create with CUSTOMER as default (will be updated by register endpoint)
                user = User.objects.create_user(
                    username=uid,
                    email=email,
                    role='CUSTOMER'  # Default to customer, register endpoint will update if needed
                )
                print(f"🆕 New user created: {user.email}, Role: {user.role}")

            return (user, None)

        except Exception as e:
            print(f"❌ Firebase auth error: {e}")
            raise AuthenticationFailed('Invalid Firebase token')