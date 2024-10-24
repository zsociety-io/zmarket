import credits.aleo;

program zmarket_marketplace.aleo {
    const MARKETPLACE_ROYALTY_INITIAL_OWNER: address = aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax;

    struct data {
        metadata: [field; 4]
    }

    record Royalty {
        owner: address,
        data: data,
        edition: scalar
    }

    struct ListingData {
        nft_commit: field,
        listing_program: address,
        price: u64,
        market_royalty: u16,
        creator_royalty: u16,
        is_private: bool,
        is_accepted: bool,
        is_removed: bool,
    }

    struct VolumeKey {
        account: address, // account who made the volume
        listing_program: address, // listing_program program where volume was made
        side: bool, // sell: true, buy: false
    }
    
    struct VolumeData {
        account: address, // account who made the volume
        listing_program: address, // listing_program program where volume was made
        side: bool, // sell: true, buy: false
        amount: u64 // amount of volume
    }

    record PrivateListing {
        owner: address,
        listing_id: field
    }

    record PrivateOffer {
        owner: address,
        nft_commit: field
    }

    record Volume {
        owner: address, // account who made the volume
        listing_program: address, // listing_program program where volume was made
        side: bool, // sell: true, buy: false
        amount: u64 // amount of volume
    }

    mapping listings: field => ListingData;
     // listing_id => listing_data

    mapping royalties: address => u16;
    // listing_program => royalties_permyriad

    mapping royalty_balances: address => u64;
    // listing_program => balance

    mapping volumes: field => VolumeData;
    // hash(VolumeKey) => VolumeData;


    inline max_u64(a: u64, b: u64) -> u64 {
        return (a > b) ? a : b;
    }


    async transition initialize_marketplace(
        public royalty_permyriad: u16
    ) -> (Royalty, Future){
        let initialize_marketplace_future: Future
            = finalize_initialize_marketplace(
                royalty_permyriad
            );
        assert_eq(self.caller, MARKETPLACE_ROYALTY_INITIAL_OWNER);
        let out_royalty: Royalty = Royalty {
            owner: self.signer,
            data: data {
                metadata: [self.address as field, 0field, 0field, 0field]
            },
            edition: 0scalar
        };
        return (out_royalty, initialize_marketplace_future);
    }
    async function finalize_initialize_marketplace(
        royalty_permyriad: u16
    ){
        assert(royalties.contains(self.address).not());
        assert(royalty_permyriad <= 10_000u16);
        royalties.set(self.address, royalty_permyriad);
    }


    async transition list_collection(
        private royalty_holder: address, public royalty_permyriad: u16
    ) -> (Royalty, Future){
        let listing_program: address = self.caller;
        let out_royalty: Royalty = Royalty {
            owner: royalty_holder,
            data: data {
                metadata: [listing_program as field, 0field, 0field, 0field]
            },
            edition: 0scalar
        };
        let list_collection_future: Future = finalize_list_collection(
            listing_program,
            royalty_permyriad
        );
        return (out_royalty, list_collection_future);
    }
    async function finalize_list_collection(
        listing_program: address, royalty_permyriad: u16
    ){
        assert(royalties.contains(listing_program).not());
        assert(royalty_permyriad <= 10000u16);
        royalties.set(listing_program, royalty_permyriad);
    }


    async transition update_royalty(
        old_royalty: Royalty,
        public new_royalty_permyriad: u16
    ) -> (Royalty, Future){
        let update_royalty_future: Future = finalize_update_royalty(
            old_royalty.data.metadata[0u16] as address,
            new_royalty_permyriad,
        );
        let new_royalty: Royalty = Royalty {
            owner: old_royalty.owner,
            data: old_royalty.data,
            edition: old_royalty.edition
        };
        return (new_royalty, update_royalty_future);
    }
    async function finalize_update_royalty(
        listing_program: address, royalty_permyriad: u16
    ){
        assert(royalty_permyriad <= 10000u16);
        royalties.set(listing_program, royalty_permyriad);
    }


    async transition withdraw_royalty_balance(
        old_royalty: Royalty,
        public amount: u64
    ) -> (Royalty, Future){
        let withdraw_royalty_balance_future: Future = finalize_withdraw_royalty_balance(
            old_royalty.data.metadata[0u16] as address,
            amount,
        );
        let new_royalty: Royalty = Royalty {
            owner: old_royalty.owner,
            data: old_royalty.data,
            edition: old_royalty.edition
        };
        return (new_royalty, withdraw_royalty_balance_future);
    }
    async function finalize_withdraw_royalty_balance(
        listing_program: address, amount: u64
    ){
        let old_balance: u64 = royalty_balances.get(listing_program);
        let new_balance: u64 = old_balance - amount;
        royalty_balances.set(listing_program, new_balance);
    }


    async transition list_private(
        public listing_id: field,
        public nft_commit: field,
        private listing_owner: address,
        public listing_price: u64,
    ) -> (PrivateListing, Future) {
        let listing_program: address = self.caller;
        let private_listing: PrivateListing = PrivateListing {
            owner: listing_owner,
            listing_id: listing_id
        };
        let list_private_future: Future = finalize_list_private(
            listing_id,
            nft_commit,
            listing_price,
            listing_program
        );
        return (
            private_listing,
            list_private_future,
        );
    }
    async function finalize_list_private(
        listing_id: field,
        nft_commit: field,
        price: u64,
        listing_program: address
    ){
        assert(listings.contains(listing_id).not());

        let market_royalty: u16 = royalties.get(self.address);
        let creator_royalty: u16 = royalties.get(listing_program);

        let market_royalty_amount: u64 = ((market_royalty as u64) * price).div(10000u64);
        let creator_royalty_amount: u64 = ((creator_royalty as u64) * price).div(10000u64);

        assert(price >= market_royalty_amount + creator_royalty_amount);
        
        let listing_data: ListingData = ListingData {
            nft_commit: nft_commit,
            listing_program: listing_program,
            price: price,
            market_royalty: market_royalty,
            creator_royalty: creator_royalty,
            is_private: true,
            is_accepted: false,
            is_removed: false
        };
        listings.set(listing_id, listing_data);
    }


    async transition unlist_private(
        private_listing: PrivateListing,
        public nft_commit: field,
    ) -> Future {
        let listing_program: address = self.caller;
        let unlist_private_future: Future = finalize_unlist_private(
            private_listing.listing_id,
            nft_commit,
            listing_program
        );
        return unlist_private_future;
    }
    async function finalize_unlist_private(
        listing_id: field,
        nft_commit: field,
        listing_program: address
    ){
        let listing_data: ListingData = listings.get(listing_id);
        assert(listing_data.is_removed.not());
        assert(listing_data.is_accepted.not());
        assert(listing_data.is_private);
        assert_eq(nft_commit, listing_data.nft_commit);
        assert_eq(listing_program, listing_data.listing_program);
        let new_listing_data: ListingData = ListingData {
            nft_commit: listing_data.nft_commit,
            listing_program: listing_data.listing_program,
            price: listing_data.price,
            market_royalty: listing_data.market_royalty,
            creator_royalty: listing_data.creator_royalty,
            is_private: listing_data.is_private,
            is_accepted: false,
            is_removed: true
        }; 
        listings.set(listing_id, new_listing_data);
    }


    async transition accept_private_listing(
        public listing_id: field,
        payment: credits.aleo/credits,
        public nft_commit: field,
        public price: u64,
        old_volume: Volume,
    ) -> (Volume, Future) {
        assert_eq(old_volume.listing_program, self.caller);
        assert(!old_volume.side);

        let new_volume: Volume = Volume {
            owner: self.signer,
            listing_program: self.caller,
            side: false,
            amount: old_volume.amount + price
        };
        let listing_program: address = self.caller;
        let (change, payment_credits_future): (
            credits.aleo/credits, Future
        ) = credits.aleo/transfer_private_to_public(
            payment, self.address, price
        );
        let accept_private_listing_future: Future = 
            finalize_accept_private_listing(
                listing_id,
                nft_commit,
                price,
                listing_program,
                payment_credits_future,
            );
        return (new_volume, accept_private_listing_future);
    }
    async function finalize_accept_private_listing(
        listing_id: field,
        nft_commit: field,
        price: u64,
        listing_program: address,
        payment_credits_future: Future,
    ){
        let listing_data: ListingData = listings.get(listing_id);
        assert(listing_data.is_private);
        assert(listing_data.is_accepted.not());
        assert(listing_data.is_removed.not());
        assert_eq(nft_commit, listing_data.nft_commit);
        assert_eq(price, listing_data.price);
        assert_eq(listing_program, listing_data.listing_program);

        let market_royalty: u16 = royalties.get(self.address);
        let creator_royalty: u16 = royalties.get(listing_program);

        let market_royalty_amount: u64 = ((market_royalty as u64) * price).div(10000u64);
        let creator_royalty_amount: u64 = ((creator_royalty as u64) * price).div(10000u64);
        let listing_amount: u64 = price - market_royalty_amount - creator_royalty_amount;

        let old_market_royalty_balance: u64 = royalty_balances.get(self.address);
        let old_creator_royalty_balance: u64 = royalty_balances.get(listing_program);
        let old_listing_balance: u64 = listing_balances.get(listing_id);

        let new_market_royalty_balance: u64 = old_market_royalty_balance - market_royalty_amount;
        let new_creator_royalty_balance: u64 = old_creator_royalty_balance - creator_royalty_amount;
        let new_listing_balance: u64 = old_listing_balance - listing_amount;

        royalty_balances.set(self.address, new_market_royalty_balance);
        royalty_balances.set(listing_program, new_creator_royalty_balance);
        listing_balances.set(listing_id, new_listing_balance);

        let new_listing_data: ListingData = ListingData {
            nft_commit: listing_data.nft_commit,
            listing_program: listing_data.listing_program,
            price: listing_data.price,
            market_royalty: listing_data.market_royalty,
            creator_royalty: listing_data.creator_royalty,
            is_private: listing_data.is_private,
            is_accepted: true,
            is_removed: false
        }; 

        listings.set(listing_id, new_listing_data);
        payment_credits_future.await();
    }


    async transition withdraw_listing_balance(
        old_private_listing: PrivateListing,
        public amount: u64,
        old_volume: Volume,
    ) -> (PrivateListing, Volume, Future){
        assert(old_volume.side);
        let new_volume: Volume = Volume {
            owner: self.signer,
            listing_program: old_volume.listing_program,
            side: true,
            amount: old_volume.amount + price
        };

        let withdraw_listing_balance_future: Future = finalize_withdraw_listing_balance(
            old_private_listing.listing_id,
            amount,
            old_volume.listing_program
        );
        let new_private_listing: PrivateListing = PrivateListing {
            owner: old_private_listing.owner,
            listing_id: old_private_listing.listing_id
        };
        return (
            new_private_listing,
            new_volume,
            withdraw_listing_balance_future
        );
    }
    async function finalize_withdraw_listing_balance(
        listing_id: field, amount: u64, listing_program: address
    ){
        let listing_data: ListingData = listings.get(listing_id);
        assert_eq(listing_data.listing_program, listing_program);
        let old_balance: u64 = listing_balances.get(listing_id);
        let new_balance: u64 = old_balance - amount;
        listing_balances.set(listing_id, new_balance);
    }
    

    async transition withdraw_listing_revenue(
        private_listing: PrivateListing,
        public price: u64,
        old_volume: Volume,
    ) -> (Volume, Future) {
        assert(old_volume.side);
        let new_volume: Volume = Volume {
            owner: self.signer,
            listing_program: old_volume.listing_program,
            side: true,
            amount: old_volume.amount + price
        };

        let seller_credits_future: Future = credits.aleo/transfer_public(
            private_listing.owner, seller_amount
        );
        let withdraw_listing_revenue_future: Future = finalize_withdraw_listing_revenue(
            private_listing.listing_id,
            price,
            market_royalty_permyriad,
            creator_royalty_permyriad,
            seller_credits_future,
        );
        return withdraw_listing_revenue_future;
    }
    async function finalize_withdraw_listing_revenue(
        listing_id: field,
        price: u64,
        market_royalty_permyriad: u16,
        creator_royalty_permyriad: u16,
        seller_credits_future: Future,
    ){
        let listing_data: ListingData = listings.get(listing_id);
        assert(listing_data.is_private);
        assert(listing_data.is_accepted);
        assert(listing_data.is_removed.not());
        assert_eq(price, listing_data.price);

        let market_royalty: Share =
            zmarket_royalty.aleo/royalties.get(listing_data.market_royalty_index);
        let creator_royalty: Share =
            ans_listing_royalty.aleo/royalties.get(listing_data.creator_royalty_index);
        assert_eq(market_royalty_permyriad, market_royalty.permyriad);
        assert_eq(creator_royalty_permyriad, creator_royalty.permyriad);



        let new_listing_data: ListingData = ListingData {
            nft_commit: listing_data.nft_commit,
            listing_program: listing_data.listing_program,
            price: listing_data.price,
            market_royalty: listing_data.market_royalty,
            creator_royalty: listing_data.creator_royalty,
            is_private: listing_data.is_private,
            is_accepted: true,
            is_removed: true
        }; 


        listings.set(listing_id, new_listing_data);
        seller_credits_future.await();
    }
    */
    

    transition add_volume(
        volume: Volume,
        amount: u64
    ) -> Volume {
        assert_eq(volume.listing_program, self.caller);
        return Volume {
            owner: self.signer,
            listing_program: self.caller,
            side: volume.side,
            amount: volume.amount + amount
        };
    }


    transition mint_volume(
        side: bool, 
        listing_program: address,
    ) -> Volume {
        return Volume{
            owner: self.signer,
            listing_program: listing_program,
            side: side,
            amount: 0u64
        };
    }


    transition join_volumes(
        volume0: Volume, volume1: Volume
    ) -> Volume{
        assert_eq(volume0.side, volume1.side);
        assert_eq(volume0.listing_program, volume1.listing_program);
        return Volume{
            owner: self.signer,
            listing_program: volume0.listing_program,
            side: volume0.side,
            amount: volume0.amount + volume1.amount
        };
    }


    async transition share_volume(
        private volume: Volume
    ) -> (Volume, Future){
        let out_volume: Volume = Volume {
            owner: volume.owner,
            listing_program: volume.listing_program,
            side: volume.side,
            amount: volume.amount
        };
        let share_volume_future: Future = set_volume(
            self.signer,
            volume.listing_program,
            volume.side,
            volume.amount
        );
        return (
            out_volume,
            share_volume_future
        );
    }

    async function set_volume(
        account: address,
        listing_program: address,
        side: bool,
        amount: u64
    ){
        let volume_key: VolumeKey = VolumeKey {
            account: account,
            listing_program: listing_program,
            side: side,
        };
        let volume_key_hash: field = BHP256::hash_to_field(volume_key);

        let old_volume_data: VolumeData = volumes.get(volume_key_hash);

        let new_volume_data: VolumeData = VolumeData {
            account: account,
            listing_program: listing_program,
            side: side,
            amount: max_u64(amount, old_volume_data.amount)
        };

        volumes.set(volume_key_hash, new_volume_data);
    }
}
