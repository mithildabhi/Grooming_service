import firebase_admin
from firebase_admin import credentials
from django.conf import settings
import os

def initialize_firebase():
    """Initialize Firebase Admin SDK"""
    if not firebase_admin._apps:
        try:
            # Path to service account key
            cred_path = os.path.join(
                settings.BASE_DIR, 
                'firebase', 
                'serviceAccountKey.json'
            )
            
            if not os.path.exists(cred_path):
                print(f"⚠️  WARNING: Firebase credentials not found at: {cred_path}")
                print("   Download from: Firebase Console → Project Settings → Service Accounts")
                print("   → Generate New Private Key")
                return False
            
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
            print("✅ Firebase Admin SDK initialized successfully")
            return True
            
        except Exception as e:
            print(f"❌ Firebase initialization error: {e}")
            return False
    else:
        print("ℹ️  Firebase already initialized")
        return True

# Initialize when module is imported
initialize_firebase()