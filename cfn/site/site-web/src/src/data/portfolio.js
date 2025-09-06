

const portfolioData = [
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
