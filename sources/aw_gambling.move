module aw_guessing::GUESSING{
    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::string::{Self, String};
    use sui::vec_map::{Self, VecMap};
    use std::type_name;
    //examples::collection::Abyss
    use examples::collection::Gekacha;
    use nft::souffl3::NFT;

    // GuessingOwner
    struct GUESSINGOWNER has key, store
    {
        id: UID
    }

    // Player A, B, C, D
    struct Boss has store, copy, drop {
        name: String,
        score: u64
    }
    
    // Guesser
    struct Guesser has store,copy {
        guesser: address,
        choice: VecMap<u64, String>,
        score: u64
    }

    // global 
    struct Guessing has key, store {
        id:UID,
        bosses: vector<Boss>,
        guessers: VecMap<address, Guesser>,
        round: u64,
        ticket_consume: VecMap<ID,u64>,
        final_winner_open: bool,
        guess_open:bool
    }

    // initialize  function
    #[expected_failure(abort_code = vec_map::EKeyAlreadyExists)]
    fun init(ctx: &mut TxContext) {
        transfer::transfer(GUESSINGOWNER{id: object::new(ctx)}, tx_context::sender(ctx));
        let bosses: vector<Boss> = vector[
            Boss {name: string::utf8(b"A"), score: 0},
            Boss {name: string::utf8(b"B"), score: 0},
            Boss {name: string::utf8(b"C"), score: 0},
            Boss {name: string::utf8(b"D"), score: 0}
        ];
        let empty_guessers: VecMap<address, Guesser> = vec_map::empty(); 
        let ticket_consume: VecMap<ID, u64> = vec_map::empty(); 
        transfer::share_object(Guessing {
            id: object::new(ctx),
            bosses: bosses,
            guessers: empty_guessers,
            round: 0,
            final_winner_open: true,
            guess_open: true,
            ticket_consume: ticket_consume,
        });
    }

    // // // support specific type of nft
    // public entry fun check_with_type(abyss_nft: &NFT<Gekacha>) {
    //     check(abyss_nft);
    // }

    // // support different type of nft
    // public entry fun check_withou_type<C>(abyss_nft: &NFT<C>) {
    //     check<C>(abyss_nft);
    // }

    // public entry fun check_withou_typeee<C>(_abyss_nft: &NFT<C>, guessing: &mut Guessing) {
    //     let c_type = type_name::get<C>();
    //     let gekacha_type = type_name::get<Gekacha>();
    //     assert!(type_name::into_string(copy c_type) == type_name::into_string(gekacha_type), 1);
    //     // guessing.a = &type_name::into_string(copy c_type);
    //     // guessing.b = &type_name::into_string(gekacha_type);
    // }

    public entry fun final_winner<C: key + store>(abyss_nft: C, guessing: &mut Guessing, choice: String, ctx: &mut TxContext) { 
        let c_type = type_name::get<C>();
        let gekacha_type = type_name::get<NFT<Gekacha>>();
        transfer::public_transfer(abyss_nft, tx_context::sender(ctx));
        assert!(type_name::into_string(copy c_type) == type_name::into_string(gekacha_type), 1);
        assert!(guessing.guess_open, 11);
        assert!(guessing.final_winner_open, 10);
        let guesseraddress = tx_context::sender(ctx);
        if (!vec_map::contains(&guessing.guessers, &guesseraddress)) {
            let choicet:VecMap<u64, String> = vec_map::empty();
            vec_map::insert(&mut choicet, 0, choice);
            vec_map::insert(&mut guessing.guessers, guesseraddress, Guesser { guesser: tx_context::sender(ctx),choice : choicet, score: 0 });
        }
        else{
            let guesser = vec_map::get_mut(&mut guessing.guessers, &guesseraddress);
            vec_map::insert(&mut guesser.choice, 0, choice);
        }
    }

    // select player
    public entry fun guess<C: key + store>(abyss_nft: C, guessing: &mut Guessing, choice: String, ctx: &mut TxContext) {
        let c_type = type_name::get<C>();
        let gekacha_type = type_name::get<NFT<Gekacha>>();
        transfer::public_transfer(abyss_nft, tx_context::sender(ctx));
        assert!(type_name::into_string(copy c_type) == type_name::into_string(gekacha_type), 1);
        assert!(guessing.guess_open, 11);
        //assert!(*vec_map::get(&guessing.ticket_consume, &object::id(abyss_nft)) < 7, 11);

        let guesseraddress = tx_context::sender(ctx);
        if (!vec_map::contains(&guessing.guessers, &guesseraddress)) {
            let choicet:VecMap<u64, String> = vec_map::empty();
            vec_map::insert(&mut choicet, guessing.round, choice);
            vec_map::insert(&mut guessing.guessers, guesseraddress, Guesser { guesser: tx_context::sender(ctx),choice : choicet, score: 0 });
        }
        else{
            let guesser = vec_map::get_mut(&mut guessing.guessers, &guesseraddress);
            vec_map::insert(&mut guesser.choice, guessing.round, choice);
        }
    }

    public entry fun guess_first<C: key + store>(abyss_nft: C, guessing: &mut Guessing, choice: String, ctx: &mut TxContext) {
        let c_type = type_name::get<C>();
        let gekacha_type = type_name::get<NFT<Gekacha>>();
        assert!(type_name::into_string(copy c_type) == type_name::into_string(gekacha_type), 1);
        transfer::public_transfer(abyss_nft, tx_context::sender(ctx));
        assert!(guessing.guess_open, 11);
        //assert!(*vec_map::get(&guessing.ticket_consume, &object::id(abyss_nft)) < 7, 11);

        let guesseraddress = tx_context::sender(ctx);
        if (!vec_map::contains(&guessing.guessers, &guesseraddress)) {
            let choicet:VecMap<u64, String> = vec_map::empty();
            vec_map::insert(&mut choicet, 1, choice);
            vec_map::insert(&mut guessing.guessers, guesseraddress, Guesser { guesser: tx_context::sender(ctx),choice : choicet, score: 0 });
        }
        else{
            let guesser = vec_map::get_mut(&mut guessing.guessers, &guesseraddress);
            vec_map::insert(&mut guesser.choice, 1, choice);
        }
    }

    public entry fun guess_sixth<C: key + store>(abyss_nft: C, guessing: &mut Guessing, choice: String, ctx: &mut TxContext) {
        let c_type = type_name::get<C>();
        let gekacha_type = type_name::get<NFT<Gekacha>>();
        assert!(type_name::into_string(copy c_type) == type_name::into_string(gekacha_type), 1);
        transfer::public_transfer(abyss_nft, tx_context::sender(ctx));
        assert!(guessing.guess_open, 11);
        //assert!(*vec_map::get(&guessing.ticket_consume, &object::id(abyss_nft)) < 7, 11);

        let guesseraddress = tx_context::sender(ctx);
        if (!vec_map::contains(&guessing.guessers, &guesseraddress)) {
            let choicet:VecMap<u64, String> = vec_map::empty();
            vec_map::insert(&mut choicet, 6, choice);
            vec_map::insert(&mut guessing.guessers, guesseraddress, Guesser { guesser: tx_context::sender(ctx),choice : choicet, score: 0 });
        }
        else{
            let guesser = vec_map::get_mut(&mut guessing.guessers, &guesseraddress);
            vec_map::insert(&mut guesser.choice, 6, choice);
        }
    }

    public entry fun set_round(_: &GUESSINGOWNER, guessing: &mut Guessing, round: u64) {
        guessing.round = round;
    }

    public entry fun set_final_winner_open(_: &GUESSINGOWNER, guessing: &mut Guessing, status: bool) {
        guessing.final_winner_open = status;
    }

    public entry fun set_guess_open(_: &GUESSINGOWNER, guessing: &mut Guessing, status: bool) {
        guessing.guess_open = status;
    }

    // public entry fun update_gueeser_score(_: &GUESSINGOWNER, guessing: &mut Guessing, score: u64, guesseraddress:address) {
    //     if (vec_map::contains(&guessing.guessers, &guesseraddress)) {
    //         let guesser = vec_map::get_mut(&mut guessing.guessers, &guesseraddress);
    //         guesser.score = score;
    //     }
    // }

    // public entry fun update_boss_score(_: &GUESSINGOWNER, guessing: &mut Guessing, scoreA: u64, scoreB: u64,scoreC: u64,scoreD: u64,) {
    //     vector::pop_back(&mut guessing.bosses);
    //     vector::pop_back(&mut guessing.bosses);
    //     vector::pop_back(&mut guessing.bosses);
    //     vector::pop_back(&mut guessing.bosses);
    //     vector::push_back(&mut guessing.bosses, Boss {name: string::utf8(b"A"), score: scoreA});
    //     vector::push_back(&mut guessing.bosses, Boss {name: string::utf8(b"B"), score: scoreB});
    //     vector::push_back(&mut guessing.bosses, Boss {name: string::utf8(b"C"), score: scoreC});
    //     vector::push_back(&mut guessing.bosses, Boss {name: string::utf8(b"D"), score: scoreD});
    // }

    // set players
    // public entry fun close(_: &GAMBLINGOwner, guessing: &mut Guessing, round: u8, winner: String) {
    //     let i = 0;
    //     // while (i < 4) {
    //     //     i = i + 1;
    //     //     let player = vector::borrow_mut(&mut guessing.players, i);
    //     //     if (player.name == winner){
    //     //         player.score = player.score + 1;
    //     //     }
    //     // };

    //     // let j = 0;
    //     // let size = vec_map::size(&guessing.guessers);
    //     // while (j < size) {
    //     //     j = j + 1;
    //     //     let (gaddress, guesser) = vec_map::get_entry_by_idx_mut(&mut guessing.guessers, j);
    //     //     if (*vec_map::get(&guesser.choice, &round) == winner){
    //     //         guesser.score = guesser.score + 1;
    //     //     }
    //     // };
    //     debug::print(guessing);
    // }

    // #[test_only]
    // public fun init_for_testing(ctx: &mut TxContext) 
    // {
    //     init(ctx);
    // }
    // #[test]
    // fun test_nft() {
    //     use sui::test_scenario;
    //     let admin = @0x0bc3923a751e4987f1a19c91eede5043f9918748c75415ff5531bfd943370a9e;
    //     let nftobjectid = @0xdea4c1a1a49d3c584d5050303fc27fa4d9568af849e5f531892de7b56532c07f;
    //     let scenario_val = test_scenario::begin(admin);
    //     let scenario = &mut scenario_val;
    //     {
    //         init(test_scenario::ctx(scenario));
    //     };
    //      // second transaction executed by admin to create the sword
    //     test_scenario::next_tx(scenario, admin);
    //     {
    //         // create the sword and transfer it to the initial owner
    //         check_with_type(&nftobjectid);
    //     };
    //     test_scenario::end(scenario_val);
    // }

}




