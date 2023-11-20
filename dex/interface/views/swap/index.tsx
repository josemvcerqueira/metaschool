import { Box, InfoCard, Typography } from '@interest-protocol/ui-kit';
import { SUI_TYPE_ARG } from '@mysten/sui.js/utils';
import { FC } from 'react';
// import { useWatch } from 'react-hook-form';
import { v4 } from 'uuid';

import ZKLogin from '@/components/zk-login';
import {
  COIN_TYPE_TO_SYMBOL,
  DEX_COIN_TYPE,
  ETH_TYPE,
  USDC_TYPE,
} from '@/constants';
import { useWeb3 } from '@/hooks';
import { useDexUserInfo } from '@/hooks/use-dex-user-info';
import { FixedPointMath } from '@/lib';
import { ZERO_BIG_NUMBER } from '@/utils';

import MintButtons from './faucet';
import Orderbook from './orderbook';
import {
  SwapBodyProps,
  // SwapManagerWrapperProps,
  SwapProps,
} from './swap.types';
import SwapForm from './swap-form';
// import SwapManager from './swap-manager';

// const SwapManagerWrapper: FC<SwapManagerWrapperProps> = ({ formSwap }) => {
//   const tokenInType = useWatch({
//     control: formSwap.control,
//     name: 'from.type',
//   });

//   const tokenOutType = useWatch({
//     control: formSwap.control,
//     name: 'to.type',
//   });

//   return (
//     <SwapManager
//       formSwap={formSwap}
//       tokenInType={tokenInType}
//       tokenOutType={tokenOutType}
//     />
//   );
// };

const SwapFormBody: FC<SwapBodyProps> = ({ formSwap }) => {
  return (
    <>
      <SwapForm formSwap={formSwap} />
      {/*<SwapManagerWrapper formSwap={formSwap} />*/}
    </>
  );
};

const Swap: FC<SwapProps> = (props) => {
  const { coinsMap, account } = useWeb3();

  const userInfo = useDexUserInfo();

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
          <MintButtons
            lastETHEpoch={userInfo.lastETHEpoch}
            lastUSDCEpoch={userInfo.lastUSDCEpoch}
          />
          <ZKLogin />
        </Box>
        {account ? (
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
              {userInfo?.swapCount || '0'}
            </InfoCard>
            {[ETH_TYPE, USDC_TYPE, DEX_COIN_TYPE].map((type) => (
              <InfoCard
                key={v4()}
                info={null}
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
            <InfoCard
              info={
                <Typography variant="small" my="2xs">
                  Balance
                </Typography>
              }
              title={<Typography variant="medium">SUI</Typography>}
            >
              {FixedPointMath.from(
                coinsMap[SUI_TYPE_ARG]?.totalBalance ?? ZERO_BIG_NUMBER
              ).toNumber()}
            </InfoCard>
          </Box>
        ) : null}
        <Typography
          mt="xl"
          pt="xl"
          color="onSurface"
          textAlign="center"
          variant="displayLarge"
        >
          SWAP
        </Typography>
        <Box display="flex" color="onSurface" gap="4xl" alignItems="flex-start">
          <SwapFormBody {...props} />
          <Orderbook />
        </Box>
      </Box>
    </Box>
  );
};

export default Swap;
