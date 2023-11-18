import { Button } from '@interest-protocol/ui-kit';
import { getFaucetHost, requestSuiFromFaucetV1 } from '@mysten/sui.js/faucet';
import { propOr } from 'ramda';
import { FC } from 'react';
import toast from 'react-hot-toast';

import { ETH_TYPE, USDC_TYPE } from '@/constants';
import { useWeb3 } from '@/hooks';

const MintButtons: FC = () => {
  const { account } = useWeb3();

  const handleOnMint = async (type: string) => {
    // try {
    //   const objects = OBJECT_RECORD[network];
    //
    //   if (!type) throw new Error('Token not found');
    //
    //   const transactionBlock = new TransactionBlock();
    //
    //   transactionBlock.moveCall({
    //     target: `${objects.FAUCET_PACKAGE_ID}::${COIN_TYPE_TO_CORE_NAME[network][type]}::get`,
    //     arguments: [
    //       transactionBlock.object(COIN_TYPE_TO_STORAGE[network][type]),
    //       transactionBlock.pure(pathOr('1', [network, type], COIN_MINT_AMOUNT)),
    //     ],
    //   });
    //
    //   const { transactionBlockBytes, signature } = await signTransactionBlock({
    //     transactionBlock,
    //   });
    //
    //   const tx = await provider.executeTransactionBlock({
    //     transactionBlock: transactionBlockBytes,
    //     signature,
    //     options: {
    //       showEffects: true,
    //       showEvents: false,
    //       showInput: false,
    //       showBalanceChanges: false,
    //       showObjectChanges: false,
    //     },
    //   });
    //
    //   throwTXIfNotSuccessful(tx);
    //   showTXSuccessToast(tx, network);
    // } finally {
    //   await mutate();
    // }
  };

  const onMint = (type: string) =>
    toast.promise(handleOnMint(type), {
      loading: 'Minting...',
      success: 'Token minted successfully!',
      error: (error) => {
        console.log('>> error :: ', error);

        return propOr('Something went wrong on mint token', 'message', error);
      },
    });

  const handleOnFaucetSUI = async () => {
    if (account)
      await requestSuiFromFaucetV1({
        host: getFaucetHost('devnet'),
        recipient: account.userAddr,
      });
  };

  const onFaucetSUI = () =>
    toast.promise(handleOnFaucetSUI(), {
      loading: 'Minting SUI',
      success: 'SUI minted successfully!',
      error: (error) => {
        console.log('>> error :: ', error);

        return propOr('Something went wrong on mint SUI', 'message', error);
      },
    });

  if (!account) return null;

  return (
    <>
      <Button size="small" variant="filled" onClick={() => onMint(ETH_TYPE)}>
        Mint ETH
      </Button>
      <Button size="small" variant="filled" onClick={() => onMint(USDC_TYPE)}>
        Mint USDC
      </Button>
      <Button size="small" variant="filled" onClick={onFaucetSUI}>
        Mint SUI
      </Button>
    </>
  );
};
export default MintButtons;
