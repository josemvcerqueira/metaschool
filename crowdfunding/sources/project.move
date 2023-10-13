module crowdfunding::project {

  use sui::event::emit;
  use sui::transfer;
  use sui::coin::{Self, Coin};
  use sui::clock::{Self, Clock};
  use sui::vec_map::{Self, VecMap};
  use sui::object::{Self, UID, ID};
  use sui::balance::{Self, Balance};
  use sui::tx_context::{Self, TxContext};

  use crowdfunding::mango::MANGO;

  const FIFTEN_DAYS: u64 = 1296000000; // in Milliseconds

  const EInvalidValue: u64 = 0;
  const EInvalidOwner: u64 = 1;
  const EOutdated: u64 = 2;
  const EFailedToRaise: u64 = 3;
  const EInvalidOperation: u64 = 4;

  struct Project has key {
    id: UID,
    mango_balance: Balance<MANGO>,
    user_map: VecMap<address, u64>,
    target: u64,
    owner: address,
    start_time: u64
  }

  // Events

  struct ProjectCreated has copy, drop {
    project_id: ID,
    target: u64,
    owner: address,
    start_time: u64
  }

  struct FundProject has copy, drop {
    project_id: ID,
    sender: address,
    amount: u64
  }

  struct OwnerWithdraw has copy, drop {
    project_id: ID,
    owner: address,
    amount: u64    
  }

  struct UserWithdraw has copy, drop {
    project_id: ID,
    sender: address,
    amount: u64    
  }
  
  /*
  * @dev it allows a user to create a project
  * @param c The Clock shared object so we can know the time on chian
  * @param target The amount of Mango Tokens the user wishes to raise
  */
  public fun create_project(c: &Clock, target: u64, ctx: &mut TxContext) {
    // get the time on chain in milliseconds
    let start_time = clock::timestamp_ms(c);
    // We get the sender of the transaction
    let owner = tx_context::sender(ctx);
    // We create a unique ID
    let id = object::new(ctx);

    // Emit the event
    emit(ProjectCreated { project_id: *object::uid_as_inner(&id), start_time, owner, target });

    // We need to share the project so users can contribute to it
    transfer::share_object(Project { 
      id, 
      mango_balance: balance::zero(), // To store the raised funds
      user_map: vec_map::empty(), // We will save how much each user has contributed so in case of failure, we can reutrn their tokens
      target, // Amount that this project wishes to raise
      owner, // Owner of the project
      start_time // The time that this project was created
    });
  }

  public fun fund(project: &mut Project, token: Coin<MANGO>, c: &Clock, ctx: &mut TxContext) {
    // It does not make sense to fund 0 tokens
    // So we throw an error
    let token_amount = coin::value(&token);
    assert!(token_amount != 0, EInvalidValue);
    // You cannot fund the project if it has been over 15 days since it's creation period
    assert!(project.start_time + FIFTEN_DAYS >= clock::timestamp_ms(c), EOutdated);

    // Deposit the Mango Token in the project
    balance::join(&mut project.mango_balance, coin::into_balance(token));
    
    let sender = tx_context::sender(ctx);
    // We check if the user has deposited in the past
    if (vec_map::contains(&project.user_map, &sender)) {
      // if the user has deposited we need to update his account
      // We get a mutable reference of his current deposit
      let value = vec_map::get_mut(&mut project.user_map, &sender);
      // We update it
      *value = *value + token_amount;
    } else {
      // If it is the first deposit, wejust register the token_amount
      vec_map::insert(&mut project.user_map, sender, token_amount);
    };

    emit(FundProject { project_id: object::id(project), amount: token_amount, sender });
  }

  public fun owner_withdraw(project: &mut Project, c: &Clock, ctx: &mut TxContext): Coin<MANGO> {
    // We make sure that it has been 15 days after the creation of the project and it raised more than the target amount
    let value = balance::value(&project.mango_balance);
    assert!(clock::timestamp_ms(c) > project.start_time + FIFTEN_DAYS && value >= project.target, EFailedToRaise);
    // We make sure that only the owner can withdraw the funds
    let sender = tx_context::sender(ctx);
    assert!(sender == project.owner, EInvalidOwner);

    emit(OwnerWithdraw { project_id: object::id(project), amount: value, owner: sender });

    // Take the Coin from the project and return to the caller
    coin::take(&mut project.mango_balance, value, ctx)
  }

  public fun user_withdraw(project: &mut Project, c: &Clock, ctx: &mut TxContext): Coin<MANGO> {
    // We make sure that it has been 15 days after the creation of the project and the project did not raise enough
    let value = balance::value(&project.mango_balance);
    assert!(clock::timestamp_ms(c) > project.start_time + FIFTEN_DAYS && project.target > value, EFailedToRaise);

    let sender = tx_context::sender(ctx);
    // If the user never deposited, he cannot withdraw so we throw an error
    assert!(vec_map::contains(&project.user_map, &sender), EInvalidOperation);

    // We remove the entry of the user from the user_map
    // So if he tries to withdraw again, the entry will not exist
    let (_, value) = vec_map::remove(&mut project.user_map, &sender);

    emit(UserWithdraw { project_id: object::id(project), amount: value, sender });

    // Take the Coin from the project and return to the caller
    coin::take(&mut project.mango_balance, value, ctx)    
  }
}