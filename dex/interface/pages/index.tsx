import { NextPage } from 'next';
import dynamic from 'next/dynamic';
import { useForm } from 'react-hook-form';

import { SEO } from '@/components';
import { ETH_TYPE, USDC_TYPE } from '@/constants';
import Swap from '@/views/swap';
import { SwapForm } from '@/views/swap/swap.types';

const Web3Manager = dynamic(() => import('@/components/web3-manager'), {
  ssr: false,
});

const SwapPage: NextPage = () => {
  const formSwap = useForm<SwapForm>({
    defaultValues: {
      from: {
        type: ETH_TYPE,
        decimals: 9,
        symbol: 'ETH',
        value: '0',
      },
      to: {
        type: USDC_TYPE,
        decimals: 9,
        symbol: 'USDC',
        value: '0',
      },
    },
  });

  return (
    <Web3Manager>
      <SEO />
      <Swap formSwap={formSwap} />
    </Web3Manager>
  );
};

export default SwapPage;
