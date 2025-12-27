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

            # 🔥 IMPORTANT: Attach firebase_user to request
            request.firebase_user = {
                'uid': uid,
                'email': email,
                'email_verified': decoded.get('email_verified', False),
                'phone_number': decoded.get('phone_number'),
                'name': decoded.get('name'),
                'picture': decoded.get('picture'),
            }

            # Map Firebase → Django User
            user, created = User.objects.get_or_create(
                username=uid,
                defaults={
                    'email': email,
                    'role': 'SALON_OWNER'  # Changed from CUSTOMER to SALON_OWNER
                }
            )

            return (user, None)

        except Exception as e:
            print(f"❌ Firebase auth error: {e}")
            raise AuthenticationFailed('Invalid Firebase token')
