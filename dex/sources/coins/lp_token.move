module dex::lp_token {
  use std::option;

  use sui::transfer;
  use sui::event::emit;
  use sui::object::{Self, UID};
  use sui::tx_context::{Self, TxContext};
  use sui::coin::{Self, Coin, TreasuryCap};

  friend dex::pool;

  // ** Structs

  struct LP_TOKEN has drop {}

  struct LPTokenStorage has key {
    id: UID,
    treasury_cap: TreasuryCap<LP_TOKEN>
  }

  // ** Events

  struct Mint has copy, drop {
    amount: u64,
    user: address
  }

  fun init(witness: LP_TOKEN, ctx: &mut TxContext) {
      let (treasury_cap, metadata) = coin::create_currency<LP_TOKEN>(
            witness, 
            9, 
            b"LP-ETH-USDC",
            b"LPCoin", 
            b"An LP Token for the ETH/USDC pool", 
            option::none(), 
            ctx
        );

      transfer::share_object(
        LPTokenStorage {
          id: object::new(ctx),
          treasury_cap
        }
      );

      transfer::public_share_object(metadata);
  }

  public(friend) fun mint(storage: &mut LPTokenStorage, value: u64, ctx: &mut TxContext): Coin<LP_TOKEN> {
    // We emit a Mint Event
    emit(Mint { amount: value, user: tx_context::sender(ctx) });
    // We mint the coin
    coin::mint(&mut storage.treasury_cap, value, ctx)
  }

  public fun total_supply(storage: &LPTokenStorage): u64 {
    coin::total_supply(&storage.treasury_cap)
  }

  // ** Test Functions

  #[test_only]
  public fun init_for_testing(ctx: &mut TxContext) {
    init(LP_TOKEN {}, ctx);
  }
}