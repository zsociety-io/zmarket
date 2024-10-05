
program zmarket_marketplace_volume.aleo {
    struct VolumeKey {
        account: address, // account who made the volume
        marketplace: address, // marketplace program where volume was made
        side: bool, // sell: true, buy: false
    }
    
    struct VolumeData {
        account: address, // account who made the volume
        marketplace: address, // marketplace program where volume was made
        side: bool, // sell: true, buy: false
        amount: u64 // amount of volume
    }

    record VolumeProof {
        owner: address, // account who made the volume
        marketplace: address, // marketplace program where volume was made
        side: bool, // sell: true, buy: false
        amount: u64 // amount of volume
    }


    mapping volumes: field => VolumeData;
    // hash(VolumeKey) => VolumeData;


    inline max_u64(a: u64, b: u64) -> u64 {
        return (a > b) ? a : b;
    }


    transition add_volume(
        volume_proof: VolumeProof,
        side: bool,
        amount: u64
    ) -> VolumeProof {
        return VolumeProof {
            owner: self.signer,
            marketplace: self.caller,
            side: side,
            amount: amount
        };
    }


    transition mint_volume_proof(
        side: bool, 
        marketplace: address,
    ) -> VolumeProof {
        return VolumeProof{
            owner: self.signer,
            marketplace: marketplace,
            side: side,
            amount: 0u64
        };
    }


    transition join_volume_proofs(
        proof0: VolumeProof, proof1: VolumeProof
    ) -> VolumeProof{
        assert_eq(proof0.side, proof1.side);
        assert_eq(proof0.marketplace, proof1.marketplace);
        return VolumeProof{
            owner: self.signer,
            marketplace: proof0.marketplace,
            side: proof0.side,
            amount: proof0.amount + proof1.amount
        };
    }


    async transition share_volume(
        private volume_proof: VolumeProof
    ) -> (VolumeProof, Future){
        let out_volume_proof: VolumeProof = VolumeProof {
            owner: volume_proof.owner,
            marketplace: volume_proof.marketplace,
            side: volume_proof.side,
            amount: volume_proof.amount
        };
        let share_volume_future: Future = set_volume(
            self.signer,
            volume_proof.marketplace,
            volume_proof.side,
            volume_proof.amount
        );
        return (
            out_volume_proof,
            share_volume_future
        );
    }

    async function set_volume(
        account: address,
        marketplace: address,
        side: bool,
        amount: u64
    ){
        let volume_key: VolumeKey = VolumeKey {
            account: account,
            marketplace: marketplace,
            side: side,
        };
        let volume_key_hash: field = BHP256::hash_to_field(volume_key);

        let old_volume_data: VolumeData = volumes.get(volume_key_hash);

        let new_volume_data: VolumeData = VolumeData {
            account: account,
            marketplace: marketplace,
            side: side,
            amount: max_u64(amount, old_volume_data.amount)
        };

        volumes.set(volume_key_hash, new_volume_data);
    }
}
