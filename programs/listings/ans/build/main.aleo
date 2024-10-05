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
    nft_commit as field.private;
    price as u64.private;

struct PublicListingData:
    price as u64;
    seller as address;


mapping public_listings:
	key as field.public;
	value as PublicListingData.public;

function list_private:
    input r0 as aleo_name_service_registry_v4.aleo/NFT.record;


function list_public:


