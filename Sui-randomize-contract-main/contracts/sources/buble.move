module buble::buble {
  use sui::random::{Random, new_generator, generate_u8_in_range};
  use sui::coin::{into_balance, from_balance, Coin};
  use sui::balance::{Balance, split, join, withdraw_all};
  //Pool with 8 coins
  public struct GamePool<phantom T> has key {
    id: UID,
    pool: Balance<T>,
    min_betting: u64,
    max_betting: u64,
  }
  //Admin Ownership
  public struct AdminCap has key {
    id: UID,
  }

  fun init(ctx: &mut TxContext) {
    //create Admin Object
    let admin = AdminCap {
      id: object::new(ctx)
    };
    transfer::transfer(admin, ctx.sender());
  }

  //create Pool and make as shareObject
  entry fun create_pool<T>(
    _: &AdminCap,
    coin: Coin<T>,
    min_betting: u64,
    max_betting: u64,
    ctx: &mut TxContext
  ) {
    let pool = GamePool{
      id: object::new(ctx),
      pool: into_balance<T>(coin),
      min_betting,
      max_betting,
    };
    transfer::share_object(pool);
  }

  entry fun update_betting<T>(
    _: &AdminCap,
    pool: &mut GamePool<T>,
    min_betting: u64,
    max_betting: u64
  ) {
    pool.min_betting = min_betting;
    pool.max_betting = max_betting;
  }
  //deposits coin to POOL
  public entry fun deposit<T>(
    pool: &mut GamePool<T>,
    in: Coin<T>,
  ) {
      let in_balance = into_balance(in);
      join(&mut pool.pool, in_balance);
  }

  //Withdraw by admin
  public entry fun withdrawAll<T>(
    _: &AdminCap,
    pool: &mut GamePool<T>,
    ctx: &mut TxContext
  ) {
    let pool_balance = withdraw_all(&mut pool.pool);
    let coin = from_balance(pool_balance, ctx);
    transfer::public_transfer(coin, ctx.sender());
  }

  fun getRandomPoints(r: &Random, ctx: &mut TxContext): u8 {
    generate_u8_in_range(&mut new_generator(r, ctx), 0, 99)
  }
  //bet with coin0
  entry fun play<T> (
    game: &mut GamePool<T>,
		r: &Random,
    in: Coin<T>,
    ctx: &mut TxContext,
  ) {
    assert!(in.balance().value() >= game.min_betting, 0);
    assert!(in.balance().value() <= game.max_betting, 0);

    let points = getRandomPoints(r, ctx);
    let in_amount = in.value();
    let in_balance = into_balance(in);
		join(&mut game.pool, in_balance);

    if (points < 18) { //0x multiplier, 18 %
      return
    } else if (points < 33) { //0.2 multiplier 15%
      let to_balance = split(&mut game.pool, in_amount * 20 / 100);
      let coin = from_balance<T>(to_balance, ctx);
      transfer::public_transfer(coin, ctx.sender());
    } else if (points < 45) { //0.4 multiplier, 12%
      let to_balance = split(&mut game.pool, in_amount * 40 / 100);
      let coin = from_balance<T>(to_balance, ctx);
      transfer::public_transfer(coin, ctx.sender());
    } else if (points < 55) { //0.7 multiplier, 10%
      let to_balance = split(&mut game.pool, in_amount * 70 / 100);
      let coin = from_balance<T>(to_balance, ctx);
      transfer::public_transfer(coin, ctx.sender());
    } else if (points < 65) { //1 multiplier, 10%
      let to_balance = split(&mut game.pool, in_amount);
      let coin = from_balance<T>(to_balance, ctx);
      transfer::public_transfer(coin, ctx.sender());
    } else if (points < 75) { //1.3 multiplier, 10%
      let to_balance = split(&mut game.pool, in_amount * 130 / 100);
      let coin = from_balance<T>(to_balance, ctx);
      transfer::public_transfer(coin, ctx.sender());
    }else if (points < 83) { //1.6 multiplier, 8%
      let to_balance = split(&mut game.pool, in_amount * 160 / 100);
      let coin = from_balance<T>(to_balance, ctx);
      transfer::public_transfer(coin, ctx.sender());
    }else if (points < 90) { //1.8 multiplier, 7%
      let to_balance = split(&mut game.pool, in_amount * 180 / 100);
      let coin = from_balance<T>(to_balance, ctx);
      transfer::public_transfer(coin, ctx.sender());
    }else if (points < 100) { //2 multiplier, 10%
      let to_balance = split(&mut game.pool, in_amount * 2);
      let coin = from_balance<T>(to_balance, ctx);
      transfer::public_transfer(coin, ctx.sender());
    }
  }
}