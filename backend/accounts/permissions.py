from rest_framework.permissions import BasePermission

class IsSalonOwner(BasePermission):
    """
    Permission check for salon owners
    """
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.role in ['SALON_OWNER', 'SUPER_ADMIN']
        )

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
