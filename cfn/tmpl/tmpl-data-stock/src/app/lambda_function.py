from typing import Any

from aws_lambda_powertools.logging import Logger
from aws_lambda_powertools.utilities.batch import (
    BatchProcessor,
    EventType,
    process_partial_response,
)
from aws_lambda_powertools.utilities.batch.types import PartialItemFailureResponse
from aws_lambda_powertools.utilities.typing import LambdaContext
from nexadata.handler.data import stock_handler

logger = Logger()
processor = BatchProcessor(event_type=EventType.SQS)


# --------------------------------------------------------------------------------------------------
# Handler
# --------------------------------------------------------------------------------------------------
@logger.inject_lambda_context(clear_state=True)
def lambda_handler(event: dict[str, Any], context: LambdaContext) -> PartialItemFailureResponse:
    return process_partial_response(event, record_handler, processor, context)


@stock_handler()
def record_handler(uri: str) -> None: ...
