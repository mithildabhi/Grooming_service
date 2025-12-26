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

            # 🔥 Map Firebase → Django User
            user, created = User.objects.get_or_create(
                username=uid,
                defaults={
                    'email': email,
                    'role': 'CUSTOMER'
                }
            )

            return (user, None)

        except Exception:
            raise AuthenticationFailed('Invalid Firebase token')
