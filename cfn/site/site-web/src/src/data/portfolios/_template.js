// ポートフォリオ追加用テンプレート
// 新しいプロジェクトを追加する際は、このファイルをコピーして編集してください
// 1. ファイル名を変更 (例: my-new-project.js)
// 2. 内容を編集
// 3. portfolio.js にインポートを追加

export default {
  id: 'project-id', // URL用の一意なID
  title: 'プロジェクトタイトル',
  description: 'プロジェクトの簡潔な説明（1-2行）',
  technologies: ['Tech1', 'Tech2', 'Tech3'], // 使用技術の配列
  thumbnail: '/images/portfolio/project-thumb.jpg', // サムネイル画像
  images: [
    '/images/portfolio/project-1.jpg',
    '/images/portfolio/project-2.jpg',
    '/images/portfolio/project-3.jpg'
  ],
  githubUrl: 'https://github.com/username/project', // GitHub URL（任意）
  liveUrl: 'https://project.demo.com', // デモサイトURL（任意）
  category: 'Web Application', // カテゴリー
  date: '2024-01', // 作成日（YYYY-MM形式）
  details: {
    overview: '詳細な概要説明。プロジェクトの目的、背景、実現したことを詳しく説明します。',
    challenges: [
      '直面した技術的課題1',
      '直面した技術的課題2',
      '直面した技術的課題3'
    ],
    features: [
      '主要機能1',
      '主要機能2',
      '主要機能3',
      '主要機能4'
    ],
    technicalDetails: {
      architecture: 'アーキテクチャの説明',
      performance: 'パフォーマンスに関する説明',
      deployment: 'デプロイメント方法'
    }
  }
}