module aw_gambling::GAMBLING{
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::string::{Self, String};
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
    struct Player has store, copy, drop {
        name: String,
        score: u8
    }
    
    // Guesser
    struct Guesser has store {
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
    public entry fun bet(round: u8, guessing: &mut Guessing, choice: String, ctx: &mut TxContext) {  //wl: &Wl, 
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

    public entry fun get_guesser_score(guessing: &Guessing, guesseraddress: address, ctx: &mut TxContext): u8 {
        // let guesseraddress = tx_context::sender(ctx);
        let guesser = table::borrow(& guessing.guessers, guesseraddress);
        guesser.score
    }

    // set players
    public entry fun close(_: &GAMBLINGOwner, guessing: &mut Guessing, round: u8, winner: String) {
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
        while (j < table::length(&guessing.guessers)) {
            j = j + 1;
            // let guesser = table::borrow(&guessing.players, i);
            // if (guesser.name == winner){
            //     //player.score = player.score + 1;
            // }
        };
        debug::print(guessing);
    }

    // public fun name(self: &Flipper): String
    // { 
    //     self.name  
    // }

    #[test_only]
    
    public fun init_for_testing(ctx: &mut TxContext) 
    {
        init(ctx);
    }

}




