import firebase_admin
from firebase_admin import credentials
from django.conf import settings
import os
import json

def initialize_firebase():
    """Initialize Firebase Admin SDK"""
    if not firebase_admin._apps:
        try:
            # Try to get credentials from environment variable first (for production/Railway)
            firebase_creds_json = os.environ.get('FIREBASE_CREDENTIALS')
            
            if firebase_creds_json:
                # Parse JSON from environment variable
                print("🔥 Loading Firebase credentials from environment variable...")
                cred_dict = json.loads(firebase_creds_json)
                cred = credentials.Certificate(cred_dict)
                firebase_admin.initialize_app(cred)
                print("✅ Firebase Admin SDK initialized successfully (from env)")
                return True
            
            # Fall back to local file (for development)
            cred_path = os.path.join(
                settings.BASE_DIR, 
                'firebase', 
                'serviceAccountKey.json'
            )
            
            if not os.path.exists(cred_path):
                print(f"⚠️  WARNING: Firebase credentials not found at: {cred_path}")
                print("   For local development: Download from Firebase Console → Project Settings → Service Accounts")
                print("   For Railway: Set FIREBASE_CREDENTIALS environment variable")
                return False
            
            print("🔥 Loading Firebase credentials from local file...")
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
            print("✅ Firebase Admin SDK initialized successfully (from file)")
            return True
            
        except Exception as e:
            print(f"❌ Firebase initialization error: {e}")
            return False
    else:
        print("ℹ️  Firebase already initialized")
        return True

# Initialize when module is imported
initialize_firebase()