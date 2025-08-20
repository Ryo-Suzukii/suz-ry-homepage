from __future__ import annotations

from abc import ABCMeta, abstractmethod
from datetime import UTC, datetime
from typing import Any, ClassVar, Self
from urllib import parse

from aws_lambda_powertools.utilities.data_classes.cloud_watch_logs_event import (
    CloudWatchLogsLogEvent,
)
from aws_lambda_powertools.utilities.data_classes.common import DictWrapper
from dateutil import parser
from dateutil.tz import gettz


class AWSLambdaPowertoolsLog(DictWrapper):
    EXPECTED_KEYS: ClassVar[set[str]] = {
        "level",
        "location",
        "message",
        "timestamp",
        "service",
        "function_name",
        "function_request_id",
    }

    @property
    def level(self: Self) -> str:
        return self["level"].lower()

    @property
    def location(self: Self) -> str:
        return self["location"]

    @property
    def message(self: Self) -> str:
        return self["message"]

    @property
    def timestamp(self: Self) -> datetime:
        return parser.parse(self["timestamp"])

    @property
    def service(self: Self) -> str:
        return self["service"]

    @property
    def function_name(self: Self) -> str:
        return self["function_name"]

    @property
    def function_request_id(self: Self) -> str:
        return self["function_request_id"]


class AWSLogToSlackMessage(metaclass=ABCMeta):
    COLOR: ClassVar[dict[str, str]] = {
        "green": "#2eb67d",
        "yellow": "#ecb22e",
        "red": "#e01e5a",
        "purple": "#6823c1",
    }
    LOG_EVENTS_LINK_FORMAT = "https://{region}.console.aws.amazon.com/cloudwatch/home?region={region}#logsV2:log-groups/log-group/{log_group}/log-events/{log_stream}"
    MESSAGE_LIMIT = 2000

    def __init__(
        self: Self,
        log_group: str,
        log_stream: str,
        event: CloudWatchLogsLogEvent,
        user_name: str,
        icon_emoji: str,
        icon_url: str,
        region: str,
        tz: str,
    ) -> None:
        self.log_group = log_group
        self.log_stream = log_stream
        self.event = event
        self.user_name = user_name
        self.icon_emoji = icon_emoji
        self.icon_url = icon_url
        self.region = region
        self.timezone = gettz(tz) or UTC

        self.log_events_link = self.LOG_EVENTS_LINK_FORMAT.format(
            region=self.region,
            log_group=parse.quote_plus(self.log_group),
            log_stream=parse.quote_plus(self.log_stream),
        )

    def _user_info(self: Self) -> dict[str, str | None]:
        if not self.icon_emoji and self.icon_url:
            self.icon_emoji = None
        return {
            "username": self.user_name,
            "icon_emoji": self.icon_emoji,
            "icon_url": self.icon_url,
        }

    def _log_events_section(self: Self) -> dict[str, Any]:
        return {
            "type": "section",
            "fields": [
                {
                    "type": "mrkdwn",
                    "text": f"*Log Group*:\n{self.log_group}",
                },
                {
                    "type": "mrkdwn",
                    "text": f"*Log Stream*:\n{self.log_stream}",
                },
                {
                    "type": "mrkdwn",
                    "text": f"<{self.log_events_link}|Log Events Link>",
                },
            ],
        }

    @abstractmethod
    def _color(self: Self) -> str:
        pass

    @abstractmethod
    def _blocks(self: Self) -> list[dict[str, Any]]:
        pass

    def _shrink_message(self: Self, message: Any) -> str:
        return str(message)[: self.MESSAGE_LIMIT]

    def message(self: Self) -> dict[str, Any]:
        return {
            "attachments": [
                {
                    "color": self._color(),
                    "blocks": self._blocks(),
                    "fallback": "CloudWatch Logs Alert",
                },
            ],
            **self._user_info(),
        }


class AWSLambdaPowertoolsLogToSlackMessage(AWSLogToSlackMessage):
    COLOR_MAPPING: ClassVar[dict[str, str]] = {
        "info": AWSLogToSlackMessage.COLOR["green"],
        "warning": AWSLogToSlackMessage.COLOR["yellow"],
        "error": AWSLogToSlackMessage.COLOR["red"],
        "critical": AWSLogToSlackMessage.COLOR["purple"],
    }

    def __init__(
        self: Self,
        log_group: str,
        log_stream: str,
        event: CloudWatchLogsLogEvent,
        log: AWSLambdaPowertoolsLog,
        user_name: str,
        icon_emoji: str,
        icon_url: str,
        region: str,
        timezone: str,
    ) -> None:
        super().__init__(
            log_group,
            log_stream,
            event,
            user_name,
            icon_emoji,
            icon_url,
            region,
            timezone,
        )
        self.log = log

    def _color(self: Self) -> str:
        color_key = self.log.level
        if color_key not in self.COLOR_MAPPING:
            return self.COLOR_MAPPING["error"]

        return self.COLOR_MAPPING[color_key]

    def _blocks(self: Self) -> list[dict[str, Any]]:
        timestamp = self.log.timestamp.astimezone(self.timezone)
        return [
            {
                "type": "header",
                "text": {
                    "type": "plain_text",
                    "text": f"Service: {self.log.service}",
                },
            },
            {
                "type": "section",
                "fields": [
                    {
                        "type": "mrkdwn",
                        "text": f"*Timestamp*:\n{timestamp}",
                    },
                    {
                        "type": "mrkdwn",
                        "text": f"*Location*:\n{self.log.location}",
                    },
                ],
            },
            {
                "type": "section",
                "fields": [
                    {
                        "type": "mrkdwn",
                        "text": f"*Function Name*:\n{self.log.function_name}",
                    },
                    {
                        "type": "mrkdwn",
                        "text": f"*Function Request Id*:\n{self.log.function_request_id}",
                    },
                ],
            },
            self._log_events_section(),
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"*Message*:\n```{self._shrink_message(self.log.message)}```",
                },
            },
        ]


class AWSTextLogToSlackMessage(AWSLogToSlackMessage):
    def _color(self: Self) -> str:
        return self.COLOR["red"]

    def _blocks(self: Self) -> list[dict[str, Any]]:
        timestamp = datetime.fromtimestamp(int(self.event.timestamp / 1000), self.timezone)
        return [
            {
                "type": "header",
                "text": {
                    "type": "plain_text",
                    "text": "Service: undefined. Please check cloudwatch logs.",
                },
            },
            {
                "type": "section",
                "fields": [
                    {
                        "type": "mrkdwn",
                        "text": f"*Timestamp*:\n{timestamp}",
                    },
                ],
            },
            self._log_events_section(),
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"*Message*:\n```{self._shrink_message(self.event.message)}```",
                },
            },
        ]
