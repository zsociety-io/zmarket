import credits.aleo;
import nft_registry_v3.aleo;
import nft_collections_v3.aleo;
import zmarket_royalties_v3.aleo;


program zmarket_public_marketplace.aleo {
    const ROYALTY_NFTS_COLLECTION_ID: field = 1234field;
    const ROYALTY_NFTS_EDITION: scalar = 0scalar;
    const MARKET_RESERVED_COLLECTION_ID: field = 5678field;

    struct PublicTrade {
        nft_id_hash: field,
        collection_id: field,
        price: u64,
        origin: address,
        market_royalty: u16,
        creator_royalty: u16,
        is_accepted: bool,
        is_removed: bool
    }

    mapping listings: field => PublicTrade;
     // listing_id => listing_data

    mapping offers: field => PublicTrade;
    // offer_id => offer_data

    mapping royalty_balances: field => u64;
    // collection_id => balance

    mapping offer_pools: address => u64;
    // address -> pooled amount


    inline commit_nft(
        nft_data: Data,
        nft_edition: scalar
    ) -> field {
        let data_hash: field = BHP256::hash_to_field(nft_data);
        let commitment: field = BHP256::commit_to_field(data_hash, nft_edition);
        return commitment;
    }
    
    inline hash_nft_id(
        collection_id: field,
        nft_data: Data,
        nft_edition: scalar,
    ) -> field {
        let nft_commit: field = commit_nft(nft_data, nft_edition);
        let nft_id: NFTId = NFTId {
            collection_id: collection_id,
            nft_commit: nft_commit
        };
        let nft_id_hash: field = BHP256::hash_to_field(nft_id);
        return nft_id_hash;
    }

    inline field_nft_data(collection_id: field) -> Data {
        return Data {
            metadata: collection_id
        };
    }

    inline hash_royalty_nft_id(collection_id: field) -> field {
        let nft_data: Data = field_nft_data(collection_id);
        let royalty_nft_id_hash: field = hash_nft_id(
            ROYALTY_NFTS_COLLECTION_ID,
            nft_data,
            ROYALTY_NFTS_EDITION
        );
        return royalty_nft_id_hash;
    }


    inline max_u64(a: u64, b: u64) -> u64 {
        return (a > b) ? a : b;
    }


    async transition withdraw_royalty_private(
        royalty_nft: nft_records_v3.aleo/NFT,
        public amount: u64
    ) -> (credits.aleo/credits, Future){
        let (payment, payment_future): (
            credits.aleo/credits, Future
        ) = credits.aleo/transfer_public_to_private(
            self.signer, amount
        );
        assert_eq(royalty_nft.collection_id, ROYALTY_NFTS_COLLECTION_ID);
        let withdraw_royalty_private_future: Future = fin_withdraw_royalty_private(
            royalty_nft.data.metadata,
            amount,
            payment_future
        );
        return (payment, withdraw_royalty_private_future);
    }
    async function fin_withdraw_royalty_private(
        collection_id: field, amount: u64, payment_future: Future
    ){
        let old_balance: u64 = royalty_balances.get_or_use(collection_id, 0u64);
        let new_balance: u64 = old_balance - amount;
        royalty_balances.set(collection_id, new_balance);
        payment_future.await();
    }


    async transition withdraw_royalty_public(
        public collection_id: field,
        public amount: u64
    ) -> Future{
        let payment_future: Future = credits.aleo/transfer_public(
            self.caller, amount
        );
        let royalty_nft_id_hash: field = hash_royalty_nft_id(collection_id);
        let withdraw_royalty_public_future: Future = fin_withdraw_royalty_public(
            self.caller,
            collection_id,
            royalty_nft_id_hash,
            amount,
            payment_future
        );
        return  withdraw_royalty_public_future;
    }
    async function fin_withdraw_royalty_public(
        caller: address, collection_id: field, royalty_nft_id_hash: field, amount: u64, payment_future: Future
    ){
        let royalty_holder: address = nft_registry_v3.aleo/nft_owners.get(royalty_nft_id_hash);
        assert_eq(royalty_holder, caller);
        let old_balance: u64 = royalty_balances.get_or_use(collection_id, 0u64);
        let new_balance: u64 = old_balance - amount;
        royalty_balances.set(collection_id, new_balance);
        payment_future.await();
    }


    /*
        Must be called in parallel of:
        - nft_records_v3.aleo/publish_nft_content if not published yet
        - nft_records_v3.aleo/approve_public
    */

    async transition list_public(
        public collection_id: field,
        public nft_id_hash: field,
        public listing_id: field,
        public listing_price: u64
    ) -> Future {
        let list_public_future: Future = finalize_list_public(
            self.caller,
            collection_id,
            nft_id_hash,
            listing_id,
            listing_price,
        );
        return list_public_future;
    }
    async function finalize_list_public(
        seller: address,
        collection_id: field,
        nft_id_hash: field,
        listing_id: field,
        price: u64,
    ){
        assert(listings.contains(listing_id).not());
        let market_royalty: u16 = zmarket_royalties_v3.aleo/royalties.get(MARKET_RESERVED_COLLECTION_ID);
        let creator_royalty: u16 = zmarket_royalties_v3.aleo/royalties.get_or_use(collection_id, 0u16);
        let market_royalty_amount: u64 = ((market_royalty as u64) * price).div(10_000u64);
        let creator_royalty_amount: u64 = ((creator_royalty as u64) * price).div(10_000u64);
        assert(price >= market_royalty_amount + creator_royalty_amount);
        let listing_data: PublicTrade = PublicTrade {
            nft_id_hash: nft_id_hash,
            collection_id: collection_id,
            price: price,
            origin: seller,
            market_royalty: market_royalty,
            creator_royalty: creator_royalty,
            is_accepted: false,
            is_removed: false
        };
        listings.set(listing_id, listing_data);
    }


    async transition unlist_public(
        public listing_id: field,
    ) -> Future {
        let unlist_public_future: Future = finalize_unlist_public(
            listing_id,
            self.caller
        );
        return unlist_public_future;
    }
    async function finalize_unlist_public(
        listing_id: field,
        caller: address
    ){
        let listing_data: PublicTrade = listings.get(listing_id);
        assert(listing_data.is_removed.not());
        assert(listing_data.is_accepted.not());
        assert_eq(caller, listing_data.origin);
        let new_listing_data: PublicTrade = PublicTrade {
            nft_id_hash: listing_data.nft_id_hash,
            collection_id: listing_data.collection_id,
            price: listing_data.price,
            origin: listing_data.origin,
            market_royalty: listing_data.market_royalty,
            creator_royalty: listing_data.creator_royalty,
            is_accepted: false,
            is_removed: true
        };
        listings.set(listing_id, new_listing_data);
    }


    async transition update_public_listing(
        public listing_id: field,
        public new_price: u64
    ) -> Future {
        let update_public_listing_future: Future = finalize_update_public_listing(
            listing_id,
            new_price,
            self.caller
        );
        return update_public_listing_future;
    }
    async function finalize_update_public_listing(
        listing_id: field,
        new_price: u64,
        caller: address
    ){
        let listing_data: PublicTrade = listings.get(listing_id);
        assert(listing_data.is_removed.not());
        assert(listing_data.is_accepted.not());
        assert_eq(caller, listing_data.origin);

        let market_royalty: u16 = zmarket_royalties_v3.aleo/royalties.get(MARKET_RESERVED_COLLECTION_ID);
        let creator_royalty: u16 = zmarket_royalties_v3.aleo/royalties.get_or_use(listing_data.collection_id, 0u16);

        let market_royalty_amount: u64 = ((market_royalty as u64) * new_price).div(10_000u64);
        let creator_royalty_amount: u64 = ((creator_royalty as u64) * new_price).div(10_000u64);

        assert(new_price >= market_royalty_amount + creator_royalty_amount);

        let new_listing_data: PublicTrade = PublicTrade {
            nft_id_hash: listing_data.nft_id_hash,
            collection_id: listing_data.collection_id,
            price: new_price,
            origin: listing_data.origin,
            market_royalty: market_royalty,
            creator_royalty: creator_royalty,
            is_accepted: false,
            is_removed: false
        };
        listings.set(listing_id, new_listing_data);
    }


    async transition accept_public_listing_as_signer(
        public listing_id: field,
        public collection_id: field,
        private nft_data: Data,
        private nft_edition: scalar,
        public price: u64,
        public seller: address,
        public seller_amount: u64
    ) -> Future {
        let payment_credits_future: Future
             = credits.aleo/transfer_public_as_signer(
                self.address, price
            );
        let seller_credits_future: Future
             = credits.aleo/transfer_public(
                seller, seller_amount
            );
        let (nft_view, nft_transfer_future): (
            nft_records_v3.aleo/NFTView, Future
        ) = nft_registry_v3.aleo/transfer_from_public(
            collection_id,
            seller,
            self.signer,
            nft_data,
            nft_edition,
        );
        let nft_id_hash: field = hash_nft_id(
            collection_id, nft_data, nft_edition
        );
        let accept_public_listing_future: Future = 
            fin_accept_public_listing_as_sg(
                listing_id,
                nft_id_hash,
                price,
                seller,
                seller_amount,
                payment_credits_future,
                seller_credits_future,
                nft_transfer_future,
            );
        return accept_public_listing_future;
    }
    async function fin_accept_public_listing_as_sg(
        listing_id: field,
        nft_id_hash: field,
        price: u64,
        seller: address,
        seller_amount: u64,
        payment_credits_future: Future,
        seller_credits_future: Future,
        nft_transfer_future: Future
    ){
        let listing_data: PublicTrade = listings.get(listing_id);
        assert(listing_data.is_accepted.not());
        assert(listing_data.is_removed.not());

        assert_eq(nft_id_hash, listing_data.nft_id_hash);
        assert_eq(price, listing_data.price);
        assert_eq(seller, listing_data.origin);

        let market_royalty: u16 = listing_data.market_royalty;
        let creator_royalty: u16 = listing_data.creator_royalty;

        let market_royalty_amount: u64 = ((market_royalty as u64) * price).div(10000u64);
        let creator_royalty_amount: u64 = ((creator_royalty as u64) * price).div(10000u64);
        let listing_amount: u64 = price - market_royalty_amount - creator_royalty_amount;
        assert_eq(seller_amount, listing_amount);

        let old_market_royalty_balance: u64 = royalty_balances.get_or_use(MARKET_RESERVED_COLLECTION_ID, 0u64);
        let old_creator_royalty_balance: u64 = royalty_balances.get_or_use(listing_data.collection_id, 0u64);

        let new_market_royalty_balance: u64 = old_market_royalty_balance + market_royalty_amount;
        let new_creator_royalty_balance: u64 = old_creator_royalty_balance + creator_royalty_amount;

        royalty_balances.set(MARKET_RESERVED_COLLECTION_ID, new_market_royalty_balance);
        royalty_balances.set(listing_data.collection_id, new_creator_royalty_balance);

        let new_listing_data: PublicTrade = PublicTrade {
            nft_id_hash: listing_data.nft_id_hash,
            collection_id: listing_data.collection_id,
            price: listing_data.price,
            origin: listing_data.origin,
            market_royalty: listing_data.market_royalty,
            creator_royalty: listing_data.creator_royalty,
            is_accepted: true,
            is_removed: true
        };
        listings.set(listing_id, new_listing_data);

        payment_credits_future.await();
        seller_credits_future.await();
        nft_transfer_future.await();
    }


    async transition accept_public_listing_private(
        public listing_id: field,
        payment: credits.aleo/credits,
        public collection_id: field,
        private nft_data: Data,
        private nft_edition: scalar,
        public price: u64,
        public seller: address,
        public seller_amount: u64
    ) -> (credits.aleo/credits, nft_records_v3.aleo/NFT, Future) {
        let (payment_change, payment_credits_future): (
            credits.aleo/credits, Future
        ) = credits.aleo/transfer_private_to_public(
            payment, self.address, price - seller_amount
        );
        let (change, seller_credits_future): (
            credits.aleo/credits, Future
        ) = credits.aleo/transfer_private_to_public(
            payment_change, seller, seller_amount
        );
        let (nft, nft_transfer_future): (
            nft_records_v3.aleo/NFT, Future
        ) = nft_registry_v3.aleo/transfer_from_public_to_private(
            collection_id,
            seller,
            self.signer,
            nft_data,
            nft_edition,
        );
        let nft_id_hash: field = hash_nft_id(
            collection_id, nft_data, nft_edition
        );
        let accept_public_listing_future: Future = 
            fin_accept_public_listing_pv(
                listing_id,
                nft_id_hash,
                price,
                seller,
                seller_amount,
                payment_credits_future,
                seller_credits_future,
                nft_transfer_future,
            );
        return (change, nft, accept_public_listing_future);
    }
    async function fin_accept_public_listing_pv(
        listing_id: field,
        nft_id_hash: field,
        price: u64,
        seller: address,
        seller_amount: u64,
        payment_credits_future: Future,
        seller_credits_future: Future,
        nft_transfer_future: Future
    ){
        let listing_data: PublicTrade = listings.get(listing_id);
        assert(listing_data.is_accepted.not());
        assert(listing_data.is_removed.not());

        assert_eq(nft_id_hash, listing_data.nft_id_hash);
        assert_eq(price, listing_data.price);
        assert_eq(seller, listing_data.origin);

        let market_royalty: u16 = listing_data.market_royalty;
        let creator_royalty: u16 = listing_data.creator_royalty;

        let market_royalty_amount: u64 = ((market_royalty as u64) * price).div(10000u64);
        let creator_royalty_amount: u64 = ((creator_royalty as u64) * price).div(10000u64);
        let listing_amount: u64 = price - market_royalty_amount - creator_royalty_amount;
        assert_eq(seller_amount, listing_amount);

        let old_market_royalty_balance: u64 = royalty_balances.get_or_use(MARKET_RESERVED_COLLECTION_ID, 0u64);
        let old_creator_royalty_balance: u64 = royalty_balances.get_or_use(listing_data.collection_id, 0u64);

        let new_market_royalty_balance: u64 = old_market_royalty_balance + market_royalty_amount;
        let new_creator_royalty_balance: u64 = old_creator_royalty_balance + creator_royalty_amount;

        royalty_balances.set(MARKET_RESERVED_COLLECTION_ID, new_market_royalty_balance);
        royalty_balances.set(listing_data.collection_id, new_creator_royalty_balance);

        let new_listing_data: PublicTrade = PublicTrade {
            nft_id_hash: listing_data.nft_id_hash,
            collection_id: listing_data.collection_id,
            price: listing_data.price,
            origin: listing_data.origin,
            market_royalty: listing_data.market_royalty,
            creator_royalty: listing_data.creator_royalty,
            is_accepted: true,
            is_removed: true
        };
        listings.set(listing_id, new_listing_data);

        payment_credits_future.await();
        seller_credits_future.await();
        nft_transfer_future.await();
    }


    async transition deposit_offer_as_signer(public amount: u64) -> Future {
        let payment_credits_future: Future 
            = credits.aleo/transfer_public_as_signer(
                self.address, amount
            );
        return fin_deposit_offer_as_signer(
            self.signer,
            amount,
            payment_credits_future,
        );
    }
    async function fin_deposit_offer_as_signer(
        signer: address,
        amount: u64,
        payment_credits_future: Future
    ){
        let old_amount: u64 = offer_pools.get_or_use(signer, 0u64);
        let new_amount: u64 = old_amount + amount;
        offer_pools.set(signer, new_amount);
        payment_credits_future.await();
    }


    async transition withdraw_offer(
        public amount: u64
    ) -> Future {
        let payment_credits_future: Future = credits.aleo/transfer_public(
                self.caller, amount
            );
        return fin_withdraw_offer(
            self.caller,
            amount,
            payment_credits_future,
        );
    }
    async function fin_withdraw_offer(
        caller: address,
        amount: u64,
        payment_credits_future: Future
    ){
        let old_amount: u64 = offer_pools.get_or_use(caller, 0u64);
        let new_amount: u64 = old_amount - amount;
        offer_pools.set(caller, new_amount);
        payment_credits_future.await();
    }
    

    /*
        Offer pool
    */

    async transition offer_public(
        public offer_id: field,
        public offer_price: u64,
        public collection_id: field,
        public nft_id_hash: field,
    ) -> Future {
        let offer_public_future: Future = finalize_offer_public(
            self.caller,
            offer_id,
            nft_id_hash,
            offer_price,
            collection_id
        );
        return offer_public_future;
    }
    async function finalize_offer_public(
        caller: address,
        offer_id: field,
        nft_id_hash: field,
        price: u64,
        collection_id: field
    ){
        assert(offers.contains(offer_id).not());

        let market_royalty: u16 = zmarket_royalties_v3.aleo/royalties.get(MARKET_RESERVED_COLLECTION_ID);
        let creator_royalty: u16 = zmarket_royalties_v3.aleo/royalties.get_or_use(collection_id, 0u16);

        let market_royalty_amount: u64 = ((market_royalty as u64) * price).div(10_000u64);
        let creator_royalty_amount: u64 = ((creator_royalty as u64) * price).div(10_000u64);

        assert(price >= market_royalty_amount + creator_royalty_amount);
        
        let offer_data: PublicTrade = PublicTrade {
            nft_id_hash: nft_id_hash,
            collection_id: collection_id,
            price: price,
            origin: caller,
            market_royalty: market_royalty,
            creator_royalty: creator_royalty,
            is_accepted: false,
            is_removed: false
        };
        offers.set(offer_id, offer_data);
    }


    async transition unoffer_public(
        public offer_id: field
    ) -> Future {
        let unoffer_public_future: Future = finalize_unoffer_public(
            offer_id,
            self.caller
        );
        return unoffer_public_future;
    }
    async function finalize_unoffer_public(
        offer_id: field,
        caller: address
    ){
        let offer_data: PublicTrade = offers.get(offer_id);
        assert(offer_data.is_removed.not());
        assert(offer_data.is_accepted.not());
        assert_eq(caller, offer_data.origin);
        let new_offer_data: PublicTrade = PublicTrade {
            nft_id_hash: offer_data.nft_id_hash,
            collection_id: offer_data.collection_id,
            price: offer_data.price,
            origin: offer_data.origin,
            market_royalty: offer_data.market_royalty,
            creator_royalty: offer_data.creator_royalty,
            is_accepted: false,
            is_removed: true
        };
        offers.set(offer_id, new_offer_data);
    }


    async transition update_public_offer(
        offer_id: field,
        public new_price: u64,
    ) -> Future {
        let update_public_offer_future: Future = finalize_update_public_offer(
            offer_id,
            new_price,
            self.caller
        );
        return update_public_offer_future;
    }
    async function finalize_update_public_offer(
        offer_id: field,
        new_price: u64,
        caller: address
    ){
        let offer_data: PublicTrade = offers.get(offer_id);
        assert(offer_data.is_removed.not());
        assert(offer_data.is_accepted.not());
        assert_eq(caller, offer_data.origin);

        let market_royalty: u16 = zmarket_royalties_v3.aleo/royalties.get(MARKET_RESERVED_COLLECTION_ID);
        let creator_royalty: u16 = zmarket_royalties_v3.aleo/royalties.get_or_use(offer_data.collection_id, 0u16);

        let market_royalty_amount: u64 = ((market_royalty as u64) * new_price).div(10_000u64);
        let creator_royalty_amount: u64 = ((creator_royalty as u64) * new_price).div(10_000u64);

        assert(new_price >= market_royalty_amount + creator_royalty_amount);

        let new_offer_data: PublicTrade = PublicTrade {
            nft_id_hash: offer_data.nft_id_hash,
            collection_id: offer_data.collection_id,
            price: new_price,
            origin: caller,
            market_royalty: market_royalty,
            creator_royalty: creator_royalty,
            is_accepted: false,
            is_removed: true
        };
        offers.set(offer_id, new_offer_data);
    }


    async transition accept_public_offer_private(
        public offer_id: field,
        public seller_amount: u64,
        public buyer: address,
        nft: nft_records_v3.aleo/NFT
    ) -> (credits.aleo/credits, Future) {
        let (nft_view, nft_transfer_future): (
            nft_records_v3.aleo/NFTView, Future
        ) = nft_registry_v3.aleo/transfer_private_to_public(nft, buyer);
        let (payment, payment_future): (
            credits.aleo/credits, Future
        ) = credits.aleo/transfer_public_to_private(
            self.signer, seller_amount
        );
        let nft_id_hash: field = hash_nft_id(
            nft.collection_id, nft.data, nft.edition
        );
        let accept_public_offer_future: Future = 
            finalize_accept_public_offer_pv(
                offer_id,
                seller_amount,
                nft.collection_id,
                buyer,
                nft_id_hash,
                nft_transfer_future,
                payment_future
            );
        return (payment, accept_public_offer_future);
    }
    async function finalize_accept_public_offer_pv(
        offer_id: field,
        seller_amount: u64,
        collection_id: field,
        buyer: address,
        nft_id_hash: field,
        nft_transfer_future: Future,
        payment_future: Future
    ){
        let offer_data: PublicTrade = offers.get(offer_id);
        assert(offer_data.is_accepted.not());
        assert(offer_data.is_removed.not());

        // Either nft_id_hash is 0field (for collection offers) 
        // or nft_id_hash matches sent nft (asset offer)
        assert(
            nft_id_hash == offer_data.nft_id_hash
            || offer_data.nft_id_hash == 0field
        );
        assert_eq(collection_id, offer_data.collection_id);
        assert_eq(offer_data.origin, buyer);

        let market_royalty: u16 = offer_data.market_royalty;
        let creator_royalty: u16 = offer_data.creator_royalty;
        let price: u64 = offer_data.price;

        let market_royalty_amount: u64 = ((market_royalty as u64) * price).div(10000u64);
        let creator_royalty_amount: u64 = ((creator_royalty as u64) * price).div(10000u64);
        let computed_seller_amount: u64 = price - market_royalty_amount - creator_royalty_amount;
        assert_eq(computed_seller_amount, seller_amount);

        let old_market_royalty_balance: u64 = royalty_balances.get_or_use(MARKET_RESERVED_COLLECTION_ID, 0u64);
        let old_creator_royalty_balance: u64 = royalty_balances.get_or_use(offer_data.collection_id, 0u64);

        let new_market_royalty_balance: u64 = old_market_royalty_balance + market_royalty_amount;
        let new_creator_royalty_balance: u64 = old_creator_royalty_balance + creator_royalty_amount;

        royalty_balances.set(MARKET_RESERVED_COLLECTION_ID, new_market_royalty_balance);
        royalty_balances.set(offer_data.collection_id, new_creator_royalty_balance);

        let old_offer_pool: u64 = offer_pools.get_or_use(buyer, 0u64);
        let new_offer_pool: u64 = old_offer_pool - price;

        offer_pools.set(buyer, new_offer_pool);

        let new_offer_data: PublicTrade = PublicTrade {
            nft_id_hash: nft_id_hash,
            collection_id: offer_data.collection_id,
            price: offer_data.price,
            origin: offer_data.origin,
            market_royalty: offer_data.market_royalty,
            creator_royalty: offer_data.creator_royalty,
            is_accepted: true,
            is_removed: false
        };
        offers.set(offer_id, new_offer_data);
        nft_transfer_future.await();
        payment_future.await();
    }

    /*
        Requires approval of nft transfer by this program from caller
    */
    async transition accept_public_offer_as_signer(
        public offer_id: field,
        public seller_amount: u64,
        public buyer: address,
        public collection_id: field,
        public nft_data: Data,
        public nft_edition: scalar
    ) -> Future {
        let (nft_view, nft_transfer_future): (
            nft_records_v3.aleo/NFTView, Future
        ) = nft_registry_v3.aleo/transfer_public_as_signer(
            collection_id, nft_data, nft_edition, buyer
        );
        let payment_future: Future = credits.aleo/transfer_public(
            self.signer, seller_amount
        );
        let nft_id_hash: field = hash_nft_id(
            collection_id, nft_data, nft_edition
        );
        let accept_public_offer_future: Future = 
            fin_accept_public_offer_as_sg(
                offer_id,
                seller_amount,
                collection_id,
                buyer,
                nft_id_hash,
                nft_transfer_future,
                payment_future
            );
        return accept_public_offer_future;
    }
    async function fin_accept_public_offer_as_sg(
        offer_id: field,
        seller_amount: u64,
        collection_id: field,
        buyer: address,
        nft_id_hash: field,
        nft_transfer_future: Future,
        payment_future: Future
    ){
        let offer_data: PublicTrade = offers.get(offer_id);
        assert(offer_data.is_accepted.not());
        assert(offer_data.is_removed.not());

        // Either nft_id_hash is 0field (for collection offers) 
        // or nft_id_hash matches sent nft (asset offer)
        assert(
            nft_id_hash == offer_data.nft_id_hash
            || offer_data.nft_id_hash == 0field
        );
        assert_eq(collection_id, offer_data.collection_id);
        assert_eq(offer_data.origin, buyer);

        let market_royalty: u16 = offer_data.market_royalty;
        let creator_royalty: u16 = offer_data.creator_royalty;
        let price: u64 = offer_data.price;

        let market_royalty_amount: u64 = ((market_royalty as u64) * price).div(10000u64);
        let creator_royalty_amount: u64 = ((creator_royalty as u64) * price).div(10000u64);
        let computed_seller_amount: u64 = price - market_royalty_amount - creator_royalty_amount;
        assert_eq(computed_seller_amount, seller_amount);

        let old_market_royalty_balance: u64 = royalty_balances.get_or_use(MARKET_RESERVED_COLLECTION_ID, 0u64);
        let old_creator_royalty_balance: u64 = royalty_balances.get_or_use(offer_data.collection_id, 0u64);

        let new_market_royalty_balance: u64 = old_market_royalty_balance + market_royalty_amount;
        let new_creator_royalty_balance: u64 = old_creator_royalty_balance + creator_royalty_amount;

        royalty_balances.set(MARKET_RESERVED_COLLECTION_ID, new_market_royalty_balance);
        royalty_balances.set(offer_data.collection_id, new_creator_royalty_balance);

        let old_offer_pool: u64 = offer_pools.get_or_use(buyer, 0u64);
        let new_offer_pool: u64 = old_offer_pool - price;

        offer_pools.set(buyer, new_offer_pool);

        let new_offer_data: PublicTrade = PublicTrade {
            nft_id_hash: nft_id_hash,
            collection_id: offer_data.collection_id,
            price: offer_data.price,
            origin: offer_data.origin,
            market_royalty: offer_data.market_royalty,
            creator_royalty: offer_data.creator_royalty,
            is_accepted: true,
            is_removed: false
        };
        offers.set(offer_id, new_offer_data);
        nft_transfer_future.await();
        payment_future.await();
    }
}
