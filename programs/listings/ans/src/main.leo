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
        is_public: bool
    }


    inline commit_nft(
        nft_data: data,
        nft_edition: scalar
    ) -> field {
        let data_hash: field = BHP256::hash_to_field(nft_data);
        let commitment: field = BHP256::commit_to_field(data_hash, nft_edition);
        return commitment;
    }


    mapping public_listings: field => PublicListingData;
    // listing_id => public_listing_data;

    mapping private_listings: field => PrivateListingData;
    // listing_id => private_listing_data;

    mapping commit_to_data: field => data;
    // listing_id => data;



    async transition list_private(
        nft: aleo_name_service_registry_v4.aleo/NFT,
        public price: u64 // total price paid by seller
    ) -> (PrivateListing, Future) {
        let (nft_view, transfer_future): (
            aleo_name_service_registry_v4.aleo/NFTView, Future
        ) = aleo_name_service_registry_v4.aleo/transfer_private_to_public(
                nft, self.address
            );
        let nft_commit: field = commit_nft(nft.data, nft.edition);
        let private_listing: PrivateListing = PrivateListing {
            owner: self.signer,
            nft_commit: nft_commit,
            price: price
        };
        let list_private_future: Future = finalize_list_private(
            nft_commit,
            price,
            nft_data.metadata[0],
            transfer_future
        );
        return (
            private_listing,
            future,
        );
    }
    async function finalize_list_private(
        nft_commit: field,
        price: bool,
        name_hash: field,
        transfer_future: Future
    ){
        let private_listing_data: PrivateListingData = PrivateListingData{
            nft_commit: nft_commit,
            price: price,
            name_hash: name_hash
        };
        private_listings.set(nft_commit, private_listing_data);
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
                nft_data, nft_edition, self.address
            );
        let nft_commit: field = commit_nft(nft_data, nft_edition);
        assert_eq(private_listing.nft_commit, );

        let list_private_future: Future = finalize_unlist_private(
            nft_commit,
            price,
            transfer_future
        );
        return (
            nft,
            future,
        );
    }
    async function finalize_unlist_private(
        nft_commit: field,
        price: bool,
        transfer_future: Future
    ){
        let private_listing_data: PrivateListingData = PrivateListingData{
            nft_commit: nft_commit,
            price: price,
        };
        private_listings.set(nft_commit, private_listing_data);
        transfer_future.await();
    }

    async function list_public() {
        return ;
    }


}
