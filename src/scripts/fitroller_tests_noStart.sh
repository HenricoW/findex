#!/bin/bash

# set -e

dfx canister create fitroller --no-wallet
echo
dfx build fitroller

FITROLLERID=$(dfx canister id fitroller)
FITROLLERID="principal \"$FITROLLERID\""
echo FiTroller id: $FITROLLERID

echo
echo == Install \(Deploy\) canisters
echo
eval dfx canister install fitroller

UTOKENID="principal \"xoyak-nmxaq-aaaaa-aaaaa-c\""
FITOKENID="principal \"onzn5-j4zaq-aaaaa-aaaaa-c\""
echo uToken id: $UTOKENID
echo FiToken id: $FITOKENID

ALICE_HOME="/tmp/tmp.Vzf1y1AUsU"
ALICE_PUBLIC_KEY="principal \"abcc6-nany4-buhsh-sw4ga-fgmjp-kcrsh-z72ag-3eztw-vv5az-edmqw-dae\""

echo
echo
echo
echo ===================== Admin functions tests =====================
echo
echo == Add an FiToken to the supported markets, should succeed.
eval dfx canister call fitroller _supportMarket "'($FITOKENID)'"
echo

echo
echo
echo
echo ===================== User functions tests =====================
echo
echo ===================== enterMarkets =====================
echo
HOME=$ALICE_HOME
echo == Read user asset data, should be empty.
eval dfx canister call fitroller getAccountAssets "'($ALICE_PUBLIC_KEY)'"
echo
echo == Read token market data, should be empty.
eval dfx canister call fitroller getMarketUsers "'($FITOKENID)'"
echo
echo == Alice enters market for an FiToken, should succeed.
eval dfx canister call fitroller enterMarkets "'(vec {$FITOKENID})'"
echo
echo == Alice enters market for same FiToken, should not succeed.
eval dfx canister call fitroller enterMarkets "'(vec {$FITOKENID})'"
echo
echo == Read Alice\'s asset entered, should be populated.
eval dfx canister call fitroller getAccountAssets "'($ALICE_PUBLIC_KEY)'"
echo
echo == Read token\'s market users, should be populated.
eval dfx canister call fitroller getMarketUsers "'($FITOKENID)'"
echo
echo == Get Alice\'s liquidity
eval dfx canister call fitroller getHypotheticalLiquidity "'($ALICE_PUBLIC_KEY, $FITOKENID, 0, 0)'"
echo

# dfx canister call fitroller getHypotheticalLiquidity "(principal \"abcc6-nany4-buhsh-sw4ga-fgmjp-kcrsh-z72ag-3eztw-vv5az-edmqw-dae\", principal \"onzn5-j4zaq-aaaaa-aaaaa-c\", 0, 9_900_000)"


