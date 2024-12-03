

snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network 1 \
  nft_collections_v3.aleo \
  initialize


snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network 1 \
  zmarket_royalties_v3.aleo \
  initialize_marketplace \
  250u16 \
  250u16 \
  "[0field, 0field, 0field, 0field]" \
  "[0field, 0field, 0field, 0field]" \
  "[0field, 0field, 0field, 0field]" \
  "[0field, 0field, 0field, 0field]"


snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network 1 \
  wrapped_ans_nft_v3.aleo \
  initialize \
  "[0field, 0field, 0field, 0field]" \
  "[0field, 0field, 0field, 0field]" 


snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network 1 \
  zmarket_ans_listing_v3.aleo \
  initialize 



snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network 1 \
  zmarket_royalties_v3.aleo \
  list_collection_public \
  123829191909212120210201field \
  "aleo1dsmwmtm80fxl3jef5yenfzlze9kg0ugg5r3kzqjzk0c4pg4epyfqmff4zh" \
  "500u16" \
  "true"



snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network 1 \
  zmarket_ans_listing_v3.aleo \
  list_private \
  "{ owner: aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax.private, data: { metadata: [ 833329101462739205318069191154451581906914459441545149198933179249477002025field.private, 0field.private, 0field.private, 0field.private ] }, edition: 0scalar.private, _nonce: 4144562084551573102719192513613452075104848449992467649556619061776772779397group.public}" \
  "123field" \
  "1000000u64"



snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network 1 \
  nft_collections_v3.aleo \
  register_collection_public \
  "666field" \
  "[0field, 0field, 0field, 0field]" \
  "[0field, 0field, 0field, 0field]"



snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network 1 \
  nft_registry_v3.aleo \
  mint_public \
  aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax \
  "666field" \
  "{metadata: 0field}" \
  0scalar


snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network 1 \
  nft_registry_v3.aleo \
  transfer_public \
  "666field" \
  "{metadata: 0field}" \
  0scalar \
  aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax


snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network 1 \
  nft_registry_v3.aleo \
  transfer_public_to_private \
  "666field" \
  "{metadata: 0field}" \
  0scalar \
  aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax


snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network 1 \
  nft_registry_v3.aleo \
  transfer_private \
  "{
  owner: aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax.private,
  collection_id: 666field.private,
  data: {
    metadata: 0field.private
  },
  edition: 0scalar.private,
  _nonce: 1501843696319091506380216427097861664136764802188005973121674748554885638225group.public
  }" \
  aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax



snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network 1 \
  zmarket_ans_listing_v3.aleo \
  accept_private_listing \
  "123field" \
  "{
  owner: aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax.private,
  microcredits: 10000000u64.private,
  _nonce: 1942401788670302663307780022287509643486450787700784881092539202601738131766group.public
}" \
  123829191909212120210201field \
  "833329101462739205318069191154451581906914459441545149198933179249477002025field" \
  "1000000u64"







snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network 1 \
  credits.aleo \
  transfer_public \
  aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax \
  "1000000u64" \
  