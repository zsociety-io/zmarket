import credits.aleo;
program zmarket_marketplace.aleo;


struct data:
    metadata as [field; 4u32];

record Royalty:
    owner as address.private;
    data as data.private;
    edition as scalar.private;

struct ListingData:
    nft_commit as field;
    listing_program as address;
    price as u64;
    market_royalty as u16;
    creator_royalty as u16;
    is_private as boolean;
    is_accepted as boolean;
    is_removed as boolean;

struct VolumeKey:
    account as address;
    listing_program as address;
    side as boolean;

struct VolumeData:
    account as address;
    listing_program as address;
    side as boolean;
    amount as u64;

record PrivateListing:
    owner as address.private;
    listing_id as field.private;

record Volume:
    owner as address.private;
    listing_program as address.private;
    side as boolean.private;
    amount as u64.private;


mapping listings:
	key as field.public;
	value as ListingData.public;


mapping royalties:
	key as address.public;
	value as u16.public;


mapping royalty_balances:
	key as address.public;
	value as u64.public;


mapping listing_balances:
	key as field.public;
	value as u64.public;


mapping volumes:
	key as field.public;
	value as VolumeData.public;


function initialize_marketplace:
    input r0 as u16.public;
    async initialize_marketplace r0 into r1;
    assert.eq self.caller aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax;
    cast zmarket_marketplace.aleo into r2 as field;
    cast  r2 0field 0field 0field into r3 as [field; 4u32];
    cast r3 into r4 as data;
    cast self.signer r4 0scalar into r5 as Royalty.record;
    output r5 as Royalty.record;
    output r1 as zmarket_marketplace.aleo/initialize_marketplace.future;

finalize initialize_marketplace:
    input r0 as u16.public;
    contains royalties[zmarket_marketplace.aleo] into r1;
    not r1 into r2;
    assert.eq r2 true;
    lte r0 10000u16 into r3;
    assert.eq r3 true;
    set r0 into royalties[zmarket_marketplace.aleo];




function list_collection:
    input r0 as address.private;
    input r1 as u16.public;
    cast self.caller into r2 as field;
    cast  r2 0field 0field 0field into r3 as [field; 4u32];
    cast r3 into r4 as data;
    cast r0 r4 0scalar into r5 as Royalty.record;
    async list_collection self.caller r1 into r6;
    output r5 as Royalty.record;
    output r6 as zmarket_marketplace.aleo/list_collection.future;

finalize list_collection:
    input r0 as address.public;
    input r1 as u16.public;
    contains royalties[r0] into r2;
    not r2 into r3;
    assert.eq r3 true;
    lte r1 10000u16 into r4;
    assert.eq r4 true;
    set r1 into royalties[r0];




function update_royalty:
    input r0 as Royalty.record;
    input r1 as u16.public;
    cast r0.data.metadata[0u32] into r2 as address;
    async update_royalty r2 r1 into r3;
    cast r0.owner r0.data r0.edition into r4 as Royalty.record;
    output r4 as Royalty.record;
    output r3 as zmarket_marketplace.aleo/update_royalty.future;

finalize update_royalty:
    input r0 as address.public;
    input r1 as u16.public;
    lte r1 10000u16 into r2;
    assert.eq r2 true;
    set r1 into royalties[r0];




function withdraw_royalty_balance:
    input r0 as Royalty.record;
    input r1 as u64.public;
    cast r0.data.metadata[0u32] into r2 as address;
    async withdraw_royalty_balance r2 r1 into r3;
    cast r0.owner r0.data r0.edition into r4 as Royalty.record;
    output r4 as Royalty.record;
    output r3 as zmarket_marketplace.aleo/withdraw_royalty_balance.future;

finalize withdraw_royalty_balance:
    input r0 as address.public;
    input r1 as u64.public;
    get royalty_balances[r0] into r2;
    sub r2 r1 into r3;
    set r3 into royalty_balances[r0];




function withdraw_listing_balance:
    input r0 as PrivateListing.record;
    input r1 as u64.public;
    async withdraw_listing_balance r0.listing_id r1 into r2;
    cast r0.owner r0.listing_id into r3 as PrivateListing.record;
    output r3 as PrivateListing.record;
    output r2 as zmarket_marketplace.aleo/withdraw_listing_balance.future;

finalize withdraw_listing_balance:
    input r0 as field.public;
    input r1 as u64.public;
    get listing_balances[r0] into r2;
    sub r2 r1 into r3;
    set r3 into listing_balances[r0];




function list_private:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as address.private;
    input r3 as u64.public;
    cast r2 r0 into r4 as PrivateListing.record;
    async list_private r0 r1 r3 self.caller into r5;
    output r4 as PrivateListing.record;
    output r5 as zmarket_marketplace.aleo/list_private.future;

finalize list_private:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as u64.public;
    input r3 as address.public;
    contains listings[r0] into r4;
    not r4 into r5;
    assert.eq r5 true;
    get royalties[zmarket_marketplace.aleo] into r6;
    get royalties[r3] into r7;
    cast r6 into r8 as u64;
    mul r8 r2 into r9;
    div r9 10000u64 into r10;
    cast r7 into r11 as u64;
    mul r11 r2 into r12;
    div r12 10000u64 into r13;
    add r10 r13 into r14;
    gte r2 r14 into r15;
    assert.eq r15 true;
    cast r1 r3 r2 r6 r7 true false false into r16 as ListingData;
    set r16 into listings[r0];




function unlist_private:
    input r0 as PrivateListing.record;
    input r1 as field.public;
    async unlist_private r0.listing_id r1 self.caller into r2;
    output r2 as zmarket_marketplace.aleo/unlist_private.future;

finalize unlist_private:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as address.public;
    get listings[r0] into r3;
    not r3.is_removed into r4;
    assert.eq r4 true;
    not r3.is_accepted into r5;
    assert.eq r5 true;
    assert.eq r3.is_private true;
    assert.eq r1 r3.nft_commit;
    assert.eq r2 r3.listing_program;
    cast r3.nft_commit r3.listing_program r3.price r3.market_royalty r3.creator_royalty r3.is_private false true into r6 as ListingData;
    set r6 into listings[r0];




function accept_private_listing:
    input r0 as field.public;
    input r1 as credits.aleo/credits.record;
    input r2 as field.public;
    input r3 as u64.public;
    call credits.aleo/transfer_private_to_public r1 zmarket_marketplace.aleo r3 into r4 r5;
    async accept_private_listing r0 r2 r3 self.caller r5 into r6;
    output r6 as zmarket_marketplace.aleo/accept_private_listing.future;

finalize accept_private_listing:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as u64.public;
    input r3 as address.public;
    input r4 as credits.aleo/transfer_private_to_public.future;
    get listings[r0] into r5;
    assert.eq r5.is_private true;
    not r5.is_accepted into r6;
    assert.eq r6 true;
    not r5.is_removed into r7;
    assert.eq r7 true;
    assert.eq r1 r5.nft_commit;
    assert.eq r2 r5.price;
    assert.eq r3 r5.listing_program;
    get royalties[zmarket_marketplace.aleo] into r8;
    get royalties[r3] into r9;
    cast r8 into r10 as u64;
    mul r10 r2 into r11;
    div r11 10000u64 into r12;
    cast r9 into r13 as u64;
    mul r13 r2 into r14;
    div r14 10000u64 into r15;
    sub r2 r12 into r16;
    sub r16 r15 into r17;
    get royalty_balances[zmarket_marketplace.aleo] into r18;
    get royalty_balances[r3] into r19;
    get listing_balances[r0] into r20;
    sub r18 r12 into r21;
    sub r19 r15 into r22;
    sub r20 r17 into r23;
    set r21 into royalty_balances[zmarket_marketplace.aleo];
    set r22 into royalty_balances[r3];
    set r23 into listing_balances[r0];
    cast r5.nft_commit r5.listing_program r5.price r5.market_royalty r5.creator_royalty r5.is_private true false into r24 as ListingData;
    set r24 into listings[r0];
    await r4;



function add_volume:
    input r0 as Volume.record;
    input r1 as u64.private;
    assert.eq r0.listing_program self.caller;
    add r0.amount r1 into r2;
    cast self.signer self.caller r0.side r2 into r3 as Volume.record;
    output r3 as Volume.record;


function mint_volume:
    input r0 as boolean.private;
    input r1 as address.private;
    cast self.signer r1 r0 0u64 into r2 as Volume.record;
    output r2 as Volume.record;


function join_volumes:
    input r0 as Volume.record;
    input r1 as Volume.record;
    assert.eq r0.side r1.side;
    assert.eq r0.listing_program r1.listing_program;
    add r0.amount r1.amount into r2;
    cast self.signer r0.listing_program r0.side r2 into r3 as Volume.record;
    output r3 as Volume.record;





function share_volume:
    input r0 as Volume.record;
    cast r0.owner r0.listing_program r0.side r0.amount into r1 as Volume.record;
    async share_volume self.signer r0.listing_program r0.side r0.amount into r2;
    output r1 as Volume.record;
    output r2 as zmarket_marketplace.aleo/share_volume.future;

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

