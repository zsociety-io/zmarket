import zmarket_private_marketplace.aleo;
import zmarket_public_marketplace.aleo;
import wrapped_ans_nft_v3.aleo;


program zmarket_ans_listing_v3.aleo {
    const WRAPPED_ANS_COLLECTION_ID: field = 123829191909212120210201field;
    const ANS_EDITION: scalar = 0scalar;

    inline registry_nft_data(name_field: field) -> Data {
        return Data {
            metadata: name_field
        };
    }

    inline ans_nft_data(name_field: field) -> data {
        return data {
            metadata: [name_field, 0field, 0field, 0field]
        };
    }


    async transition initialize() -> Future{
        let approve_future: Future = nft_registry_v3.aleo/set_for_all_approval(
            WRAPPED_ANS_COLLECTION_ID,
            wrapped_ans_nft_v3.aleo,
            true
        );
        return finalize_initialize(approve_future);
    }
    async function finalize_initialize(approve_future: Future){
        approve_future.await();
    }


    async transition list_private(
        ans_nft: aleo_name_service_registry_v4.aleo/NFT,
        public listing_id: field,
        public listing_price: u64
    ) -> (zmarket_private_marketplace.aleo/PrivateListing, Future) {
        let (registry_nft, wrap_private_future): (
            nft_records_v3.aleo/NFT, Future
        ) = wrapped_ans_nft_v3.aleo/wrap_private(ans_nft, self.signer);
        let (private_listing, marketplace_future): (
            zmarket_private_marketplace.aleo/PrivateListing, Future
        ) = zmarket_private_marketplace.aleo/list_private(
            registry_nft, listing_id, listing_price
        );
        let list_private_future: Future = finalize_list_private(
            wrap_private_future,
            marketplace_future
        );
        return (
            private_listing,
            list_private_future,
        );
    }
    async function finalize_list_private(
        wrap_private_future: Future,
        marketplace_future: Future
    ){
        wrap_private_future.await();
        marketplace_future.await();
    }


    async transition unlist_private(
        private_listing: zmarket_private_marketplace.aleo/PrivateListing,
        public name_field: field,
    ) -> (aleo_name_service_registry_v4.aleo/NFT, Future) {
        let (registry_nft, marketplace_future): (
            nft_records_v3.aleo/NFT, Future
        ) = zmarket_private_marketplace.aleo/unlist_private(
            private_listing,
            WRAPPED_ANS_COLLECTION_ID,
            registry_nft_data(name_field),
            ANS_EDITION
        );
        let (ans_nft, unwrap_private_future): (
            nft_records_v3.aleo/NFT, Future
        ) = wrapped_ans_nft_v3.aleo/unwrap_private(registry_nft, self.signer);

        let unlist_private_future: Future = finalize_unlist_private(
            marketplace_future,
            unwrap_private_future
        );
        return (ans_nft, unlist_private_future);
    }
    async function finalize_unlist_private(
        marketplace_future: Future,
        unwrap_private_future: Future,
    ){
        marketplace_future.await();
        unwrap_private_future.await();
    }


    // zmarket_private_marketplace.aleo/update_private_listing can be called directly


    async transition accept_private_listing(
        public listing_id: field,
        payment: credits.aleo/credits,
        public name_field: field,
        public price: u64
    ) -> (aleo_name_service_registry_v4.aleo/NFT, Future) {
        let (registry_nft, marketplace_future): (
            nft_records_v3.aleo/NFT, Future
        ) = zmarket_private_marketplace.aleo/accept_withdraw_nft_pv_listing(
            listing_id,
            payment,
            WRAPPED_ANS_COLLECTION_ID,
            registry_nft_data(name_field),
            ANS_EDITION,
            price
        );
        let (ans_nft, unwrap_private_future): (
            aleo_name_service_registry_v4.aleo/NFT, Future
        ) = wrapped_ans_nft_v3.aleo/unwrap_private(registry_nft, self.signer);

        let accept_private_listing_future: Future = 
            finalize_accept_private_listing(
                marketplace_future,
                unwrap_private_future,
            );
        return (ans_nft, accept_private_listing_future);
    }
    async function finalize_accept_private_listing(
        marketplace_future: Future,
        unwrap_private_future: Future,
    ){
        marketplace_future.await();
        unwrap_private_future.await();
    }

    // zmarket_private_marketplace.aleo/offer_private can be called directly
    // zmarket_private_marketplace.aleo/unoffer_private can be called directly
    // zmarket_private_marketplace.aleo/update_private_offer can be called directly

    async transition accept_private_offer(
        public offer_id: field,
        public seller_amount: u64,
        ans_nft: aleo_name_service_registry_v4.aleo/NFT
    ) -> (credits.aleo/credits, Future) {
        let (registry_nft, wrap_private_future): (
            nft_records_v3.aleo/NFT, Future
        ) = wrapped_ans_nft_v3.aleo/wrap_private(ans_nft, self.signer);
        let (payment, marketplace_future):  (
            credits.aleo/credits, Future
        ) = zmarket_private_marketplace.aleo/accept_private_offer(
            offer_id, seller_amount, registry_nft
        );
        
        let accept_private_offer_future: Future = 
            finalize_accept_private_offer(
                wrap_private_future,
                marketplace_future
            );
        return (payment, accept_private_offer_future);
    }
    async function finalize_accept_private_offer(
        wrap_private_future: Future,
        marketplace_future: Future
    ){
        wrap_private_future.await();
        marketplace_future.await();
    }


    async transition withdraw_nft_private_offer(
        offer: zmarket_private_marketplace.aleo/PrivateOffer,
        private name_field: field,
    ) -> (aleo_name_service_registry_v4.aleo/NFT, Future) {
        let (registry_nft, marketplace_future): (
            nft_records_v3.aleo/NFT, Future
        ) = zmarket_private_marketplace.aleo/withdraw_nft_private_offer(
            offer,
            WRAPPED_ANS_COLLECTION_ID,
            registry_nft_data(name_field),
            ANS_EDITION
        );
        let (ans_nft, unwrap_private_future): (
            aleo_name_service_registry_v4.aleo/NFT, Future
        ) = wrapped_ans_nft_v3.aleo/unwrap_private(registry_nft, self.signer);
        let withdraw_nft_private_offer_future: Future = 
            fin_withdraw_nft_private_offer(
                marketplace_future,
                unwrap_private_future,
            );
        return (ans_nft, withdraw_nft_private_offer_future);
    }
    async function fin_withdraw_nft_private_offer(
        marketplace_future: Future,
        unwrap_private_future: Future,
    ){
        marketplace_future.await();
        unwrap_private_future.await();
    }


    /*
        Public listings:

        // zmarket_private_marketplace.aleo/list_public can be called directly
        // in parallel of aleo_name_service_registry_v4.aleo/approve_public
        // in parallel of nft_records_v3.aleo/set_for_approval on WRAPPED_ANS_COLLECTION_ID
    */

    async transition accept_public_listing_as_signer(
        public listing_id: field,
        public name_field: field,
        public price: u64,
        public seller: address,
        public seller_amount: u64
    ) -> Future {
        let wrap_future: Future = wrapped_ans_nft_v3.aleo/wrap_from_public(
            ans_nft_data(name_field),
            ANS_EDITION,
            seller,
            seller
        );
        let marketplace_future: Future
             = zmarket_public_marketplace.aleo/accept_public_listing_as_signer(
                listing_id,
                WRAPPED_ANS_COLLECTION_ID,
                registry_nft_data(name_field),
                ANS_EDITION,
                price,
                seller,
                seller_amount
            );
        let (nft_view, transfer_future): (
            nft_records_v3.aleo/NFTView, Future
        ) = nft_registry_v3.aleo/transfer_public_as_signer(
            WRAPPED_ANS_COLLECTION_ID,
            registry_nft_data(name_field),
            ANS_EDITION,
            self.address
        );
        let unwrap_future: Future = wrapped_ans_nft_v3.aleo/unwrap_from_public(
            registry_nft_data(name_field),
            ANS_EDITION,
            self.address,
            self.signer
        );
        let accept_public_listing_future: Future = 
            fin_accept_public_listing_as_sg(
                wrap_future,
                marketplace_future,
                transfer_future,
                unwrap_future
            );
        return accept_public_listing_future;
    }
    async function fin_accept_public_listing_as_sg(
        wrap_future: Future,
        marketplace_future: Future,
        transfer_future: Future,
        unwrap_future: Future
    ){
        wrap_future.await();
        marketplace_future.await();
        transfer_future.await();
        unwrap_future.await();
    }


    async transition accept_public_listing_private(
        payment: credits.aleo/credits,
        public listing_id: field,
        public name_field: field,
        public price: u64,
        public seller: address,
        public seller_amount: u64
    ) -> (credits.aleo/credits, aleo_name_service_registry_v4.aleo/NFT, Future) {
        let wrap_future: Future = wrapped_ans_nft_v3.aleo/wrap_from_public(
            ans_nft_data(name_field),
            ANS_EDITION,
            seller,
            seller
        );
        let (change, registry_nft, marketplace_future): (
            credits.aleo/credits, nft_records_v3.aleo/NFT, Future
        ) = zmarket_public_marketplace.aleo/accept_public_listing_private(
            listing_id,
            payment,
            WRAPPED_ANS_COLLECTION_ID,
            registry_nft_data(name_field),
            ANS_EDITION,
            price,
            seller,
            seller_amount
        );
        let (ans_nft, unwrap_future): (
            aleo_name_service_registry_v4.aleo/NFT, Future
        ) = wrapped_ans_nft_v3.aleo/unwrap_private(
            registry_nft,
            self.signer
        );
        let accept_public_listing_future: Future = 
            fin_accept_public_listing_pv(
                wrap_future,
                marketplace_future,
                unwrap_future
            );
        return (change, ans_nft, accept_public_listing_future);
    }
    async function fin_accept_public_listing_pv(
        wrap_future: Future,
        marketplace_future: Future,
        unwrap_future: Future
    ){
        wrap_future.await();
        marketplace_future.await();
        unwrap_future.await();
    }


    /*
        Public offers:

        zmarket_private_marketplace.aleo/list_public can be called directly
        in parallel nft_records_v3.aleo/set_for_approval: 
            buyer approves zmarket_ans_listing_v3.aleo to spend any WRAPPED_ANS_COLLECTION_ID
    */


    async transition accept_public_offer_private(
        public offer_id: field,
        public seller_amount: u64,
        public buyer: address,
        ans_nft: aleo_name_service_registry_v4.aleo/NFT
    ) -> (credits.aleo/credits, Future) {
        let (registry_nft, wrap_future): (
            nft_records_v3.aleo/NFT, Future
        ) = wrapped_ans_nft_v3.aleo/wrap_private(
            ans_nft,
            self.signer
        );
        let (payment, marketplace_future): (
            credits.aleo/credits, Future
        ) = zmarket_public_marketplace.aleo/accept_public_offer_private(
            offer_id,
            seller_amount,
            buyer,
            registry_nft
        );
        let unwrap_future: Future = wrapped_ans_nft_v3.aleo/unwrap_from_public(
            registry_nft_data(ans_nft.data.metadata[0u16]),
            ans_nft.edition,
            buyer,
            buyer
        );
        let accept_public_offer_future: Future = 
            fin_accept_public_offer_pv(
                wrap_future,
                marketplace_future,
                unwrap_future
            );
        return (payment, accept_public_offer_future);
    }
    async function fin_accept_public_offer_pv(
        wrap_future: Future,
        marketplace_future: Future,
        unwrap_future: Future
    ){
        wrap_future.await();
        marketplace_future.await();
        unwrap_future.await();
    }


    // Requires prior call to:
    // aleo_name_service_registry_v4.aleo/set_for_all_approval(wrapped_ans_nft_v3.aleo, true)

    async transition accept_public_offer(
        public offer_id: field,
        public seller_amount: u64,
        public buyer: address,
        public name_field: field
    ) -> Future {
        let wrap_future: Future = wrapped_ans_nft_v3.aleo/wrap_from_public(
            ans_nft_data(name_field),
            ANS_EDITION,
            self.caller,
            self.signer
        );
        let reg_nft_data: Data = registry_nft_data(name_field);
        let marketplace_future: Future = zmarket_public_marketplace.aleo/accept_public_offer_as_signer(
            offer_id,
            seller_amount,
            buyer,
            WRAPPED_ANS_COLLECTION_ID,
            reg_nft_data,
            ANS_EDITION
        );
        let unwrap_future: Future = wrapped_ans_nft_v3.aleo/unwrap_from_public(
            reg_nft_data,
            ANS_EDITION,
            buyer,
            buyer
        );
        let accept_public_offer_future: Future = 
            fin_accept_public_offer(
                wrap_future,
                marketplace_future,
                unwrap_future
            );
        return accept_public_offer_future;
    }
    async function fin_accept_public_offer(
        wrap_future: Future,
        marketplace_future: Future,
        unwrap_future: Future
    ){
        wrap_future.await();
        marketplace_future.await();
        unwrap_future.await();
    }
}
