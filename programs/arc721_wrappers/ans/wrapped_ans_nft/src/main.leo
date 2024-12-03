import nft_registry_v3.aleo;
import aleo_name_service_registry_v4.aleo;
import nft_collections_v3.aleo;


program wrapped_ans_nft_v3.aleo {
    const WRAPPED_ANS_COLLECTION_ID: field = 123829191909212120210201field;
    const ADMIN_NFTS_COLLECTION_ID: field = 0field;

    const ADMIN_NFTS_EDITION: scalar = 0scalar;

    /*
        *********************************************************************
        ******************** Called by collection admin *********************
        *********************************************************************
    */


    async transition initialize(
        public base_uri: [field; 4],
        public metadata_uri: [field; 4]
    ) -> Future {
        let (nft_view, register_collection_future): (
            nft_records_v3.aleo/NFTView, Future
        ) = nft_collections_v3.aleo/register_collection_public(
            WRAPPED_ANS_COLLECTION_ID,
            base_uri,
            metadata_uri
        );
        return finalize_initialize(
            register_collection_future
        );
    }
    async function finalize_initialize(
        register_collection_future: Future
    ){
        register_collection_future.await();
    }


    async transition withdraw_admin(
        public base_uri: [field; 4],
        public metadata_uri: [field; 4]
    ) -> (nft_records_v3.aleo/NFT, Future) {
        let (transfer_admin_nft, transfer_admin_nft_future): (
            nft_records_v3.aleo/NFT, Future
        ) = nft_registry_v3.aleo/transfer_public_to_private(
            ADMIN_NFTS_COLLECTION_ID,
            Data { metadata: WRAPPED_ANS_COLLECTION_ID },
            ADMIN_NFTS_EDITION,
            self.signer
        );
        let withdraw_admin_future: Future = finalize_withdraw_admin(
            self.signer as field,
            transfer_admin_nft_future
        );
        return (transfer_admin_nft, withdraw_admin_future);
    }
    async function finalize_withdraw_admin(
        signer: field,
        transfer_admin_nft_future: Future
    ){
        assert_eq(signer, aleo_name_service_registry_v4.aleo/general_settings.get(7u8));
        transfer_admin_nft_future.await();
    }


    /*
        *********************************************************************
        ********************** Called by token owner ************************
        *********************************************************************
    */


    async transition wrap_private(
        ans_nft: aleo_name_service_registry_v4.aleo/NFT,
        private recipient: address,
    ) -> (nft_records_v3.aleo/NFT, Future) {
        let (ans_view, ans_future): (
            aleo_name_service_registry_v4.aleo/NFTView, Future
        ) = aleo_name_service_registry_v4.aleo/transfer_private_to_public(
                ans_nft,
                self.address
            );
        let (registry_nft, registry_future): (
            nft_records_v3.aleo/NFT, Future
        ) = nft_registry_v3.aleo/mint_private_as_public(
            recipient,
            WRAPPED_ANS_COLLECTION_ID,
            Data {
                metadata: ans_nft.data.metadata[0u8]
            },
            ans_nft.edition,
        );
        let wrap_private_future: Future = finalize_wrap_private(
            ans_future,
            registry_future
        );
        return (registry_nft, wrap_private_future);
    }
    async function finalize_wrap_private(
        ans_future: Future,
        registry_future: Future
    ){
        ans_future.await();
        registry_future.await();
    }


    async transition wrap_private_to_public(
        ans_nft: aleo_name_service_registry_v4.aleo/NFT,
        public recipient: address,
    ) -> Future {
        let (ans_view, ans_future): (
            aleo_name_service_registry_v4.aleo/NFTView, Future
        ) = aleo_name_service_registry_v4.aleo/transfer_private_to_public(
            ans_nft,
            self.address
        );
        let (nft_view, registry_future): (
            nft_records_v3.aleo/NFTView, Future
        ) = nft_registry_v3.aleo/mint_public(
            recipient,
            WRAPPED_ANS_COLLECTION_ID,
            Data {
                metadata: ans_nft.data.metadata[0u8]
            },
            ans_nft.edition,
        );
        let wrap_private_to_public_future: Future = fin_wrap_private_to_public(
            ans_future,
            registry_future
        );
        return wrap_private_to_public_future;
    }
    async function fin_wrap_private_to_public(
        ans_future: Future,
        registry_future: Future
    ){
        ans_future.await();
        registry_future.await();
    }
    
    
    // aleo_name_service_registry_v4.aleo/approve_public must be called first by caller
    async transition wrap_from_public(
        private ans_nft_data: data,
        private ans_nft_edition: scalar,
        public from: address,
        public recipient: address,
    ) -> Future {
        let (
            nft_view, ans_future
        ): (aleo_name_service_registry_v4.aleo/NFTView, Future) = aleo_name_service_registry_v4.aleo/transfer_from_public(
            from,
            self.address,
            ans_nft_data,
            ans_nft_edition,
        );
        let (registry_nft_view, registry_future): (
            nft_records_v3.aleo/NFTView, Future
        ) = nft_registry_v3.aleo/mint_public(
            recipient,
            WRAPPED_ANS_COLLECTION_ID,
            Data {
                metadata: ans_nft_data.metadata[0u8]
            },
            ans_nft_edition,
        );
        let wrap_from_public_future: Future = finalize_wrap_from_public(
            ans_future,
            registry_future
        );
        return wrap_from_public_future;
    }
    async function finalize_wrap_from_public(
        ans_future: Future,
        registry_future: Future
    ){
        ans_future.await();
        registry_future.await();
    }
    

    // aleo_name_service_registry_v4.aleo/approve_public must be called first by caller
    async transition wrap_public_as_signer(
        private ans_nft_data: data,
        private ans_nft_edition: scalar,
        public from: address,
        public recipient: address
    ) -> Future {
        let (
            nft_view, ans_future
        ): (aleo_name_service_registry_v4.aleo/NFTView, Future) = aleo_name_service_registry_v4.aleo/transfer_from_public(
            from,
            self.address,
            ans_nft_data,
            ans_nft_edition,
        );
        let (registry_nft_view, registry_future): (
            nft_records_v3.aleo/NFTView, Future
        ) = nft_registry_v3.aleo/mint_public(
            recipient,
            WRAPPED_ANS_COLLECTION_ID,
            Data {
                metadata: ans_nft_data.metadata[0u8]
            },
            ans_nft_edition,
        );
        let wrap_from_public_future: Future = fin_wrap_public_as_signer(
            ans_future,
            registry_future
        );
        return wrap_from_public_future;
    }
    async function fin_wrap_public_as_signer(
        ans_future: Future,
        registry_future: Future
    ){
        ans_future.await();
        registry_future.await();
    }


    // aleo_name_service_registry_v4.aleo/approve_public must be called first by caller
    async transition wrap_from_public_to_private(
        private ans_nft_data: data,
        private ans_nft_edition: scalar,
        public from: address,
        public recipient: address,
    ) -> (nft_records_v3.aleo/NFT, Future) {
        let (
            nft_view, ans_future
        ): (
            aleo_name_service_registry_v4.aleo/NFTView, Future
        ) = aleo_name_service_registry_v4.aleo/transfer_from_public(
            from,
            self.address,
            ans_nft_data,
            ans_nft_edition
        );
        let (registry_nft, registry_future): (
            nft_records_v3.aleo/NFT, Future
        ) = nft_registry_v3.aleo/mint_private_as_public(
            recipient,
            WRAPPED_ANS_COLLECTION_ID,
            Data {
                metadata: ans_nft_data.metadata[0u8]
            },
            ans_nft_edition,
        );
        let wrap_from_public_to_private_future: Future = fin_wrap_from_public_to_pv(
            ans_future,
            registry_future
        );
        return (registry_nft, wrap_from_public_to_private_future);
    }
    async function fin_wrap_from_public_to_pv(
        ans_future: Future,
        registry_future: Future
    ){
        ans_future.await();
        registry_future.await();
    }


    async transition unwrap_private(
        registry_nft: nft_records_v3.aleo/NFT,
        private recipient: address,
    ) -> (aleo_name_service_registry_v4.aleo/NFT, Future) {
        let (ans_nft, ans_future): (
            aleo_name_service_registry_v4.aleo/NFT, Future
        ) = aleo_name_service_registry_v4.aleo/transfer_public_to_private(
            data {
                metadata: [registry_nft.data.metadata, 0field, 0field, 0field]
            },
            registry_nft.edition,
            recipient
        );
        let registry_future: Future = nft_registry_v3.aleo/burn_private_as_public(registry_nft);
        let unwrap_private_future: Future = finalize_unwrap_private(
            ans_future,
            registry_future
        );
        return (ans_nft, unwrap_private_future);
    }
    async function finalize_unwrap_private(
        ans_future: Future,
        registry_future: Future
    ){
        ans_future.await();
        registry_future.await();
    }


    async transition unwrap_private_to_public(
        registry_nft: nft_records_v3.aleo/NFT,
        private recipient: address,
    ) -> Future {
        let (ans_nft_view, ans_future): (
            aleo_name_service_registry_v4.aleo/NFTView, Future
        ) = aleo_name_service_registry_v4.aleo/transfer_public(
            data {
                metadata: [registry_nft.data.metadata, 0field, 0field, 0field]
            },
            registry_nft.edition,
            recipient
        );
        let registry_future: Future = nft_registry_v3.aleo/burn_private_as_public(registry_nft);
        let unwrap_private_to_public_future: Future = fin_unwrap_private_to_pb(
            ans_future,
            registry_future
        );
        return unwrap_private_to_public_future;
    }
    async function fin_unwrap_private_to_pb(
        ans_future: Future,
        registry_future: Future
    ){
        ans_future.await();
        registry_future.await();
    }


    // aleo_name_service_registry_v4.aleo/approve_public must be called first by caller
    async transition unwrap_from_public(
        private registry_nft_data: Data,
        private registry_nft_edition: scalar,
        private from: address,
        private recipient: address,
    ) -> Future {
        let (ans_nft_view, ans_future): (
            aleo_name_service_registry_v4.aleo/NFTView, Future
        ) = aleo_name_service_registry_v4.aleo/transfer_public(
            data {
                metadata: [registry_nft_data.metadata, 0field, 0field, 0field]
            },
            registry_nft_edition,
            recipient
        );
        let (registry_nft_view, transfer_from_future): (
            nft_records_v3.aleo/NFTView, Future
        ) = nft_registry_v3.aleo/transfer_from_public(
            WRAPPED_ANS_COLLECTION_ID,
            from,
            self.address,
            registry_nft_data,
            registry_nft_edition,
        );
        let burn_future: Future = nft_registry_v3.aleo/burn_public(
            WRAPPED_ANS_COLLECTION_ID,
            registry_nft_data,
            registry_nft_edition
        );
        let unwrap_from_public_future: Future = finalize_unwrap_from_public(
            ans_future,
            transfer_from_future,
            burn_future,
        );
        return unwrap_from_public_future;
    }
    async function finalize_unwrap_from_public(
        ans_future: Future,
        transfer_from_future: Future,
        burn_future: Future,
    ){
        ans_future.await();
        transfer_from_future.await();
        burn_future.await();
    }


    // aleo_name_service_registry_v4.aleo/approve_public must be called first by caller
    async transition unwrap_from_public_to_pv(
        private registry_nft_data: Data,
        private registry_nft_edition: scalar,
        private recipient: address,
    ) -> (aleo_name_service_registry_v4.aleo/NFT, Future) {
        let (ans_nft, ans_future): (
            aleo_name_service_registry_v4.aleo/NFT, Future
        ) = aleo_name_service_registry_v4.aleo/transfer_public_to_private(
            data {
                metadata: [registry_nft_data.metadata, 0field, 0field, 0field]
            },
            registry_nft_edition,
            recipient
        );
        let (registry_nft_view, transfer_from_future): (
            nft_records_v3.aleo/NFTView, Future
        ) = nft_registry_v3.aleo/transfer_from_public(
            WRAPPED_ANS_COLLECTION_ID,
            self.caller,
            self.address,
            registry_nft_data,
            registry_nft_edition,
        );
        let burn_future: Future = nft_registry_v3.aleo/burn_public(
            WRAPPED_ANS_COLLECTION_ID,
            registry_nft_data,
            registry_nft_edition
        );
        let unwrap_from_public_to_pv_future: Future = fin_unwrap_ans_pb_from_to_pv(
            ans_future,
            transfer_from_future,
            burn_future,
        );
        return (ans_nft, unwrap_from_public_to_pv_future);
    }
    async function fin_unwrap_ans_pb_from_to_pv(
        ans_future: Future,
        transfer_from_future: Future,
        burn_future: Future,
    ){
        ans_future.await();
        transfer_from_future.await();
        burn_future.await();
    }


    async transition update_base_uri(
        public new_base_uri: [field; 4],
        public new_metadata_uri: [field; 4]
    ) -> Future {
        let registry_future: Future = nft_collections_v3.aleo/update_collection_public(
            WRAPPED_ANS_COLLECTION_ID,
            new_base_uri,
            new_metadata_uri
        );
        return finalize_update_base_uri(
            self.caller as field,
            //new_base_uri,
            registry_future
        );
    }
    async function finalize_update_base_uri(
        caller: field,
        //base_uri: [field; 4],
        registry_future: Future,
    ){
        assert_eq(caller, aleo_name_service_registry_v4.aleo/general_settings.get(7u8));
        /*
        assert_eq(aleo_name_service_registry_v4.aleo/general_settings.get(3u8) as field, base_uri[0u8]);
        assert_eq(aleo_name_service_registry_v4.aleo/general_settings.get(4u8) as field, base_uri[1u8]);
        assert_eq(aleo_name_service_registry_v4.aleo/general_settings.get(5u8) as field, base_uri[2u8]);
        assert_eq(aleo_name_service_registry_v4.aleo/general_settings.get(6u8) as field, base_uri[3u8]);
        */
        registry_future.await();
    }
}