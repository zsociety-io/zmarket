import ans_utils_v2.aleo;
import aleo_name_service_registry_v4.aleo;
import credits.aleo;
import zmarket_marketplace_volume.aleo;
program zmarket_ans_listing.aleo;

struct NameStruct:
    name as [u128; 4u32];
    parent as field;
    resolver as field;

struct data:
    metadata as [field; 4u32];





record PrivateListing:
    owner as address.private;
    listing_id as field.private;

struct ListingData:
    nft_commit as field;
    price as u64;
    name_hash as field;
    is_private as boolean;
    is_live as boolean;


mapping listings:
	key as field.public;
	value as ListingData.public;


mapping commit_to_data:
	key as field.public;
	value as data.public;




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
    cast r1 r2 r3 true true into r7 as ListingData;
    set r7 into listings[r0];
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
    assert.eq r3.is_live true;
    assert.eq r3.is_private true;
    assert.eq r1 r3.nft_commit;
    cast r3.nft_commit r3.price r3.name_hash r3.is_private false into r4 as ListingData;
    set r4 into listings[r0];
    await r2;

