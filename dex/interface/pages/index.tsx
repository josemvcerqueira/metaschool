import { Network } from '@interest-protocol/sui-amm-sdk';
import { NextPage } from 'next';
import dynamic from 'next/dynamic';
import { useForm } from 'react-hook-form';

import { SEO } from '@/components';
import { COINS } from '@/constants';
import Swap from '@/views/swap';
import { SwapForm } from '@/views/swap/swap.types';

const Web3Manager = dynamic(() => import('@/components/web3-manager'), {
  ssr: false,
});

const SwapPage: NextPage = () => {
  const formSwap = useForm<SwapForm>({
    defaultValues: {
      from: {
        ...COINS[Network.TESTNET].ETH,
      },
      to: {
        ...COINS[Network.TESTNET].USDC,
      },
    },
  });

  return (
    <Web3Manager>
      <SEO pageTitle="DEX" />
      <Swap formSwap={formSwap} />
    </Web3Manager>
  );
};

export default SwapPage;
