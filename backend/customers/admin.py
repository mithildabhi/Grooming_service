from django.contrib import admin
from django.utils.html import format_html, mark_safe
from django.urls import reverse
from .models import Customer


@admin.register(Customer)
class CustomerAdmin(admin.ModelAdmin):
    """
    Django Admin configuration for Customer model
    ✅ Clicking customer name opens Customer detail (not User)
    """
    
    list_display = [
        'customer_link',  # ✅ Changed to link to Customer detail
        'email',
        'phone',
        'city',
        'loyalty_badge',
        'total_bookings_count',
        'total_spent_display',
        'is_verified',
        'created_at',
    ]
    
    list_filter = [
        'is_verified',
        'gender',
        'city',
        'created_at',
    ]
    
    search_fields = [
        'user__username',
        'user__email',
        'full_name',
        'phone',
        'city',
        'pincode',
    ]
    
    readonly_fields = [
        'user_link',  # ✅ Link to User (for reference)
        'email_display',
        'created_at',
        'updated_at',
        'statistics_summary',
    ]
    
    fieldsets = (
        ('User Account', {
            'fields': ('user_link', 'email_display'),
            'description': 'Email is managed in User account. Click username to edit User details.'
        }),
        ('Personal Information', {
            'fields': ('full_name', 'phone', 'gender', 'date_of_birth', 'profile_picture')
        }),
        ('Address', {
            'fields': ('address', 'city', 'pincode')
        }),
        ('Preferences', {
            'fields': ('preferred_services', 'preferred_salons'),
            'classes': ('collapse',)
        }),
        ('Status', {
            'fields': ('is_verified',)
        }),
        ('Statistics', {
            'fields': ('statistics_summary',),
            'classes': ('collapse',)
        }),
        ('Metadata', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    # ========================================
    # CUSTOM DISPLAY METHODS
    # ========================================
    
    def customer_link(self, obj):
        """
        ✅ Display customer name as link to Customer detail page
        This is what shows in the list and opens Customer on click
        """
        url = reverse('admin:customers_customer_change', args=[obj.pk])
        return format_html(
            '<a href="{}" style="font-weight: bold; color: #0c4b33;">{}</a>',
            url,
            obj.full_name or obj.user.username
        )
    customer_link.short_description = 'Customer Name'
    customer_link.admin_order_field = 'full_name'
    
    def user_link(self, obj):
        """
        Display username with link to User account (in readonly field)
        """
        url = reverse('admin:accounts_user_change', args=[obj.user.pk])
        return format_html(
            '<a href="{}" target="_blank" style="color: #417690;">👤 {} (Edit User Account)</a>',
            url,
            obj.user.username
        )
    user_link.short_description = 'User Account'
    
    def email(self, obj):
        """Display user email in list"""
        return obj.user.email
    email.short_description = 'Email'
    email.admin_order_field = 'user__email'
    
    def email_display(self, obj):
        """Display email in detail view - READ ONLY"""
        return format_html(
            '<strong style="color: #0c4b33; font-size: 14px;">{}</strong><br>'
            '<em style="color: #666; font-size: 12px;">Email is managed in the User account</em>',
            obj.user.email
        )
    email_display.short_description = 'Email Address'
    
    def loyalty_badge(self, obj):
        """Display loyalty tier as colored badge"""
        tier = obj.loyalty_tier
        colors = {
            'PLATINUM': '#E5E4E2',
            'GOLD': '#FFD700',
            'SILVER': '#C0C0C0',
            'BRONZE': '#CD7F32',
            'NEW': '#808080',
        }
        return format_html(
            '<span style="background-color: {}; color: black; padding: 4px 12px; '
            'border-radius: 4px; font-weight: bold; font-size: 11px;">{}</span>',
            colors.get(tier, '#808080'),
            tier
        )
    loyalty_badge.short_description = 'Loyalty Tier'
    loyalty_badge.admin_order_field = 'user__bookings__status'
    
    def total_bookings_count(self, obj):
        """Display total bookings"""
        count = obj.total_bookings
        color = '#0c4b33' if count > 0 else '#999'
        return format_html(
            '<span style="font-weight: bold; color: {};">{}</span>',
            color,
            count
        )
    total_bookings_count.short_description = 'Bookings'
    
    def total_spent_display(self, obj):
        """Display total spent with currency"""
        amount = obj.total_spent
        color = '#0c4b33' if amount > 0 else '#999'
        amount_formatted = f'{amount:,.2f}'
        return format_html(
            '<span style="font-weight: bold; color: {};">₹{}</span>',
            color,
            amount_formatted
        )
    total_spent_display.short_description = 'Total Spent'
    
    def statistics_summary(self, obj):
        """Display complete statistics in admin"""
        stats = obj.get_statistics_summary()
        
        # ✅ FIX: Pre-format all values before using mark_safe
        total_spent_formatted = f'{stats["total_spent"]:,.2f}'
        avg_value_formatted = f'{stats["average_booking_value"]:,.2f}'
        
        html = f"""
        <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; border: 1px solid #dee2e6;">
            <h3 style="margin-top: 0; color: #0c4b33;">Customer Statistics</h3>
            
            <table style="width: 100%; border-collapse: collapse; margin-top: 15px;">
                <thead>
                    <tr style="background-color: #e9ecef;">
                        <th style="text-align: left; padding: 10px; border-bottom: 2px solid #dee2e6;">Metric</th>
                        <th style="text-align: right; padding: 10px; border-bottom: 2px solid #dee2e6;">Value</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td style="padding: 8px; border-bottom: 1px solid #dee2e6;">📊 Total Bookings</td>
                        <td style="text-align: right; padding: 8px; border-bottom: 1px solid #dee2e6; font-weight: bold;">
                            {stats['total_bookings']}
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 8px; border-bottom: 1px solid #dee2e6;">✅ Completed Bookings</td>
                        <td style="text-align: right; padding: 8px; border-bottom: 1px solid #dee2e6; color: #28a745; font-weight: bold;">
                            {stats['completed_bookings']}
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 8px; border-bottom: 1px solid #dee2e6;">📅 Upcoming Bookings</td>
                        <td style="text-align: right; padding: 8px; border-bottom: 1px solid #dee2e6; color: #007bff; font-weight: bold;">
                            {stats['upcoming_bookings']}
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 8px; border-bottom: 1px solid #dee2e6;">❌ Cancelled Bookings</td>
                        <td style="text-align: right; padding: 8px; border-bottom: 1px solid #dee2e6; color: #dc3545;">
                            {stats['cancelled_bookings']}
                        </td>
                    </tr>
                    <tr style="background-color: #e9ecef;">
                        <td style="padding: 10px; border-bottom: 1px solid #dee2e6; font-weight: bold;">💰 Total Spent</td>
                        <td style="text-align: right; padding: 10px; border-bottom: 1px solid #dee2e6; font-weight: bold; color: #0c4b33;">
                            ₹{total_spent_formatted}
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 8px; border-bottom: 1px solid #dee2e6;">📈 Average Booking Value</td>
                        <td style="text-align: right; padding: 8px; border-bottom: 1px solid #dee2e6;">
                            ₹{avg_value_formatted}
                        </td>
                    </tr>
                    <tr>
                        <td style="padding: 8px; border-bottom: 1px solid #dee2e6;">🏆 Loyalty Tier</td>
                        <td style="text-align: right; padding: 8px; border-bottom: 1px solid #dee2e6;">
                            <span style="background-color: #FFD700; color: black; padding: 3px 10px; border-radius: 3px; font-weight: bold;">
                                {stats['loyalty_tier']}
                            </span>
                        </td>
                    </tr>
        """
        
        if stats['favorite_salon']:
            html += f"""
                    <tr style="background-color: #f8f9fa;">
                        <td style="padding: 8px; border-bottom: 1px solid #dee2e6;">❤️ Favorite Salon</td>
                        <td style="text-align: right; padding: 8px; border-bottom: 1px solid #dee2e6;">
                            <strong>{stats['favorite_salon']['salon__name']}</strong><br>
                            <small style="color: #666;">({stats['favorite_salon']['visit_count']} visits)</small>
                        </td>
                    </tr>
            """
        
        if stats['favorite_service']:
            html += f"""
                    <tr>
                        <td style="padding: 8px; border-bottom: 1px solid #dee2e6;">⭐ Favorite Service</td>
                        <td style="text-align: right; padding: 8px; border-bottom: 1px solid #dee2e6;">
                            <strong>{stats['favorite_service']['service__name']}</strong><br>
                            <small style="color: #666;">({stats['favorite_service']['booking_count']} times)</small>
                        </td>
                    </tr>
            """
        
        html += """
                </tbody>
            </table>
        </div>
        """
        
        # ✅ FIX: Use mark_safe instead of format_html for pre-formatted HTML
        return mark_safe(html)
    
    statistics_summary.short_description = 'Customer Statistics'
    
    # ========================================
    # ADMIN ACTIONS
    # ========================================
    
    def mark_as_verified(self, request, queryset):
        """Mark selected customers as verified"""
        updated = queryset.update(is_verified=True)
        self.message_user(request, f'{updated} customer(s) marked as verified.', 'success')
    mark_as_verified.short_description = '✅ Mark as verified'
    
    def mark_as_unverified(self, request, queryset):
        """Mark selected customers as unverified"""
        updated = queryset.update(is_verified=False)
        self.message_user(request, f'{updated} customer(s) marked as unverified.', 'warning')
    mark_as_unverified.short_description = '❌ Mark as unverified'
    
    actions = ['mark_as_verified', 'mark_as_unverified']
    
    # ========================================
    # CUSTOMIZATIONS
    # ========================================
    
    def get_queryset(self, request):
        """Optimize queries"""
        qs = super().get_queryset(request)
        return qs.select_related('user')