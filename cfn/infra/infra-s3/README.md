# Infrastructure S3 - 集約S3バケット管理

各種AWSサービスで使用するS3バケットを集約管理するためのインフラストラクチャです。

## 概要

このスタックは、プロジェクト全体で使用する各種S3バケットを一元管理します。各バケットは目的別に最適化された設定を持ち、適切なライフサイクルポリシーが適用されています。

## 管理されるS3バケット

### 1. Lambda Layer バケット
**用途**: Lambda Layerのパッケージ保存
- **バケット名**: `infra-s3-{env}-lambda-layer-{account}-{region}`
- **ライフサイクル**: 90日後に削除
- **バージョニング**: 有効

### 2. CodePipeline バケット
**用途**: CodePipelineとCodeBuildのアーティファクト保存
- **バケット名**: `infra-s3-{env}-codepipeline-{account}-{region}`
- **ライフサイクル**: アーティファクト30日、ソース7日後に削除
- **バージョニング**: 有効

### 3. CloudFormation バケット
**用途**: CloudFormationテンプレートとデプロイパッケージ保存
- **バケット名**: `infra-s3-{env}-cloudformation-{account}-{region}`
- **ライフサイクル**: テンプレート180日、パッケージ90日後に削除
- **バージョニング**: 有効

### 4. アプリケーションデータ バケット
**用途**: アプリケーション固有のデータ保存
- **バケット名**: `infra-s3-{env}-appdata-{account}-{region}`
- **ライフサイクル**: 段階的にIA→Glacier→Deep Archiveに移行
- **バージョニング**: 有効

## プロジェクト構成

```
infra-s3/
├── template.yaml    # CloudFormation テンプレート
├── deploy.sh       # デプロイスクリプト
└── README.md       # このファイル
```

## デプロイ方法

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

| Export名 | 説明 | 用途 |
|----------|------|------|
| `{StackName}-LambdaLayerBucketName` | Lambda Layerバケット名 | Lambda Layer管理 |
| `{StackName}-LambdaLayerBucketArn` | Lambda LayerバケットARN | IAMポリシー |
| `{StackName}-CodePipelineBucketName` | CodePipelineバケット名 | CI/CDパイプライン |
| `{StackName}-CodePipelineBucketArn` | CodePipelineバケットARN | IAMポリシー |
| `{StackName}-CloudFormationBucketName` | CloudFormationバケット名 | デプロイメント |
| `{StackName}-CloudFormationBucketArn` | CloudFormationバケットARN | IAMポリシー |
| `{StackName}-ApplicationDataBucketName` | アプリデータバケット名 | アプリケーション |
| `{StackName}-ApplicationDataBucketArn` | アプリデータバケットARN | IAMポリシー |

## 他のスタックからの参照

### CloudFormation テンプレートでの参照

```yaml
Parameters:
  S3StackName:
    Type: String
    Description: Name of the S3 infrastructure stack
    Default: infra-s3-dev

Resources:
  MyLambdaFunction:
    Type: AWS::Serverless::Function
    Properties:
      Environment:
        Variables:
          LAYER_BUCKET: !ImportValue 
            Fn::Sub: "${S3StackName}-LambdaLayerBucketName"
```

### CodePipeline での参照

```yaml
CodePipeline:
  Type: AWS::CodePipeline::Pipeline
  Properties:
    ArtifactStore:
      Type: S3
      Location: !ImportValue infra-s3-dev-CodePipelineBucketName
```

### AWS CLI での参照

```bash
# Lambda Layer バケット名を取得
LAYER_BUCKET=$(aws cloudformation describe-stacks \
  --stack-name infra-s3-dev \
  --query 'Stacks[0].Outputs[?OutputKey==`LambdaLayerBucketName`].OutputValue' \
  --output text)

# CodePipeline バケット名を取得
PIPELINE_BUCKET=$(aws cloudformation describe-stacks \
  --stack-name infra-s3-dev \
  --query 'Stacks[0].Outputs[?OutputKey==`CodePipelineBucketName`].OutputValue' \
  --output text)
```

## セキュリティ機能

### 共通設定
- **パブリックアクセス完全ブロック**: 全バケットでパブリックアクセス無効
- **サーバーサイド暗号化**: AES256による自動暗号化
- **バージョニング**: 誤削除対策として有効化
- **不完全アップロード削除**: 1日後に自動削除

### バケット別最適化
- **Lambda Layer**: 90日間の保持でストレージ効率化
- **CodePipeline**: 短期間の保持でコスト削減
- **CloudFormation**: 長期間の保持でガバナンス強化
- **アプリデータ**: 段階的アーカイブでコスト最適化

## 依存関係

このスタックは他のスタックの基盤となります：

```
infra-s3 (基盤)
├── infra-layer (Lambda Layer管理)
├── infra-hosting (静的サイトホスティング)
└── 各種アプリケーションスタック
```

## 使用例

```bash
# 1. S3インフラをデプロイ（最初に実行）
cd cfn/infra/infra-s3
./deploy.sh dev

# 2. 他のインフラをデプロイ
cd ../infra-layer
./deploy.sh dev  # Lambda Layer管理

cd ../infra-hosting  
./deploy.sh dev  # 静的サイトホスティング
```

## コスト最適化

### ライフサイクルポリシー
- **短期利用**: CodePipelineアーティファクト（7-30日）
- **中期利用**: Lambda Layer、CloudFormationパッケージ（90-180日）
- **長期利用**: アプリケーションデータ（段階的アーカイブ）

### ストレージクラス移行
```
Standard (0日) → Standard-IA (30日) → Glacier (90日) → Deep Archive (365日)
```

## クリーンアップ

```bash
# 注意: 他のスタックが依存しているため、削除前に確認が必要
aws cloudformation delete-stack --stack-name infra-s3-dev

# バケット内のオブジェクトを先に削除（必要に応じて）
aws s3 rm s3://infra-s3-dev-lambda-layer-* --recursive
aws s3 rm s3://infra-s3-dev-codepipeline-* --recursive
aws s3 rm s3://infra-s3-dev-cloudformation-* --recursive
aws s3 rm s3://infra-s3-dev-appdata-* --recursive
```

**警告**: このスタックは他の多くのスタックから参照されているため、削除する前に依存関係を必ず確認してください。