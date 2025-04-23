import nft_records_v3.aleo;
import nft_registry_v3.aleo;
import nft_collections_v3.aleo;
import zmarket_royalties_v3.aleo;
import credits.aleo;
program zmarket_public_marketplace.aleo;

struct Data:
    metadata as field;

struct NFTId:
    collection_id as field;
    nft_commit as field;

struct NFTContent:
    data as Data;
    edition as scalar;

struct CollectionMetadata:
    collection_id as field;
    base_uri as [field; 4u32];
    metadata_uri as [field; 4u32];

struct PublicTrade:
    nft_id_hash as field;
    collection_id as field;
    price as u64;
    origin as address;
    market_royalty as u16;
    creator_royalty as u16;
    is_accepted as boolean;
    is_removed as boolean;

mapping listings:
    key as field.public;
    value as PublicTrade.public;

mapping offers:
    key as field.public;
    value as PublicTrade.public;

mapping royalty_balances:
    key as field.public;
    value as u64.public;

mapping offer_pools:
    key as address.public;
    value as u64.public;

function withdraw_royalty_private:
    input r0 as nft_records_v3.aleo/NFT.record;
    input r1 as u64.public;
    call credits.aleo/transfer_public_to_private self.signer r1 into r2 r3;
    assert.eq r0.collection_id 1234field;
    async withdraw_royalty_private r0.data.metadata r1 r3 into r4;
    output r2 as credits.aleo/credits.record;
    output r4 as zmarket_public_marketplace.aleo/withdraw_royalty_private.future;

finalize withdraw_royalty_private:
    input r0 as field.public;
    input r1 as u64.public;
    input r2 as credits.aleo/transfer_public_to_private.future;
    get.or_use royalty_balances[r0] 0u64 into r3;
    sub r3 r1 into r4;
    set r4 into royalty_balances[r0];
    await r2;

function withdraw_royalty_public:
    input r0 as field.public;
    input r1 as u64.public;
    call credits.aleo/transfer_public self.caller r1 into r2;
    cast r0 into r3 as Data;
    hash.bhp256 r3 into r4 as field;
    commit.bhp256 r4 0scalar into r5 as field;
    cast 1234field r5 into r6 as NFTId;
    hash.bhp256 r6 into r7 as field;
    async withdraw_royalty_public self.caller r0 r7 r1 r2 into r8;
    output r8 as zmarket_public_marketplace.aleo/withdraw_royalty_public.future;

finalize withdraw_royalty_public:
    input r0 as address.public;
    input r1 as field.public;
    input r2 as field.public;
    input r3 as u64.public;
    input r4 as credits.aleo/transfer_public.future;
    get nft_registry_v3.aleo/nft_owners[r2] into r5;
    assert.eq r5 r0;
    get.or_use royalty_balances[r1] 0u64 into r6;
    sub r6 r3 into r7;
    set r7 into royalty_balances[r1];
    await r4;

function list_public:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as field.public;
    input r3 as u64.public;
    async list_public self.caller r0 r1 r2 r3 into r4;
    output r4 as zmarket_public_marketplace.aleo/list_public.future;

finalize list_public:
    input r0 as address.public;
    input r1 as field.public;
    input r2 as field.public;
    input r3 as field.public;
    input r4 as u64.public;
    contains listings[r3] into r5;
    not r5 into r6;
    assert.eq r6 true;
    get zmarket_royalties_v3.aleo/royalties[5678field] into r7;
    get.or_use zmarket_royalties_v3.aleo/royalties[r1] 0u16 into r8;
    cast r7 into r9 as u64;
    mul r9 r4 into r10;
    div r10 10_000u64 into r11;
    cast r8 into r12 as u64;
    mul r12 r4 into r13;
    div r13 10_000u64 into r14;
    add r11 r14 into r15;
    gte r4 r15 into r16;
    assert.eq r16 true;
    cast r2 r1 r4 r0 r7 r8 false false into r17 as PublicTrade;
    set r17 into listings[r3];

function unlist_public:
    input r0 as field.public;
    async unlist_public r0 self.caller into r1;
    output r1 as zmarket_public_marketplace.aleo/unlist_public.future;

finalize unlist_public:
    input r0 as field.public;
    input r1 as address.public;
    get listings[r0] into r2;
    not r2.is_removed into r3;
    assert.eq r3 true;
    not r2.is_accepted into r4;
    assert.eq r4 true;
    assert.eq r1 r2.origin;
    cast r2.nft_id_hash r2.collection_id r2.price r2.origin r2.market_royalty r2.creator_royalty false true into r5 as PublicTrade;
    set r5 into listings[r0];

function update_public_listing:
    input r0 as field.public;
    input r1 as u64.public;
    async update_public_listing r0 r1 self.caller into r2;
    output r2 as zmarket_public_marketplace.aleo/update_public_listing.future;

finalize update_public_listing:
    input r0 as field.public;
    input r1 as u64.public;
    input r2 as address.public;
    get listings[r0] into r3;
    not r3.is_removed into r4;
    assert.eq r4 true;
    not r3.is_accepted into r5;
    assert.eq r5 true;
    assert.eq r2 r3.origin;
    get zmarket_royalties_v3.aleo/royalties[5678field] into r6;
    get.or_use zmarket_royalties_v3.aleo/royalties[r3.collection_id] 0u16 into r7;
    cast r6 into r8 as u64;
    mul r8 r1 into r9;
    div r9 10_000u64 into r10;
    cast r7 into r11 as u64;
    mul r11 r1 into r12;
    div r12 10_000u64 into r13;
    add r10 r13 into r14;
    gte r1 r14 into r15;
    assert.eq r15 true;
    cast r3.nft_id_hash r3.collection_id r1 r3.origin r6 r7 false false into r16 as PublicTrade;
    set r16 into listings[r0];

function accept_public_listing_as_signer:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as Data.private;
    input r3 as scalar.private;
    input r4 as u64.public;
    input r5 as address.public;
    input r6 as u64.public;
    call credits.aleo/transfer_public_as_signer zmarket_public_marketplace.aleo r4 into r7;
    call credits.aleo/transfer_public r5 r6 into r8;
    call nft_registry_v3.aleo/transfer_from_public r1 r5 self.signer r2 r3 into r9 r10;
    hash.bhp256 r2 into r11 as field;
    commit.bhp256 r11 r3 into r12 as field;
    cast r1 r12 into r13 as NFTId;
    hash.bhp256 r13 into r14 as field;
    async accept_public_listing_as_signer r0 r14 r4 r5 r6 r7 r8 r10 into r15;
    output r15 as zmarket_public_marketplace.aleo/accept_public_listing_as_signer.future;

finalize accept_public_listing_as_signer:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as u64.public;
    input r3 as address.public;
    input r4 as u64.public;
    input r5 as credits.aleo/transfer_public_as_signer.future;
    input r6 as credits.aleo/transfer_public.future;
    input r7 as nft_registry_v3.aleo/transfer_from_public.future;
    get listings[r0] into r8;
    not r8.is_accepted into r9;
    assert.eq r9 true;
    not r8.is_removed into r10;
    assert.eq r10 true;
    assert.eq r1 r8.nft_id_hash;
    assert.eq r2 r8.price;
    assert.eq r3 r8.origin;
    cast r8.market_royalty into r11 as u64;
    mul r11 r2 into r12;
    div r12 10000u64 into r13;
    cast r8.creator_royalty into r14 as u64;
    mul r14 r2 into r15;
    div r15 10000u64 into r16;
    sub r2 r13 into r17;
    sub r17 r16 into r18;
    assert.eq r4 r18;
    get.or_use royalty_balances[5678field] 0u64 into r19;
    get.or_use royalty_balances[r8.collection_id] 0u64 into r20;
    add r19 r13 into r21;
    add r20 r16 into r22;
    set r21 into royalty_balances[5678field];
    set r22 into royalty_balances[r8.collection_id];
    cast r8.nft_id_hash r8.collection_id r8.price r8.origin r8.market_royalty r8.creator_royalty true true into r23 as PublicTrade;
    set r23 into listings[r0];
    await r5;
    await r6;
    await r7;

function accept_public_listing_private:
    input r0 as field.public;
    input r1 as credits.aleo/credits.record;
    input r2 as field.public;
    input r3 as Data.private;
    input r4 as scalar.private;
    input r5 as u64.public;
    input r6 as address.public;
    input r7 as u64.public;
    sub r5 r7 into r8;
    call credits.aleo/transfer_private_to_public r1 zmarket_public_marketplace.aleo r8 into r9 r10;
    call credits.aleo/transfer_private_to_public r9 r6 r7 into r11 r12;
    call nft_registry_v3.aleo/transfer_from_public_to_private r2 r6 self.signer r3 r4 into r13 r14;
    hash.bhp256 r3 into r15 as field;
    commit.bhp256 r15 r4 into r16 as field;
    cast r2 r16 into r17 as NFTId;
    hash.bhp256 r17 into r18 as field;
    async accept_public_listing_private r0 r18 r5 r6 r7 r10 r12 r14 into r19;
    output r11 as credits.aleo/credits.record;
    output r13 as nft_records_v3.aleo/NFT.record;
    output r19 as zmarket_public_marketplace.aleo/accept_public_listing_private.future;

finalize accept_public_listing_private:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as u64.public;
    input r3 as address.public;
    input r4 as u64.public;
    input r5 as credits.aleo/transfer_private_to_public.future;
    input r6 as credits.aleo/transfer_private_to_public.future;
    input r7 as nft_registry_v3.aleo/transfer_from_public_to_private.future;
    get listings[r0] into r8;
    not r8.is_accepted into r9;
    assert.eq r9 true;
    not r8.is_removed into r10;
    assert.eq r10 true;
    assert.eq r1 r8.nft_id_hash;
    assert.eq r2 r8.price;
    assert.eq r3 r8.origin;
    cast r8.market_royalty into r11 as u64;
    mul r11 r2 into r12;
    div r12 10000u64 into r13;
    cast r8.creator_royalty into r14 as u64;
    mul r14 r2 into r15;
    div r15 10000u64 into r16;
    sub r2 r13 into r17;
    sub r17 r16 into r18;
    assert.eq r4 r18;
    get.or_use royalty_balances[5678field] 0u64 into r19;
    get.or_use royalty_balances[r8.collection_id] 0u64 into r20;
    add r19 r13 into r21;
    add r20 r16 into r22;
    set r21 into royalty_balances[5678field];
    set r22 into royalty_balances[r8.collection_id];
    cast r8.nft_id_hash r8.collection_id r8.price r8.origin r8.market_royalty r8.creator_royalty true true into r23 as PublicTrade;
    set r23 into listings[r0];
    await r5;
    await r6;
    await r7;

function deposit_offer_as_signer:
    input r0 as u64.public;
    call credits.aleo/transfer_public_as_signer zmarket_public_marketplace.aleo r0 into r1;
    async deposit_offer_as_signer self.signer r0 r1 into r2;
    output r2 as zmarket_public_marketplace.aleo/deposit_offer_as_signer.future;

finalize deposit_offer_as_signer:
    input r0 as address.public;
    input r1 as u64.public;
    input r2 as credits.aleo/transfer_public_as_signer.future;
    get.or_use offer_pools[r0] 0u64 into r3;
    add r3 r1 into r4;
    set r4 into offer_pools[r0];
    await r2;

function withdraw_offer:
    input r0 as u64.public;
    call credits.aleo/transfer_public self.caller r0 into r1;
    async withdraw_offer self.caller r0 r1 into r2;
    output r2 as zmarket_public_marketplace.aleo/withdraw_offer.future;

finalize withdraw_offer:
    input r0 as address.public;
    input r1 as u64.public;
    input r2 as credits.aleo/transfer_public.future;
    get.or_use offer_pools[r0] 0u64 into r3;
    sub r3 r1 into r4;
    set r4 into offer_pools[r0];
    await r2;

function offer_public:
    input r0 as field.public;
    input r1 as u64.public;
    input r2 as field.public;
    input r3 as field.public;
    async offer_public self.caller r0 r3 r1 r2 into r4;
    output r4 as zmarket_public_marketplace.aleo/offer_public.future;

finalize offer_public:
    input r0 as address.public;
    input r1 as field.public;
    input r2 as field.public;
    input r3 as u64.public;
    input r4 as field.public;
    contains offers[r1] into r5;
    not r5 into r6;
    assert.eq r6 true;
    get zmarket_royalties_v3.aleo/royalties[5678field] into r7;
    get.or_use zmarket_royalties_v3.aleo/royalties[r4] 0u16 into r8;
    cast r7 into r9 as u64;
    mul r9 r3 into r10;
    div r10 10_000u64 into r11;
    cast r8 into r12 as u64;
    mul r12 r3 into r13;
    div r13 10_000u64 into r14;
    add r11 r14 into r15;
    gte r3 r15 into r16;
    assert.eq r16 true;
    cast r2 r4 r3 r0 r7 r8 false false into r17 as PublicTrade;
    set r17 into offers[r1];

function unoffer_public:
    input r0 as field.public;
    async unoffer_public r0 self.caller into r1;
    output r1 as zmarket_public_marketplace.aleo/unoffer_public.future;

finalize unoffer_public:
    input r0 as field.public;
    input r1 as address.public;
    get offers[r0] into r2;
    not r2.is_removed into r3;
    assert.eq r3 true;
    not r2.is_accepted into r4;
    assert.eq r4 true;
    assert.eq r1 r2.origin;
    cast r2.nft_id_hash r2.collection_id r2.price r2.origin r2.market_royalty r2.creator_royalty false true into r5 as PublicTrade;
    set r5 into offers[r0];

function update_public_offer:
    input r0 as field.public;
    input r1 as u64.public;
    async update_public_offer r0 r1 self.caller into r2;
    output r2 as zmarket_public_marketplace.aleo/update_public_offer.future;

finalize update_public_offer:
    input r0 as field.public;
    input r1 as u64.public;
    input r2 as address.public;
    get offers[r0] into r3;
    not r3.is_removed into r4;
    assert.eq r4 true;
    not r3.is_accepted into r5;
    assert.eq r5 true;
    assert.eq r2 r3.origin;
    get zmarket_royalties_v3.aleo/royalties[5678field] into r6;
    get.or_use zmarket_royalties_v3.aleo/royalties[r3.collection_id] 0u16 into r7;
    cast r6 into r8 as u64;
    mul r8 r1 into r9;
    div r9 10_000u64 into r10;
    cast r7 into r11 as u64;
    mul r11 r1 into r12;
    div r12 10_000u64 into r13;
    add r10 r13 into r14;
    gte r1 r14 into r15;
    assert.eq r15 true;
    cast r3.nft_id_hash r3.collection_id r1 r2 r6 r7 false true into r16 as PublicTrade;
    set r16 into offers[r0];

function accept_public_offer_private:
    input r0 as field.public;
    input r1 as u64.public;
    input r2 as address.public;
    input r3 as nft_records_v3.aleo/NFT.record;
    call nft_registry_v3.aleo/transfer_private_to_public r3 r2 into r4 r5;
    call credits.aleo/transfer_public_to_private self.signer r1 into r6 r7;
    hash.bhp256 r3.data into r8 as field;
    commit.bhp256 r8 r3.edition into r9 as field;
    cast r3.collection_id r9 into r10 as NFTId;
    hash.bhp256 r10 into r11 as field;
    async accept_public_offer_private r0 r1 r3.collection_id r2 r11 r5 r7 into r12;
    output r6 as credits.aleo/credits.record;
    output r12 as zmarket_public_marketplace.aleo/accept_public_offer_private.future;

finalize accept_public_offer_private:
    input r0 as field.public;
    input r1 as u64.public;
    input r2 as field.public;
    input r3 as address.public;
    input r4 as field.public;
    input r5 as nft_registry_v3.aleo/transfer_private_to_public.future;
    input r6 as credits.aleo/transfer_public_to_private.future;
    get offers[r0] into r7;
    not r7.is_accepted into r8;
    assert.eq r8 true;
    not r7.is_removed into r9;
    assert.eq r9 true;
    is.eq r4 r7.nft_id_hash into r10;
    is.eq r7.nft_id_hash 0field into r11;
    or r10 r11 into r12;
    assert.eq r12 true;
    assert.eq r2 r7.collection_id;
    assert.eq r7.origin r3;
    cast r7.market_royalty into r13 as u64;
    mul r13 r7.price into r14;
    div r14 10000u64 into r15;
    cast r7.creator_royalty into r16 as u64;
    mul r16 r7.price into r17;
    div r17 10000u64 into r18;
    sub r7.price r15 into r19;
    sub r19 r18 into r20;
    assert.eq r20 r1;
    get.or_use royalty_balances[5678field] 0u64 into r21;
    get.or_use royalty_balances[r7.collection_id] 0u64 into r22;
    add r21 r15 into r23;
    add r22 r18 into r24;
    set r23 into royalty_balances[5678field];
    set r24 into royalty_balances[r7.collection_id];
    get.or_use offer_pools[r3] 0u64 into r25;
    sub r25 r7.price into r26;
    set r26 into offer_pools[r3];
    cast r4 r7.collection_id r7.price r7.origin r7.market_royalty r7.creator_royalty true false into r27 as PublicTrade;
    set r27 into offers[r0];
    await r5;
    await r6;

function accept_public_offer_as_signer:
    input r0 as field.public;
    input r1 as u64.public;
    input r2 as address.public;
    input r3 as field.public;
    input r4 as Data.public;
    input r5 as scalar.public;
    call nft_registry_v3.aleo/transfer_public_as_signer r3 r4 r5 r2 into r6 r7;
    call credits.aleo/transfer_public self.signer r1 into r8;
    hash.bhp256 r4 into r9 as field;
    commit.bhp256 r9 r5 into r10 as field;
    cast r3 r10 into r11 as NFTId;
    hash.bhp256 r11 into r12 as field;
    async accept_public_offer_as_signer r0 r1 r3 r2 r12 r7 r8 into r13;
    output r13 as zmarket_public_marketplace.aleo/accept_public_offer_as_signer.future;

finalize accept_public_offer_as_signer:
    input r0 as field.public;
    input r1 as u64.public;
    input r2 as field.public;
    input r3 as address.public;
    input r4 as field.public;
    input r5 as nft_registry_v3.aleo/transfer_public_as_signer.future;
    input r6 as credits.aleo/transfer_public.future;
    get offers[r0] into r7;
    not r7.is_accepted into r8;
    assert.eq r8 true;
    not r7.is_removed into r9;
    assert.eq r9 true;
    is.eq r4 r7.nft_id_hash into r10;
    is.eq r7.nft_id_hash 0field into r11;
    or r10 r11 into r12;
    assert.eq r12 true;
    assert.eq r2 r7.collection_id;
    assert.eq r7.origin r3;
    cast r7.market_royalty into r13 as u64;
    mul r13 r7.price into r14;
    div r14 10000u64 into r15;
    cast r7.creator_royalty into r16 as u64;
    mul r16 r7.price into r17;
    div r17 10000u64 into r18;
    sub r7.price r15 into r19;
    sub r19 r18 into r20;
    assert.eq r20 r1;
    get.or_use royalty_balances[5678field] 0u64 into r21;
    get.or_use royalty_balances[r7.collection_id] 0u64 into r22;
    add r21 r15 into r23;
    add r22 r18 into r24;
    set r23 into royalty_balances[5678field];
    set r24 into royalty_balances[r7.collection_id];
    get.or_use offer_pools[r3] 0u64 into r25;
    sub r25 r7.price into r26;
    set r26 into offer_pools[r3];
    cast r4 r7.collection_id r7.price r7.origin r7.market_royalty r7.creator_royalty true false into r27 as PublicTrade;
    set r27 into offers[r0];
    await r5;
    await r6;
