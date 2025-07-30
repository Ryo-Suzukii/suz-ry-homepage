# AWS Project Template

このリポジトリは、AWS SAMを使用したプロジェクトの作業環境を楽にするためのテンプレートです。

## 特徴

- SAMによるデプロイをサポート
- 簡単なシェルスクリプトでのデプロイ実行
- dev/prd環境の引数による切り替え
- 設定ファイルによる環境名管理
- CloudFormationテンプレートでのAppName自動設定

## ディレクトリ構成

```
.
├── README.md
├── setting.json          # 環境設定ファイル
└── cfn/                 # SAMテンプレート配置ディレクトリ
    └── sample-app/      # サンプルアプリケーション
        ├── deploy.sh    # デプロイスクリプト
        ├── template.yaml
        └── src/
            ├── __init__.py
            ├── app.py
            └── requirements.txt
```

## 前提条件

- AWS CLI がインストールされていること
- AWS SAM CLI がインストールされていること
- jq がインストールされていること
- AWS SSO プロファイルが設定されていること
  - dev環境: `hoge_dev`
  - prd環境: `hoge_prd`

## 使用方法

### 1. 環境設定

`setting.json` でEnvironmentNameを設定してください：

```json
{
  "EnvironmentName": "dev"
}
```

### 2. デプロイ実行

各アプリケーションのディレクトリに移動してからデプロイスクリプトを実行します：

```bash
cd cfn/<app-name>
./deploy.sh <environment> [profile=<aws-profile>]
```

例：
```bash
# dev環境にsample-appをデプロイ（デフォルトのhoge_devプロファイル使用）
cd cfn/sample-app
./deploy.sh dev

# prd環境にsample-appをデプロイ（デフォルトのhoge_prdプロファイル使用）
cd cfn/sample-app
./deploy.sh prd

# カスタムプロファイルを指定してデプロイ
cd cfn/sample-app
./deploy.sh dev profile=my-custom-profile

# AWS_PROFILE環境変数を使用してデプロイ
export AWS_PROFILE=my-env-profile
cd cfn/sample-app
./deploy.sh dev
```

#### AWSプロファイルの優先順位

1. **profile=引数** - 最優先
2. **AWS_PROFILE環境変数** - 2番目
3. **デフォルト** - `hoge_{environment}` パターン

AppName（アプリケーション名）は、ディレクトリ名から自動的に取得されます。

### 3. 新しいアプリケーションの作成

1. `cfn/` ディレクトリ内に新しいアプリケーション用のディレクトリを作成
2. `template.yaml` を作成し、パラメータに `EnvironmentName` と `AppName` を含める
3. `sample-app/deploy.sh` をコピーして新しいアプリケーション用のデプロイスクリプトを作成
4. 必要に応じてLambda関数のソースコードを `src/` ディレクトリに配置

## テンプレートのパラメータ

SAMテンプレートでは以下のパラメータが自動的に設定されます：

- `EnvironmentName`: `setting.json` から読み込まれる環境名
- `AppName`: cfnディレクトリ内のフォルダ名（デプロイスクリプトで自動取得）

## サンプルアプリケーション

`cfn/sample-app/` に含まれるサンプルアプリケーションには以下のリソースが含まれています：

- Lambda関数（Hello World API）
- S3バケット
- DynamoDBテーブル

各リソースは `AppName` と `EnvironmentName` を使用して命名されます。
