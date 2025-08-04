# Sample Site - React Application

React アプリケーションのサンプルです。外部のホスティングインフラ（`infra-hosting`）を使用してファイルをデプロイします。

## 特徴

- **シンプルなデプロイ**: CloudFormationスタック不要
- **外部インフラ使用**: 共有可能なホスティングインフラを参照
- **分離された責任**: アプリケーションとインフラを独立管理
- **依存関係チェック**: ホスティングインフラの存在を確認

## プロジェクト構成

```
sample-site/
├── src/                    # React source code
├── public/                 # Static assets
├── dist/                   # Build output (generated)
├── deploy.sh              # ファイルアップロードスクリプト
├── file-upload.sh         # ファイルアップロード専用
├── package.json           # Node.js dependencies
└── README.md              # This file
```

## 前提条件

- Node.js (v18 or later)
- AWS CLI configured with appropriate permissions
- AWS account with CloudFormation, S3, and CloudFront access

## ローカル開発

1. 依存関係インストール:
   ```bash
   npm install
   ```

2. 開発サーバー起動:
   ```bash
   npm run dev
   ```

3. プロダクション用ビルド:
   ```bash
   npm run build
   ```

## 前提条件

- Node.js (v18 or later)
- AWS CLI configured with appropriate permissions
- ホスティングインフラが事前にデプロイされていること

### ホスティングインフラのデプロイ

このアプリケーションをデプロイする前に、ホスティングインフラが必要です：

```bash
# ホスティングインフラをデプロイ
cd ../../infra/infra-hosting
./deploy.sh dev
```

## デプロイ方法

### 基本的なデプロイ
```bash
# ビルド + ファイルアップロード
./deploy.sh dev

# ビルドスキップしてアップロード
./deploy.sh dev --skip-build

# カスタムプロファイル使用
./deploy.sh dev profile=my-profile
```

### 直接ファイルアップロード
```bash
# file-upload.shを直接実行も可能
./file-upload.sh dev
./file-upload.sh dev --skip-build
```

## 外部インフラ依存

このアプリケーションは以下の外部インフラに依存します：

### ホスティングインフラ (`infra-hosting`)
- **S3 Bucket**: 静的ファイルホスティング（プライベート）
- **Origin Access Control**: CloudFront から S3 への安全なアクセス
- **S3 Bucket Policy**: CloudFront サービスのみアクセス許可
- **CloudFront Distribution**: CDN、HTTPS、セキュリティヘッダー

### 参照方法
デプロイスクリプトが AWS CLI を使用して動的に値を取得：

```bash
BUCKET_NAME=$(aws cloudformation describe-stacks \
  --stack-name "infra-hosting-${ENVIRONMENT}" \
  --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' \
  --output text)
```

## AWS リソース

このアプリケーション自体はAWSリソースを作成しません：
- **CloudFormationスタックなし**: 静的ファイルのアップロードのみ
- **外部インフラ参照**: ホスティングインフラから動的に設定取得

## 使用例

```bash
# 1. ホスティングインフラをデプロイ（初回のみ）
cd ../../infra/infra-hosting
./deploy.sh dev

# 2. アプリケーション初回デプロイ
cd ../../sites/sample-site
./deploy.sh dev

# 3. コード更新時
./deploy.sh dev

# 4. ビルドスキップしてアップロード
./deploy.sh dev --skip-build

# 5. 本番環境デプロイ
./deploy.sh prd profile=my-production-profile
```

## デプロイフロー

```
1. infra-hosting をデプロイ
   ↓
2. sample-site でファイルをビルド・アップロード
   （共有S3バケットへ直接アップロード）
```

## クリーンアップ

```bash
# アプリケーションファイルをS3から削除（オプション）
aws s3 rm s3://bucket-name --recursive --profile hoge_dev

# ホスティングインフラを削除（他に依存するアプリがない場合）
aws cloudformation delete-stack --stack-name infra-hosting-dev --profile hoge_dev
```

**注意**: 
- このアプリケーション自体はCloudFormationスタックを作成しないため、削除するものはありません
- ホスティングインフラは複数のアプリケーションで共有される可能性があるため、削除前に他の依存関係を確認してください
