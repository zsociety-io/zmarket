tx_fee () {
    curl -s "http://127.0.0.1:3030/testnet/transaction/$1" | jq -r '.fee.transition.inputs[] | select(.value | test("u64$")) | .value' | sed 's/u64//' | awk '$1 != "0"'  | awk '$1 != "0" {print $1 / 1000000}'
}


tx_fee "at1s6z6jfjjxcntqnhc3les7zffuy3h2gwlp97k5jvtse46nklgq5rq8efj9c"


✅ Created deployment transaction for 'nft_records_v3.aleo'
at1uuv32najg62md86lvpnph88xaq26acg7s5rp9085fh0ek9ml8vyqpsaevs
> 16,6922

✅ Created deployment transaction for 'nft_registry_v3.aleo'
at1luscjvnm9luq6ghu0ukz5a7y2kfrq4995lqk25thz7fswew9n5ys4ge2ky
> 71,3226

✅ Created deployment transaction for 'nft_collections_v3.aleo'
at1jsymegd39yrtkthkj0tykhhc5w07eytlgfg6tesjn27qwkn0rygsr9qh7t
> 15,8576

✅ Created deployment transaction for 'ans_utils_v2.aleo'
at1k4ct9ys9c26wsk0rt3pjk78zfev2aw62ytfk2nz962jz0t06tsyqmh7kxu
> 35,6436

✅ Created deployment transaction for 'aleo_name_service_registry_v4.aleo'
at1uadla4kyczk7t5eyqcxt9es6c7upzddk40qdd5qcwlyqzfk45yqqzwczr8
> 70,9569

✅ Created deployment transaction for 'wrapped_ans_nft_v3.aleo'
at175z04stkjwvjff7gsnv8upll2g836xkpcfmxz9qczla7frm58yzqrrgacj
> 45,8166

✅ Created deployment transaction for 'zmarket_royalties_v3.aleo'
at1njw6qfumuegzc4ywa9wwjsw77hg2gv276r9qhzyf9ma9pkdj3vqs9tf5j0
> 19,8243

✅ Created deployment transaction for 'zmarket_private_marketplace.aleo'
at1dmyny84kprv94e6ypk92qf6j9euws5sea9ceuzm2vjc3aan8l5zq3nqe4s
> 59,1752

✅ Created deployment transaction for 'zmarket_public_marketplace.aleo'
at1sxcqn555tyuefzfrgcuf33m65k4v9vrdkqg5d7dwujjs8m9rsurq85egz7
> 42,8523

✅ Created deployment transaction for 'zmarket_ans_listing_v3.aleo'
at1p7hsr56mk5p3yel2sddls3rremhunkvl77swl4azm4vwvzudggyqvjw84v
> 42,0899

✅ Created deployment transaction for 'zmarket_batch_withdraw.aleo'
at1s6z6jfjjxcntqnhc3les7zffuy3h2gwlp97k5jvtse46nklgq5rq8efj9c
> 37,105


✅ Total:
16,6922+71,3226+15,8576+35,6436+70,9569+45,8166+19,8243+59,1752+42,8523+42,0899+37,105
> 457.3362