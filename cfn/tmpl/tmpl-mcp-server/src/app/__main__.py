from __future__ import annotations

import asyncio

import uvicorn
from aws_lambda_powertools.logging import Logger
from fastmcp import FastMCP
from starlette.requests import Request
from starlette.responses import PlainTextResponse

from .tools import mcp as mcp_tools
from .values import Env

logger = Logger()


mcp = FastMCP("tmpl-mcp")


@mcp.custom_route("/", methods=["GET"])
async def health_check(_: Request) -> PlainTextResponse:
    return PlainTextResponse("OK", status_code=200)


async def setup() -> None:
    await mcp.import_server(mcp_tools)
    logger.info("Successfully imported MCP tools.")


if __name__ == "__main__":
    asyncio.run(setup())
    uvicorn.run(
        mcp.http_app(json_response=True, stateless_http=True, transport="http"),
        port=Env.PORT,
    )
