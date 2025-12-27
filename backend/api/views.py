from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from authentication.firebase_auth import FirebaseAuthentication
from .models import AppUser

class TestProtectedView(APIView):
    authentication_classes = [FirebaseAuthentication]
    permission_classes = []  # No permission required for testing

    def get(self, request):
        # Now request.firebase_user exists because we set it in authenticate()
        if not hasattr(request, 'firebase_user'):
            return Response({
                "error": "Firebase user not attached"
            }, status=401)
        
        uid = request.firebase_user['uid']
        email = request.firebase_user.get('email')
        
        return Response({
            "message": "✅ Authenticated successfully",
            "uid": uid,
            "email": email,
            "django_user": {
                "id": request.user.id,
                "username": request.user.username,
                "role": request.user.role,
            }
        })


class SyncUserView(APIView):
    authentication_classes = [FirebaseAuthentication]
    permission_classes = [IsAuthenticated]

    def post(self, request):
        # request.firebase_user now exists
        if not hasattr(request, 'firebase_user'):
            return Response({
                "error": "Firebase user not attached"
            }, status=401)
        
        firebase_user = request.firebase_user
        uid = firebase_user['uid']
        email = firebase_user.get('email', '')

        # Sync to AppUser model
        user, created = AppUser.objects.get_or_create(
            firebase_uid=uid,
            defaults={
                'email': email,
                'role': 'SALON_OWNER'
            }
        )

        return Response({
            "success": True,
            "created": created,
            "user": {
                "firebase_uid": user.firebase_uid,
                "email": user.email,
                "role": user.role,
            },
            "django_user": {
                "id": request.user.id,
                "username": request.user.username,
                "role": request.user.role,
            }
        })


class WhoAmI(APIView):
    authentication_classes = [FirebaseAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response({
            "django_user": {
                "id": request.user.id,
                "username": request.user.username,
                "email": request.user.email,
                "role": request.user.role,
            },
            "firebase_user": request.firebase_user if hasattr(request, 'firebase_user') else None
        })
