// todo: abstract marketplace
// todo: add volume measurement
// todo: add offers


import aleo_name_service_registry_v4.aleo;

import zmarket_marketplace.aleo;
import zmarket_royalty.aleo;
import ans_listing_royalty.aleo;
import credits.aleo;


program zmarket_ans_listing.aleo {
    record PrivateListing {
        owner: address,
        listing_id: field
    }

    record PrivateOffer {
        owner: address,
        nft_commit: field
    }

    struct ListingData {
        nft_commit: field,
        price: u64,
        name_hash: field,
        market_royalty_index: u16,
        creator_royalty_index: u16,
        is_private: bool,
        is_accepted: bool,
        is_removed: bool,
    }


    inline commit_nft(
        nft_data: data,
        nft_edition: scalar
    ) -> field {
        let data_hash: field = BHP256::hash_to_field(nft_data);
        let commitment: field = BHP256::commit_to_field(data_hash, nft_edition);
        return commitment;
    }


    mapping listings: field => ListingData;
    // listing_id => listing_data;

    /*
        List as seller
    */
    async transition list_private(
        nft: aleo_name_service_registry_v4.aleo/NFT,
        public price: u64,
        public listing_id: field
    ) -> (PrivateListing, aleo_name_service_registry_v4.aleo/NFTView, Future) {
        let (nft_view, transfer_future): (
            aleo_name_service_registry_v4.aleo/NFTView, Future
        ) = aleo_name_service_registry_v4.aleo/transfer_private_to_public(
                nft, self.address
            );
        let nft_commit: field = commit_nft(nft.data, nft.edition);
        let private_listing: PrivateListing = PrivateListing {
            owner: self.signer,
            listing_id: listing_id
        };
        let list_private_future: Future = finalize_list_private(
            listing_id,
            nft_commit,
            price,
            nft.data.metadata[0u16],
            transfer_future
        );
        return (
            private_listing,
            nft_view,
            list_private_future,
        );
    }
    async function finalize_list_private(
        listing_id: field,
        nft_commit: field,
        price: u64,
        name_hash: field,
        transfer_future: Future
    ){
        assert(listings.contains(listing_id).not());

        let market_royalty_index: u16 =
            zmarket_royalty.aleo/royalties_length.get(true) - 1u16;
        let creator_royalty_index: u16 =
            ans_listing_royalty.aleo/royalties_length.get(true) - 1u16;
        
        let listing_data: ListingData = ListingData {
            nft_commit: nft_commit,
            price: price,
            name_hash: name_hash,
            market_royalty_index: market_royalty_index,
            creator_royalty_index: creator_royalty_index,
            is_removed: false,
            is_private: true,
            is_accepted: false,
        };
        listings.set(listing_id, listing_data);
        transfer_future.await();
    }

    /*
        Unlist as seller
    */
    async transition unlist_private(
        private_listing: PrivateListing,
        public name_hash: field,
    ) -> (aleo_name_service_registry_v4.aleo/NFT, Future) {
        let nft_data: data = data {
            metadata: [name_hash, 0field, 0field, 0field]
        };
        let nft_edition: scalar = 0scalar;
        let (nft, transfer_future): (
            aleo_name_service_registry_v4.aleo/NFT, Future
        ) = aleo_name_service_registry_v4.aleo/transfer_public_to_private(
            nft_data, nft_edition, self.signer
        );
        let nft_commit: field = commit_nft(nft_data, nft_edition);

        let list_private_future: Future = finalize_unlist_private(
            private_listing.listing_id,
            nft_commit,
            transfer_future
        );
        return (
            nft,
            list_private_future,
        );
    }
    async function finalize_unlist_private(
        listing_id: field,
        nft_commit: field,
        transfer_future: Future
    ){
        let listing_data: ListingData = listings.get(listing_id);
        assert(listing_data.is_removed.not());
        assert(listing_data.is_accepted.not());
        assert(listing_data.is_private);
        assert_eq(nft_commit, listing_data.nft_commit);
        let new_listing_data: ListingData = ListingData {
            nft_commit: listing_data.nft_commit,
            price: listing_data.price,
            name_hash: listing_data.name_hash,
            is_private: listing_data.is_private,
            market_royalty_index: listing_data.market_royalty_index,
            creator_royalty_index: listing_data.creator_royalty_index,
            is_accepted: false,
            is_removed: true
        }; 
        listings.set(listing_id, new_listing_data);
        transfer_future.await();
    }

    /*
        Accept listing as buyer
    */
    async transition accept_private_listing(
        public listing_id: field,
        public name_hash: field,
        payment: credits.aleo/credits,
        public price: u64,
        public market_royalty_permyriad: u16,
        public market_royalty_holder: address,
        public creator_royalty_permyriad: u16,
        public creator_royalty_holder: address,
    ) -> (aleo_name_service_registry_v4.aleo/NFT, Future) {
        let nft_data: data = data {
            metadata: [name_hash, 0field, 0field, 0field]
        };
        let nft_edition: scalar = 0scalar;
        let (nft, nft_future): (
            aleo_name_service_registry_v4.aleo/NFT, Future
        ) = aleo_name_service_registry_v4.aleo/transfer_public_to_private(
            nft_data, nft_edition, self.signer
        );
        let nft_commit: field = commit_nft(nft_data, nft_edition);

        let market_royality_amount: u64 = ((market_royalty_permyriad as u64) * price).div(10000u64);
        let creator_royality_amount: u64 = ((creator_royalty_permyriad as u64) * price).div(10000u64);
        let seller_amount: u64 = price - market_royality_amount - creator_royality_amount;

        let (change, payment_credits_future): (
            credits.aleo/credits, Future
        ) = credits.aleo/transfer_private_to_public(
            payment, self.address, price
        );
        let creator_credits_future: Future = credits.aleo/transfer_public(
            creator_royalty_holder, creator_royality_amount
        );
        let market_credits_future: Future = credits.aleo/transfer_public(
            market_royalty_holder, market_royality_amount
        );
        let accept_private_listing_future: Future = 
            finalize_accept_private_listing(
                listing_id,
                nft_commit,
                price,
                market_royalty_permyriad,
                market_royalty_holder,
                creator_royalty_permyriad,
                creator_royalty_holder,
                nft_future,
                payment_credits_future,
                creator_credits_future,
                market_credits_future
            );
        return (
            nft,
            accept_private_listing_future,
        );
    }
    async function finalize_accept_private_listing(
        listing_id: field,
        nft_commit: field,
        price: u64,
        market_royalty_permyriad: u16,
        market_royalty_holder: address,
        creator_royalty_permyriad: u16,
        creator_royalty_holder: address,
        nft_future: Future,
        payment_credits_future: Future,
        royalties_credits_future: Future,
        market_credits_future: Future,
    ){
        let listing_data: ListingData = listings.get(listing_id);
        assert(listing_data.is_private);
        assert(listing_data.is_accepted.not());
        assert(listing_data.is_removed.not());
        assert_eq(nft_commit, listing_data.nft_commit);
        assert_eq(price, listing_data.price);

        let market_royalty: Share =
            zmarket_royalty.aleo/royalties.get(listing_data.market_royalty_index);
        let creator_royalty: Share =
            ans_listing_royalty.aleo/royalties.get(listing_data.creator_royalty_index);
        assert_eq(market_royalty_permyriad, market_royalty.permyriad);
        assert_eq(market_royalty_holder, market_royalty.holder);
        assert_eq(creator_royalty_permyriad, creator_royalty.permyriad);
        assert_eq(creator_royalty_holder, creator_royalty.holder);

        let new_listing_data: ListingData = ListingData {
            nft_commit: listing_data.nft_commit,
            price: listing_data.price,
            name_hash: listing_data.name_hash,
            market_royalty_index: listing_data.market_royalty_index,
            creator_royalty_index: listing_data.creator_royalty_index,
            is_private: listing_data.is_private,
            is_accepted: true,
            is_removed: false
        }; 

        listings.set(listing_id, new_listing_data);
        nft_future.await();
        payment_credits_future.await();
        royalties_credits_future.await();
        market_credits_future.await();
    }
    
    /*
        Withdraw payment as seller
    */

    async transition withdraw_payment(
        private_listing: PrivateListing,
        public price: u64,
        public market_royalty_permyriad: u16,
        public creator_royalty_permyriad: u16,
    ) -> (aleo_name_service_registry_v4.aleo/NFT, Future) {
        let market_royality_amount: u64 = ((market_royalty_permyriad as u64) * price).div(10000u64);
        let creator_royality_amount: u64 = ((creator_royalty_permyriad as u64) * price).div(10000u64);
        let seller_amount: u64 = price - market_royality_amount - creator_royality_amount;

        let seller_credits_future: Future = credits.aleo/transfer_public(
            private_listing.owner, seller_amount
        );
        let withdraw_payment_future: Future = finalize_withdraw_payment(
            private_listing.listing_id,
            price,
            market_royalty_permyriad,
            creator_royalty_permyriad,
            nft_future,
            seller_credits_future,
        );
        return (
            nft,
            withdraw_payment_future,
        );
    }
    async function finalize_withdraw_payment(
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
            price: listing_data.price,
            name_hash: listing_data.name_hash,
            market_royalty_index: listing_data.market_royalty_index,
            creator_royalty_index: listing_data.creator_royalty_index,
            is_private: listing_data.is_private,
            is_accepted: true,
            is_removed: true
        }; 

        listings.set(listing_id, new_listing_data);
        seller_credits_future.await();
    }
}
