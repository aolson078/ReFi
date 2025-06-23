# ReFi Donation Pool

This repository contains a minimal proof-of-concept for an on-chain donation
pool that accepts ETH and USDC contributions. Funds are routed once per day to a
predefined environmental NGO. A lightweight React front-end displays the current
pool balance and total tonnes of CO₂ funded.

## Contracts

The Solidity contract `DonationPool.sol` implements the following features:

- Accept ETH via the `receive` function.
- Accept USDC via `donateUSDC()`.
- Anyone can trigger a daily `withdraw()` which forwards all funds to the NGO
  address and updates the running total of CO₂ tonnes funded.
- Exposes `poolBalances()` for the front-end.

The contract is intentionally simple and roughly 200 lines of code.

## Front-end

The `frontend` folder contains a tiny Vite + React app using Wagmi and
RainbowKit for wallet connectivity. It queries the donation pool contract and
shows the current balances. Running the dev server requires Node.js 18+.

```bash
cd frontend
npm install
npm run dev
```

## NGO metadata

The file `metadata.json` contains example metadata that can be uploaded to IPFS
and referenced by the front-end or other applications.
