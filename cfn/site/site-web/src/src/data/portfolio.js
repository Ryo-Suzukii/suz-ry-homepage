import spaceExplorer from './portfolios/space-explorer.js'
import aiChatPlatform from './portfolios/ai-chat-platform.js'
import blockchainAnalytics from './portfolios/blockchain-analytics.js'

const portfolioData = [
  spaceExplorer,
  aiChatPlatform,
  blockchainAnalytics
]

export function getPortfolioById(id) {
  return portfolioData.find(item => item.id === id)
}

export function getAllPortfolios() {
  return portfolioData
}

export function getPortfoliosByCategory(category) {
  return portfolioData.filter(item => item.category === category)
}

export { portfolioData }