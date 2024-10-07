import zmarket_authority.aleo;

program zmarket_royalty.aleo {
    struct Share {
        holder: address,
        permyriad: u16, // 1 permyriad = 0.01%
    }

    mapping royalties: u16 => Share;
    mapping royalties_length: bool => u16;
    // index => share

    async transition update_royalty(
        public holder: address,
        public permyriad: u16
    ) -> Future {
        let check_authorized_future: Future = zmarket_authority.aleo/check_authorized(
            self.caller
        );
        assert(permyriad <= 10000u16);
        return finalize_update_royalty(
            holder,
            permyriad,
            check_authorized_future
        );
    }
    async function finalize_update_royalty(
        holder: address,
        permyriad: u16,
        check_authorized_future: Future
    ){
        check_authorized_future.await();
        let share: Share = Share {
            holder: holder,
            permyriad: permyriad
        };
        let length: u16 = royalties_length.get_or_use(true, 0u16);
        royalties.set(length, share);
        royalties_length.set(true, length + 1u16);
    }
}