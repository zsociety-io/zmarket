
import nft_registry_v3.aleo;
import nft_collections_v3.aleo;


program zmarket_royalties_v3.aleo {
    const INITIAL_ADMIN: address = aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax;
    const ADMIN_NFTS_COLLECTION_ID: field = 0field;
    const ROYALTY_NFTS_EDITION: scalar = 0scalar;
    const ADMIN_NFTS_EDITION: scalar = 0scalar;

    const ROYALTY_NFTS_COLLECTION_ID: field = 1234field;
    const MARKET_RESERVED_COLLECTION_ID: field = 5678field;


    mapping royalties: field => u16;
    // collection_id => royalties_permyriad


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

    inline hash_admin_nft_id(collection_id: field) -> field {
        let nft_data: Data = field_nft_data(collection_id);
        let admin_nft_id_hash: field = hash_nft_id(
            ADMIN_NFTS_COLLECTION_ID,
            nft_data,
            ADMIN_NFTS_EDITION
        );
        return admin_nft_id_hash;
    }


    async transition initialize_marketplace(
        public market_fee_permyriad: u16,
        public royalty_col_royalty_permyriad: u16,
        public royalty_base_uri: [field; 4],
        public royalty_metadata_uri: [field; 4],
        public market_base_uri: [field; 4],
        public market_metadata_uri: [field; 4]
    ) -> Future {
        assert_eq(self.caller, INITIAL_ADMIN);
        let (royalty_admin_nft_view, register_royalty_collection_ft): (
            nft_records_v3.aleo/NFTView, Future
        ) = nft_collections_v3.aleo/register_collection_public(
            ROYALTY_NFTS_COLLECTION_ID,
            royalty_base_uri,
            royalty_metadata_uri
        );
        let (market_admin_nft_view, register_market_collection_ft): (
            nft_records_v3.aleo/NFTView, Future
        ) = nft_collections_v3.aleo/register_collection_public(
            MARKET_RESERVED_COLLECTION_ID,
            market_base_uri,
            market_metadata_uri
        );
        let (royalty_royalty_nft_view, mint_royalty_royalty_nft_future): (
            nft_records_v3.aleo/NFTView, Future
        ) = nft_registry_v3.aleo/mint_public(
                self.caller,
                ROYALTY_NFTS_COLLECTION_ID,
                field_nft_data(ROYALTY_NFTS_COLLECTION_ID),
                ROYALTY_NFTS_EDITION
        );
        let (market_royalty_nft_view, mint_market_royalty_nft_future): (
            nft_records_v3.aleo/NFTView, Future
        ) = nft_registry_v3.aleo/mint_public(
                self.caller,
                ROYALTY_NFTS_COLLECTION_ID,
                field_nft_data(MARKET_RESERVED_COLLECTION_ID),
                ROYALTY_NFTS_EDITION
        );
        let (transfer_market_admin_nft_view, transfer_market_admin_nft_ft): (
            nft_records_v3.aleo/NFTView, Future
        ) = nft_registry_v3.aleo/transfer_public(
                ADMIN_NFTS_COLLECTION_ID,
                market_admin_nft_view.data,
                market_admin_nft_view.edition,
                self.caller
            );
        let initialize_marketplace_future: Future
            = finalize_initialize_marketplace(
                market_fee_permyriad,
                royalty_col_royalty_permyriad,
                register_royalty_collection_ft,
                register_market_collection_ft,
                mint_royalty_royalty_nft_future,
                mint_market_royalty_nft_future,
                transfer_market_admin_nft_ft
            );
        return initialize_marketplace_future;
    }
    async function finalize_initialize_marketplace(
        market_fee_permyriad: u16,
        royalty_col_royalty_permyriad: u16,
        register_royalty_collection_ft: Future,
        register_market_collection_ft: Future,
        mint_royalty_royalty_nft_future: Future,
        mint_market_royalty_nft_future: Future,
        transfer_market_admin_nft_ft: Future,
    ){
        assert(market_fee_permyriad <= 10_000u16);
        royalties.set(MARKET_RESERVED_COLLECTION_ID, market_fee_permyriad);

        assert(royalty_col_royalty_permyriad <= 10_000u16);
        royalties.set(ROYALTY_NFTS_COLLECTION_ID, royalty_col_royalty_permyriad);

        register_royalty_collection_ft.await();
        register_market_collection_ft.await();
        mint_royalty_royalty_nft_future.await();
        mint_market_royalty_nft_future.await();
        transfer_market_admin_nft_ft.await();
    }


    async transition list_collection_private(
        admin_nft: nft_records_v3.aleo/NFT,
        private royalty_holder: address,
        public royalty_permyriad: u16,
        public listed_collection_id: field // Only relevant in case of market admin listing
    ) -> (nft_records_v3.aleo/NFT, Future){
        let list_as_market_admin: bool = (
            admin_nft.collection_id == MARKET_RESERVED_COLLECTION_ID
        );
        assert(
            list_as_market_admin
            || admin_nft.collection_id == ADMIN_NFTS_COLLECTION_ID
        );
        let collection_id: field = list_as_market_admin ? 
            listed_collection_id : 
            admin_nft.data.metadata;
        let (royalty_nft, mint_royalty_future): (
            nft_records_v3.aleo/NFT, Future
        ) = nft_registry_v3.aleo/mint_private_as_public(
                royalty_holder,
                ROYALTY_NFTS_COLLECTION_ID,
                field_nft_data(collection_id),
                ROYALTY_NFTS_EDITION
        );
        let list_collection_private_future: Future = fin_list_collection_private(
            collection_id,
            royalty_permyriad,
            mint_royalty_future
        );
        return (royalty_nft, list_collection_private_future);
    }
    async function fin_list_collection_private(
        collection_id: field,
        royalty_permyriad: u16,
        mint_royalty_future: Future
    ){
        assert(royalties.contains(collection_id).not());
        assert(royalty_permyriad <= 10_000u16);
        royalties.set(collection_id, royalty_permyriad);
        mint_royalty_future.await();
    }


    async transition list_collection_public(
        public collection_id: field,
        public royalty_holder: address,
        public royalty_permyriad: u16,
        public list_as_market_admin: bool
    ) -> Future {
        let admin_nft_id_hash: field = hash_admin_nft_id(collection_id);
        let (nft_view, mint_royalty_future): (
            nft_records_v3.aleo/NFTView, Future
        ) = nft_registry_v3.aleo/mint_public(
                royalty_holder,
                ROYALTY_NFTS_COLLECTION_ID,
                field_nft_data(collection_id),
                ROYALTY_NFTS_EDITION
        );
        let list_collection_public_future: Future 
            = finalize_list_collection_public(
                list_as_market_admin,
                collection_id,
                self.caller,
                royalty_permyriad,
                admin_nft_id_hash,
                mint_royalty_future
            );
        return list_collection_public_future;
    }
    async function finalize_list_collection_public(
        list_as_market_admin: bool,
        collection_id: field,
        caller: address,
        royalty_permyriad: u16,
        admin_nft_id_hash: field,
        mint_royalty_future: Future
    ){
        // authorized_caller is either market admin or collection admin
        let nft_id_hash: field = list_as_market_admin ? 
            hash_admin_nft_id(MARKET_RESERVED_COLLECTION_ID):
            admin_nft_id_hash;
        let authorized_caller: address = nft_registry_v3.aleo/nft_owners.get(
            nft_id_hash
        );
        assert_eq(authorized_caller, caller);
        assert(royalties.contains(collection_id).not());
        assert(royalty_permyriad <= 10000u16);
        royalties.set(collection_id, royalty_permyriad);
        mint_royalty_future.await();
    }


    async transition update_royalty_private(
        admin_nft: nft_records_v3.aleo/NFT,
        public new_royalty_permyriad: u16,
        public updated_collection_id: field // Only relevant in case of market admin listing
    ) -> Future{
        let update_as_market_admin: bool = (
            admin_nft.collection_id == MARKET_RESERVED_COLLECTION_ID
        );
        assert(
            update_as_market_admin
            || admin_nft.collection_id == ADMIN_NFTS_COLLECTION_ID
        );
        let collection_id: field = update_as_market_admin ? 
            updated_collection_id : 
            admin_nft.data.metadata;

        let update_royalty_private_future: Future = finalize_update_royalty_private(
            collection_id,
            new_royalty_permyriad
        );
        return update_royalty_private_future;
    }
    async function finalize_update_royalty_private(
        collection_id: field, royalty_permyriad: u16
    ){
        assert(royalties.contains(collection_id));
        assert(royalty_permyriad <= 10000u16);
        royalties.set(collection_id, royalty_permyriad);
    }


    async transition update_royalty_public(
        collection_id: field,
        public new_royalty_permyriad: u16,
        public update_as_market_admin: bool
    ) -> Future {
        let admin_nft_id_hash: field = hash_admin_nft_id(collection_id);
        let update_royalty_public_future: Future = finalize_update_royalty_public(
            update_as_market_admin,
            collection_id,
            new_royalty_permyriad,
            admin_nft_id_hash,
            self.caller
        );
        return update_royalty_public_future;
    }
    async function finalize_update_royalty_public(
        update_as_market_admin: bool,
        collection_id: field,
        royalty_permyriad: u16,
        admin_nft_id_hash: field,
        caller: address
    ){
        let nft_id_hash: field = update_as_market_admin ? 
            hash_admin_nft_id(MARKET_RESERVED_COLLECTION_ID):
            admin_nft_id_hash;
        let authorized_caller: address = nft_registry_v3.aleo/nft_owners.get(
            nft_id_hash
        );
        assert_eq(authorized_caller, caller);

        assert(royalties.contains(collection_id));
        assert(royalty_permyriad <= 10_000u16);
        royalties.set(collection_id, royalty_permyriad);
    }
}
