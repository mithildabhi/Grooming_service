import logging
import firebase_admin
from firebase_admin import credentials, messaging
import os
from django.conf import settings

logger = logging.getLogger(__name__)

def initialize_firebase():
    if not firebase_admin._apps:
        possible_paths = [
            os.path.join(settings.BASE_DIR, "firebase_key.json"),
            os.path.join(settings.BASE_DIR, "firebase", "serviceAccountKey.json"),
            os.path.join(settings.BASE_DIR, "config", "firebase_key.json"),
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
                logger.info("Firebase initialized using key at: %s", key_path)
            except Exception as e:
                logger.error("Error initializing Firebase: %s", e)
        else:
            logger.warning("Firebase key not found. Firebase features will not work.")

def send_notification(token, title, body, data=None):
    try:
        initialize_firebase()
        if not firebase_admin._apps:
            logger.warning("Firebase not initialized, skipping notification.")
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
        logger.info("Notification sent: %s", response)
        return response
    except Exception as e:
        logger.error("Error sending notification: %s", e)
        return None
