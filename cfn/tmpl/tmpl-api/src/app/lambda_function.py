import json
from http import HTTPStatus
from typing import Any

from aws_lambda_powertools.event_handler.api_gateway import (
    APIGatewayRestResolver,
    Response,
)
from aws_lambda_powertools.event_handler.exceptions import ServiceError
from aws_lambda_powertools.event_handler.middlewares import NextMiddleware
from aws_lambda_powertools.logging import Logger
from aws_lambda_powertools.logging.correlation_paths import API_GATEWAY_REST
from aws_lambda_powertools.utilities.typing import LambdaContext

from .values import Env

logger = Logger()
app = APIGatewayRestResolver(strip_prefixes=[f"/${Env.PATH_PREFIX}"])


# --------------------------------------------------------------------------------------------------
# Handler
# --------------------------------------------------------------------------------------------------
@logger.inject_lambda_context(correlation_id_path=API_GATEWAY_REST, clear_state=True)
def lambda_handler(event: dict[str, Any], context: LambdaContext) -> dict[str, Any]:
    return app.resolve(event, context)


# --------------------------------------------------------------------------------------------------
# Middleware
# --------------------------------------------------------------------------------------------------
def parse_authorizer(app: APIGatewayRestResolver, next_middleware: NextMiddleware) -> Response[Any]:
    authorizer = app.current_event.request_context.authorizer
    app.append_context(user=json.loads(authorizer["user"]), claims=json.loads(authorizer["claims"]))
    return next_middleware(app)


def check_user(app: APIGatewayRestResolver, next_middleware: NextMiddleware) -> Response[Any]:
    if False:
        """
        許可されていないユーザからのリクエストの場合は403エラーを返す
        """
        raise ServiceError(HTTPStatus.FORBIDDEN, "Forbidden")

    return next_middleware(app)


# --------------------------------------------------------------------------------------------------
# Router
# --------------------------------------------------------------------------------------------------
@app.get("/", cache_control="max-age=0", middlewares=[parse_authorizer, check_user])
def get() -> tuple[dict[str, Any], int] | Response[str]:
    return {}, HTTPStatus.OK
