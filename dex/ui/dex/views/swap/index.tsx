import { Box, Typography } from '@interest-protocol/ui-kit';
import { FC } from 'react';
import { useWatch } from 'react-hook-form';
import { mutate } from 'swr';

import Wallet from '@/components/wallet';

import MintButtons from './faucet';
import { useGetDexMarkets } from './swap.hooks';
import {
  SwapBodyProps,
  SwapManagerWrapperProps,
  SwapProps,
} from './swap.types';
import SwapForm from './swap-form';
import SwapManager from './swap-manager';

const SwapManagerWrapper: FC<SwapManagerWrapperProps> = ({
  formSwap,
  dexMarket,
}) => {
  const tokenInType = useWatch({
    control: formSwap.control,
    name: 'from.type',
  });

  const tokenOutType = useWatch({
    control: formSwap.control,
    name: 'to.type',
  });

  return (
    <SwapManager
      formSwap={formSwap}
      dexMarket={dexMarket}
      tokenInType={tokenInType}
      tokenOutType={tokenOutType}
    />
  );
};

const SwapFormBody: FC<SwapBodyProps> = ({ formSwap }) => {
  const { data, isLoading } = useGetDexMarkets();

  return (
    <>
      <SwapForm
        mutate={mutate}
        formSwap={formSwap}
        isLoading={isLoading}
        dexMarket={data || {}}
      />
      <SwapManagerWrapper formSwap={formSwap} dexMarket={data || {}} />
    </>
  );
};

const Swap: FC<SwapProps> = (props) => (
  <Box bg="surface" minHeight="100vh" display="flex">
    <Box
      width="100%"
      display="flex"
      variant="container"
      alignItems="center"
      justifyItems="unset"
      flexDirection="column"
      justifyContent={['space-between', 'space-between', 'unset']}
    >
      <Box display="flex" justifyContent="flex-end" width="100%" gap="l">
        <MintButtons />
        <Wallet />
      </Box>
      <Typography variant="displayLarge" color="onSurface" mt="4xl" pt="4xl">
        SWAP
      </Typography>
      <SwapFormBody {...props} />
    </Box>
  </Box>
);

export default Swap;
