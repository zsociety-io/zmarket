// todo: abstract marketplace
// todo: add volume measurement
// todo: add offers


import zmarket_marketplace.aleo;
import credits.aleo;
import aleo_name_service_registry_v4.aleo;


program zmarket_ans_listing.aleo {
    inline commit_nft(
        nft_data: data,
        nft_edition: scalar
    ) -> field {
        let data_hash: field = BHP256::hash_to_field(nft_data);
        let commitment: field = BHP256::commit_to_field(data_hash, nft_edition);
        return commitment;
    }

    struct NFTContent {
        data: data,
        edition: scalar
    }


    mapping listing_contents: field => NFTContent;
    // listing_id => listing_data;

    /*
        List as seller
    */
    async transition list_private(
        public listing_id: field,
        nft: aleo_name_service_registry_v4.aleo/NFT,
        public price: u64,
    ) -> (
        zmarket_marketplace.aleo/PrivateListing,
        aleo_name_service_registry_v4.aleo/NFTView,
        Future
    ) {
        let (nft_view, transfer_future): (
            aleo_name_service_registry_v4.aleo/NFTView, Future
        ) = aleo_name_service_registry_v4.aleo/transfer_private_to_public(
                nft, self.address
            );
        let nft_commit: field = commit_nft(nft.data, nft.edition);

        let (
            private_listing, zmarket_future
        ): (zmarket_marketplace.aleo/PrivateListing, Future) = 
            zmarket_marketplace.aleo/list_private(
                listing_id,
                nft_commit,
                self.signer,
                price
            );

        let list_private_future: Future = finalize_list_private(
            listing_id,
            nft.data,
            nft.edition,
            transfer_future,
            zmarket_future
        );
        return (
            private_listing,
            nft_view,
            list_private_future,
        );
    }
    async function finalize_list_private(
        listing_id: field,
        nft_data: data,
        nft_edition: scalar,
        transfer_future: Future,
        zmarket_future: Future
    ){
        transfer_future.await();
        zmarket_future.await();
        
        let nft_content: NFTContent = NFTContent {
            data: nft_data,
            edition: nft_edition
        };
        listing_contents.set(listing_id, nft_content);
    }

    /*
        Unlist as seller

        For ANS:

        let nft_data: data = data {
            metadata: [name_hash, 0field, 0field, 0field]
        };
        let nft_edition: scalar = 0scalar;
    */
    async transition unlist_private(
        private_listing: zmarket_marketplace.aleo/PrivateListing,
        public nft_data: data,
        public nft_edition: scalar
    ) -> (aleo_name_service_registry_v4.aleo/NFT, Future) {
        let nft_commit: field = commit_nft(nft_data, nft_edition);

        let (nft, transfer_future): (
            aleo_name_service_registry_v4.aleo/NFT, Future
        ) = aleo_name_service_registry_v4.aleo/transfer_public_to_private(
            nft_data, nft_edition, self.signer
        );

        let zmarket_future: Future = zmarket_marketplace.aleo/unlist_private(
            private_listing, nft_commit
        );

        let unlist_private_future: Future = finalize_unlist_private(
            private_listing.listing_id,
            nft_commit,
            transfer_future,
            zmarket_future
        );
        return (
            nft,
            unlist_private_future,
        );
    }
    async function finalize_unlist_private(
        listing_id: field,
        nft_commit: field,
        transfer_future: Future,
        zmarket_future: Future
    ){
        transfer_future.await();
        zmarket_future.await();
    }

    /*
        Accept listing as buyer
    */
    async transition accept_private_listing(
        public listing_id: field,
        public nft_data: data,
        public nft_edition: scalar,
        payment: credits.aleo/credits,
        public price: u64,
        old_volume: Volume,
    ) -> (
        aleo_name_service_registry_v4.aleo/NFT, 
        zmarket_marketplace.aleo/Volume,
        Future
    ) {
        let (nft, nft_transfer_future): (
            aleo_name_service_registry_v4.aleo/NFT, Future
        ) = aleo_name_service_registry_v4.aleo/transfer_public_to_private(
            nft_data, nft_edition, self.signer
        );
        let nft_commit: field = commit_nft(nft_data, nft_edition);

        let (
            new_volume, zmarket_future
        ): Future = zmarket_marketplace.aleo/accept_private_listing(
            listing_id,
            payment,
            nft_commit,
            price,
            old_volume
        );

        let accept_private_listing_future: Future = 
            finalize_accept_private_listing(
                listing_id,
                nft_commit,
                price,
                nft_transfer_future,
                zmarket_future,
            );
        return (
            nft,
            new_volume,
            accept_private_listing_future,
        );
    }
    async function finalize_accept_private_listing(
        nft_transfer_future: Future,
        zmarket_future: Future,
    ){
        nft_transfer_future.await();
        zmarket_future.await();
    }
}
