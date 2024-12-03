
source ./development/.env

# deploy_any $path $program_id

deploy_program () {
    build_path="$1/build"
    cd $build_path;
    snarkos developer deploy \
        --private-key $PRIVATE_KEY \
        --query $NODE_URL \
        --priority-fee 0 \
        --broadcast "$NODE_URL/$NETWORK/transaction/broadcast" \
        --network $([[ $NETWORK == "mainnet" ]] && echo 0 || echo 1) \
        "$2.aleo";
    only_slash="${build_path//[^\/]}";
    slash_amount="${#only_slash}";
    back_steps=$(printf '../%.0s' $(seq 1 $slash_amount));
    cd $back_steps;
}

deploy_program "./programs/aleo-standard-programs/arc722_records" "nft_records_v3";
deploy_program "./programs/aleo-standard-programs/arc722" "nft_registry_v3";
deploy_program "./programs/aleo-standard-programs/arc722_collections" "nft_collections_v3";

deploy_program "./programs/arc721_wrappers/ans/ans-programs/programs/ans_utils" "ans_utils_v2";
deploy_program "./programs/arc721_wrappers/ans/ans-programs/programs/registry" "aleo_name_service_registry_v4";

deploy_program "./programs/arc721_wrappers/ans/wrapped_ans_nft" "wrapped_ans_nft_v3";
deploy_program "./programs/royalties" "zmarket_royalties_v3";
deploy_program "./programs/private_marketplace" "zmarket_private_marketplace";
deploy_program "./programs/public_marketplace" "zmarket_public_marketplace";
deploy_program "./programs/listings/ans" "zmarket_ans_listing_v3";
deploy_program "./programs/batch_withdraw" "zmarket_batch_withdraw";

