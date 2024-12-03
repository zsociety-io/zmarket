import credits.aleo;
import nft_records_v3.aleo;
import nft_registry_v3.aleo;
import nft_collections_v3.aleo;
import zmarket_royalties_v3.aleo;
import zmarket_private_marketplace.aleo;
import zmarket_public_marketplace.aleo;
import ans_utils_v2.aleo;
import aleo_name_service_registry_v4.aleo;
import wrapped_ans_nft_v3.aleo;
program zmarket_ans_listing_v3.aleo;

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

struct NameStruct:
    name as [u128; 4u32];
    parent as field;
    resolver as field;

struct data:
    metadata as [field; 4u32];

function initialize:
    call nft_registry_v3.aleo/set_for_all_approval 123829191909212120210201field wrapped_ans_nft_v3.aleo true into r0;
    async initialize r0 into r1;
    output r1 as zmarket_ans_listing_v3.aleo/initialize.future;

finalize initialize:
    input r0 as nft_registry_v3.aleo/set_for_all_approval.future;
    await r0;

function list_private:
    input r0 as aleo_name_service_registry_v4.aleo/NFT.record;
    input r1 as field.public;
    input r2 as u64.public;
    call wrapped_ans_nft_v3.aleo/wrap_private r0 self.signer into r3 r4;
    call zmarket_private_marketplace.aleo/list_private r3 r1 r2 into r5 r6;
    async list_private r4 r6 into r7;
    output r5 as zmarket_private_marketplace.aleo/PrivateListing.record;
    output r7 as zmarket_ans_listing_v3.aleo/list_private.future;

finalize list_private:
    input r0 as wrapped_ans_nft_v3.aleo/wrap_private.future;
    input r1 as zmarket_private_marketplace.aleo/list_private.future;
    await r0;
    await r1;

function unlist_private:
    input r0 as zmarket_private_marketplace.aleo/PrivateListing.record;
    input r1 as field.public;
    cast r1 into r2 as Data;
    call zmarket_private_marketplace.aleo/unlist_private r0 123829191909212120210201field r2 0scalar into r3 r4;
    call wrapped_ans_nft_v3.aleo/unwrap_private r3 self.signer into r5 r6;
    async unlist_private r4 r6 into r7;
    output r5 as aleo_name_service_registry_v4.aleo/NFT.record;
    output r7 as zmarket_ans_listing_v3.aleo/unlist_private.future;

finalize unlist_private:
    input r0 as zmarket_private_marketplace.aleo/unlist_private.future;
    input r1 as wrapped_ans_nft_v3.aleo/unwrap_private.future;
    await r0;
    await r1;

function accept_private_listing:
    input r0 as field.public;
    input r1 as credits.aleo/credits.record;
    input r2 as field.public;
    input r3 as u64.public;
    cast r2 into r4 as Data;
    call zmarket_private_marketplace.aleo/accept_withdraw_nft_pv_listing r0 r1 123829191909212120210201field r4 0scalar r3 into r5 r6;
    call wrapped_ans_nft_v3.aleo/unwrap_private r5 self.signer into r7 r8;
    async accept_private_listing r6 r8 into r9;
    output r7 as aleo_name_service_registry_v4.aleo/NFT.record;
    output r9 as zmarket_ans_listing_v3.aleo/accept_private_listing.future;

finalize accept_private_listing:
    input r0 as zmarket_private_marketplace.aleo/accept_withdraw_nft_pv_listing.future;
    input r1 as wrapped_ans_nft_v3.aleo/unwrap_private.future;
    await r0;
    await r1;

function accept_private_offer:
    input r0 as field.public;
    input r1 as u64.public;
    input r2 as aleo_name_service_registry_v4.aleo/NFT.record;
    call wrapped_ans_nft_v3.aleo/wrap_private r2 self.signer into r3 r4;
    call zmarket_private_marketplace.aleo/accept_private_offer r0 r1 r3 into r5 r6;
    async accept_private_offer r4 r6 into r7;
    output r5 as credits.aleo/credits.record;
    output r7 as zmarket_ans_listing_v3.aleo/accept_private_offer.future;

finalize accept_private_offer:
    input r0 as wrapped_ans_nft_v3.aleo/wrap_private.future;
    input r1 as zmarket_private_marketplace.aleo/accept_private_offer.future;
    await r0;
    await r1;

function withdraw_nft_private_offer:
    input r0 as zmarket_private_marketplace.aleo/PrivateOffer.record;
    input r1 as field.private;
    cast r1 into r2 as Data;
    call zmarket_private_marketplace.aleo/withdraw_nft_private_offer r0 123829191909212120210201field r2 0scalar into r3 r4;
    call wrapped_ans_nft_v3.aleo/unwrap_private r3 self.signer into r5 r6;
    async withdraw_nft_private_offer r4 r6 into r7;
    output r5 as aleo_name_service_registry_v4.aleo/NFT.record;
    output r7 as zmarket_ans_listing_v3.aleo/withdraw_nft_private_offer.future;

finalize withdraw_nft_private_offer:
    input r0 as zmarket_private_marketplace.aleo/withdraw_nft_private_offer.future;
    input r1 as wrapped_ans_nft_v3.aleo/unwrap_private.future;
    await r0;
    await r1;

function accept_public_listing_as_signer:
    input r0 as field.public;
    input r1 as field.public;
    input r2 as u64.public;
    input r3 as address.public;
    input r4 as u64.public;
    cast  r1 0field 0field 0field into r5 as [field; 4u32];
    cast r5 into r6 as data;
    call wrapped_ans_nft_v3.aleo/wrap_from_public r6 0scalar r3 r3 into r7;
    cast r1 into r8 as Data;
    call zmarket_public_marketplace.aleo/accept_public_listing_as_signer r0 123829191909212120210201field r8 0scalar r2 r3 r4 into r9;
    cast r1 into r10 as Data;
    call nft_registry_v3.aleo/transfer_public_as_signer 123829191909212120210201field r10 0scalar zmarket_ans_listing_v3.aleo into r11 r12;
    cast r1 into r13 as Data;
    call wrapped_ans_nft_v3.aleo/unwrap_from_public r13 0scalar zmarket_ans_listing_v3.aleo self.signer into r14;
    async accept_public_listing_as_signer r7 r9 r12 r14 into r15;
    output r15 as zmarket_ans_listing_v3.aleo/accept_public_listing_as_signer.future;

finalize accept_public_listing_as_signer:
    input r0 as wrapped_ans_nft_v3.aleo/wrap_from_public.future;
    input r1 as zmarket_public_marketplace.aleo/accept_public_listing_as_signer.future;
    input r2 as nft_registry_v3.aleo/transfer_public_as_signer.future;
    input r3 as wrapped_ans_nft_v3.aleo/unwrap_from_public.future;
    await r0;
    await r1;
    await r2;
    await r3;

function accept_public_listing_private:
    input r0 as credits.aleo/credits.record;
    input r1 as field.public;
    input r2 as field.public;
    input r3 as u64.public;
    input r4 as address.public;
    input r5 as u64.public;
    cast  r2 0field 0field 0field into r6 as [field; 4u32];
    cast r6 into r7 as data;
    call wrapped_ans_nft_v3.aleo/wrap_from_public r7 0scalar r4 r4 into r8;
    cast r2 into r9 as Data;
    call zmarket_public_marketplace.aleo/accept_public_listing_private r1 r0 123829191909212120210201field r9 0scalar r3 r4 r5 into r10 r11 r12;
    call wrapped_ans_nft_v3.aleo/unwrap_private r11 self.signer into r13 r14;
    async accept_public_listing_private r8 r12 r14 into r15;
    output r10 as credits.aleo/credits.record;
    output r13 as aleo_name_service_registry_v4.aleo/NFT.record;
    output r15 as zmarket_ans_listing_v3.aleo/accept_public_listing_private.future;

finalize accept_public_listing_private:
    input r0 as wrapped_ans_nft_v3.aleo/wrap_from_public.future;
    input r1 as zmarket_public_marketplace.aleo/accept_public_listing_private.future;
    input r2 as wrapped_ans_nft_v3.aleo/unwrap_private.future;
    await r0;
    await r1;
    await r2;

function accept_public_offer_private:
    input r0 as field.public;
    input r1 as u64.public;
    input r2 as address.public;
    input r3 as aleo_name_service_registry_v4.aleo/NFT.record;
    call wrapped_ans_nft_v3.aleo/wrap_private r3 self.signer into r4 r5;
    call zmarket_public_marketplace.aleo/accept_public_offer_private r0 r1 r2 r4 into r6 r7;
    cast r3.data.metadata[0u32] into r8 as Data;
    call wrapped_ans_nft_v3.aleo/unwrap_from_public r8 r3.edition r2 r2 into r9;
    async accept_public_offer_private r5 r7 r9 into r10;
    output r6 as credits.aleo/credits.record;
    output r10 as zmarket_ans_listing_v3.aleo/accept_public_offer_private.future;

finalize accept_public_offer_private:
    input r0 as wrapped_ans_nft_v3.aleo/wrap_private.future;
    input r1 as zmarket_public_marketplace.aleo/accept_public_offer_private.future;
    input r2 as wrapped_ans_nft_v3.aleo/unwrap_from_public.future;
    await r0;
    await r1;
    await r2;

function accept_public_offer:
    input r0 as field.public;
    input r1 as u64.public;
    input r2 as address.public;
    input r3 as field.public;
    cast  r3 0field 0field 0field into r4 as [field; 4u32];
    cast r4 into r5 as data;
    call wrapped_ans_nft_v3.aleo/wrap_from_public r5 0scalar self.caller self.signer into r6;
    cast r3 into r7 as Data;
    call zmarket_public_marketplace.aleo/accept_public_offer_as_signer r0 r1 r2 123829191909212120210201field r7 0scalar into r8;
    call wrapped_ans_nft_v3.aleo/unwrap_from_public r7 0scalar r2 r2 into r9;
    async accept_public_offer r6 r8 r9 into r10;
    output r10 as zmarket_ans_listing_v3.aleo/accept_public_offer.future;

finalize accept_public_offer:
    input r0 as wrapped_ans_nft_v3.aleo/wrap_from_public.future;
    input r1 as zmarket_public_marketplace.aleo/accept_public_offer_as_signer.future;
    input r2 as wrapped_ans_nft_v3.aleo/unwrap_from_public.future;
    await r0;
    await r1;
    await r2;
