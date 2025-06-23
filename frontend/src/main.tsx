import React from 'react';
import ReactDOM from 'react-dom/client';
import { WagmiConfig, createClient, configureChains } from 'wagmi';
import { publicProvider } from 'wagmi/providers/public';
import { RainbowKitProvider, getDefaultWallets } from '@rainbow-me/rainbowkit';
import App from './App';
import '@rainbow-me/rainbowkit/styles.css';

const { chains, provider } = configureChains([
  { id: 1, name: 'Ethereum', network: 'homestead', nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 }, rpcUrls: { default: { http: ['https://eth.llamarpc.com'] } } }
], [publicProvider()]);

const { connectors } = getDefaultWallets({ appName: 'ReFi Pool', chains });

const client = createClient({ autoConnect: true, connectors, provider });

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <React.StrictMode>
    <WagmiConfig client={client}>
      <RainbowKitProvider chains={chains}>
        <App />
      </RainbowKitProvider>
    </WagmiConfig>
  </React.StrictMode>
);
