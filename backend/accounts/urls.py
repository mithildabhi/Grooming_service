from django.urls import path
from .views import get_user_profile, register
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

urlpatterns = [
    path('register/', register),
    path('login/', TokenObtainPairView.as_view()),
    path('me/', get_user_profile, name='user-profile'),  # ✅ NEW

    path('refresh/', TokenRefreshView.as_view()),
]
