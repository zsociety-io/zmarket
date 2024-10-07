
program zmarket_marketplace.aleo {
    struct VolumeKey {
        account: address, // account who made the volume
        listing: address, // listing program where volume was made
        side: bool, // sell: true, buy: false
    }
    
    struct VolumeData {
        account: address, // account who made the volume
        listing: address, // listing program where volume was made
        side: bool, // sell: true, buy: false
        amount: u64 // amount of volume
    }

    record Volume {
        owner: address, // account who made the volume
        listing: address, // listing program where volume was made
        side: bool, // sell: true, buy: false
        amount: u64 // amount of volume
    }


    mapping volumes: field => VolumeData;
    // hash(VolumeKey) => VolumeData;


    inline max_u64(a: u64, b: u64) -> u64 {
        return (a > b) ? a : b;
    }


    transition add_volume(
        volume: Volume,
        amount: u64
    ) -> Volume {
        assert_eq(volume.listing, self.caller);
        return Volume {
            owner: self.signer,
            listing: self.caller,
            side: volume.side,
            amount: volume.amount + amount
        };
    }


    transition mint_volume(
        side: bool, 
        listing: address,
    ) -> Volume {
        return Volume{
            owner: self.signer,
            listing: listing,
            side: side,
            amount: 0u64
        };
    }


    transition join_volumes(
        volume0: Volume, volume1: Volume
    ) -> Volume{
        assert_eq(volume0.side, volume1.side);
        assert_eq(volume0.listing, volume1.listing);
        return Volume{
            owner: self.signer,
            listing: volume0.listing,
            side: volume0.side,
            amount: volume0.amount + volume1.amount
        };
    }


    async transition share_volume(
        private volume: Volume
    ) -> (Volume, Future){
        let out_volume: Volume = Volume {
            owner: volume.owner,
            listing: volume.listing,
            side: volume.side,
            amount: volume.amount
        };
        let share_volume_future: Future = set_volume(
            self.signer,
            volume.listing,
            volume.side,
            volume.amount
        );
        return (
            out_volume,
            share_volume_future
        );
    }

    async function set_volume(
        account: address,
        listing: address,
        side: bool,
        amount: u64
    ){
        let volume_key: VolumeKey = VolumeKey {
            account: account,
            listing: listing,
            side: side,
        };
        let volume_key_hash: field = BHP256::hash_to_field(volume_key);

        let old_volume_data: VolumeData = volumes.get(volume_key_hash);

        let new_volume_data: VolumeData = VolumeData {
            account: account,
            listing: listing,
            side: side,
            amount: max_u64(amount, old_volume_data.amount)
        };

        volumes.set(volume_key_hash, new_volume_data);
    }
}
