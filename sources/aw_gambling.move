module aw_gambling::GAMBLING{
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::string::{Self, String};
    use sui::sui::SUI;
    use std::hash::sha2_256;
    use std::debug;
    use std::vector;
    use sui::coin::{Self, Coin};
    use sui::table::{Self, Table};
    use sui::object_table::{Self, ObjectTable};
    use sui::vec_map::{Self, VecMap};

    // Rounds
    const TOTAL_ROUNDS: u8 = 6;

    // GAMBLINGOwner
    struct GAMBLINGOwner has key, store
    {
        id: UID
    }

    // Player A, B, C, D
    struct Player has store,copy,drop{
        name: String,
        score: u8
    }
    
    // Guesser
    struct Guesser has store{
        guesser: address,
        choice: Table<u8, String>,
        score: u8
    }

    // global 
    struct Guessing has key, store {
        //admin: address,
        id:UID,
        players: vector<Player>,
        guessers: Table<address, Guesser>,
        //rounds: u8,
        //round_winners: vector<u8>
    }

    // whitelist 
    struct Wl has key, store {
        id:UID,
        list: vector<address>,
    }

    // initialize  function
    #[expected_failure(abort_code = vec_map::EKeyAlreadyExists)]
    fun init(ctx: &mut TxContext) {
        transfer::transfer(GAMBLINGOwner{id: object::new(ctx)}, tx_context::sender(ctx));
        //let m = vec_map::empty(); // 
        //vec_map::insert(&mut m, k, v);
        let players: vector<Player> = vector[
            Player {name: string::utf8(b"A"), score: 0},
            Player {name: string::utf8(b"B"), score: 0},
            Player {name: string::utf8(b"C"), score: 0},
            Player {name: string::utf8(b"D"), score: 0}
        ];
        let empty_guessers: Table<address, Guesser> = table::new(ctx);
        transfer::share_object(Guessing {
            id: object::new(ctx),
            //admin: tx_context::sender(ctx),
            players: players,
            guessers: empty_guessers,
            //rounds: TOTAL_ROUNDS,
            //round_winners: empty_round_winners
        });
        transfer::transfer( Wl{id: object::new(ctx), list: vector::empty<address>()}, tx_context::sender(ctx));
    }

    // add addresses 
    public entry fun add_wl(_: &GAMBLINGOwner, wl: &mut Wl,  wladdress: address) {
        vector::push_back(&mut wl.list, wladdress);
    }

    // select player
    public entry fun bet(round: u8, guessing: &mut Guessing, choice: String, wl: &Wl, ctx: &mut TxContext) {
        //assert!(round <= guessing.rounds, 1003);  
        //guessing.guessers.push(Guesser {guesser: tx_context::sender(ctx), score: 0, choice: choice});
        let guesseraddress = tx_context::sender(ctx);
        if (!table::contains(&guessing.guessers, guesseraddress)){
            let choicet = table::new(ctx);
            table::add(&mut choicet, round, choice);
            table::add(&mut guessing.guessers, guesseraddress, Guesser { guesser: tx_context::sender(ctx),choice : choicet, score: 0 });
        }
        else{
            let guesser = table::borrow_mut(&mut guessing.guessers, guesseraddress);
            table::add(&mut guesser.choice, round, choice);
        }
    }

    // set players
    public entry fun set_result(_: &GAMBLINGOwner, guessing: &mut Guessing, round: u8, winner: String) {
        //assert!(round <= guessing.rounds, 1002);  
        //guessing.rounds = guessing.rounds+ 1;
        let i = 0;
        while (i < 4) {
            i = i + 1;
            let player = vector::borrow(&guessing.players, i);
            if (player.name == winner){
                //player.score = player.score + 1;
            }
        };

        let j = 0;
        while (i < table::length(&guessing.guessers)) {
            i = i + 1;
            // let guesser = table::borrow(&guessing.players, i);
            // if (guesser.name == winner){
            //     //player.score = player.score + 1;
            // }
        };

        debug::print(guessing);
    }






    // /// User doesn't have enough coins to play 
    // const ENotEnoughMoney: u64 = 1;
    // const EOutOfService: u64 = 2;
    // const AmountOfCombinations: u8 = 2;

    // const Counter: u64 = 2;

    // const DRAND_PK: vector<u8> =
    //     x"868f005eb8e6e4ca0a47c8a77ceaa5309a47978a7c71bc5cce96366b5d7a569937c529eeda66c7293784a9402801af31";

    // struct FlipperOwner has key, store
    // {
    //     id: UID
    // }

    // struct GambleEvent has copy, drop
    // {
    //     id: ID,
    //     winnings: u64,
    //     gambler: address,
    //     coin_side: u8,
    // }

    // struct Flipper has key,store 
    // {
    //     id: UID,
    //     name: String,
    //     description: String,
    //     flipper_balance: Balance<SUI>,
    //     counter: u64
    // }

    // public fun name(self: &Flipper): String
    // { 
    //     self.name  
    // }

    // public fun casino_balance(self:  &Flipper): u64
    // {
    //    balance::value<SUI>(&self.flipper_balance)
    // }




    // // let's play a game
    // public entry fun gamble(flipper: &mut Flipper, assumption:vector<u8>, bet: u64, wallet: &mut Coin<SUI>, ctx: &mut TxContext){

    //     // calculate max user earnings through the casino
    //     // let max_earnings = casino.cost_per_game ; // we calculate the maximum potential winnings on the casino.

    //     // Make sure Casino has enough money to support this gameplay.
    //     assert!(casino_balance(flipper) >= bet, EOutOfService);
    //     // make sure we have enough money to play a game!
    //     assert!(coin::value(wallet) >= bet, ENotEnoughMoney);


    //     // get balance reference
    //     let wallet_balance = coin::balance_mut(wallet);

    //     // get money from balance
    //     let payment = balance::split(wallet_balance, bet);

    //     // add to casino's balance.
    //     balance::join(&mut flipper.flipper_balance, payment);


    //     let uid = object::new(ctx);
    //     debug::print(ctx);


    //     let randomNums = pseudoRandomNumGenerator(&uid,flipper);
    //     let winnings = 0;

    //     let coin_side = *vector::borrow(&randomNums, 0);

    //     // debug::print(slot_1);

    //     if(coin_side == 0 && assumption == b"tails"){
    //         winnings = bet * 2  ; // calculate winnings + the money the user spent.
    //         let payment = balance::split(&mut flipper.flipper_balance, winnings); // get from casino's balance.
    //         balance::join(coin::balance_mut(wallet), payment); // add to user's wallet!
    //         //add winnings to user's wallet
    //     } else if(coin_side == 1 && assumption == b"heads"){
    //         winnings = bet ; 
    //         let payment = balance::split(&mut flipper.flipper_balance, winnings); // get from casino's balance.
    //         balance::join(coin::balance_mut(wallet), payment); // add to user's wallet!
    //         //add winnings to user's wallet
    //     };

    //     // emit event
    //     event::emit( GambleEvent{
    //         id: object::uid_to_inner(&uid),
    //         gambler: tx_context::sender(ctx),
    //         winnings,
    //         coin_side,
    //     });
        
    // }
    


    #[test_only]
    
    public fun init_for_testing(ctx: &mut TxContext) 
    {
        init(ctx);
    }

}




