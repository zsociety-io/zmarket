import zmarket_private_marketplace.aleo;
import zmarket_public_marketplace.aleo;
import nft_registry_v3.aleo;
import credits.aleo;


program zmarket_batch_withdraw.aleo {
    const ADMIN_NFTS_COLLECTION_ID: field = 0field;
    const ADMIN_NFTS_EDITION: scalar = 0scalar;

    async transition withdraw_royalty_private(
        royalty_nft: nft_records_v3.aleo/NFT,
        public amount_private_markerplace: u64,
        public amount_public_markerplace: u64
    ) -> (credits.aleo/credits, Future){
        let (payment_private_marketplace, withdraw_private_future): (
            credits.aleo/credits, Future
        ) = zmarket_public_marketplace.aleo/withdraw_royalty_private(
            royalty_nft, amount_private_markerplace
        );
        let (payment_public_marketplace, withdraw_public_future): (
            credits.aleo/credits, Future
        ) = zmarket_public_marketplace.aleo/withdraw_royalty_private(
            royalty_nft, amount_public_markerplace
        );
        let payment: credits.aleo/credits = credits.aleo/join(
            payment_private_marketplace, payment_public_marketplace
        );
        let withdraw_royalty_private_future: Future = fin_withdraw_royalty_private(
            withdraw_private_future,
            withdraw_public_future
        );
        return (payment, withdraw_royalty_private_future);
    }
    async function fin_withdraw_royalty_private(
        withdraw_private_future: Future, withdraw_public_future: Future
    ){
        withdraw_private_future.await();
        withdraw_public_future.await();
    }


    async transition withdraw_listing_balance_2(
        old_private_listing_0: zmarket_private_marketplace.aleo/PrivateListing,
        old_private_listing_1: zmarket_private_marketplace.aleo/PrivateListing,
        public amounts: [u64; 2],
    ) -> (credits.aleo/credits, Future){
        let (new_private_listing_0, payment_0, payment_future_0): (
            zmarket_private_marketplace.aleo/PrivateListing, credits.aleo/credits, Future
        ) = zmarket_private_marketplace.aleo/withdraw_listing_balance(
            old_private_listing_0, amounts[0u16]
        );
        let (new_private_listing_1, payment_1, payment_future_1): (
            zmarket_private_marketplace.aleo/PrivateListing, credits.aleo/credits, Future
        ) = zmarket_private_marketplace.aleo/withdraw_listing_balance(
            old_private_listing_1, amounts[1u16]
        );
        let payment: credits.aleo/credits = credits.aleo/join(
            payment_0, payment_1
        );
        let withdraw_listing_balance_2_fut: Future = fin_withdraw_listing_balance_2(
            payment_future_0,
            payment_future_1
        );
        return (payment, withdraw_listing_balance_2_fut);
    }
    async function fin_withdraw_listing_balance_2(
        payment_future_0: Future, payment_future_1: Future
    ){
        payment_future_0.await();
        payment_future_1.await();
    }


    async transition withdraw_listing_balance_3(
        old_private_listing_0: zmarket_private_marketplace.aleo/PrivateListing,
        old_private_listing_1: zmarket_private_marketplace.aleo/PrivateListing,
        old_private_listing_2: zmarket_private_marketplace.aleo/PrivateListing,
        public amounts: [u64; 3],
    ) -> (credits.aleo/credits, Future){
        let (new_private_listing_0, payment_0, payment_future_0): (
            zmarket_private_marketplace.aleo/PrivateListing, credits.aleo/credits, Future
        ) = zmarket_private_marketplace.aleo/withdraw_listing_balance(
            old_private_listing_0, amounts[0u16]
        );
        let (new_private_listing_1, payment_1, payment_future_1): (
            zmarket_private_marketplace.aleo/PrivateListing, credits.aleo/credits, Future
        ) = zmarket_private_marketplace.aleo/withdraw_listing_balance(
            old_private_listing_1, amounts[1u16]
        );
        let (new_private_listing_2, payment_2, payment_future_2): (
            zmarket_private_marketplace.aleo/PrivateListing, credits.aleo/credits, Future
        ) = zmarket_private_marketplace.aleo/withdraw_listing_balance(
            old_private_listing_2, amounts[2u16]
        );
        let payment_0_1: credits.aleo/credits = credits.aleo/join(
            payment_0, payment_1
        );
        let payment: credits.aleo/credits = credits.aleo/join(
            payment_0_1, payment_2
        );
        let withdraw_listing_balance_3_fut: Future = fin_withdraw_listing_balance_3(
            payment_future_0,
            payment_future_1,
            payment_future_2
        );
        return (payment, withdraw_listing_balance_3_fut);
    }
    async function fin_withdraw_listing_balance_3(
        payment_future_0: Future,
        payment_future_1: Future,
        payment_future_2: Future
    ){
        payment_future_0.await();
        payment_future_1.await();
        payment_future_2.await();
    }


    async transition withdraw_listing_balance_4(
        old_private_listing_0: zmarket_private_marketplace.aleo/PrivateListing,
        old_private_listing_1: zmarket_private_marketplace.aleo/PrivateListing,
        old_private_listing_2: zmarket_private_marketplace.aleo/PrivateListing,
        old_private_listing_3: zmarket_private_marketplace.aleo/PrivateListing,
        public amounts: [u64; 4],
    ) -> (credits.aleo/credits, Future){
        let (new_private_listing_0, payment_0, payment_future_0): (
            zmarket_private_marketplace.aleo/PrivateListing, credits.aleo/credits, Future
        ) = zmarket_private_marketplace.aleo/withdraw_listing_balance(
            old_private_listing_0, amounts[0u16]
        );
        let (new_private_listing_1, payment_1, payment_future_1): (
            zmarket_private_marketplace.aleo/PrivateListing, credits.aleo/credits, Future
        ) = zmarket_private_marketplace.aleo/withdraw_listing_balance(
            old_private_listing_1, amounts[1u16]
        );
        let (new_private_listing_2, payment_2, payment_future_2): (
            zmarket_private_marketplace.aleo/PrivateListing, credits.aleo/credits, Future
        ) = zmarket_private_marketplace.aleo/withdraw_listing_balance(
            old_private_listing_2, amounts[2u16]
        );
        let (new_private_listing_3, payment_3, payment_future_3): (
            zmarket_private_marketplace.aleo/PrivateListing, credits.aleo/credits, Future
        ) = zmarket_private_marketplace.aleo/withdraw_listing_balance(
            old_private_listing_3, amounts[3u16]
        );
        let payment_0_1: credits.aleo/credits = credits.aleo/join(
            payment_0, payment_1
        );
        let payment_0_1_2: credits.aleo/credits = credits.aleo/join(
            payment_0_1, payment_2
        );
        let payment: credits.aleo/credits = credits.aleo/join(
            payment_0_1_2, payment_3
        );
        let withdraw_listing_balance_4_fut: Future = fin_withdraw_listing_balance_4(
            payment_future_0,
            payment_future_1,
            payment_future_2,
            payment_future_3
        );
        return (payment, withdraw_listing_balance_4_fut);
    }
    async function fin_withdraw_listing_balance_4(
        payment_future_0: Future,
        payment_future_1: Future,
        payment_future_2: Future,
        payment_future_3: Future
    ){
        payment_future_0.await();
        payment_future_1.await();
        payment_future_2.await();
        payment_future_3.await();
    }


    async transition withdraw_listing_balance_5(
        old_private_listing_0: zmarket_private_marketplace.aleo/PrivateListing,
        old_private_listing_1: zmarket_private_marketplace.aleo/PrivateListing,
        old_private_listing_2: zmarket_private_marketplace.aleo/PrivateListing,
        old_private_listing_3: zmarket_private_marketplace.aleo/PrivateListing,
        old_private_listing_4: zmarket_private_marketplace.aleo/PrivateListing,
        public amounts: [u64; 5],
    ) -> (credits.aleo/credits, Future){
        let (new_private_listing_0, payment_0, payment_future_0): (
            zmarket_private_marketplace.aleo/PrivateListing, credits.aleo/credits, Future
        ) = zmarket_private_marketplace.aleo/withdraw_listing_balance(
            old_private_listing_0, amounts[0u16]
        );
        let (new_private_listing_1, payment_1, payment_future_1): (
            zmarket_private_marketplace.aleo/PrivateListing, credits.aleo/credits, Future
        ) = zmarket_private_marketplace.aleo/withdraw_listing_balance(
            old_private_listing_1, amounts[1u16]
        );
        let (new_private_listing_2, payment_2, payment_future_2): (
            zmarket_private_marketplace.aleo/PrivateListing, credits.aleo/credits, Future
        ) = zmarket_private_marketplace.aleo/withdraw_listing_balance(
            old_private_listing_2, amounts[2u16]
        );
        let (new_private_listing_3, payment_3, payment_future_3): (
            zmarket_private_marketplace.aleo/PrivateListing, credits.aleo/credits, Future
        ) = zmarket_private_marketplace.aleo/withdraw_listing_balance(
            old_private_listing_3, amounts[3u16]
        );
        let (new_private_listing_4, payment_4, payment_future_4): (
            zmarket_private_marketplace.aleo/PrivateListing, credits.aleo/credits, Future
        ) = zmarket_private_marketplace.aleo/withdraw_listing_balance(
            old_private_listing_4, amounts[4u16]
        );
        let payment_0_1: credits.aleo/credits = credits.aleo/join(
            payment_0, payment_1
        );
        let payment_0_1_2: credits.aleo/credits = credits.aleo/join(
            payment_0_1, payment_2
        );
        let payment_0_1_2_3: credits.aleo/credits = credits.aleo/join(
            payment_0_1_2, payment_3
        );
        let payment: credits.aleo/credits = credits.aleo/join(
            payment_0_1_2_3, payment_4
        );
        let withdraw_listing_balance_5_fut: Future = fin_withdraw_listing_balance_5(
            payment_future_0,
            payment_future_1,
            payment_future_2,
            payment_future_3,
            payment_future_4,
        );
        return (payment, withdraw_listing_balance_5_fut);
    }
    async function fin_withdraw_listing_balance_5(
        payment_future_0: Future,
        payment_future_1: Future,
        payment_future_2: Future,
        payment_future_3: Future,
        payment_future_4: Future
    ){
        payment_future_0.await();
        payment_future_1.await();
        payment_future_2.await();
        payment_future_3.await();
        payment_future_4.await();
    }
}
