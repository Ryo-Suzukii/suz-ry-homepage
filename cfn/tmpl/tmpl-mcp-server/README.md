# tmpl-mcp-server

リモート MCP サーバーのテンプレート。

## クライアント側の設定

VSCode であれば settings.json に下記を追加する。

```json
{
  "mcp": {
    "servers": {
      "custom-mcp": {
        "type": "http",
        "url": "https://dev-btob-project-template-api-common.machineman.pt-aws.nexadata.com/mcp/v1/tmpl/mcp/"
      }
    }
  }
}
```
