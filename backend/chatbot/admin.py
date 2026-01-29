# chatbot/admin.py
# ✅ UPDATED: Admin interface for both Admin and User chatbots

from django.contrib import admin
from .models import ChatHistory, ChatSession, UserChatHistory, UserChatSession


# ========================================
# ADMIN CHATBOT (Salon Owners)
# ========================================

@admin.register(ChatHistory)
class ChatHistoryAdmin(admin.ModelAdmin):
    list_display = ['id', 'user_email', 'salon_name', 'user_message_preview', 'created_at', 'intent']
    list_filter = ['created_at', 'intent', 'salon']
    search_fields = ['user__email', 'user_message', 'bot_response', 'salon__name']
    date_hierarchy = 'created_at'
    readonly_fields = ['created_at']
    
    def user_email(self, obj):
        return obj.user.email
    user_email.short_description = 'Salon Owner'
    
    def salon_name(self, obj):
        return obj.salon.name
    salon_name.short_description = 'Salon'
    
    def user_message_preview(self, obj):
        return obj.user_message[:50] + '...' if len(obj.user_message) > 50 else obj.user_message
    user_message_preview.short_description = 'Message'
    
    fieldsets = (
        ('Chat Information', {
            'fields': ('user', 'salon', 'intent')
        }),
        ('Conversation', {
            'fields': ('user_message', 'bot_response')
        }),
        ('Metadata', {
            'fields': ('created_at',)
        }),
    )


@admin.register(ChatSession)
class ChatSessionAdmin(admin.ModelAdmin):
    list_display = ['id', 'user', 'salon', 'session_start', 'session_end', 'message_count']
    list_filter = ['session_start', 'salon']
    date_hierarchy = 'session_start'
    readonly_fields = ['session_start']


# ========================================
# ✅ NEW: USER CHATBOT (Customers)
# ========================================

@admin.register(UserChatHistory)
class UserChatHistoryAdmin(admin.ModelAdmin):
    list_display = ['id', 'user_email', 'user_message_preview', 'intent', 'salon_mentioned', 'created_at']
    list_filter = ['created_at', 'intent', 'salon_mentioned']
    search_fields = ['user__email', 'user_message', 'bot_response']
    date_hierarchy = 'created_at'
    readonly_fields = ['created_at']
    
    def user_email(self, obj):
        return obj.user.email
    user_email.short_description = 'Customer'
    
    def user_message_preview(self, obj):
        return obj.user_message[:60] + '...' if len(obj.user_message) > 60 else obj.user_message
    user_message_preview.short_description = 'Customer Message'
    
    fieldsets = (
        ('Chat Information', {
            'fields': ('user', 'intent', 'salon_mentioned')
        }),
        ('Conversation', {
            'fields': ('user_message', 'bot_response')
        }),
        ('Metadata', {
            'fields': ('created_at',)
        }),
    )


@admin.register(UserChatSession)
class UserChatSessionAdmin(admin.ModelAdmin):
    list_display = ['id', 'user_email', 'session_start', 'session_end', 'message_count', 'actions_preview']
    list_filter = ['session_start']
    date_hierarchy = 'session_start'
    readonly_fields = ['session_start']
    search_fields = ['user__email']
    
    def user_email(self, obj):
        return obj.user.email
    user_email.short_description = 'Customer'
    
    def actions_preview(self, obj):
        if obj.actions_taken:
            return ', '.join(obj.actions_taken[:3])
        return 'No actions'
    actions_preview.short_description = 'Actions'
    
    fieldsets = (
        ('Session Info', {
            'fields': ('user', 'session_start', 'session_end', 'message_count')
        }),
        ('Actions Taken', {
            'fields': ('actions_taken',)
        }),
    )