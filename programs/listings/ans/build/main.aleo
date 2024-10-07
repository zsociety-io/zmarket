import ans_utils_v2.aleo;
import aleo_name_service_registry_v4.aleo;
import credits.aleo;
import zmarket_marketplace.aleo;
import ans_authority.aleo;
import ans_listing_royalty.aleo;
import zmarket_authority.aleo;
import zmarket_royalty.aleo;
program zmarket_ans_listing.aleo;

struct NameStruct:
    name as [u128; 4u32];
    parent as field;
    resolver as field;

struct data:
    metadata as [field; 4u32];





struct Share:
    holder as address;
    permyriad as u16;

record PrivateListing:
    owner as address.private;
    listing_id as field.private;

struct ListingData:
    nft_commit as field;
    price as u64;
    name_hash as field;
    market_royalty_index as u16;
    creator_royalty_index as u16;
    is_private as boolean;
    is_accepted as boolean;
    is_removed as boolean;


mapping listings:
	key as field.public;
	value as ListingData.public;




function list_private:
    input r0 as aleo_name_service_registry_v4.aleo/NFT.record;
    input r1 as u64.public;
    input r2 as field.public;
    call aleo_name_service_registry_v4.aleo/transfer_private_to_public r0 zmarket_ans_listing.aleo into r3 r4;
    hash.bhp256 r0.data into r5 as field;
    commit.bhp256 r5 r0.edition into r6 as field;
    cast self.signer r2 into r7 as PrivateListing.record;
    async list_private r2 r6 r1 r0.data.metadata[0u32] r4 into r8;
    output r7 as PrivateListing.record;
    output r8 as zmarket_ans_listing.aleo/list_private.future;

finalize list_private:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as u64.public;
    input r3 as field.public;
    input r4 as aleo_name_service_registry_v4.aleo/transfer_private_to_public.future;
    contains listings[r0] into r5;
    not r5 into r6;
    assert.eq r6 true;
    get zmarket_royalty.aleo/royalties_length[true] into r7;
    sub r7 1u16 into r8;
    get ans_listing_royalty.aleo/royalties_length[true] into r9;
    sub r9 1u16 into r10;
    cast r1 r2 r3 r8 r10 true false false into r11 as ListingData;
    set r11 into listings[r0];
    await r4;




function unlist_private:
    input r0 as PrivateListing.record;
    input r1 as field.public;
    cast  r1 0field 0field 0field into r2 as [field; 4u32];
    cast r2 into r3 as data;
    call aleo_name_service_registry_v4.aleo/transfer_public_to_private r3 0scalar self.signer into r4 r5;
    hash.bhp256 r3 into r6 as field;
    commit.bhp256 r6 0scalar into r7 as field;
    async unlist_private r0.listing_id r7 r5 into r8;
    output r4 as aleo_name_service_registry_v4.aleo/NFT.record;
    output r8 as zmarket_ans_listing.aleo/unlist_private.future;

finalize unlist_private:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as aleo_name_service_registry_v4.aleo/transfer_public_to_private.future;
    get listings[r0] into r3;
    not r3.is_removed into r4;
    assert.eq r4 true;
    not r3.is_accepted into r5;
    assert.eq r5 true;
    assert.eq r3.is_private true;
    assert.eq r1 r3.nft_commit;
    cast r3.nft_commit r3.price r3.name_hash r3.market_royalty_index r3.creator_royalty_index r3.is_private false true into r6 as ListingData;
    set r6 into listings[r0];
    await r2;




function accept_private_listing:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as credits.aleo/credits.record;
    input r3 as u64.public;
    input r4 as u16.public;
    input r5 as address.public;
    input r6 as u16.public;
    input r7 as address.public;
    cast  r1 0field 0field 0field into r8 as [field; 4u32];
    cast r8 into r9 as data;
    call aleo_name_service_registry_v4.aleo/transfer_public_to_private r9 0scalar self.signer into r10 r11;
    hash.bhp256 r9 into r12 as field;
    commit.bhp256 r12 0scalar into r13 as field;
    cast r4 into r14 as u64;
    mul r14 r3 into r15;
    div r15 10000u64 into r16;
    cast r6 into r17 as u64;
    mul r17 r3 into r18;
    div r18 10000u64 into r19;
    sub r3 r16 into r20;
    sub r20 r19 into r21;
    call credits.aleo/transfer_private_to_public r2 zmarket_ans_listing.aleo r3 into r22 r23;
    call credits.aleo/transfer_public r7 r19 into r24;
    call credits.aleo/transfer_public r5 r16 into r25;
    async accept_private_listing r0 r13 r3 r4 r5 r6 r7 r11 r23 r24 r25 into r26;
    output r10 as aleo_name_service_registry_v4.aleo/NFT.record;
    output r26 as zmarket_ans_listing.aleo/accept_private_listing.future;

finalize accept_private_listing:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as u64.public;
    input r3 as u16.public;
    input r4 as address.public;
    input r5 as u16.public;
    input r6 as address.public;
    input r7 as aleo_name_service_registry_v4.aleo/transfer_public_to_private.future;
    input r8 as credits.aleo/transfer_private_to_public.future;
    input r9 as credits.aleo/transfer_public.future;
    input r10 as credits.aleo/transfer_public.future;
    get listings[r0] into r11;
    assert.eq r11.is_private true;
    not r11.is_accepted into r12;
    assert.eq r12 true;
    not r11.is_removed into r13;
    assert.eq r13 true;
    assert.eq r1 r11.nft_commit;
    assert.eq r2 r11.price;
    get zmarket_royalty.aleo/royalties[r11.market_royalty_index] into r14;
    get ans_listing_royalty.aleo/royalties[r11.creator_royalty_index] into r15;
    assert.eq r3 r14.permyriad;
    assert.eq r4 r14.holder;
    assert.eq r5 r15.permyriad;
    assert.eq r6 r15.holder;
    cast r11.nft_commit r11.price r11.name_hash r11.market_royalty_index r11.creator_royalty_index r11.is_private true false into r16 as ListingData;
    set r16 into listings[r0];
    await r7;
    await r8;
    await r9;
    await r10;

