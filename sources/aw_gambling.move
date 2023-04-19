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
    struct Guesser has store,copy {
        guesser: address,
        choice: VecMap<u8, String>,
        score: u8
    }

    // global 
    struct Guessing has key, store {
        //admin: address,
        id:UID,
        players: vector<Player>,
        guessers: VecMap<address, Guesser>,
        round: u8,
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
        let players: vector<Player> = vector[
            Player {name: string::utf8(b"A"), score: 0},
            Player {name: string::utf8(b"B"), score: 0},
            Player {name: string::utf8(b"C"), score: 0},
            Player {name: string::utf8(b"D"), score: 0}
        ];
        let empty_guessers: VecMap<address, Guesser> = vec_map::empty(); 
        transfer::share_object(Guessing {
            id: object::new(ctx),
            players: players,
            guessers: empty_guessers,
            round: 0
        });
        transfer::transfer( Wl{id: object::new(ctx), list: vector::empty<address>()}, tx_context::sender(ctx));
    }

    // add addresses 
    public entry fun add_wl(_: &GAMBLINGOwner, wl: &mut Wl,  wladdress: address) {
        vector::push_back(&mut wl.list, wladdress);
    }

    // select player
    public entry fun bet(guessing: &mut Guessing, choice: String, ctx: &mut TxContext) {  //wl: &Wl, 
        let guesseraddress = tx_context::sender(ctx);
        if (!vec_map::contains(&guessing.guessers, &guesseraddress)) {
            let choicet:VecMap<u8, String> = vec_map::empty();
            vec_map::insert(&mut choicet, guessing.round, choice);
            vec_map::insert(&mut guessing.guessers, guesseraddress, Guesser { guesser: tx_context::sender(ctx),choice : choicet, score: 0 });
        }
        else{
            let guesser = vec_map::get_mut(&mut guessing.guessers, &guesseraddress);
            vec_map::insert(&mut guesser.choice, guessing.round, choice);
        }
    }

    public entry fun set_round(_: &GAMBLINGOwner, guessing: &mut Guessing, round: u8) {
        guessing.round = round;
    }

    public entry fun get_guesser_score(guessing: &Guessing, guesseraddress: address): u8 {
        let guesser = vec_map::get(& guessing.guessers, &guesseraddress);
        guesser.score
    }

    // set players
    public entry fun close(_: &GAMBLINGOwner, guessing: &mut Guessing, round: u8, winner: String) {
        let i = 0;
        while (i < 4) {
            i = i + 1;
            let player = vector::borrow_mut(&mut guessing.players, i);
            if (player.name == winner){
                player.score = player.score + 1;
            }
        };

        let j = 0;
        let size = vec_map::size(&guessing.guessers);
        while (j < size) {
            j = j + 1;
            let (gaddress, guesser) = vec_map::get_entry_by_idx_mut(&mut guessing.guessers, j);
            if (*vec_map::get(&guesser.choice, &round) == winner){
                guesser.score = guesser.score + 1;
            }
        };
        debug::print(guessing);
    }

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) 
    {
        init(ctx);
    }

}




