program zmarket_marketplace_volume.aleo;

struct VolumeKey:
    account as address;
    marketplace as address;
    side as boolean;

struct VolumeData:
    account as address;
    marketplace as address;
    side as boolean;
    amount as u64;

record VolumeProof:
    owner as address.private;
    marketplace as address.private;
    side as boolean.private;
    amount as u64.private;


mapping volumes:
	key as field.public;
	value as VolumeData.public;

function add_volume:
    input r0 as VolumeProof.record;
    input r1 as boolean.private;
    input r2 as u64.private;
    cast self.signer self.caller r1 r2 into r3 as VolumeProof.record;
    output r3 as VolumeProof.record;


function mint_volume_proof:
    input r0 as boolean.private;
    input r1 as address.private;
    cast self.signer r1 r0 0u64 into r2 as VolumeProof.record;
    output r2 as VolumeProof.record;


function join_volume_proofs:
    input r0 as VolumeProof.record;
    input r1 as VolumeProof.record;
    assert.eq r0.side r1.side;
    assert.eq r0.marketplace r1.marketplace;
    add r0.amount r1.amount into r2;
    cast self.signer r0.marketplace r0.side r2 into r3 as VolumeProof.record;
    output r3 as VolumeProof.record;





function share_volume:
    input r0 as VolumeProof.record;
    cast r0.owner r0.marketplace r0.side r0.amount into r1 as VolumeProof.record;
    async share_volume self.signer r0.marketplace r0.side r0.amount into r2;
    output r1 as VolumeProof.record;
    output r2 as zmarket_marketplace_volume.aleo/share_volume.future;

finalize share_volume:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as boolean.public;
    input r3 as u64.public;
    cast r0 r1 r2 into r4 as VolumeKey;
    hash.bhp256 r4 into r5 as field;
    get volumes[r5] into r6;
    gt r3 r6.amount into r7;
    ternary r7 r3 r6.amount into r8;
    cast r0 r1 r2 r8 into r9 as VolumeData;
    set r9 into volumes[r5];

