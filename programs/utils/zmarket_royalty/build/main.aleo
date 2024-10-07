import zmarket_authority.aleo;
program zmarket_royalty.aleo;

struct Share:
    holder as address;
    permyriad as u16;


mapping royalties:
	key as u16.public;
	value as Share.public;


mapping royalties_length:
	key as boolean.public;
	value as u16.public;


function update_royalty:
    input r0 as address.public;
    input r1 as u16.public;
    call zmarket_authority.aleo/check_authorized self.caller into r2;
    lte r1 10000u16 into r3;
    assert.eq r3 true;
    async update_royalty r0 r1 r2 into r4;
    output r4 as zmarket_royalty.aleo/update_royalty.future;

finalize update_royalty:
    input r0 as address.public;
    input r1 as u16.public;
    input r2 as zmarket_authority.aleo/check_authorized.future;
    await r2;
    cast r0 r1 into r3 as Share;
    get.or_use royalties_length[true] 0u16 into r4;
    set r3 into royalties[r4];
    add r4 1u16 into r5;
    set r5 into royalties_length[true];

