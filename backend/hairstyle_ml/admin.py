# hairstyle_ml/admin.py

from django.contrib import admin
from django.utils.html import format_html
from django.utils.safestring import mark_safe
from .models import HairstyleAnalysis, HairstyleRecommendationFeedback


@admin.register(HairstyleAnalysis)
class HairstyleAnalysisAdmin(admin.ModelAdmin):
    list_display = [
        'id',
        'user_email',
        'face_shape',
        'current_hair_length',
        'user_gender',
        'analysis_successful',
        'image_thumbnail',
        'created_at'
    ]
    
    list_filter = [
        'analysis_successful',
        'face_shape',
        'user_gender',
        'current_hair_length',
        'created_at'
    ]
    
    search_fields = [
        'user__email',
        'user__username',
        'face_shape'
    ]
    
    readonly_fields = [
        'created_at',
        'updated_at',
        'image_preview',
        'recommendations_display',
        'styling_tips_display',
        'products_display'
    ]
    
    date_hierarchy = 'created_at'
    
    fieldsets = (
        ('User Information', {
            'fields': ('user', 'user_gender', 'user_preferences')
        }),
        ('Image', {
            'fields': ('uploaded_image', 'image_preview')
        }),
        ('Analysis Results', {
            'fields': (
                'analysis_successful',
                'face_shape',
                'current_hair_length',
                'current_hair_color',
                'confidence_score',
                'error_message'
            )
        }),
        ('Recommendations', {
            'fields': (
                'recommendations_display',
                'styling_tips_display',
                'products_display'
            )
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at')
        }),
    )
    
    def user_email(self, obj):
        return obj.user.email
    user_email.short_description = 'User'
    
    def image_thumbnail(self, obj):
        if obj.uploaded_image:
            return format_html(
                '<img src="{}" style="width: 50px; height: 50px; object-fit: cover; border-radius: 5px;" />',
                obj.uploaded_image.url
            )
        return '-'
    image_thumbnail.short_description = 'Image'
    
    def image_preview(self, obj):
        if obj.uploaded_image:
            return format_html(
                '<img src="{}" style="max-width: 400px; max-height: 400px; border-radius: 8px;" />',
                obj.uploaded_image.url
            )
        return 'No image'
    image_preview.short_description = 'Image Preview'
    
    def recommendations_display(self, obj):
        if not obj.recommendations:
            return 'No recommendations'
        
        html = '<div style="padding: 10px; background: #f5f5f5; border-radius: 5px;">'
        for i, rec in enumerate(obj.recommendations, 1):
            html += f'<div style="margin-bottom: 10px; padding: 8px; background: white; border-radius: 4px;">'
            html += f'<strong>{i}. {rec.get("name", "Unknown")}</strong><br/>'
            html += f'Difficulty: {rec.get("difficulty", "N/A")} | '
            html += f'Maintenance: {rec.get("maintenance", "N/A")}<br/>'
            html += f'<small>{rec.get("description", "")}</small>'
            html += '</div>'
        html += '</div>'
        return mark_safe(html)
    recommendations_display.short_description = 'Recommendations'
    
    def styling_tips_display(self, obj):
        if not obj.styling_tips:
            return 'No tips'
        
        html = '<ul style="margin: 0; padding-left: 20px;">'
        for tip in obj.styling_tips:
            html += f'<li>{tip}</li>'
        html += '</ul>'
        return mark_safe(html)
    styling_tips_display.short_description = 'Styling Tips'
    
    def products_display(self, obj):
        if not obj.recommended_products:
            return 'No products'
        
        html = '<ul style="margin: 0; padding-left: 20px;">'
        for product in obj.recommended_products:
            html += f'<li>{product}</li>'
        html += '</ul>'
        return mark_safe(html)
    products_display.short_description = 'Recommended Products'


@admin.register(HairstyleRecommendationFeedback)
class HairstyleRecommendationFeedbackAdmin(admin.ModelAdmin):
    list_display = [
        'id',
        'analysis_id',
        'user_email',
        'recommendation_name',
        'liked_emoji',
        'tried',
        'created_at'
    ]
    
    list_filter = [
        'liked',
        'tried',
        'created_at'
    ]
    
    search_fields = [
        'analysis__user__email',
        'recommendation_name',
        'comment'
    ]
    
    readonly_fields = ['created_at']
    
    date_hierarchy = 'created_at'
    
    fieldsets = (
        ('Feedback Information', {
            'fields': (
                'analysis',
                'recommendation_name',
                'liked',
                'tried',
                'comment'
            )
        }),
        ('Timestamp', {
            'fields': ('created_at',)
        }),
    )
    
    def analysis_id(self, obj):
        return obj.analysis.id
    analysis_id.short_description = 'Analysis ID'
    
    def user_email(self, obj):
        return obj.analysis.user.email
    user_email.short_description = 'User'
    
    def liked_emoji(self, obj):
        return '👍' if obj.liked else '👎'
    liked_emoji.short_description = 'Liked'