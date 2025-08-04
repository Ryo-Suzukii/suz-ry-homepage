# Infrastructure Layer - Lambda共通ライブラリ

Lambda関数で共通して使用するPythonライブラリをLayerとして管理するためのインフラストラクチャです。

## 概要

このLayerを使用することで以下のメリットがあります：

- **デプロイサイズ削減**: Lambda関数のパッケージサイズを削減
- **デプロイ時間短縮**: 共通ライブラリを別途デプロイするため、関数の更新が高速
- **依存関係管理**: 共通ライブラリのバージョンを一元管理
- **コールドスタート改善**: 小さなデプロイパッケージによる起動時間の短縮

## 含まれるライブラリ

### AWS関連
- `boto3`, `botocore` - AWS SDK
- `awswrangler` - AWS Data Wrangler
- `aws-lambda-powertools` - Lambda ユーティリティ

### データ処理
- `pandas`, `numpy` - データ分析
- `scipy` - 科学計算

### Web・API
- `requests`, `urllib3` - HTTP クライアント
- `beautifulsoup4`, `lxml` - Web スクレイピング

### データベース
- `sqlalchemy` - ORM
- `psycopg2-binary` - PostgreSQL アダプター

### ユーティリティ
- `pydantic` - データバリデーション
- `jsonschema` - JSON スキーマ検証
- `structlog` - 構造化ログ
- `python-dateutil`, `pytz` - 日時処理
- `cryptography`, `bcrypt` - 暗号化
- `Jinja2`, `PyYAML` - テンプレート・設定
- `python-dotenv` - 環境変数管理

### 画像処理
- `Pillow` - 画像処理ライブラリ

## プロジェクト構成

```
infra-layer/
├── requirements.txt     # 共通ライブラリの定義
├── template.yaml        # CloudFormation テンプレート
├── deploy.sh           # デプロイスクリプト
├── build/              # ビルド用ディレクトリ（自動生成）
└── README.md           # このファイル
```

## デプロイ方法

### 1. S3 Infrastructure のデプロイ

まず、S3バケットをデプロイします：

```bash
# S3 インフラをデプロイ
cd ../../infra/infra-s3
./deploy.sh dev
```

### 2. Pipeline Infrastructure のデプロイ

次に、CodeBuildパイプラインをデプロイします：

```bash
# Pipeline インフラをデプロイ（基本）
cd ../infra-layer
./deploy-pipeline.sh dev

# カスタムプロファイル使用
./deploy-pipeline.sh dev profile=my-profile

# 特定のPythonバージョン指定
./deploy-pipeline.sh dev python=python3.12

# GitHub連携有効化（オプション）
./deploy-pipeline.sh dev \
  --github-owner=your-github-username \
  --github-repo=aws-project-template \
  --github-token=ghp_xxxxxxxxxxxx

# GitHub連携＋カスタム設定
./deploy-pipeline.sh prd \
  profile=production-profile \
  python=python3.12 \
  --github-owner=your-org \
  --github-repo=your-repo \
  --github-branch=production \
  --github-token=ghp_xxxxxxxxxxxx
```

### 3. Layer のビルドとデプロイ

```bash
# CodeBuildを使用してビルド＆デプロイ
./deploy.sh dev

# 本番環境
./deploy.sh prd

# カスタムプロファイル
./deploy.sh dev profile=my-profile

# 特定のPythonバージョン
./deploy.sh dev python=python3.12

# ビルドをスキップ（Layer作成のみ）
./deploy.sh dev --skip-build
```

## CI/CD ビルドプロセス

### CodeBuild による自動ビルド

1. **ソース準備**
   - `requirements.txt` と `buildspec.yml` をS3にアップロード
   - CodeBuild プロジェクトを起動

2. **Lambda互換ビルド**
   - AWS CodeBuild の Amazon Linux 2 環境を使用
   - `--platform manylinux2014_x86_64` でLambda互換パッケージをビルド
   - 不要ファイル（テスト、キャッシュ等）を自動削除

3. **Layer パッケージ作成**
   - 標準的な `python/lib/python3.x/site-packages/` 構造
   - ZIP圧縮とサイズ検証（250MB制限）
   - S3バケットに自動アップロード

4. **CloudFormation デプロイ**
   - Layer リソースを作成・更新
   - Export値を設定して他のスタックから参照可能

### ビルドの特徴

- **クロスプラットフォーム対応**: Lambda実行環境と完全互換
- **自動最適化**: 不要ファイルの削除でサイズ削減
- **リアルタイム監視**: ビルド状況をリアルタイムで表示
- **エラーハンドリング**: 失敗時のログ表示と適切なエラー処理

## Lambda関数での使用方法

### CloudFormation テンプレートでの参照

```yaml
Resources:
  MyLambdaFunction:
    Type: AWS::Serverless::Function
    Properties:
      FunctionName: my-function
      Runtime: python3.13
      Handler: app.lambda_handler
      CodeUri: src/
      Layers:
        - !ImportValue infra-layer-dev-LayerArnWithVersion
      Environment:
        Variables:
          ENVIRONMENT_NAME: !Ref EnvironmentName
```

### SAM テンプレートでの参照

```yaml
Globals:
  Function:
    Layers:
      - !ImportValue infra-layer-dev-LayerArnWithVersion
    Runtime: python3.13

Resources:
  MyFunction:
    Type: AWS::Serverless::Function
    Properties:
      CodeUri: src/
      Handler: app.lambda_handler
```

### AWS CLI での参照

```bash
# Layer ARN を取得
LAYER_ARN=$(aws cloudformation describe-stacks \
  --stack-name infra-layer-dev \
  --query 'Stacks[0].Outputs[?OutputKey==`LayerArnWithVersion`].OutputValue' \
  --output text)

# Lambda関数に Layer を追加
aws lambda update-function-configuration \
  --function-name my-function \
  --layers $LAYER_ARN
```

## Export値

このスタックは以下の値をエクスポートします：

| Export名 | 説明 |
|----------|------|
| `{StackName}-LayerArn` | Layer ARN（バージョンなし） |
| `{StackName}-LayerVersion` | Layer バージョン番号 |
| `{StackName}-LayerArnWithVersion` | Layer ARN（バージョン付き）**推奨** |
| `{StackName}-LayerName` | Layer 名 |
| `{StackName}-ArtifactsBucketName` | S3バケット名 |
| `{StackName}-PythonVersion` | Python バージョン |

## ライブラリの追加・更新

1. `requirements.txt` を編集してライブラリを追加・更新
2. デプロイを実行（自動的に新しいバージョンが作成される）
3. 依存する Lambda 関数のテンプレートで新しい Layer を参照

```bash
# ライブラリ更新後のデプロイ
./deploy.sh dev
```

## ベストプラクティス

### バージョン管理
- Layer は更新のたびに新しいバージョンが作成されます
- 本番環境では特定のバージョンを固定することを推奨
- `LayerArnWithVersion` を使用して特定バージョンを参照

### CI/CD パイプライン
- CodeBuild を使用することで一貫性のあるビルド環境を確保
- GitHub 連携により、コード変更時の自動ビルドが可能
- パイプライン成果物は S3 で管理され、履歴が保持される

### サイズ制限
- Lambda Layer の上限は 250MB（解凍後）
- CodeBuild が自動的にサイズ検証を実行
- 不要ファイルは buildspec.yml で自動削除

### 互換性
- CodeBuild の Amazon Linux 2 環境でLambda互換ビルド
- `manylinux2014_x86_64` プラットフォームを使用
- Python バージョンは Lambda 関数と一致させる

## トラブルシューティング

### CodeBuild プロジェクトが見つからない場合
```bash
# Pipeline インフラが未デプロイの場合
aws cloudformation deploy \
  --template-file pipeline-template.yaml \
  --stack-name infra-layer-dev-pipeline \
  --capabilities CAPABILITY_NAMED_IAM
```

### ビルドが失敗する場合
- CodeBuild のログで詳細なエラー情報を確認
- `requirements.txt` の依存関係の競合をチェック
- Python バージョンの互換性を確認

### Layer の参照エラー
- Layer のバージョンが正しく参照されているか確認
- Export された値が正しいスタック名で参照されているかチェック

### GitHub 連携の問題
- GitHub トークンの権限を確認
- リポジトリの可視性設定をチェック
- Webhook の設定状況を確認

## プロジェクト構成（3スタック構成）

```
infra-layer/
├── requirements.txt         # 共通ライブラリの定義
├── buildspec.yml           # CodeBuild ビルド設定
├── template.yaml           # Lambda Layer CloudFormation テンプレート
├── pipeline-template.yaml  # CodePipeline/CodeBuild インフラテンプレート
├── deploy.sh              # デプロイスクリプト（CodeBuild使用）
└── README.md              # このファイル
```

## スタック依存関係

```
infra-s3 (S3バケット管理)
    ↓
infra-layer-pipeline (CodeBuild/Pipeline)
    ↓  
infra-layer (Lambda Layer)
```

## 使用開始の流れ

```bash
# 1. S3 インフラをデプロイ
cd ../../infra/infra-s3
./deploy.sh dev

# 2. Pipeline インフラをデプロイ
cd ../infra-layer
./deploy-pipeline.sh dev

# 3. Layer をビルド＆デプロイ
./deploy.sh dev

# 4. Lambda関数で使用
# template.yamlにLayerArnWithVersionを追加
```

## クリーンアップ

依存関係を考慮して逆順で削除します：

```bash
# 1. Layer スタックを削除
aws cloudformation delete-stack --stack-name infra-layer-dev

# 2. Pipeline インフラを削除
aws cloudformation delete-stack --stack-name infra-layer-dev-pipeline

# 3. S3 インフラを削除（他の依存がない場合のみ）
# 注意: 他のサービスがS3バケットを使用している可能性があります
aws cloudformation delete-stack --stack-name infra-s3-dev

# 4. S3 バケット内のオブジェクトを手動削除（必要に応じて）
aws s3 rm s3://infra-s3-dev-lambda-layer-* --recursive
aws s3 rm s3://infra-s3-dev-codepipeline-* --recursive
```

**重要な注意事項**: 
- Layer を使用している Lambda 関数がある場合、先に関数を更新してから削除
- S3 インフラスタックは他の多くのサービスから参照されているため、削除前に依存関係を必ず確認
- 本番環境では特に慎重に削除手順を実行してください