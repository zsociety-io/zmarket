import credits.aleo;
import token_registry.aleo;


program zsociety_token_v3.aleo {
    const ZSY_TOKEN_ID: field = 777field;
    const ZSOCIETY_ADDRESS: address = aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax;
    const PRECISION: u128 = 1_000_000u128;
    const SUPPLY: u128 = 1_000_000_000_000u128;

    record HolderState {
        owner: address,
        share_permyriad: u8,
        total_income: u128,
        last_total: u128,
    }

    record PublicIncome {
        owner: address,
        amount: u64
    }

    mapping account_already_claimed: address => u128;
    mapping balances: u8 => u128;
    // u0 => total claimed

    mapping has_minted: u8 => bool;


    inline null_balance() -> Balance{
        return Balance {
            token_id: 0field,
            account: ZSOCIETY_ADDRESS,
            balance: 0u128,
            authorized_until: 4294967295u32
        };
    }


    // The zSociety token is only minted once and the total supply is fixed.
    async transition initialize_token() -> Future {
        assert_eq(self.caller, ZSOCIETY_ADDRESS);

        let name: u128 = 8814511368454894713u128; // "zSociety", ascii encoded
        let symbol: u128 = 1515410521u128; // "ZSTY", ascii encoded
        let decimals: u8 = 6u8;
        let external_authorization_required: bool = true;
        let external_authorization_party: address = self.address;

        let f0: Future = token_registry.aleo/register_token(ZSY_TOKEN_ID, name, symbol, decimals, SUPPLY, external_authorization_required, external_authorization_party);

        return finalize_initialize_token(f0);
    }
    async function finalize_initialize_token(
        f0: Future
    ) {
        f0.await();
    }


    async transition mint_public() -> Future {
        assert_eq(self.caller, ZSOCIETY_ADDRESS);
        let f0: Future = token_registry.aleo/mint_public(ZSY_TOKEN_ID, ZSOCIETY_ADDRESS, SUPPLY, 4294967295u32);
        return finalize_mint_public(f0);
    }
    async function finalize_mint_public(
        f0: Future
    ) {
        f0.await();

        let has_already_minted: bool = has_minted.contains(0u8);
        assert(!has_already_minted);
        has_minted.set(0u8, true);
    }


    async transition withdraw_income_as_signer(
        public amount: u64,
    ) -> Future {
        let withdrawer: address = self.signer;
        let transfer_future: Future = credits.aleo/transfer_public(self.signer, amount);
        let withdraw_income_future: Future = finalize_withdraw_income(
            amount,
            self.signer,
            transfer_future
        );
        return withdraw_income_future;
    }
    async function finalize_withdraw_income(
        amount: u64, withdrawer: address, transfer_future: Future
    ){
        let token_owner: TokenOwner = TokenOwner {
            account: withdrawer,
            token_id: ZSY_TOKEN_ID
        };
        let token_owner_hash: field = BHP256::hash_to_field(token_owner);
        let withdrawer_token_balance: u128 = (
            token_registry.aleo/balances.get_or_use(token_owner_hash, null_balance()).balance
        );
        let contract_credits_balance: u64 = credits.aleo/account.get_or_use(self.address, 0u64);
        let total_claimed: u128 = balances.get_or_use(0u8, 0u128);

        let total_revenue: u128 = (
            (contract_credits_balance as u128) + total_claimed
        );

        let withdrawer_already_claimed: u128 = account_already_claimed.get_or_use(withdrawer, 0u128);

        let owned: u128 = (withdrawer_token_balance * total_revenue).div(SUPPLY) - withdrawer_already_claimed;

        let amount_u128: u128 = amount as u128;
        let new_total_claimed: u128 = total_claimed + amount_u128;
        let new_withdrawer_already_claimed: u128 = withdrawer_already_claimed + amount_u128;
        balances.set(0u8, new_total_claimed);
        account_already_claimed.set(withdrawer, new_withdrawer_already_claimed);
        transfer_future.await();
    }


    async transition transfer_public_as_signer(
        public recipient: address,
        public amount: u128,
    ) -> Future {
        let token_owner: TokenOwner = TokenOwner {
            account: self.signer,
            token_id: ZSY_TOKEN_ID
        };
        let f0: Future = token_registry.aleo/prehook_public(
            token_owner, amount, 4294967295u32
        );
        let f1: Future = token_registry.aleo/transfer_public_as_signer(
            ZSY_TOKEN_ID, recipient, amount
        );
        return finalize_transfer_public_as_signer(
            self.signer,
            recipient,
            amount,
            f0,
            f1
        );
    }
    async function finalize_transfer_public_as_signer(
        signer: address,
        recipient: address,
        amount: u128,
        f0: Future,
        f1: Future
    ) {
        let signer_token_owner: TokenOwner = TokenOwner {
            account: signer,
            token_id: ZSY_TOKEN_ID
        };
        let signer_token_owner_hash: field = BHP256::hash_to_field(signer_token_owner);
        let signer_token_balance: u128 = (
            token_registry.aleo/balances.get_or_use(signer_token_owner_hash, null_balance()).balance
        );
        assert(signer_token_balance > 0u128);

        let already_claimed_delta: u128 = amount / signer_token_balance;

        let signer_claimed: u128 = account_already_claimed.get_or_use(signer, 0u128);
        let recipient_claimed: u128 = account_already_claimed.get_or_use(recipient, 0u128);

        let new_signer_claimed: u128 = signer_claimed - already_claimed_delta;
        let new_recipient_claimed: u128 = recipient_claimed + already_claimed_delta;

        account_already_claimed.set(signer, new_signer_claimed);
        account_already_claimed.set(recipient, new_recipient_claimed);

        f0.await();
        f1.await();
    }
}
