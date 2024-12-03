import credits.aleo;
import nft_registry_v3.aleo;
import nft_collections_v3.aleo;
import zmarket_royalties_v3.aleo;


program zmarket_private_marketplace.aleo {
    const ROYALTY_NFTS_COLLECTION_ID: field = 1234field;
    const ROYALTY_NFTS_EDITION: scalar = 0scalar;
    const MARKET_RESERVED_COLLECTION_ID: field = 5678field;

    struct Trade {
        nft_id_hash: field,
        collection_id: field,
        price: u64,
        market_royalty: u16,
        creator_royalty: u16,
        is_accepted: bool,
        is_removed: bool
    }

    record PrivateListing {
        owner: address,
        listing_id: field,
    }

    record AcceptedListing {
        owner: address,
        listing_id: field,
    }

    record PrivateOffer {
        owner: address,
        offer_id: field,
    }

    mapping listings: field => Trade;
     // listing_id => listing_data

    mapping royalty_balances: field => u64;
    // collection_id => balance

    mapping listing_balances: field => u64;
    // listing_id => balance

    mapping offers: field => Trade;
    // offer_id => offer_data


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


    async transition withdraw_listing_balance(
        old_private_listing: PrivateListing,
        public amount: u64,
    ) -> (PrivateListing, credits.aleo/credits, Future){
        let (payment, payment_future): (
            credits.aleo/credits, Future
        ) = credits.aleo/transfer_public_to_private(
            self.signer, amount
        );
        let withdraw_listing_balance_future: Future = fin_withdraw_listing_balance(
            old_private_listing.listing_id,
            amount,
            payment_future
        );
        let new_private_listing: PrivateListing = PrivateListing {
            owner: old_private_listing.owner,
            listing_id: old_private_listing.listing_id
        };
        return (
            new_private_listing,
            payment,
            withdraw_listing_balance_future
        );
    }
    async function fin_withdraw_listing_balance(
        listing_id: field, amount: u64, payment_future: Future
    ){
        let old_balance: u64 = listing_balances.get(listing_id);
        let new_balance: u64 = old_balance - amount;
        listing_balances.set(listing_id, new_balance);
        payment_future.await();
    }


    async transition list_private(
        nft: nft_records_v3.aleo/NFT,
        public listing_id: field,
        public listing_price: u64
    ) -> (PrivateListing, Future) {
        let (nft_view, nft_transfer_future): (
            nft_records_v3.aleo/NFTView, Future
        ) = nft_registry_v3.aleo/transfer_private_to_public(
            nft, self.address
        );

        let nft_id_hash: field = hash_nft_id(
            nft.collection_id,
            nft.data,
            nft.edition
        );
        let private_listing: PrivateListing = PrivateListing {
            owner: nft.owner,
            listing_id: listing_id
        };
        let list_private_future: Future = finalize_list_private(
            listing_id,
            nft_id_hash,
            listing_price,
            nft.collection_id,
            nft_transfer_future
        );
        return (
            private_listing,
            list_private_future,
        );
    }
    async function finalize_list_private(
        listing_id: field,
        nft_id_hash: field,
        price: u64,
        collection_id: field,
        nft_transfer_future: Future
    ){
        nft_transfer_future.await();
        assert(listings.contains(listing_id).not());

        let market_royalty: u16 = zmarket_royalties_v3.aleo/royalties.get(MARKET_RESERVED_COLLECTION_ID);
        let creator_royalty: u16 = zmarket_royalties_v3.aleo/royalties.get_or_use(collection_id, 0u16);

        let market_royalty_amount: u64 = ((market_royalty as u64) * price).div(10_000u64);
        let creator_royalty_amount: u64 = ((creator_royalty as u64) * price).div(10_000u64);

        assert(price >= market_royalty_amount + creator_royalty_amount);
        
        let listing_data: Trade = Trade {
            nft_id_hash: nft_id_hash,
            collection_id: collection_id,
            price: price,
            market_royalty: market_royalty,
            creator_royalty: creator_royalty,
            is_accepted: false,
            is_removed: false
        };
        listings.set(listing_id, listing_data);
    }


    async transition unlist_private(
        private_listing: PrivateListing,
        public collection_id: field,
        private nft_data: Data,
        private nft_edition: scalar
    ) -> (nft_records_v3.aleo/NFT, Future) {
        let (nft, nft_transfer_future): (
            nft_records_v3.aleo/NFT, Future
        ) = nft_registry_v3.aleo/transfer_public_to_private(
            collection_id,
            nft_data,
            nft_edition,
            private_listing.owner
        );
        let nft_id_hash: field = hash_nft_id(
            collection_id, nft_data, nft_edition
        );

        let unlist_private_future: Future = finalize_unlist_private(
            private_listing.listing_id,
            nft_id_hash,
            nft_transfer_future
        );
        return (nft, unlist_private_future);
    }
    async function finalize_unlist_private(
        listing_id: field,
        nft_id_hash: field,
        nft_transfer_future: Future
    ){
        nft_transfer_future.await();
        let listing_data: Trade = listings.get(listing_id);
        assert(listing_data.is_removed.not());
        assert(listing_data.is_accepted.not());
        assert_eq(nft_id_hash, listing_data.nft_id_hash);
        let new_listing_data: Trade = Trade {
            nft_id_hash: listing_data.nft_id_hash,
            collection_id: listing_data.collection_id,
            price: listing_data.price,
            market_royalty: listing_data.market_royalty,
            creator_royalty: listing_data.creator_royalty,
            is_accepted: false,
            is_removed: true
        };
        listings.set(listing_id, new_listing_data);
    }


    async transition update_private_listing(
        private_listing: PrivateListing,
        public new_price: u64
    ) -> (PrivateListing, Future) {
        let new_private_listing: PrivateListing = PrivateListing {
            owner: private_listing.owner,
            listing_id: private_listing.listing_id
        };
        let update_private_listing_future: Future = finalize_update_private_listing(
            private_listing.listing_id,
            new_price
        );
        return (new_private_listing, update_private_listing_future);
    }
    async function finalize_update_private_listing(
        listing_id: field,
        new_price: u64
    ){
        let listing_data: Trade = listings.get(listing_id);
        assert(listing_data.is_removed.not());
        assert(listing_data.is_accepted.not());

        let market_royalty: u16 = zmarket_royalties_v3.aleo/royalties.get(MARKET_RESERVED_COLLECTION_ID);
        let creator_royalty: u16 = zmarket_royalties_v3.aleo/royalties.get_or_use(listing_data.collection_id, 0u16);

        let market_royalty_amount: u64 = ((market_royalty as u64) * new_price).div(10_000u64);
        let creator_royalty_amount: u64 = ((creator_royalty as u64) * new_price).div(10_000u64);

        assert(new_price >= market_royalty_amount + creator_royalty_amount);

        let new_listing_data: Trade = Trade {
            nft_id_hash: listing_data.nft_id_hash,
            collection_id: listing_data.collection_id,
            price: new_price,
            market_royalty: market_royalty,
            creator_royalty: creator_royalty,
            is_accepted: false,
            is_removed: false
        };
        listings.set(listing_id, new_listing_data);
    }


    async transition accept_withdraw_nft_pv_listing(
        public listing_id: field,
        payment: credits.aleo/credits,
        public collection_id: field,
        private nft_data: Data,
        private nft_edition: scalar,
        public price: u64
    ) -> (nft_records_v3.aleo/NFT, Future) {
        let (change, payment_credits_future): (
            credits.aleo/credits, Future
        ) = credits.aleo/transfer_private_to_public(
            payment, self.address, price
        );
        let (nft, nft_transfer_future): (
            nft_records_v3.aleo/NFT, Future
        ) = nft_registry_v3.aleo/transfer_public_to_private(
            collection_id,
            nft_data,
            nft_edition,
            self.signer
        );
        let nft_id_hash: field = hash_nft_id(
            collection_id, nft_data, nft_edition
        );
        let accept_withdraw_nft_pv_listing_future: Future = 
            fin_accept_withdraw_nft_pv_ls(
                listing_id,
                nft_id_hash,
                price,
                payment_credits_future,
                nft_transfer_future,
            );
        return (nft, accept_withdraw_nft_pv_listing_future);
    }
    async function fin_accept_withdraw_nft_pv_ls(
        listing_id: field,
        nft_id_hash: field,
        price: u64,
        payment_credits_future: Future,
        nft_transfer_future: Future,
    ){
        let listing_data: Trade = listings.get(listing_id);
        assert(listing_data.is_accepted.not());
        assert(listing_data.is_removed.not());
        assert_eq(nft_id_hash, listing_data.nft_id_hash);
        assert_eq(price, listing_data.price);

        let market_royalty: u16 = listing_data.market_royalty;
        let creator_royalty: u16 = listing_data.creator_royalty;

        let market_royalty_amount: u64 = ((market_royalty as u64) * price).div(10000u64);
        let creator_royalty_amount: u64 = ((creator_royalty as u64) * price).div(10000u64);
        let listing_amount: u64 = price - market_royalty_amount - creator_royalty_amount;

        let old_market_royalty_balance: u64 = royalty_balances.get_or_use(MARKET_RESERVED_COLLECTION_ID, 0u64);
        let old_creator_royalty_balance: u64 = royalty_balances.get_or_use(listing_data.collection_id, 0u64);

        let new_market_royalty_balance: u64 = old_market_royalty_balance + market_royalty_amount;
        let new_creator_royalty_balance: u64 = old_creator_royalty_balance + creator_royalty_amount;

        royalty_balances.set(MARKET_RESERVED_COLLECTION_ID, new_market_royalty_balance);
        royalty_balances.set(listing_data.collection_id, new_creator_royalty_balance);
        listing_balances.set(listing_id, listing_amount);

        let new_listing_data: Trade = Trade {
            nft_id_hash: listing_data.nft_id_hash,
            collection_id: listing_data.collection_id,
            price: listing_data.price,
            market_royalty: listing_data.market_royalty,
            creator_royalty: listing_data.creator_royalty,
            is_accepted: true,
            is_removed: true
        };
        listings.set(listing_id, new_listing_data);
        payment_credits_future.await();
        nft_transfer_future.await();
    }


    async transition accept_private_listing(
        public listing_id: field,
        payment: credits.aleo/credits,
        public price: u64
    ) -> (AcceptedListing, Future) {
        let (change, payment_credits_future): (
            credits.aleo/credits, Future
        ) = credits.aleo/transfer_private_to_public(
            payment, self.address, price
        );
        let accepted_listing: AcceptedListing = AcceptedListing {
            owner: self.signer,
            listing_id: listing_id
        };
        let accept_private_listing_future: Future = 
            finalize_accept_private_listing(
                listing_id,
                price,
                payment_credits_future,
            );
        return (accepted_listing, accept_private_listing_future);
    }
    async function finalize_accept_private_listing(
        listing_id: field,
        price: u64,
        payment_credits_future: Future,
    ){
        let listing_data: Trade = listings.get(listing_id);
        assert(listing_data.is_accepted.not());
        assert(listing_data.is_removed.not());
        assert_eq(price, listing_data.price);

        let market_royalty: u16 = listing_data.market_royalty;
        let creator_royalty: u16 = listing_data.creator_royalty;

        let market_royalty_amount: u64 = ((market_royalty as u64) * price).div(10000u64);
        let creator_royalty_amount: u64 = ((creator_royalty as u64) * price).div(10000u64);
        let listing_amount: u64 = price - market_royalty_amount - creator_royalty_amount;

        let old_market_royalty_balance: u64 = royalty_balances.get_or_use(MARKET_RESERVED_COLLECTION_ID, 0u64);
        let old_creator_royalty_balance: u64 = royalty_balances.get_or_use(listing_data.collection_id, 0u64);

        let new_market_royalty_balance: u64 = old_market_royalty_balance + market_royalty_amount;
        let new_creator_royalty_balance: u64 = old_creator_royalty_balance + creator_royalty_amount;

        royalty_balances.set(MARKET_RESERVED_COLLECTION_ID, new_market_royalty_balance);
        royalty_balances.set(listing_data.collection_id, new_creator_royalty_balance);
        listing_balances.set(listing_id, listing_amount);

        let new_listing_data: Trade = Trade {
            nft_id_hash: listing_data.nft_id_hash,
            collection_id: listing_data.collection_id,
            price: listing_data.price,
            market_royalty: listing_data.market_royalty,
            creator_royalty: listing_data.creator_royalty,
            is_accepted: true,
            is_removed: false
        };
        listings.set(listing_id, new_listing_data);
        payment_credits_future.await();
    }


    async transition withdraw_nft_private_listing(
        public accepted_listing: AcceptedListing,
        public collection_id: field,
        private nft_data: Data,
        private nft_edition: scalar,
    ) -> (nft_records_v3.aleo/NFT, Future) {
        let (nft, nft_transfer_future): (
            nft_records_v3.aleo/NFT, Future
        ) = nft_registry_v3.aleo/transfer_public_to_private(
            collection_id,
            nft_data,
            nft_edition,
            self.signer
        );
        let nft_id_hash: field = hash_nft_id(
            collection_id, nft_data, nft_edition
        );
        let withdraw_nft_private_listing_future: Future = 
            fin_withdraw_nft_private_ls(
                accepted_listing.listing_id,
                nft_id_hash,
                nft_transfer_future,
            );
        return (nft, withdraw_nft_private_listing_future);
    }
    async function fin_withdraw_nft_private_ls(
        listing_id: field,
        nft_id_hash: field,
        nft_transfer_future: Future,
    ){
        let listing_data: Trade = listings.get(listing_id);
        assert(listing_data.is_accepted);
        assert(listing_data.is_removed.not());
        assert_eq(nft_id_hash, listing_data.nft_id_hash);
        
        let new_listing_data: Trade = Trade {
            nft_id_hash: listing_data.nft_id_hash,
            collection_id: listing_data.collection_id,
            price: listing_data.price,
            market_royalty: listing_data.market_royalty,
            creator_royalty: listing_data.creator_royalty,
            is_accepted: true,
            is_removed: true
        };
        listings.set(listing_id, new_listing_data);
        nft_transfer_future.await();
    }


    async transition offer_private(
        payment: credits.aleo/credits,
        public offer_id: field,
        public offer_price: u64,
        public collection_id: field,
        public nft_id_hash: field,
    ) -> (PrivateOffer, Future) {
        let (change, payment_credits_future): (
            credits.aleo/credits, Future
        ) = credits.aleo/transfer_private_to_public(
            payment, self.address, offer_price
        );
        let private_offer: PrivateOffer = PrivateOffer {
            owner: self.signer,
            offer_id: offer_id
        };
        let offer_private_future: Future = finalize_offer_private(
            offer_id,
            nft_id_hash,
            offer_price,
            collection_id,
            payment_credits_future
        );
        return (
            private_offer,
            offer_private_future,
        );
    }
    async function finalize_offer_private(
        offer_id: field,
        nft_id_hash: field,
        price: u64,
        collection_id: field,
        payment_credits_future: Future
    ){
        payment_credits_future.await();
        assert(offers.contains(offer_id).not());

        let market_royalty: u16 = zmarket_royalties_v3.aleo/royalties.get(MARKET_RESERVED_COLLECTION_ID);
        let creator_royalty: u16 = zmarket_royalties_v3.aleo/royalties.get_or_use(collection_id, 0u16);

        let market_royalty_amount: u64 = ((market_royalty as u64) * price).div(10_000u64);
        let creator_royalty_amount: u64 = ((creator_royalty as u64) * price).div(10_000u64);

        assert(price >= market_royalty_amount + creator_royalty_amount);
        
        let offer_data: Trade = Trade {
            nft_id_hash: nft_id_hash,
            collection_id: collection_id,
            price: price,
            market_royalty: market_royalty,
            creator_royalty: creator_royalty,
            is_accepted: false,
            is_removed: false
        };
        offers.set(offer_id, offer_data);
    }


    async transition unoffer_private(
        private_offer: PrivateOffer,
        public price: u64,
    ) -> (credits.aleo/credits, Future) {
        let (payment, payment_future): (
            credits.aleo/credits, Future
        ) = credits.aleo/transfer_public_to_private(
            private_offer.owner, price
        );
        let unoffer_private_future: Future = finalize_unoffer_private(
            private_offer.offer_id,
            price,
            payment_future
        );
        return (payment, unoffer_private_future);
    }
    async function finalize_unoffer_private(
        offer_id: field,
        price: u64,
        payment_future: Future
    ){
        payment_future.await();
        let offer_data: Trade = offers.get(offer_id);
        assert(offer_data.is_removed.not());
        assert(offer_data.is_accepted.not());
        assert_eq(price, offer_data.price);
        let new_offer_data: Trade = Trade {
            nft_id_hash: offer_data.nft_id_hash,
            collection_id: offer_data.collection_id,
            price: offer_data.price,
            market_royalty: offer_data.market_royalty,
            creator_royalty: offer_data.creator_royalty,
            is_accepted: false,
            is_removed: true
        };
        offers.set(offer_id, new_offer_data);
    }


    async transition update_private_offer(
        private_offer: PrivateOffer,
        payment: credits.aleo/credits,
        public old_price: u64,
        public new_price: u64,
    ) -> (credits.aleo/credits, PrivateOffer, Future) {
        let (payback, payment1_future): (
            credits.aleo/credits, Future
        ) = credits.aleo/transfer_public_to_private(
            private_offer.owner, old_price
        );
        let joined: credits.aleo/credits = credits.aleo/join(payment, payback);
        let (change, payment2_future): (
            credits.aleo/credits, Future
        ) = credits.aleo/transfer_private_to_public(
            joined, self.address, new_price
        );
        let new_private_offer: PrivateOffer = PrivateOffer {
            owner: self.signer,
            offer_id: private_offer.offer_id
        };
        let update_private_offer_future: Future = finalize_update_private_offer(
            private_offer.offer_id,
            old_price,
            new_price,
            payment1_future,
            payment2_future,
        );
        return (change, new_private_offer, update_private_offer_future);
    }
    async function finalize_update_private_offer(
        offer_id: field,
        old_price: u64,
        new_price: u64,
        payment1_future: Future,
        payment2_future: Future,
    ){
        payment1_future.await();
        payment2_future.await();
        let offer_data: Trade = offers.get(offer_id);
        assert(offer_data.is_removed.not());
        assert(offer_data.is_accepted.not());
        assert_eq(old_price, offer_data.price);

        let market_royalty: u16 = zmarket_royalties_v3.aleo/royalties.get(MARKET_RESERVED_COLLECTION_ID);
        let creator_royalty: u16 = zmarket_royalties_v3.aleo/royalties.get_or_use(offer_data.collection_id, 0u16);

        let market_royalty_amount: u64 = ((market_royalty as u64) * new_price).div(10_000u64);
        let creator_royalty_amount: u64 = ((creator_royalty as u64) * new_price).div(10_000u64);

        assert(new_price >= market_royalty_amount + creator_royalty_amount);

        let new_offer_data: Trade = Trade {
            nft_id_hash: offer_data.nft_id_hash,
            collection_id: offer_data.collection_id,
            price: new_price,
            market_royalty: market_royalty,
            creator_royalty: creator_royalty,
            is_accepted: false,
            is_removed: true
        };
        offers.set(offer_id, new_offer_data);
    }


    async transition accept_private_offer(
        public offer_id: field,
        public seller_amount: u64,
        nft: nft_records_v3.aleo/NFT
    ) -> (credits.aleo/credits, Future) {
        let (nft_view, nft_transfer_future): (
            nft_records_v3.aleo/NFTView, Future
        ) = nft_registry_v3.aleo/transfer_private_to_public(
            nft, self.address
        );
        let (payment, payment_future): (
            credits.aleo/credits, Future
        ) = credits.aleo/transfer_public_to_private(
            self.signer, seller_amount
        );
        let nft_id_hash: field = hash_nft_id(
            nft.collection_id, nft.data, nft.edition
        );
        let accept_private_offer_future: Future = 
            finalize_accept_private_offer(
                seller_amount,
                offer_id,
                nft.collection_id,
                nft_id_hash,
                nft_transfer_future,
                payment_future
            );
        return (payment, accept_private_offer_future);
    }
    async function finalize_accept_private_offer(
        seller_amount: u64,
        offer_id: field,
        collection_id: field,
        nft_id_hash: field,
        nft_transfer_future: Future,
        payment_future: Future
    ){
        let offer_data: Trade = offers.get(offer_id);
        assert(offer_data.is_accepted.not());
        assert(offer_data.is_removed.not());

        // Either nft_id_hash is 0field (for collection offers) 
        // or nft_id_hash matches sent nft (asset offer)
        assert(
            nft_id_hash == offer_data.nft_id_hash
            || offer_data.nft_id_hash == 0field
        );
        assert_eq(collection_id, offer_data.collection_id);

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

        let new_offer_data: Trade = Trade {
            nft_id_hash: nft_id_hash,
            collection_id: offer_data.collection_id,
            price: offer_data.price,
            market_royalty: offer_data.market_royalty,
            creator_royalty: offer_data.creator_royalty,
            is_accepted: true,
            is_removed: false
        };
        offers.set(offer_id, new_offer_data);
        nft_transfer_future.await();
        payment_future.await();
    }


    async transition withdraw_nft_private_offer(
        offer: PrivateOffer,
        public collection_id: field,
        private nft_data: Data,
        private nft_edition: scalar,
    ) -> (nft_records_v3.aleo/NFT, Future) {
        let (nft, nft_transfer_future): (
            nft_records_v3.aleo/NFT, Future
        ) = nft_registry_v3.aleo/transfer_public_to_private(
            collection_id,
            nft_data,
            nft_edition,
            self.signer
        );
        let nft_id_hash: field = hash_nft_id(
            collection_id, nft_data, nft_edition
        );
        let withdraw_nft_private_offer_future: Future = 
            fin_withdraw_nft_private_offer(
                offer.offer_id,
                nft_id_hash,
                nft_transfer_future,
            );
        return (nft, withdraw_nft_private_offer_future);
    }
    async function fin_withdraw_nft_private_offer(
        offer_id: field,
        nft_id_hash: field,
        nft_transfer_future: Future,
    ){
        let offer_data: Trade = offers.get(offer_id);
        assert(offer_data.is_accepted);
        assert(offer_data.is_removed.not());
        assert_eq(nft_id_hash, offer_data.nft_id_hash);
        
        let new_offer_data: Trade = Trade {
            nft_id_hash: offer_data.nft_id_hash,
            collection_id: offer_data.collection_id,
            price: offer_data.price,
            market_royalty: offer_data.market_royalty,
            creator_royalty: offer_data.creator_royalty,
            is_accepted: true,
            is_removed: true
        };
        offers.set(offer_id, new_offer_data);
        nft_transfer_future.await();
    }
}
