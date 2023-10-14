import { Network } from '@interest-protocol/sui-amm-sdk';
import useSWR from 'swr';

import { useNetwork } from '@/hooks';
import { makeSWRKey } from '@/utils';

export const useGetDexMarkets = () => {
  const { network } = useNetwork();

  return useSWR(
    makeSWRKey([network], getDexMarket.name),
    async () => getDexMarket(network),
    {
      revalidateOnFocus: false,
      revalidateOnMount: true,
      refreshWhenHidden: false,
    }
  );
};

// TODO: get hard-coded market
// eslint-disable-next-line @typescript-eslint/no-unused-vars
function getDexMarket(network: Network): any {
  throw new Error('Function not implemented.');
}
