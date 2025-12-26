from rest_framework.permissions import BasePermission

class IsSalonOwner(BasePermission):
    def has_permission(self, request, view):
        user = request.user

        if not user:
            return False

        # request.user IS AppUser
        return user.role == 'SALON_OWNER'

class IsCustomer(BasePermission):
    def has_permission(self, request, view):
        return (
            request.user.is_authenticated and
            request.user.role == 'CUSTOMER'
        )

class IsSuperAdmin(BasePermission):
    def has_permission(self, request, view):
        return (
            request.user.is_authenticated and
            request.user.role == 'SUPER_ADMIN'
        )
