module dex::usdc {
  use std::option;

  use sui::url;
  use sui::transfer;
  use sui::event::emit;
  use sui::object::{Self, UID};
  use sui::tx_context::{Self, TxContext};
  use sui::coin::{Self, Coin, TreasuryCap};

  // Only the Faucet and Pool modules can call mint
  friend dex::faucet;
  friend dex::pool;

  // ** Structs

  // One Time Witness to create a Current in Sui
  // This struct has the drop ability so it cannot be transferred nor stored. 
  // It allows the Network to know it is a unique type
  struct USDC has drop {}

  // Objects with the Key ability can be Shared with the entire network, and sent to any address but need a custom transfer function
  // We will share this object to wrap the TreasuryCap because it is needed to mint coins
  struct USDCStorage has key {
    id: UID,
    treasury_cap: TreasuryCap<USDC>
  }

  // ** Events

  // Events are Objects with Copy and Drop 
  struct Mint has copy, drop {
    amount: u64,
    user: address
  }

  // The init function runs once on Module creation and accepts a one-time witness as the first argument
  // Witness is a struct with 1 ability, drop, it guarantees that there is only one in the entire network as you can only get it in the init function
  fun init(witness: USDC, ctx: &mut TxContext) {
      // We call the create_currency
      // Creating a currency requires a one-time witness to ensure it is a unique coin
      // Only the holder of the TreasuryCap is allowed to mint and burn this coin
      // Metadata holds all the information about the coin, so other applications query it
      let (treasury_cap, metadata) = coin::create_currency<USDC>(
            witness, // One time witness
            6, // Decimals of the coin
            b"USDC", // Symbol of the coin
            b"USDC Coin", // Name of the coin
            b"A stable coin issued by Circle", // Description of the coin
            option::some(url::new_unsafe_from_bytes(b"https://s3.coinmarketcap.com/static-gravity/image/5a8229787b5e4c809b5914eef709b59a.png")), // An image of the Coin
            ctx
        );

      // We Wrap the TreasuryCap inside The USDCStorage and share it with the entire Network
      // Object properties can only be accessed by the module that creates it. Therefore, no one can access the treasury_cap because it is inside USDCStorage
      // The USDCStorage object can be passed an argument to any function because it is shared
      transfer::share_object(
        USDCStorage {
          id: object::new(ctx),
          treasury_cap
        }
      );

      // We also share the Metadata with the entire network as anyone should be able to query information about the Coin
      transfer::public_share_object(metadata);
  }

  /**
  * @dev This function can only be called by friend modules
  * @param storage The USDCStorage
  * @param value The amount of USDC to mint
  * @return Coin<USDC> New created USDC coin
  */
  public(friend) fun mint(storage: &mut USDCStorage, value: u64, ctx: &mut TxContext): Coin<USDC> {
    // We emit a Mint Event
    emit(Mint { amount: value, user: tx_context::sender(ctx) });
    // We mint the coin
    coin::mint(&mut storage.treasury_cap, value, ctx)
  }

  /**
  * It allows anyone to know the total value in existence of USDC
  * @storage The shared USDCollarStorage
  * @return u64 The total value of USDC in existence
  */
  public fun total_supply(storage: &USDCStorage): u64 {
    coin::total_supply(&storage.treasury_cap)
  }

  // ** Test Functions

  #[test_only]
  public fun init_for_testing(ctx: &mut TxContext) {
    init(USDC {}, ctx);
  }
}