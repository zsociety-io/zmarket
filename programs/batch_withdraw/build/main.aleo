import credits.aleo;
import nft_records_v3.aleo;
import nft_registry_v3.aleo;
import nft_collections_v3.aleo;
import zmarket_royalties_v3.aleo;
import zmarket_public_marketplace.aleo;
import zmarket_private_marketplace.aleo;
program zmarket_batch_withdraw.aleo;

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

function withdraw_royalty_private:
    input r0 as nft_records_v3.aleo/NFT.record;
    input r1 as u64.public;
    input r2 as u64.public;
    call zmarket_public_marketplace.aleo/withdraw_royalty_private r0 r1 into r3 r4;
    call zmarket_public_marketplace.aleo/withdraw_royalty_private r0 r2 into r5 r6;
    call credits.aleo/join r3 r5 into r7;
    async withdraw_royalty_private r4 r6 into r8;
    output r7 as credits.aleo/credits.record;
    output r8 as zmarket_batch_withdraw.aleo/withdraw_royalty_private.future;

finalize withdraw_royalty_private:
    input r0 as zmarket_public_marketplace.aleo/withdraw_royalty_private.future;
    input r1 as zmarket_public_marketplace.aleo/withdraw_royalty_private.future;
    await r0;
    await r1;

function withdraw_listing_balance_2:
    input r0 as zmarket_private_marketplace.aleo/PrivateListing.record;
    input r1 as zmarket_private_marketplace.aleo/PrivateListing.record;
    input r2 as [u64; 2u32].public;
    call zmarket_private_marketplace.aleo/withdraw_listing_balance r0 r2[0u32] into r3 r4 r5;
    call zmarket_private_marketplace.aleo/withdraw_listing_balance r1 r2[1u32] into r6 r7 r8;
    call credits.aleo/join r4 r7 into r9;
    async withdraw_listing_balance_2 r5 r8 into r10;
    output r9 as credits.aleo/credits.record;
    output r10 as zmarket_batch_withdraw.aleo/withdraw_listing_balance_2.future;

finalize withdraw_listing_balance_2:
    input r0 as zmarket_private_marketplace.aleo/withdraw_listing_balance.future;
    input r1 as zmarket_private_marketplace.aleo/withdraw_listing_balance.future;
    await r0;
    await r1;

function withdraw_listing_balance_3:
    input r0 as zmarket_private_marketplace.aleo/PrivateListing.record;
    input r1 as zmarket_private_marketplace.aleo/PrivateListing.record;
    input r2 as zmarket_private_marketplace.aleo/PrivateListing.record;
    input r3 as [u64; 3u32].public;
    call zmarket_private_marketplace.aleo/withdraw_listing_balance r0 r3[0u32] into r4 r5 r6;
    call zmarket_private_marketplace.aleo/withdraw_listing_balance r1 r3[1u32] into r7 r8 r9;
    call zmarket_private_marketplace.aleo/withdraw_listing_balance r2 r3[2u32] into r10 r11 r12;
    call credits.aleo/join r5 r8 into r13;
    call credits.aleo/join r13 r11 into r14;
    async withdraw_listing_balance_3 r6 r9 r12 into r15;
    output r14 as credits.aleo/credits.record;
    output r15 as zmarket_batch_withdraw.aleo/withdraw_listing_balance_3.future;

finalize withdraw_listing_balance_3:
    input r0 as zmarket_private_marketplace.aleo/withdraw_listing_balance.future;
    input r1 as zmarket_private_marketplace.aleo/withdraw_listing_balance.future;
    input r2 as zmarket_private_marketplace.aleo/withdraw_listing_balance.future;
    await r0;
    await r1;
    await r2;

function withdraw_listing_balance_4:
    input r0 as zmarket_private_marketplace.aleo/PrivateListing.record;
    input r1 as zmarket_private_marketplace.aleo/PrivateListing.record;
    input r2 as zmarket_private_marketplace.aleo/PrivateListing.record;
    input r3 as zmarket_private_marketplace.aleo/PrivateListing.record;
    input r4 as [u64; 4u32].public;
    call zmarket_private_marketplace.aleo/withdraw_listing_balance r0 r4[0u32] into r5 r6 r7;
    call zmarket_private_marketplace.aleo/withdraw_listing_balance r1 r4[1u32] into r8 r9 r10;
    call zmarket_private_marketplace.aleo/withdraw_listing_balance r2 r4[2u32] into r11 r12 r13;
    call zmarket_private_marketplace.aleo/withdraw_listing_balance r3 r4[3u32] into r14 r15 r16;
    call credits.aleo/join r6 r9 into r17;
    call credits.aleo/join r17 r12 into r18;
    call credits.aleo/join r18 r15 into r19;
    async withdraw_listing_balance_4 r7 r10 r13 r16 into r20;
    output r19 as credits.aleo/credits.record;
    output r20 as zmarket_batch_withdraw.aleo/withdraw_listing_balance_4.future;

finalize withdraw_listing_balance_4:
    input r0 as zmarket_private_marketplace.aleo/withdraw_listing_balance.future;
    input r1 as zmarket_private_marketplace.aleo/withdraw_listing_balance.future;
    input r2 as zmarket_private_marketplace.aleo/withdraw_listing_balance.future;
    input r3 as zmarket_private_marketplace.aleo/withdraw_listing_balance.future;
    await r0;
    await r1;
    await r2;
    await r3;

function withdraw_listing_balance_5:
    input r0 as zmarket_private_marketplace.aleo/PrivateListing.record;
    input r1 as zmarket_private_marketplace.aleo/PrivateListing.record;
    input r2 as zmarket_private_marketplace.aleo/PrivateListing.record;
    input r3 as zmarket_private_marketplace.aleo/PrivateListing.record;
    input r4 as zmarket_private_marketplace.aleo/PrivateListing.record;
    input r5 as [u64; 5u32].public;
    call zmarket_private_marketplace.aleo/withdraw_listing_balance r0 r5[0u32] into r6 r7 r8;
    call zmarket_private_marketplace.aleo/withdraw_listing_balance r1 r5[1u32] into r9 r10 r11;
    call zmarket_private_marketplace.aleo/withdraw_listing_balance r2 r5[2u32] into r12 r13 r14;
    call zmarket_private_marketplace.aleo/withdraw_listing_balance r3 r5[3u32] into r15 r16 r17;
    call zmarket_private_marketplace.aleo/withdraw_listing_balance r4 r5[4u32] into r18 r19 r20;
    call credits.aleo/join r7 r10 into r21;
    call credits.aleo/join r21 r13 into r22;
    call credits.aleo/join r22 r16 into r23;
    call credits.aleo/join r23 r19 into r24;
    async withdraw_listing_balance_5 r8 r11 r14 r17 r20 into r25;
    output r24 as credits.aleo/credits.record;
    output r25 as zmarket_batch_withdraw.aleo/withdraw_listing_balance_5.future;

finalize withdraw_listing_balance_5:
    input r0 as zmarket_private_marketplace.aleo/withdraw_listing_balance.future;
    input r1 as zmarket_private_marketplace.aleo/withdraw_listing_balance.future;
    input r2 as zmarket_private_marketplace.aleo/withdraw_listing_balance.future;
    input r3 as zmarket_private_marketplace.aleo/withdraw_listing_balance.future;
    input r4 as zmarket_private_marketplace.aleo/withdraw_listing_balance.future;
    await r0;
    await r1;
    await r2;
    await r3;
    await r4;
