from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from backend.firebase_service import send_notification

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def save_fcm_token(request):
    token = request.data.get("token")
    if not token:
        return Response({"error": "Token is required"}, status=400)

    user = request.user
    user.fcm_token = token
    user.save()

    return Response({"status": "saved"})

@api_view(['POST', 'GET'])
@permission_classes([AllowAny])
def test_notification(request):
    # Try to get token from request data (POST) or query params (GET)
    token = request.data.get("token") or request.GET.get("token")
    
    # If no token provided, try to use authenticated user's token
    if not token and request.user.is_authenticated:
        token = request.user.fcm_token
    
    if not token:
        return Response({"error": "Token is required. Provide it via 'token' param or login."}, status=400)

    try:
        response = send_notification(
            token,
            "Test Notification",
            "FCM is working!"
        )

        if response:
            return Response({"success": True, "message_id": response})
        else:
            return Response({"success": False, "error": "Failed to send notification. Check server logs."}, status=500)
    except Exception as e:
        return Response({"success": False, "error": str(e)}, status=500)
