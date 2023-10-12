module dex::eth {
  use std::option;

  use sui::url;
  use sui::transfer;
  use sui::event::emit;
  use sui::object::{Self, UID};
  use sui::tx_context::{Self, TxContext};
  use sui::coin::{Self, Coin, TreasuryCap};

  friend dex::faucet;
  friend dex::pool;

  // ** Structs

  struct ETH has drop {}

  struct ETHStorage has key {
    id: UID,
    treasury_cap: TreasuryCap<ETH>
  }

  // ** Events

  struct Mint has copy, drop {
    amount: u64,
    user: address
  }

  fun init(witness: ETH, ctx: &mut TxContext) {
      let (treasury_cap, metadata) = coin::create_currency<ETH>(
            witness, 
            9, 
            b"ETH",
            b"ETH Coin", 
            b"Ethereum Native Coin", 
            option::some(url::new_unsafe_from_bytes(b"https://s2.coinmarketcap.com/static/img/coins/64x64/1027.png")), 
            ctx
        );

      transfer::share_object(
        ETHStorage {
          id: object::new(ctx),
          treasury_cap
        }
      );

      // Objects defined in different modules need to use the public_ transfer functions
      transfer::public_share_object(metadata);
  }

  public(friend) fun mint(storage: &mut ETHStorage, value: u64, ctx: &mut TxContext): Coin<ETH> {
    // We emit a Mint Event
    emit(Mint { amount: value, user: tx_context::sender(ctx) });
    // We mint the coin
    coin::mint(&mut storage.treasury_cap, value, ctx)
  }

  public fun total_supply(storage: &ETHStorage): u64 {
    coin::total_supply(&storage.treasury_cap)
  }

  // ** Test Functions

  #[test_only]
  public fun init_for_testing(ctx: &mut TxContext) {
    init(ETH {}, ctx);
  }
}