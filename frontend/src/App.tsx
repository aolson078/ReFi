import { useAccount, useBalance, useContractRead } from 'wagmi';
import DonationPoolAbi from '../contracts/DonationPool.json';

const CONTRACT_ADDRESS = '0x0000000000000000000000000000000000000000';

export default function App() {
  const { address } = useAccount();
  const { data: ethBalance } = useBalance({ address: CONTRACT_ADDRESS });
  const { data: usdcBalance } = useContractRead({
    address: CONTRACT_ADDRESS,
    abi: DonationPoolAbi,
    functionName: 'poolBalances'
  }) as { data: [BigInt, BigInt] };

  return (
    <div style={{ padding: '2rem' }}>
      <h1>ReFi Donation Pool</h1>
      <p>Connected Wallet: {address}</p>
      <p>Pool ETH Balance: {ethBalance?.formatted}</p>
      <p>Pool USDC Balance: {usdcBalance?.[1]?.toString()}</p>
    </div>
  );
}
