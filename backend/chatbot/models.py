# chatbot/models.py

from django.db import models
from accounts.models import User  # Using your User model
from salons.models import Salon
from django.utils import timezone


class ChatHistory(models.Model):
    """Store conversation history for context and analytics"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='chat_history')
    salon = models.ForeignKey(Salon, on_delete=models.CASCADE, related_name='chat_history')
    user_message = models.TextField()
    bot_response = models.TextField()
    intent = models.CharField(max_length=50, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Chat History'
        verbose_name_plural = 'Chat Histories'
        indexes = [
            models.Index(fields=['user', 'salon', '-created_at']),
        ]
    
    def __str__(self):
        return f"{self.user.email} - {self.created_at.strftime('%Y-%m-%d %H:%M')}"


class ChatSession(models.Model):
    """Track chat sessions for analytics"""
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='chat_sessions')
    salon = models.ForeignKey(Salon, on_delete=models.CASCADE, related_name='chat_sessions')
    session_start = models.DateTimeField(auto_now_add=True)
    session_end = models.DateTimeField(null=True, blank=True)
    message_count = models.IntegerField(default=0)
    
    class Meta:
        ordering = ['-session_start']
        verbose_name = 'Chat Session'
        verbose_name_plural = 'Chat Sessions'
    
    def __str__(self):
        return f"Session {self.id} - {self.user.email}"