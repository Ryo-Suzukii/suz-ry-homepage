from __future__ import annotations

from aws_lambda_powertools.logging import Logger
from fastmcp import FastMCP

logger = Logger(child=True)

mcp = FastMCP("tmpl-mcp-tools")


@mcp.tool()
def add(a: int, b: int) -> int:
    """
    Add two integers.
    """
    return a + b


@mcp.tool()
def multiply(a: int, b: int) -> int:
    """
    Multiply two integers.
    """
    return a * b
