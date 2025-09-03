# ポートフォリオデータ管理

## 新しいポートフォリオの追加方法

### 1. 新しいデータファイルを作成
1. `_template.js` をコピーして、新しいプロジェクト名でファイルを作成
   ```bash
   cp _template.js your-project-name.js
   ```

2. ファイル内容を編集
   - `id`: URL用の一意なID（ハイフン区切り）
   - `title`: プロジェクトタイトル
   - `description`: 簡潔な説明
   - `technologies`: 使用技術の配列
   - `images`: 画像パスの配列
   - `details`: 詳細情報

### 2. メインファイルにインポートを追加
`../portfolio.js` を編集：

```javascript
// インポートを追加
import yourProjectName from './portfolios/your-project-name.js'

// portfolioDataの配列に追加
const portfolioData = [
  spaceExplorer,
  aiChatPlatform,
  blockchainAnalytics,
  yourProjectName // 新しいプロジェクトを追加
]
```

### 3. 画像ファイルを配置
`public/images/portfolio/` ディレクトリに画像を配置：
- サムネイル画像
- 詳細画像（複数可）

### 4. 確認
- ブラウザでポートフォリオ一覧ページを確認
- 個別詳細ページが正しく表示されることを確認

## データ構造

```javascript
{
  id: 'unique-project-id',
  title: 'プロジェクトタイトル',
  description: '1-2行の簡潔な説明',
  technologies: ['Vue.js', 'Three.js', 'WebGL'],
  thumbnail: '/images/portfolio/thumb.jpg',
  images: ['/images/portfolio/img1.jpg'],
  githubUrl: 'https://github.com/...',
  liveUrl: 'https://demo.com',
  category: 'Web Application',
  date: '2024-01',
  details: {
    overview: '詳細な概要',
    challenges: ['課題1', '課題2'],
    features: ['機能1', '機能2'],
    technicalDetails: {
      architecture: 'アーキテクチャ説明',
      performance: 'パフォーマンス説明',
      deployment: 'デプロイ方法'
    }
  }
}
```

## 注意事項
- `id` は URL に使用されるため、英数字とハイフンのみ使用
- 画像は適切なサイズに最適化してから配置
- 全てのフィールドが必須ではありませんが、`id`, `title`, `description` は必須