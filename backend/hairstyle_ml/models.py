# hairstyle_ml/models.py
from django.db import models
from accounts.models import User


class HairstyleAnalysis(models.Model):
    """Store hairstyle analysis results and user uploads"""
    
    FACE_SHAPE_CHOICES = [
        ('OVAL', 'Oval'),
        ('ROUND', 'Round'),
        ('SQUARE', 'Square'),
        ('HEART', 'Heart'),
        ('LONG', 'Long/Oblong'),
        ('DIAMOND', 'Diamond'),
    ]
    
    HAIR_LENGTH_CHOICES = [
        ('short', 'Short'),
        ('medium', 'Medium'),
        ('long', 'Long'),
    ]
    
    user = models.ForeignKey(
        User, 
        on_delete=models.CASCADE, 
        related_name='hairstyle_analyses'
    )
    
    # Image storage
    uploaded_image = models.ImageField(
        upload_to='hairstyle_uploads/%Y/%m/%d/',
        help_text='User uploaded face image'
    )
    
    # Analysis results
    face_shape = models.CharField(
        max_length=10, 
        choices=FACE_SHAPE_CHOICES,
        null=True,
        blank=True
    )
    
    current_hair_length = models.CharField(
        max_length=10,
        choices=HAIR_LENGTH_CHOICES,
        null=True,
        blank=True
    )
    
    current_hair_color = models.CharField(
        max_length=50,
        null=True,
        blank=True
    )
    
    # Recommendations (stored as JSON)
    recommendations = models.JSONField(
        default=list,
        help_text='List of recommended hairstyles'
    )
    
    styling_tips = models.JSONField(
        default=list,
        help_text='Styling tips for the user'
    )
    
    recommended_products = models.JSONField(
        default=list,
        help_text='Recommended hair products'
    )
    
    # Analysis metadata
    analysis_successful = models.BooleanField(default=False)
    error_message = models.TextField(null=True, blank=True)
    
    # User preferences (captured from chat)
    user_gender = models.CharField(
        max_length=10,
        choices=[
            ('male', 'Male'),
            ('female', 'Female'),
            ('unisex', 'Unisex/Other'),
        ],
        default='unisex'
    )
    
    user_preferences = models.JSONField(
        default=dict,
        help_text='User preferences like maintenance level, style preferences'
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    # Stats
    confidence_score = models.FloatField(
        null=True,
        blank=True,
        help_text='Confidence score of face detection (0-1)'
    )
    
    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Hairstyle Analysis'
        verbose_name_plural = 'Hairstyle Analyses'
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['face_shape']),
        ]
    
    def __str__(self):
        return f"{self.user.email} - {self.face_shape or 'Pending'} - {self.created_at.strftime('%Y-%m-%d')}"
    
    @property
    def image_url(self):
        """Get the full URL of the uploaded image"""
        if self.uploaded_image:
            return self.uploaded_image.url
        return None


class HairstyleRecommendationFeedback(models.Model):
    """Track user feedback on recommendations"""
    
    analysis = models.ForeignKey(
        HairstyleAnalysis,
        on_delete=models.CASCADE,
        related_name='feedbacks'
    )
    
    recommendation_name = models.CharField(max_length=100)
    
    liked = models.BooleanField(
        help_text='Did the user like this recommendation?'
    )
    
    tried = models.BooleanField(
        default=False,
        help_text='Did the user try this style?'
    )
    
    comment = models.TextField(
        null=True,
        blank=True,
        help_text='User comments about the recommendation'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Recommendation Feedback'
        verbose_name_plural = 'Recommendation Feedbacks'
    
    def __str__(self):
        return f"{self.recommendation_name} - {'👍' if self.liked else '👎'}"