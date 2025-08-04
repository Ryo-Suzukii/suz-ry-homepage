# Infrastructure Hosting

S3 + CloudFront による静的ウェブサイトホスティングのための共有インフラストラクチャです。

## 概要

このテンプレートは、複数のアプリケーションで共有可能な S3 + CloudFront ホスティング環境を提供します。セキュリティベストプラクティスに従い、以下の機能を含みます：

- **セキュアな S3 設定**: パブリックアクセス完全ブロック
- **Origin Access Control (OAC)**: CloudFront から S3 への安全なアクセス
- **モダンな CloudFront 設定**: 最新のCache PolicyとSecurity Headers Policy
- **Export値による共有**: 他のスタックから参照可能

## リソース

### S3 Bucket
- バケット名: `{AppName}-{EnvironmentName}-{AccountId}-{Region}`
- パブリックアクセス: 完全ブロック
- 暗号化: AES256
- バージョニング: 有効

### CloudFront Distribution
- Origin Access Control使用
- Cache Policy: Managed-CachingOptimized
- Security Headers Policy: Managed-SecurityHeadersPolicy
- HTTP/2 & HTTP/3サポート
- SPA対応のエラーハンドリング

## デプロイ

```bash
# 開発環境
./deploy.sh dev

# 本番環境
./deploy.sh prd

# カスタムプロファイル
./deploy.sh dev profile=my-profile
```

## Export値

このスタックは以下の値をエクスポートします：

| Export名 | 説明 |
|----------|------|
| `{StackName}-BucketName` | S3バケット名 |
| `{StackName}-BucketArn` | S3バケットARN |
| `{StackName}-CloudFrontURL` | CloudFront Distribution URL |
| `{StackName}-DistributionId` | CloudFront Distribution ID |
| `{StackName}-DistributionDomainName` | CloudFront ドメイン名 |
| `{StackName}-OriginAccessControlId` | Origin Access Control ID |

## 他のスタックからの参照

### CloudFormation テンプレートでの参照

```yaml
Parameters:
  HostingStackName:
    Type: String
    Description: Name of the hosting infrastructure stack
    Default: infra-hosting-dev

Resources:
  MyResource:
    Type: AWS::SomeResource
    Properties:
      BucketName: !ImportValue 
        Fn::Sub: "${HostingStackName}-BucketName"
```

### AWS CLI での参照

```bash
# バケット名を取得
BUCKET_NAME=$(aws cloudformation describe-stacks \
  --stack-name infra-hosting-dev \
  --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' \
  --output text)

# Distribution IDを取得
DISTRIBUTION_ID=$(aws cloudformation describe-stacks \
  --stack-name infra-hosting-dev \
  --query 'Stacks[0].Outputs[?OutputKey==`DistributionId`].OutputValue' \
  --output text)
```

## セキュリティ機能

### S3セキュリティ
- パブリックアクセス完全ブロック
- CloudFrontサービスプリンシパルのみアクセス許可
- バケットレベル暗号化
- バージョニング有効化

### CloudFrontセキュリティ
- HTTPS強制（redirect-to-https）
- セキュリティヘッダー自動追加
- 圧縮有効化
- 適切なキャッシュ設定

## 使用例

1. **このインフラをデプロイ**
   ```bash
   cd cfn/infra/infra-hosting
   ./deploy.sh dev
   ```

2. **アプリケーションからファイルをアップロード**
   ```bash
   # バケット名を取得
   BUCKET_NAME=$(aws cloudformation describe-stacks \
     --stack-name infra-hosting-dev \
     --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' \
     --output text)
   
   # ファイルをアップロード
   aws s3 sync ./dist/ s3://$BUCKET_NAME --delete
   
   # CloudFront無効化
   DISTRIBUTION_ID=$(aws cloudformation describe-stacks \
     --stack-name infra-hosting-dev \
     --query 'Stacks[0].Outputs[?OutputKey==`DistributionId`].OutputValue' \
     --output text)
   
   aws cloudfront create-invalidation \
     --distribution-id $DISTRIBUTION_ID \
     --paths "/*"
   ```

## クリーンアップ

```bash
aws cloudformation delete-stack --stack-name infra-hosting-dev
```

**注意**: このスタックを削除する前に、依存している他のスタックがないことを確認してください。