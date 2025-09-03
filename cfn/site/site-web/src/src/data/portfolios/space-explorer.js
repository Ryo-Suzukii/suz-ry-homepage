export default {
  id: 'space-explorer',
  title: '宇宙探査シミュレーター',
  description: 'Three.jsを使用したリアルタイム宇宙探査シミュレーション。惑星間航行や重力計算を実装。',
  technologies: ['Vue.js', 'Three.js', 'WebGL', 'JavaScript'],
  thumbnail: '/images/portfolio/space-explorer-thumb.jpg',
  images: [
    '/images/portfolio/space-explorer-1.jpg',
    '/images/portfolio/space-explorer-2.jpg',
    '/images/portfolio/space-explorer-3.jpg'
  ],
  githubUrl: 'https://github.com/username/space-explorer',
  liveUrl: 'https://space-explorer.demo.com',
  category: 'Web Application',
  date: '2024-01',
  details: {
    overview: '宇宙空間での物理法則を正確に再現した3Dシミュレーター。ユーザーは宇宙船を操縦して太陽系を探索できます。',
    challenges: [
      '3D空間での正確な物理演算の実装',
      'パフォーマンス最適化とメモリ管理',
      'リアルタイムレンダリングの効率化'
    ],
    features: [
      '惑星間航行システム',
      'リアルタイム重力計算',
      '3D宇宙マップ',
      '宇宙船のカスタマイゼーション'
    ],
    technicalDetails: {
      architecture: 'クライアントサイドレンダリング with Three.js',
      performance: '60FPS維持、メモリ使用量最適化',
      deployment: 'Vercel with CDN optimization'
    }
  }
}