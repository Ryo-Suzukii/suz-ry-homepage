import json

from aws_lambda_powertools.utilities.data_classes.sqs_event import SQSRecord

from . import lambda_function


def main(bucket: str, key: str) -> None:
    body = {
        "detail": {"bucket": {"name": bucket}, "object": {"key": key}},
        "time": "1970-01-01T00:00:00Z",
    }
    record = SQSRecord({"body": json.dumps(body)})

    lambda_function.record_handler(record)


if __name__ == "__main__":
    from fire import Fire

    Fire(main)
