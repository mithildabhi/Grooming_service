# reviews/admin.py
# ✅ FIXED: Admin Panel Errors

from django.contrib import admin
from django.utils.html import format_html
from django.urls import reverse
from .models import Review, ReviewHelpfulness, ReviewReport


@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = [
        'id',
        'user_name_display',
        'salon_link',
        'service_name',
        'rating_display',
        'is_verified',
        'is_approved',
        'has_owner_reply',  # ✅ FIXED METHOD
        'helpful_display',
        'created_at',
    ]
    
    list_filter = [
        'rating',
        'is_verified',
        'is_approved',
        'is_edited',
        'created_at',
        'salon',
    ]
    
    search_fields = [
        'user__email',
        'salon__name',
        'service__name',
        'title',
        'comment',
    ]
    
    readonly_fields = [
        'user',
        'salon',
        'service',
        'booking',
        'created_at',
        'updated_at',
        'is_verified',
        'is_edited',
        'helpful_count',
        'not_helpful_count',
        'helpfulness_percentage',
    ]
    
    fieldsets = (
        ('Review Information', {
            'fields': (
                'user',
                'salon',
                'service',
                'booking',
            )
        }),
        ('Ratings', {
            'fields': (
                'rating',
                'title',
                'comment',
                'service_quality_rating',
                'staff_behavior_rating',
                'ambiance_rating',
                'value_for_money_rating',
            )
        }),
        ('Status', {
            'fields': (
                'is_verified',
                'is_approved',
                'is_edited',
            )
        }),
        ('Owner Reply', {
            'fields': (
                'owner_reply',
                'owner_replied_at',
            )
        }),
        ('Helpfulness', {
            'fields': (
                'helpful_count',
                'not_helpful_count',
                'helpfulness_percentage',
            )
        }),
        ('Media', {
            'fields': ('images',),
            'classes': ('collapse',),
        }),
        ('Timestamps', {
            'fields': (
                'created_at',
                'updated_at',
            ),
            'classes': ('collapse',),
        }),
    )
    
    actions = ['approve_reviews', 'unapprove_reviews']
    
    def user_name_display(self, obj):
        """Display user name"""
        return obj.user_name
    user_name_display.short_description = 'User'
    
    def salon_link(self, obj):
        """Link to salon"""
        if obj.salon:
            url = reverse('admin:salons_salon_change', args=[obj.salon.id])
            return format_html('<a href="{}">{}</a>', url, obj.salon.name)
        return '-'
    salon_link.short_description = 'Salon'
    
    def service_name(self, obj):
        """Display service name"""
        return obj.service.name if obj.service else '-'
    service_name.short_description = 'Service'
    
    def rating_display(self, obj):
        """Display rating with stars"""
        stars = '⭐' * obj.rating
        return format_html('{} ({})', stars, obj.rating)
    rating_display.short_description = 'Rating'
    
    # ✅ FIXED: has_owner_reply method
    def has_owner_reply(self, obj):
        if obj.owner_reply:
            return "✓ Replied"
        return "✗ No Reply"

    has_owner_reply.short_description = "Owner Reply"
    has_owner_reply.admin_order_field = "owner_reply"

    
    def helpful_display(self, obj):
        """Display helpfulness stats"""
        total = obj.helpful_count + obj.not_helpful_count

        if total == 0:
            return "0 votes"

        percentage = obj.helpfulness_score  # ✅ FIXED

        return format_html(
            '👍 {} / 👎 {} ({}%)',
            obj.helpful_count,
            obj.not_helpful_count,
            percentage
        )

    helpful_display.short_description = 'Helpfulness'
    
    def helpfulness_percentage(self, obj):
        """Calculate helpfulness percentage"""
        return f"{obj.helpfulness_score}%"
    helpfulness_percentage.short_description = 'Helpfulness %'
    
    def approve_reviews(self, request, queryset):
        """Approve selected reviews"""
        updated = queryset.update(is_approved=True)
        self.message_user(
            request,
            f'{updated} review(s) approved successfully.'
        )
    approve_reviews.short_description = 'Approve selected reviews'
    
    def unapprove_reviews(self, request, queryset):
        """Unapprove selected reviews"""
        updated = queryset.update(is_approved=False)
        self.message_user(
            request,
            f'{updated} review(s) unapproved successfully.'
        )
    unapprove_reviews.short_description = 'Unapprove selected reviews'


@admin.register(ReviewHelpfulness)
class ReviewHelpfulnessAdmin(admin.ModelAdmin):
    list_display = [
        'id',
        'review_link',
        'user_email',
        'vote_display',
        'voted_at',
    ]
    
    list_filter = [
        'is_helpful',
        'voted_at',
    ]
    
    search_fields = [
        'user__email',
        'review__title',
        'review__salon__name',
    ]
    
    readonly_fields = [
        'review',
        'user',
        'voted_at',
    ]
    
    def review_link(self, obj):
        """Link to review"""
        url = reverse('admin:reviews_review_change', args=[obj.review.id])
        return format_html(
            '<a href="{}">Review #{}</a>',
            url,
            obj.review.id
        )
    review_link.short_description = 'Review'
    
    def user_email(self, obj):
        """Display user email"""
        return obj.user.email
    user_email.short_description = 'User'
    
    def vote_display(self, obj):
        if obj.is_helpful:
            return "👍 Helpful"
        return "👎 Not Helpful"

    vote_display.short_description = "Vote"

@admin.register(ReviewReport)
class ReviewReportAdmin(admin.ModelAdmin):
    list_display = [
        'id',
        'review_link',
        'reported_by_email',
        'reason_display',
        'is_resolved',
        'created_at',
    ]
    
    list_filter = [
        'reason',
        'is_resolved',
        'created_at',
    ]
    
    search_fields = [
        'review__title',
        'review__salon__name',
        'reported_by__email',
        'description',
    ]
    
    readonly_fields = [
        'review',
        'reported_by',
        'created_at',
    ]
    
    fieldsets = (
        ('Report Information', {
            'fields': (
                'review',
                'reported_by',
                'reason',
                'description',
            )
        }),
        ('Status', {
            'fields': (
                'is_resolved',
                'resolved_at',
            )
        }),
        ('Timestamps', {
            'fields': ('created_at',),
            'classes': ('collapse',),
        }),
    )
    
    actions = ['mark_as_resolved', 'mark_as_unresolved']
    
    def review_link(self, obj):
        """Link to review"""
        url = reverse('admin:reviews_review_change', args=[obj.review.id])
        return format_html(
            '<a href="{}">Review #{}: {}</a>',
            url,
            obj.review.id,
            obj.review.title[:50] if obj.review.title else obj.review.comment[:50]
        )
    review_link.short_description = 'Review'
    
    def reported_by_email(self, obj):
        """Display reporter email"""
        return obj.reported_by.email
    reported_by_email.short_description = 'Reported By'
    
    def reason_display(self, obj):
        """Display reason with icon"""
        icons = {
            'spam': '🚫',
            'offensive': '⚠️',
            'irrelevant': '❓',
            'personal': '🔒',
            'duplicate': '📋',
            'other': '📝',
        }
        icon = icons.get(obj.reason, '📝')
        return format_html(
            '{} {}',
            icon,
            obj.get_reason_display()
        )
    reason_display.short_description = 'Reason'
    
    def mark_as_resolved(self, request, queryset):
        """Mark reports as resolved"""
        from django.utils import timezone
        updated = queryset.update(
            is_resolved=True,
            resolved_at=timezone.now()
        )
        self.message_user(
            request,
            f'{updated} report(s) marked as resolved.'
        )
    mark_as_resolved.short_description = 'Mark as resolved'
    
    def mark_as_unresolved(self, request, queryset):
        """Mark reports as unresolved"""
        updated = queryset.update(
            is_resolved=False,
            resolved_at=None
        )
        self.message_user(
            request,
            f'{updated} report(s) marked as unresolved.'
        )
    mark_as_unresolved.short_description = 'Mark as unresolved'