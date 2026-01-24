# chatbot/staff_management.py
# 🎯 Staff Management Logic

import re
import random
from staff.models import Employee
from accounts.models import User


def detect_add_staff_intent(message):
    """Detect if user wants to add staff"""
    message_lower = message.lower()
    keywords = [
        'add staff', 'new staff', 'hire', 'add employee', 
        'new employee', 'create staff', 'register staff',
        'onboard', 'add team member'
    ]
    return any(keyword in message_lower for keyword in keywords)


def extract_staff_details(message, salon):
    """Extract staff details from message"""
    staff_data = {
        'full_name': None,
        'role': 'stylist',
        'primary_skill': 'hair_styling',
        'email': None,
        'phone': None,
    }
    
    lines = message.split('\n')
    
    for line in lines:
        line = line.strip().lower()
        
        # Extract name
        if 'name:' in line or 'name -' in line or 'name=' in line:
            name = re.split(r'[:=-]', line, 1)[-1].strip()
            name = name.replace('*', '').replace('`', '').strip()
            if name and len(name) > 2:
                staff_data['full_name'] = name.title()
        
        # Extract role
        if 'role:' in line or 'position:' in line:
            if 'barber' in line:
                staff_data['role'] = 'barber'
            elif 'stylist' in line:
                staff_data['role'] = 'stylist'
            elif 'manager' in line:
                staff_data['role'] = 'manager'
            elif 'receptionist' in line:
                staff_data['role'] = 'receptionist'
            elif 'specialist' in line:
                staff_data['role'] = 'specialist'
        
        # Extract skill
        if 'skill:' in line or 'specialty:' in line:
            if 'cut' in line:
                staff_data['primary_skill'] = 'hair_cutting'
            elif 'styling' in line:
                staff_data['primary_skill'] = 'hair_styling'
            elif 'color' in line:
                staff_data['primary_skill'] = 'coloring'
            elif 'beard' in line:
                staff_data['primary_skill'] = 'beard_trim'
            elif 'spa' in line:
                staff_data['primary_skill'] = 'spa'
            elif 'massage' in line:
                staff_data['primary_skill'] = 'massage'
            elif 'nail' in line:
                staff_data['primary_skill'] = 'nails'
            elif 'makeup' in line:
                staff_data['primary_skill'] = 'makeup'
        
        # Extract email
        if 'email:' in line or '@' in line:
            email_match = re.search(r'[\w\.-]+@[\w\.-]+\.\w+', line)
            if email_match:
                staff_data['email'] = email_match.group(0)
        
        # Extract phone
        if 'phone:' in line or 'mobile:' in line or 'number:' in line:
            phone_match = re.search(r'\d{10}', line)
            if phone_match:
                staff_data['phone'] = phone_match.group(0)
    
    # Validation
    if not staff_data['full_name']:
        return None
    
    # Generate email if not provided
    if not staff_data['email']:
        name_parts = staff_data['full_name'].lower().replace(' ', '')
        staff_data['email'] = f"{name_parts}@{salon.name.lower().replace(' ', '')}.com"
    
    # Generate phone if not provided
    if not staff_data['phone']:
        staff_data['phone'] = f"{''.join([str(random.randint(0, 9)) for _ in range(10)])}"
    
    return staff_data


def create_staff_member(salon, staff_data):
    """Create staff member in database"""
    try:
        # Check if user already exists
        if User.objects.filter(email=staff_data['email']).exists():
            return (False, f"User with email {staff_data['email']} already exists.")

        # Create user
        user = User.objects.create_user(
            username=staff_data['email'],
            email=staff_data['email'],
            role='EMPLOYEE'
        )
        
        # Create employee
        employee = Employee.objects.create(
            user=user,
            salon=salon,
            full_name=staff_data['full_name'],
            email=staff_data['email'],
            phone=staff_data['phone'],
            role=staff_data['role'],
            primary_skill=staff_data['primary_skill'],
            is_active=True
        )
        
        return (True, employee)
        
    except Exception as e:
        return (False, str(e))