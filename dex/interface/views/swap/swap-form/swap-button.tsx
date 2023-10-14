import { Button, ProgressIndicator } from '@interest-protocol/ui-kit';
import { TransactionBlock } from '@mysten/sui.js';
import { useWalletKit } from '@mysten/wallet-kit';
import BigNumber from 'bignumber.js';
import { path, pathOr } from 'ramda';
import { FC, useState } from 'react';
import { useWatch } from 'react-hook-form';
import toast from 'react-hot-toast';

import { useAmmSdk, useNetwork, useProvider, useWeb3 } from '@/hooks';
import { FixedPointMath } from '@/lib';
import {
  createObjectsParameter,
  showTXSuccessToast,
  throwTXIfNotSuccessful,
  ZERO_BIG_NUMBER,
} from '@/utils';

import { getAmountMinusSlippage } from '../swap.utils';
import { SwapFormButtonProps } from './swap-form.types';
import { getError } from './swap-form.utils';

const SwapFormButton: FC<SwapFormButtonProps> = ({
  formSwap,
  dexMarket,
  mutate,
}) => {
  const formValues = useWatch({ control: formSwap.control });

  const isDisabled =
    !path(['to', 'type'], formValues) ||
    !path(['from', 'type'], formValues) ||
    !+pathOr(0, ['to', 'value'], formValues) ||
    !+pathOr(0, ['from', 'value'], formValues) ||
    formValues.disabled;

  const sdk = useAmmSdk();
  const { account, coinsMap } = useWeb3();
  const { network } = useNetwork();
  const { provider } = useProvider();
  const [loading, setLoading] = useState(false);
  const { signTransactionBlock } = useWalletKit();

  const tokenIn = formSwap.getValues('from');
  const tokenOut = formSwap.getValues('to');

  const resetInput = () => {
    formSwap.setValue('to.value', '0');
    formSwap.setValue('disabled', true);
    formSwap.setValue('from.value', '0');
  };

  const handleSwap = async () => {
    try {
      setLoading(true);

      const slippage = '0.1';
      const deadline = '10';

      if (!tokenIn.type || !tokenOut.type)
        throw new Error(getError('select2Tokens'));

      if (!account) throw new Error(getError('accountNotFound'));

      if (!+tokenIn.value) throw new Error(getError('cannotSell0'));

      const isMaxTrade = formSwap.getValues('maxValue');

      const amount = isMaxTrade
        ? coinsMap[tokenIn.type]?.totalBalance ?? ZERO_BIG_NUMBER
        : FixedPointMath.toBigNumber(
            tokenIn.value,
            tokenIn.decimals
          ).decimalPlaces(0, BigNumber.ROUND_DOWN);

      const amountOut = FixedPointMath.toBigNumber(
        tokenOut.value,
        tokenOut.decimals
      ).decimalPlaces(0, BigNumber.ROUND_DOWN);

      const minAmountOut = getAmountMinusSlippage(amountOut, slippage);

      const txb = new TransactionBlock();

      const coinInList = createObjectsParameter({
        coinsMap,
        txb,
        type: tokenIn.type,
        amount: amount.toString(),
      });

      const swapTxB = await sdk.swap({
        txb,
        coinInList,
        coinInAmount: amount.toString(),
        coinInType: tokenIn.type,
        coinOutType: tokenOut.type,
        coinOutMinimumAmount: minAmountOut.toString(),
        deadline: deadline,
        dexMarkets: dexMarket,
      });

      const { signature, transactionBlockBytes } = await signTransactionBlock({
        transactionBlock: swapTxB,
      });

      const tx = await provider.executeTransactionBlock({
        transactionBlock: transactionBlockBytes,
        signature,
        options: { showEffects: true },
        requestType: 'WaitForEffectsCert',
      });

      throwTXIfNotSuccessful(tx);

      await showTXSuccessToast(tx, network);
    } finally {
      resetInput();
      setLoading(false);
      await mutate();
    }
  };

  const onSwap = () =>
    toast.promise(handleSwap(), {
      loading: 'Swapping...',
      success: 'Swap was successfully!',
      error: (error) => error,
    });

  return (
    <Button
      mx="auto"
      size="small"
      variant="filled"
      disabled={isDisabled}
      boxSizing="border-box"
      justifyContent="center"
      mt={['4xl', '4xl', '2xl']}
      width={['100%', '100%', 'auto']}
      onClick={isDisabled ? undefined : onSwap}
      PrefixIcon={
        loading ? <ProgressIndicator variant="loading" size={16} /> : null
      }
    >
      {loading ? 'Swapping...' : 'Swap'}
    </Button>
  );
};

export default SwapFormButton;
