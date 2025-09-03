export default {
  id: 'ai-chat-platform',
  title: 'AI チャットプラットフォーム',
  description: 'OpenAI APIを活用したリアルタイムチャットアプリケーション。多言語対応とコンテキスト保持機能。',
  technologies: ['React', 'Node.js', 'OpenAI API', 'WebSocket', 'MongoDB'],
  thumbnail: '/images/portfolio/ai-chat-thumb.jpg',
  images: [
    '/images/portfolio/ai-chat-1.jpg',
    '/images/portfolio/ai-chat-2.jpg',
    '/images/portfolio/ai-chat-3.jpg'
  ],
  githubUrl: 'https://github.com/username/ai-chat-platform',
  liveUrl: 'https://ai-chat.demo.com',
  category: 'Full Stack Application',
  date: '2024-03',
  details: {
    overview: 'GPT-4を活用したインテリジェントなチャットプラットフォーム。ユーザーは複数のAIと同時に対話でき、会話履歴も保持されます。',
    challenges: [
      'リアルタイム通信の最適化',
      'AIレスポンスの品質管理',
      'コンテキスト維持とセッション管理'
    ],
    features: [
      'リアルタイムチャット',
      '多言語翻訳機能',
      '会話履歴の保存・検索',
      'カスタムAIキャラクター'
    ],
    technicalDetails: {
      architecture: 'マイクロサービスアーキテクチャ',
      performance: 'WebSocket接続で低遅延通信',
      deployment: 'Docker + Kubernetes on AWS EKS'
    }
  }
}