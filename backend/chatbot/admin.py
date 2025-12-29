# chatbot/admin.py

from django.contrib import admin
from .models import ChatHistory, ChatSession


@admin.register(ChatHistory)
class ChatHistoryAdmin(admin.ModelAdmin):
    list_display = ['id', 'user_email', 'salon_name', 'user_message_preview', 'created_at', 'intent']
    list_filter = ['created_at', 'intent', 'salon']
    search_fields = ['user__email', 'user_message', 'bot_response', 'salon__name']
    date_hierarchy = 'created_at'
    readonly_fields = ['created_at']
    
    def user_email(self, obj):
        return obj.user.email
    user_email.short_description = 'User'
    
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