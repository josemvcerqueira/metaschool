import { Box, InfoCard, Typography } from '@interest-protocol/ui-kit';
import { FC } from 'react';
import { useWatch } from 'react-hook-form';
import { mutate } from 'swr';
import { v4 } from 'uuid';

import ZKLogin from '@/components/zk-login';
import { COIN_TYPE_TO_SYMBOL, ETH_TYPE, USDC_TYPE } from '@/constants';
import { useWeb3 } from '@/hooks';
import { FixedPointMath } from '@/lib';
import { ZERO_BIG_NUMBER } from '@/utils';

import MintButtons from './faucet';
import Orderbook from './orderbook';
import {
  SwapBodyProps,
  SwapManagerWrapperProps,
  SwapProps,
} from './swap.types';
import SwapForm from './swap-form';
import SwapManager from './swap-manager';

const SwapManagerWrapper: FC<SwapManagerWrapperProps> = ({ formSwap }) => {
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
      tokenInType={tokenInType}
      tokenOutType={tokenOutType}
    />
  );
};

const SwapFormBody: FC<SwapBodyProps> = ({ formSwap }) => {
  return (
    <>
      {/*<SwapForm mutate={mutate} formSwap={formSwap} />*/}
      {/*<SwapManagerWrapper formSwap={formSwap} />*/}
    </>
  );
};

const Swap: FC<SwapProps> = (props) => {
  const { coinsMap } = useWeb3();

  return (
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
          <ZKLogin />
        </Box>
        <Box display="flex" gap="m" mt="2xl">
          <InfoCard
            info={
              <Typography variant="small" my="2xs">
                DEX Swaps
              </Typography>
            }
            title={
              <Typography variant="medium" fontSize="2rem">
                ⇋
              </Typography>
            }
          >
            10
          </InfoCard>
          {[ETH_TYPE, USDC_TYPE].map((type) => (
            <InfoCard
              key={v4()}
              info={
                <Typography variant="small" my="2xs">
                  DEX Tokens
                </Typography>
              }
              title={
                <Typography variant="medium">
                  {COIN_TYPE_TO_SYMBOL[network][type]}
                </Typography>
              }
            >
              {Number((Math.random() * 1000).toFixed(6)).toPrecision()}
            </InfoCard>
          ))}
          {COINS_TYPE[network].map((type) => (
            <InfoCard
              key={v4()}
              info={
                <Typography variant="small" my="2xs">
                  Balance
                </Typography>
              }
              title={
                <Typography variant="medium">
                  {COIN_TYPE_TO_SYMBOL[type]}
                </Typography>
              }
            >
              {FixedPointMath.from(
                coinsMap[type]?.totalBalance ?? ZERO_BIG_NUMBER
              ).toNumber()}
            </InfoCard>
          ))}
        </Box>
        <Typography
          mt="xl"
          pt="xl"
          color="onSurface"
          textAlign="center"
          variant="displayLarge"
        >
          SWAP
        </Typography>
        {/*<Box display="flex" color="onSurface" gap="4xl" alignItems="flex-start">*/}
        {/*  <SwapFormBody {...props} />*/}
        {/*  <Orderbook />*/}
        {/*</Box>*/}
      </Box>
    </Box>
  );
};

export default Swap;
