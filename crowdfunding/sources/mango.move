module crowdfunding::mango {
  use std::option;

  use sui::transfer;
  use sui::event::emit;
  use sui::object::{Self, UID};
  use sui::tx_context::{Self, TxContext};
  use sui::coin::{Self, Coin, TreasuryCap};

  friend crowdfunding::faucet;

  // ** Structs

  struct MANGO has drop {}

  struct MangoStorage has key {
    id: UID,
    treasury_cap: TreasuryCap<MANGO>
  }

  // ** Events

  struct Mint has copy, drop {
    amount: u64,
    user: address
  }

  fun init(witness: MANGO, ctx: &mut TxContext) {
      let (treasury_cap, metadata) = coin::create_currency<MANGO>(
            witness, 
            9, 
            b"MANGO",
            b"Mango Coin", 
            b"Crowdfunding Coin", 
            option::none(), 
            ctx
        );

      transfer::share_object(
        MangoStorage {
          id: object::new(ctx),
          treasury_cap
        }
      );

      // Objects defined in different modules need to use the public_ transfer functions
      transfer::public_share_object(metadata);
  }

  public(friend) fun mint(storage: &mut MangoStorage, value: u64, ctx: &mut TxContext): Coin<MANGO> {
    // We emit a Mint Event
    emit(Mint { amount: value, user: tx_context::sender(ctx) });
    // We mint the coin
    coin::mint(&mut storage.treasury_cap, value, ctx)
  }

  public fun total_supply(storage: &MangoStorage): u64 {
    coin::total_supply(&storage.treasury_cap)
  }

  // ** Test Functions

  #[test_only]
  public fun init_for_testing(ctx: &mut TxContext) {
    init(MANGO {}, ctx);
  }
}