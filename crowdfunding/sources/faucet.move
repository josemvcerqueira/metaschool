module crowdfunding::faucet {

  use sui::coin::Coin;
  use sui::tx_context::TxContext;

  use crowdfunding::mango::{Self, MANGO, MangoStorage};

  const MANGO_MINT_AMOUNT: u64 = 10000000000; // 10e9 - it is 10 MANGO

  public fun mint(storage: &mut MangoStorage, ctx: &mut TxContext): Coin<MANGO> {
    mango::mint(storage, MANGO_MINT_AMOUNT, ctx)
  }  
}