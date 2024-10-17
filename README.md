# Decentralized Meme Voting Platform

## Overview
This project implements a decentralized meme voting platform on the Stacks blockchain. Users can submit memes, vote on their favorites, and earn token rewards based on the popularity of their submissions.

## Features
- Meme submission with unique IDs stored on-chain
- Voting system with token rewards
- Leaderboard based on meme popularity
- Token-based entry system for users

## Smart Contract Functions
- `submit-meme()`: Submit a new meme (requires entry fee)
- `vote-for-meme(meme-id)`: Vote for a specific meme
- `get-meme(meme-id)`: Retrieve details of a specific meme
- `get-meme-count()`: Get the total number of memes submitted
- `distribute-rewards()`: Calculate and distribute rewards for meme creators

## Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet): Clarity smart contract development tool
- [Node.js](https://nodejs.org/) and npm
- [Vitest](https://vitest.dev/) for running tests

## Setup
1. Clone the repository:
   ```
   git clone https://github.com/your-username/meme-voting-platform.git
   cd meme-voting-platform
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Set up Clarinet project:
   ```
   clarinet new meme-voting-project
   cd meme-voting-project
   ```

4. Copy the `meme-voting.clar` contract into the `contracts` folder of your Clarinet project.

## Running Tests
To run the test suite:

```
npm test
```

## Deployment
To deploy the contract to the Stacks blockchain:

1. Configure your Stacks wallet in Clarinet
2. Run:
   ```
   clarinet deploy
   ```

## Usage
After deployment, users can interact with the contract using a Stacks wallet or a custom frontend application. Key interactions include:

1. Submitting a meme (requires entry fee)
2. Voting for favorite memes
3. Checking meme details and vote counts
4. Claiming rewards for popular memes

## Contributing
Contributions are welcome! Please fork the repository and submit a pull request with your changes.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer
This is an experimental project. Use at your own risk. Always audit smart contracts before using them with real assets.
