import { Ed25519Keypair } from '@mysten/sui.js/keypairs/ed25519';
import { SuiClient } from '@mysten/sui.js/client';
import { TransactionBlock } from '@mysten/sui.js/transactions';
import { rpcClient } from 'typed-rpc';

// Setup for issuing json rpc calls to the gas station for sponsorship.
interface SponsoredTransaction {
  txBytes: string;
  txDigest: string;
  signature: string;
  expireAtTime: number;
  expireAfterEpoch: number;
}
type SponsoredTransactionStatus = 'IN_FLIGHT' | 'COMPLETE' | 'INVALID';

interface SponsorRpc {
  gas_sponsorTransactionBlock(
    txBytes: string,
    sender: string,
    gasBudget: number
  ): SponsoredTransaction;
  gas_getSponsoredTransactionBlockStatus(
    txDigest: string
  ): SponsoredTransactionStatus;
}

// Shinami Gas Station endpoint:
// It will pay for the gas
const SPONSOR_RPC_URL = 'https://api.shinami.com/gas/v1/<GAS_ACCESS_KEY>';

// Create provider
const suiClient = new SuiClient({
  url: 'https://api.shinami.com/node/v1/<NODE_ACCESS_KEY>',
});

const start = async () => {
  // gas budget for our transactions, in MIST
  const GAS_BUDGET = 5000000;

  // random Keypair
  const keypair = new Ed25519Keypair();

  const sponsor = rpcClient<SponsorRpc>(SPONSOR_RPC_URL);

  // Start a Transaction Block
  const txb = new TransactionBlock();

  // Add some Transactions
  // *** Add random Transactions

  // Build the transaction
  const bytes = await txb.build({
    client: suiClient,
    onlyTransactionKind: true,
  });

  const gaslessPayloadBase64 = btoa(
    bytes.reduce((data, byte) => data + String.fromCharCode(byte), '')
  );

  const sponsoredResponse = await sponsor.gas_sponsorTransactionBlock(
    gaslessPayloadBase64,
    keypair.getPublicKey().toSuiAddress(),
    GAS_BUDGET
  );

  // The transaction should be sponsored now, so its status will be "IN_FLIGHT"
  const sponsoredStatus = await sponsor.gas_getSponsoredTransactionBlockStatus(
    sponsoredResponse.txDigest
  );
  console.log('Sponsorship Status:', sponsoredStatus);

  const { signature, bytes: transactionBlock } =
    await keypair.signTransactionBlock(
      await TransactionBlock.from(sponsoredResponse.txBytes).build({
        client: suiClient,
      })
    );

  const executeResponse = await suiClient.executeTransactionBlock({
    signature,
    transactionBlock,
  });

  console.log('Execution Status:', executeResponse.effects?.status.status);
};

start().then().catch(console.warn);
