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

// Shinami Gas Station Fund endpoint:
// It will pay for the gas
const SPONSOR_RPC_URL = 'https://api.shinami.com/gas/v1/<GAS_ACCESS_KEY>';
const sponsor = rpcClient<SponsorRpc>(SPONSOR_RPC_URL);

// Create Sui Client provider
const suiClient = new SuiClient({
  url: 'https://api.shinami.com/node/v1/<NODE_ACCESS_KEY>',
});

const start = async () => {
  // gas budget for our transactions, in MIST
  const GAS_BUDGET = 5000000;

  // Random Keypair for the sender
  const keypair = new Ed25519Keypair();

  // Start a Transaction Block
  const txb = new TransactionBlock();

  // Add some Transactions
  // *** Add random Transactions

  // Build the transaction
  const bytes = await txb.build({
    client: suiClient,
    onlyTransactionKind: true,
  });

  // Convert the byte array to a base64 encoded string
  const gaslessPayloadBase64 = btoa(
    bytes.reduce((data, byte) => data + String.fromCharCode(byte), '')
  );

  // Send the gasless programmable payload to Shinami Gas Station for sponsorship, along with the sender and budget
  // The sponsor will attach a GasData object to the transaction and sign it.
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

  // The user will sign the transaction returned from the sponsor, which has a GasData object now
  const { signature: senderSignature } = await keypair.signTransactionBlock(
    await TransactionBlock.from(sponsoredResponse.txBytes).build()
  );

  // The user will submit the transaction to Sui Network with both signatures
  const executeResponse = await suiClient.executeTransactionBlock({
    signature: [sponsoredResponse.signature, senderSignature],
    transactionBlock: sponsoredResponse.txBytes,
    options: {
      showEffects: true,
    },
  });

  console.log('Execution Status:', executeResponse.effects?.status.status);
};

start().then().catch(console.warn);
