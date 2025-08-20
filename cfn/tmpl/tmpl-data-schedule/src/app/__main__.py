import json
from typing import Any

from aws_lambda_powertools.utilities.data_classes.sqs_event import SQSRecord

from . import lambda_function


def main(time: str, detail: dict[str, Any]) -> None:
    body = {"time": time, "detail": detail}
    record = SQSRecord({"body": json.dumps(body)})

    lambda_function.record_handler(record)


if __name__ == "__main__":
    from fire import Fire

    Fire(main)
