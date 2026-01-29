# chatbot/models.py
# ✅ UPDATED: Added UserChatHistory for customer chatbot

from django.db import models
from accounts.models import User
from salons.models import Salon
from django.utils import timezone


class ChatHistory(models.Model):
    """Store ADMIN conversation history for context and analytics"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='admin_chat_history')
    salon = models.ForeignKey(Salon, on_delete=models.CASCADE, related_name='admin_chat_history')
    user_message = models.TextField()
    bot_response = models.TextField()
    intent = models.CharField(max_length=50, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Admin Chat History'
        verbose_name_plural = 'Admin Chat Histories'
        indexes = [
            models.Index(fields=['user', 'salon', '-created_at']),
        ]
    
    def __str__(self):
        return f"Admin: {self.user.email} - {self.created_at.strftime('%Y-%m-%d %H:%M')}"


class ChatSession(models.Model):
    """Track ADMIN chat sessions for analytics"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='admin_chat_sessions')
    salon = models.ForeignKey(Salon, on_delete=models.CASCADE, related_name='admin_chat_sessions')
    session_start = models.DateTimeField(auto_now_add=True)
    session_end = models.DateTimeField(null=True, blank=True)
    message_count = models.IntegerField(default=0)
    
    class Meta:
        ordering = ['-session_start']
        verbose_name = 'Admin Chat Session'
        verbose_name_plural = 'Admin Chat Sessions'
    
    def __str__(self):
        return f"Admin Session {self.id} - {self.user.email}"


# ✅ NEW: User/Customer Chatbot Models

class UserChatHistory(models.Model):
    """Store USER/CUSTOMER conversation history"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='user_chat_history')
    user_message = models.TextField()
    bot_response = models.TextField()
    intent = models.CharField(max_length=50, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    # Optional: Track which salon was discussed
    salon_mentioned = models.ForeignKey(
        Salon, 
        on_delete=models.SET_NULL, 
        null=True, 
        blank=True,
        related_name='user_chat_mentions'
    )
    
    class Meta:
        ordering = ['-created_at']
        verbose_name = 'User Chat History'
        verbose_name_plural = 'User Chat Histories'
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['intent']),
        ]
    
    def __str__(self):
        return f"User: {self.user.email} - {self.created_at.strftime('%Y-%m-%d %H:%M')}"


class UserChatSession(models.Model):
    """Track USER chat sessions for analytics"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='user_chat_sessions')
    session_start = models.DateTimeField(auto_now_add=True)
    session_end = models.DateTimeField(null=True, blank=True)
    message_count = models.IntegerField(default=0)
    
    # Track what user accomplished in this session
    actions_taken = models.JSONField(default=list, blank=True)
    # Example: ['searched_salons', 'viewed_pricing', 'got_beauty_tips']
    
    class Meta:
        ordering = ['-session_start']
        verbose_name = 'User Chat Session'
        verbose_name_plural = 'User Chat Sessions'
    
    def __str__(self):
        return f"User Session {self.id} - {self.user.email}"