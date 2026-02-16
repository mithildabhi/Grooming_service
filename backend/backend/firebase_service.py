import firebase_admin
from firebase_admin import credentials, messaging
import os
from django.conf import settings

def initialize_firebase():
    if not firebase_admin._apps:
        # Check multiple possible locations for the key
        possible_paths = [
            os.path.join(settings.BASE_DIR, "firebase_key.json"),
            os.path.join(settings.BASE_DIR, "firebase", "serviceAccountKey.json"),
            os.path.join(settings.BASE_DIR, "config", "firebase_key.json"), # Common alternative
        ]
        
        key_path = None
        for path in possible_paths:
            if os.path.exists(path):
                key_path = path
                break
        
        if key_path:
            try:
                cred = credentials.Certificate(key_path)
                firebase_admin.initialize_app(cred)
                print(f"✅ Firebase initialized successfully using key at: {key_path}")
            except Exception as e:
                print(f"❌ Error initializing Firebase: {e}")
        else:
            print(f"⚠️ Warning: Firebase key not found in any of these locations: {possible_paths}. Firebase features will not work.")

def send_notification(token, title, body, data=None):
    try:
        initialize_firebase()
        if not firebase_admin._apps:
             print("❌ Firebase not initialized, skipping notification.")
             return None
             
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data=data or {},
            token=token,
            android=messaging.AndroidConfig(
                priority="high",
                notification=messaging.AndroidNotification(
                    channel_id='high_importance_channel',
                ),
            )
        )
        response = messaging.send(message)
        print(f"✅ Notification sent: {response}")
        return response
    except Exception as e:
        print(f"❌ Error sending notification: {e}")
        return None
