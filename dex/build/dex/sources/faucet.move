module dex::faucet {

  use sui::coin::Coin;
  use sui::tx_context::TxContext;

  use dex::eth::{Self, ETHStorage, ETH};
  use dex::usdc::{Self, USDCStorage, USDC};

  const ETH_MINT_AMOUNT: u64 = 1000000000; // 1e9 - it is 1 ETH
  const USDC_MINT_AMOUNT: u64 = 1800000000; // 1800e6- it is 1800 USDC

  // @dev This are utility functions so users can mint coins to swap

  /*
  * @storage We pass a mutable reference of the Shared Object. It is a shared object so anyone poss to the function. The Mut keyword means that it can be mutated.  
  * @ctx It is automatically passed as the last argument to all Sui functions. Tt contains metadta about the current Chain/TX Status
  */
  public fun mint_usdc(storage: &mut USDCStorage, ctx: &mut TxContext): Coin<USDC> {
    usdc::mint(storage, USDC_MINT_AMOUNT, ctx)
  }

  public fun mint_eth(storage: &mut ETHStorage, ctx: &mut TxContext): Coin<ETH> {
    eth::mint(storage, ETH_MINT_AMOUNT, ctx)
  }
}