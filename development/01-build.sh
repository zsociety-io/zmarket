source ./development/.env

build_from_path () {
    build_path="$1"
    cd $build_path;
    leo build --network $NETWORK --endpoint $NODE_URL;
    only_slash="${build_path//[^\/]}";
    slash_amount="${#only_slash}";
    back_steps=$(printf '../%.0s' $(seq 1 $slash_amount));
    cd $back_steps;
}


build_from_path "./programs/aleo-standard-programs/arc722_records";
build_from_path "./programs/aleo-standard-programs/arc722";
build_from_path "./programs/aleo-standard-programs/arc722_collections";

build_from_path "./programs/arc721_wrappers/ans/ans-programs/programs/ans_utils";
build_from_path "./programs/arc721_wrappers/ans/ans-programs/programs/registry";

build_from_path "./programs/arc721_wrappers/ans/wrapped_ans_nft";
build_from_path "./programs/royalties";
build_from_path "./programs/public_marketplace";
build_from_path "./programs/private_marketplace";
build_from_path "./programs/listings/ans";
build_from_path "./programs/batch_withdraw";


add public marketplace
add batch withdrawal