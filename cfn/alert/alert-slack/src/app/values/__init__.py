from dataclasses import dataclass
from typing import ClassVar

from nexadata.value import get_env


@dataclass(frozen=True)
class ConstType: ...


@dataclass(frozen=True)
class EnvType:
    AWS_REGION = get_env("AWS_REGION", str)
    SLACK_OAUTH_TOKEN = get_env("SLACK_OAUTH_TOKEN", str)
    SLACK_CHANNEL_ID = get_env("SLACK_CHANNEL_ID", str)
    SLACK_USER_NAME = get_env("SLACK_USER_NAME", str)
    SLACK_ICON_EMOJI = get_env("SLACK_ICON_EMOJI", str)
    SLACK_ICON_URL = get_env("SLACK_ICON_URL", str)
    ALERT_LEVEL: ClassVar[list[str]] = [el.lower() for el in get_env("ALERT_LEVEL", cast=str).split(",")]
    TIMEZONE = get_env("TIMEZONE", str)


Const = ConstType()
Env = EnvType()
