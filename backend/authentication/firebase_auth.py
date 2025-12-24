from firebase_admin import auth
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed

class FirebaseAuthentication(BaseAuthentication):
    def authenticate(self, request):
        auth_header = request.headers.get('Authorization')

        if not auth_header:
            return None  # No auth header → DRF handles it

        try:
            token = auth_header.split(' ')[1]  # Bearer <token>
            decoded_token = auth.verify_id_token(token)
            request.firebase_user = decoded_token
            return (decoded_token, None)
        except Exception:
            raise AuthenticationFailed('Invalid or expired Firebase token')
