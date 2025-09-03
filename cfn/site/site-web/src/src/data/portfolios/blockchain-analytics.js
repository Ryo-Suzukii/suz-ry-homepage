export default {
  id: 'blockchain-analytics',
  title: 'ブロックチェーン分析ダッシュボード',
  description: 'Web3.jsとD3.jsを使用したブロックチェーンデータの可視化ツール。リアルタイムトランザクション監視。',
  technologies: ['Vue.js', 'D3.js', 'Web3.js', 'Python', 'FastAPI'],
  thumbnail: '/images/portfolio/blockchain-thumb.jpg',
  images: [
    '/images/portfolio/blockchain-1.jpg',
    '/images/portfolio/blockchain-2.jpg',
    '/images/portfolio/blockchain-3.jpg'
  ],
  githubUrl: 'https://github.com/username/blockchain-analytics',
  liveUrl: 'https://blockchain-analytics.demo.com',
  category: 'Data Visualization',
  date: '2024-02',
  details: {
    overview: 'Ethereumブロックチェーンのデータをリアルタイムで取得・分析・可視化するダッシュボード。トレーダーやデベロッパー向けの分析ツール。',
    challenges: [
      '大量データのリアルタイム処理',
      '複雑なデータ構造の可視化',
      'ブロックチェーンAPIの効率的な利用'
    ],
    features: [
      'リアルタイムトランザクション監視',
      'ガス価格予測モデル',
      'ウォレット分析機能',
      'カスタムアラート設定'
    ],
    technicalDetails: {
      architecture: 'フロントエンド + Python API',
      performance: 'リアルタイムデータストリーミング',
      deployment: 'Frontend on Netlify, API on Railway'
    }
  }
}