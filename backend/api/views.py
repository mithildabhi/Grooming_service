from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from authentication.firebase_auth import FirebaseAuthentication
from .models import AppUser

# class TestProtectedView(APIView):
#     permission_classes = []
#     authentication_classes = [FirebaseAuthentication]  # 🔥 THIS LINE

#     def get(self, request):
#         uid = request.firebase_user['uid']
#         email = request.firebase_user.get('email')
#         return Response({
#             "message": "Authenticated successfully",
#             "uid": uid,
#             "email": email
#         })
        
        
# class SyncUserView(APIView):
#     authentication_classes = [FirebaseAuthentication]
#     permission_classes = [IsAuthenticated]

#     def post(self, request):
#         firebase_user = request.firebase_user

#         uid = firebase_user['uid']
#         email = firebase_user.get('email', '')

#         user, created = AppUser.objects.get_or_create(
#             firebase_uid=uid,
#             defaults={'email': email}
#         )

#         return Response({
#             "created": created,
#             "role": user.role
#         })
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

class WhoAmI(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response({
            "id": request.user.id,
            "email": request.user.email,
            "role": request.user.role
        })
