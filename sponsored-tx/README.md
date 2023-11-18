# Sponsored TX via Shinami

To submit a sponsored transaction, the sender has to build a TransactionBlock and then send it to a sponsor (Shinami in our example).
The sponsor will attach a GasData object to the transaction, sign it, and return it to the user. The user then has to sign the transaction and submit it to the network.

## Make sure you have Node and Yarn installed

- [Node](https://nodejs.org/en/)

- [Yarn](https://yarnpkg.com/)

## Please install all project dependencies

```console
yarn install
```

## Create an Account on Shinami

For an in-depth walkthrough guide click [here](https://docs.shinami.com/docs/sponsored-transaction-typescript-tutorial-copy).

Below is a summary of the guide above.

1.  Create an account on [Shinami](https://www.shinami.com/)
2.  Create a Fund under Gas Station
3.  Send Sui to your Fund address
4.  Create an access key to your fund
5.  Create an access key to your node
6.  Make sure both the node and fund are under the same network (testnet or mainnet)
7.  Replace `<GAS_ACCESS_KEY>` with your Fund Key
8.  Replace `<NODE_ACCESS_KEY>` with your node Key
9.  Run `yarn start`
