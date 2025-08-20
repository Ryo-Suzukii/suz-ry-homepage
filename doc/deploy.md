# Deploy Procedure

## Preparation

```shell
brew install awscli aws-sam-cli jq
```

> [!NOTE]
> デプロイだけであれば、Docker は不要。

## CLI 設定

### SSO 設定

`~/.aws/config`に下記内容を追加（`ProfilePrefix`は、`dev|stg|prd`を除外したアカウント名などとする）

```ini
[sso-session WNI]
sso_start_url = https://wni.awsapps.com/start/
sso_region = us-east-1
sso_registration_scopes = sso:account:access

[profile <ProfilePrefix>_dev]
sso_session = WNI
sso_account_id = <Account ID>
sso_role_name = <Role Name>
region = ap-northeast-1
output = json

[profile <ProfilePrefix>_stg]
sso_session = WNI
sso_account_id = <Account ID>
sso_role_name = <Role Name>
region = ap-northeast-1
output = json

[profile <ProfilePrefix>_prd]
sso_session = WNI
sso_account_id = <Account ID>
sso_role_name = <Role Name>
region = ap-northeast-1
output = json
```

## 基本設定

### パラメータ定義

- グローバル定義
  `/path/to/env_params/env.json`に適切な値を設定

  ```jsonc
  {
    "Exports": {
      "Infra": "<共通インフラ名>", // インフラリポジトリ側の env.json に書かれた Project を指定
      "Planning": "<チーム名>",
      "Project": "<チーム名>-<プロジェクト名>",
      "ProfilePrefix": "<AWSプロファイルのプレフィックス>",
      "DeployRegion": "ap-northeast-1"
    },
    "Parameters": {
      "Region": "ane1"
    },
    "Tags": {
      "Cost": "<コストタグ>",
      "map-migrated": "migMCX7KD5RU8"
    }
  }
  ```

### アカウント設定

- API Gateway の IAM（設定済みの場合はスキップ）

  ```shell
  cd /path/to/cfn/account/account-config
  ./deploy.sh (dev|prd)
  ```

- Slack Workspace
  コンソールから設定する

### 外部認証情報の登録

```shell
cd /path/to/cfn/infra/infra-resource
./put_ssm.sh (dev|stg|prd) (ane1|use1) <キー名> <値>
```

必須登録項目

| Region | Key                    | Description                                      |
| ------ | ---------------------- | ------------------------------------------------ |
| ane1   | slack/workspace-id     | AWS に登録した Slack のワークスペース ID         |
| ane1   | slack/channel-id/alarm | CloudWatch Alarm 経由で送信する Slack チャンネル |
| ane1   | slack/channel-id/logs  | CloudWatch Logs 経由で送信する Slack チャンネル  |
| ane1   | slack/oauth-token      | Slack 連携用のトークン                           |

### CI-CD 環境の構築

```shell
cd /path/to/cfn/infra/infra-cicd
./deploy.sh (dev|stg|prd)
```

### 共通 IAM/セキュリティグループの作成

```shell
cd /path/to/cfn/infra/infra-security
./deploy.sh (dev|stg|prd)
```

### バックアッププランの作成

```shell
cd /path/to/cfn/infra/infra-backup
./deploy.sh (dev|stg|prd)
```

### Lambda Layer の構築

```shell
cd /path/to/cfn/layer/layer-python313
./upload_to_pipeline.sh (dev|stg|prd)
./deploy_pipeline.sh (dev|stg|prd)
```

- AWS コンソールで対象の CodePipeline を開き、承認

### Slack 通知用トピックの作成

```shell
cd /path/to/cfn/alert/alert-topic
./deploy.sh (dev|stg|prd) ane1
./deploy.sh (dev|stg|prd) use1
```

### Chatbot の構築

```shell
cd /path/to/cfn/alert/alert-chatbot
./deploy.sh (dev|stg|prd)
```

### Slack 通知用 Lambda の構築

```shell
# Lambda Layerの構築と同じ
cd /path/to/cfn/alert/alert-slack
./upload_to_pipeline.sh (dev|stg|prd)
./deploy_pipeline.sh (dev|stg|prd)
```

### DB の作成

```shell
cd /path/to/cfn/store/store-data
./deploy.sh (dev|stg|prd)
```

## CloudFormation のデプロイ先

| Category | Name            | Region    |
| -------- | --------------- | --------- |
| account  | account-config  | ane1      |
| alert    | alert-chatbot   | ane1      |
| alert    | alert-slack     | ane1      |
| alert    | alert-topic     | ane1/use1 |
| infra    | infra-backup    | ane1      |
| infra    | infra-cicd      | ane1      |
| infra    | infra-resource  | ane1/use1 |
| infra    | infra-security  | ane1      |
| layer    | layer-python313 | ane1      |
| store    | store-data      | ane1      |
