# DEX

## Dependencies

- [Sui](https://docs.sui.io/guides/developer/getting-started/sui-install)
- [Node](https://nodejs.org/en/)
- [Yarn](https://yarnpkg.com/)

## Directories

- [**contracts**](./contracts) contain the Move code
- [**interface**](./interface) contain the frontend code

## Contracts

The contracts used by the front end have been deployed to the testnet because creating a Pool on DeepBook costs 100 Sui.
It would be impractical to get 100 Sui every time the Devnet got wiped out.

#### Check active address

```console
sui client active-address
```

#### Check active environment

```console
sui client active-env
```

#### Switch to Testnet

```console
sui client switch --env testnet
```

#### Get Testnet Sui

```console
curl --location --request POST 'https://faucet.testnet.sui.io/gas' \
--header 'Content-Type: application/json' \
--data-raw '{
    "FixedAmountRequest": {
        "recipient": "<YOUR SUI ADDRESS>"
    }
}'
```

#### Run the tests

```console
sui move test
```

#### Publish

```console
sui move publish --gas-budget 50000000
```

## Interface

#### Get the OpenId providers client IDs

[Click here for a walkthrough](https://docs.sui.io/concepts/cryptography/zklogin#google)

#### Deploy your ZkLogin Prover on Digital Ocean

[Click here for a walkthrough](https://github.com/interest-protocol/zk-login-prover)

#### Add env variables to .env.local file

```
NEXT_PUBLIC_CLIENT_ID_GOOGLE=YOUR_GOOGLE_CLIENT_ID

NEXT_PUBLIC_CLIENT_ID_TWITCH=YOUR_TWITCH_CLIENT_ID

NEXT_PUBLIC_CLIENT_ID_FACEBOOK=YOUR_FACEBOOK_CLIENT_ID

URL_ZK_PROVER=http://YOUR_ZK_LOGIN_PROVER_IP/v1
```

#### Run the frontend

```console
# Install dependencies
yarn install
# Run the frontend locally
yarn dev
```
