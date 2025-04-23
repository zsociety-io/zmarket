



snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/$([[ $NETWORK == 'mainnet' ]] && echo 'mainnet' || echo 'testnet')/transaction/broadcast" \
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
  token_registry.aleo \
  transfer_private_to_public \
  aleo1dsmwmtm80fxl3jef5yenfzlze9kg0ugg5r3kzqjzk0c4pg4epyfqmff4zh \
  20000000000u128 \
  "{ owner: aleo1dsmwmtm80fxl3jef5yenfzlze9kg0ugg5r3kzqjzk0c4pg4epyfqmff4zh.private, amount: 20000000000u128.private, token_id: 13759769624877785000field.private, external_authorization_required: false.private, authorized_until: 4294967295u32.private, _nonce: 2885070201599878126488521550499632581730794877651425363230035121817156886863group.public}"


snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
  aleo_name_service_registry_v4.aleo \
  set_for_all_approval \
  aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax \
  true


snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
  nft_collections_v3.aleo \
  initialize
  

: '
snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
  credits.aleo \
  transfer_public \
  aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax \
  10_000_000_000u64

PRIVATE_KEY=

snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
  aleo_name_service_registry_v4.aleo \
  initialize_collection \
  "[184555836509371486643729180464841087996994525386362889823339413645119811119field, 0field, 0field, 0field]"

snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
  aleo_name_service_registry_v4.aleo \
  register \
  "[8026941076661429604u128, 0u128, 0u128, 0u128]" \
  559532657689873513833888656958509165446284001025178663602770230581478239512field \
  aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax \
  0field

snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
  aleo_name_service_registry_v4.aleo \
  transfer_private_to_public \
  "{
  owner: aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax.private,
  data: {
    metadata: [
      4726151986382737885774729803094400715432828111986117154513084343082343817886field.private,
      0field.private,
      0field.private,
      0field.private
    ]
  },
  edition: 0scalar.private,
  _nonce: 6740181706182263405388484213062446107921132945420656664743798182810330727961group.public
}" \
  aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax


snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
  aleo_name_service_registry_v4.aleo \
  transfer_public \
  "{metadata: [
      4726151986382737885774729803094400715432828111986117154513084343082343817886field,
      0field,
      0field,
      0field
    ]}" \
    0scalar \
  aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax

snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
  aleo_name_service_registry_v4.aleo \
  transfer_public_to_private \
  "{metadata: [
      4726151986382737885774729803094400715432828111986117154513084343082343817886field,
      0field,
      0field,
      0field
    ]}" \
    0scalar \
  aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax
'

snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
  zmarket_royalties_v3.aleo \
  initialize_marketplace \
  250u16 \
  250u16 \
  "[3144565289251880978667903074226330800661205682396127880461755386493451793455field, 31941486054026331686211900600078520153053858615field, 0field, 0field]" \
  "[5901222158416856528567965712374334914478123141238751990510661793728627828083field, 29050612332890824915204485114444214field, 0field, 0field]" \
  "[0field, 0field, 0field, 0field]" \
  "[0field, 0field, 0field, 0field]"

#async transition initialize_marketplace(
#    public market_fee_permyriad: u16,
#    public royalty_col_royalty_permyriad: u16,
#    public royalty_base_uri: [field; 4],
#    public royalty_metadata_uri: [field; 4],
#    public market_base_uri: [field; 4],
#    public market_metadata_uri: [field; 4]
#) -> Future {



snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
  wrapped_ans_nft_v3.aleo \
  initialize \
  "[184555836509371486643729180464841087996994525386362889823339413645119811119field, 0field, 0field, 0field]" \
  "[6579457258335983359855863597384440320763731473378049735637177104745392860787field, 103208507812591765127field, 0field, 0field]" 




snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
  zmarket_ans_listing_v3.aleo \
  initialize 

list_collection_public(
        public collection_id: field,
        public royalty_holder: address,
        public royalty_permyriad: u16,
        public list_as_market_admin: bool
    )


snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
  zmarket_royalties_v3.aleo \
  list_collection_public \
  123829191909212120210201field \
  "aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax" \
  "500u16" \
  "true"



snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
  zmarket_ans_listing_v3.aleo \
  list_private \
  "{
  owner: aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax.private,
  data: {
    metadata: [
      4726151986382737885774729803094400715432828111986117154513084343082343817886field.private,
      0field.private,
      0field.private,
      0field.private
    ]
  },
  edition: 0scalar.private,
  _nonce: 7716324172962557062277739838222423840716092023105457502464803226047120729782group.public
}" \
  "123field" \
  "1000000u64"


snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
  zmarket_ans_listing_v3.aleo \
  unlist_private \
  "{
  owner: aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax.private,
  listing_id: 123field.private,
  _nonce: 7029861082511989484100089868378231202388696115052951854682882789020248169598group.public
}" \
  "4726151986382737885774729803094400715432828111986117154513084343082343817886field"





snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
  zmarket_ans_listing_v3.aleo \
  list_public \
  "{
  owner: aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax.private,
  data: {
    metadata: [
      4726151986382737885774729803094400715432828111986117154513084343082343817886field.private,
      0field.private,
      0field.private,
      0field.private
    ]
  },
  edition: 0scalar.private,
  _nonce: 1306643725331229547460375411318874339764643873726119284492785756171945507957group.public
}" \
  "123field" \
  "1000000u64"



snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
  nft_collections_v3.aleo \
  register_collection_public \
  "666field" \
  "[0field, 0field, 0field, 0field]" \
  "[0field, 0field, 0field, 0field]"



snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/testnet/transaction/broadcast" \
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
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
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
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
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
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
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
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
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
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
  --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
  credits.aleo \
  transfer_public \
  aleo1wamjqlka7d0gazlxdys6n8e8zeee3ymedwvw8elvh7529kwd45rq0plgax \
  "1000000u64" \






snarkos developer execute \
  --private-key $PRIVATE_KEY \
  --query $NODE_URL \
  --broadcast "$NODE_URL/mainnet/transaction/broadcast" \
  --network 0 \
  vs__2_candidates.aleo \
  withdraw_receipt \
  "20000000000u128" \
  "{ owner: aleo1dsmwmtm80fxl3jef5yenfzlze9kg0ugg5r3kzqjzk0c4pg4epyfqmff4zh.private, amount: 20000000000u128.private, token_id: 13759769624877785000field.private, external_authorization_required: false.private, dao_id: 108499308674561316722141147149076657250625290770962488479599113291173424802field.private, proposal_id: 6980244902825108881703284087339462100954240005807707204789552599942732464462field.private, candidate: 1field.private, _nonce: 7579210663418594707367229654572376199541993008041899314682048189658272332384group.public}"





