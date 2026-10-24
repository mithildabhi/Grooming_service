import logging
import firebase_admin
from firebase_admin import credentials
from django.conf import settings
import os
import json

logger = logging.getLogger(__name__)

def initialize_firebase():
    """Initialize Firebase Admin SDK"""
    if not firebase_admin._apps:
        try:
            firebase_creds_json = os.environ.get('FIREBASE_CREDENTIALS')

            if firebase_creds_json:
                logger.info("Loading Firebase credentials from environment variable")
                cred_dict = json.loads(firebase_creds_json)
                cred = credentials.Certificate(cred_dict)
                firebase_admin.initialize_app(cred)
                logger.info("Firebase Admin SDK initialized successfully (from env)")
                return True

            cred_path = os.path.join(
                settings.BASE_DIR,
                'firebase',
                'serviceAccountKey.json'
            )

            if not os.path.exists(cred_path):
                logger.warning("Firebase credentials not found at: %s", cred_path)
                return False

            logger.info("Loading Firebase credentials from local file")
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
            logger.info("Firebase Admin SDK initialized successfully (from file)")
            return True

        except Exception as e:
            logger.error("Firebase initialization error: %s", e)
            return False
    else:
        logger.debug("Firebase already initialized")
        return True

initialize_firebase()