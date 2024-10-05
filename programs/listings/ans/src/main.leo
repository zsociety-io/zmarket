import aleo_name_service_registry_v4.aleo;
import zmarket_marketplace_volume.aleo;
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
        is_private: bool,
        is_live: bool
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


    async transition list_private(
        nft: aleo_name_service_registry_v4.aleo/NFT,
        public price: u64, // total price paid by seller
        public listing_id: field
    ) -> (PrivateListing, Future) {
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
            nft.data.metadata[0u8],
            transfer_future
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
        name_hash: field,
        transfer_future: Future
    ){
        assert(listings.contains(listing_id).not());
        let listing_data: ListingData = ListingData {
            nft_commit: nft_commit,
            price: price,
            name_hash: name_hash,
            is_private: true,
            is_live: true
        };
        listings.set(listing_id, listing_data);
        transfer_future.await();
    }

    
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
        assert(listing_data.is_live);
        assert(listing_data.is_private);
        assert_eq(nft_commit, listing_data.nft_commit);
        let new_listing_data: ListingData = ListingData {
            nft_commit: listing_data.nft_commit,
            price: listing_data.price,
            name_hash: listing_data.name_hash,
            is_private: listing_data.is_private,
            is_live: false
        }; 
        listings.set(listing_id, new_listing_data);
        transfer_future.await();
    }

    /*
    async function list_public() {
        return ;
    }
    */

}
