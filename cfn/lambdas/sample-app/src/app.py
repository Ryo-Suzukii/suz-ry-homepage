import json
import os
from typing import Any


def lambda_handler(event: dict[str, Any], _: Any) -> dict[str, Any]:
    """
    Sample Lambda function handler
    """
    environment_name = os.environ.get("ENVIRONMENT_NAME", "unknown")
    app_name = os.environ.get("APP_NAME", "unknown")

    return {
        "statusCode": 200,
        "body": json.dumps(
            {
                "message": "Hello World!",
                "environment": environment_name,
                "app_name": app_name,
                "event": event,
            },
        ),
    }
