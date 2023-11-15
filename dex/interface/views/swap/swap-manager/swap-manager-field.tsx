import { BigNumber } from 'bignumber.js';
import { prop } from 'ramda';
import { FC, useEffect } from 'react';
import { useWatch } from 'react-hook-form';
import useSWR from 'swr';
import { useDebounce } from 'use-debounce';

import { useSuiClient } from '@/hooks';
import { FixedPointMath } from '@/lib';
import { makeSWRKey } from '@/utils';

import { SwapManagerProps } from './swap-manager.types';

const SwapManagerField: FC<SwapManagerProps> = ({
  type,
  name,
  control,
  account,
  setError,
  decimals,
  setValue,
  hasNoMarket,
  setSwapPath,
  setIsZeroSwapAmount,
  isFetchingSwapAmount,
  setIsFetchingSwapAmount,
  setValueName,
}) => {
  const provider = useSuiClient();
  const [tokenIn] = useDebounce(useWatch({ control, name }), 900);

  const lock = useWatch({ control, name: 'lock' });

  return null;
};

export default SwapManagerField;
