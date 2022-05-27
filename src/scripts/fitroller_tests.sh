#!/bin/bash

# set -e

# clear
dfx stop
rm -rf .dfx

ALICE_HOME=$(mktemp -d)
FEE_HOME=$(mktemp -d)

HOME=$ALICE_HOME
ALICE_PUBLIC_KEY="principal \"$( \
    HOME=$ALICE_HOME dfx identity get-principal
)\""
FEE_PUBLIC_KEY="principal \"$( \
    HOME=$FEE_HOME dfx identity get-principal
)\""

echo Alice id = $ALICE_PUBLIC_KEY
echo Fee id = $FEE_PUBLIC_KEY
echo

dfx start --clean --background --emulator
echo
dfx canister create utoken --no-wallet
dfx canister create fitoken --no-wallet
dfx canister create fitroller --no-wallet
echo
dfx build utoken
dfx build fitoken
dfx build fitroller

UTOKENID_TEXT=$(dfx canister id utoken)
UTOKENID="principal \"$UTOKENID_TEXT\""
echo uToken id: $UTOKENID

FITOKENID=$(dfx canister id fitoken)
FITOKENID="principal \"$FITOKENID\""
echo FiToken id: $FITOKENID

FITROLLERID=$(dfx canister id fitroller)
FITROLLERID="principal \"$FITROLLERID\""
echo FiTroller id: $FITROLLERID

echo
echo == Install \(Deploy\) canisters
echo

HOME=$ALICE_HOME
eval dfx canister install utoken --argument="'(\"Test uToken Logo\", \"Test uToken Name\", \"Test uToken Symbol\", 6, "1_000_000_000", $ALICE_PUBLIC_KEY, 0)'"
eval dfx canister install fitoken --argument="'(\"Fi Token Logo\", \"Fi Token Name\", \"Fi Token Symbol\", 8, $ALICE_PUBLIC_KEY, \"$UTOKENID_TEXT\", "110_000_000", 0)'"
eval dfx canister install fitroller

echo
echo
echo
echo ===================== Admin functions tests =====================
echo
echo == Add an FiToken to the supported markets, should succeed.
eval dfx canister call fitroller _supportMarket "'($FITOKENID)'"
echo
echo == Add an FiToken to the supported markets, should not succeed.
eval dfx canister call fitroller _supportMarket "'($FITOKENID)'"
echo
echo == Add a DIP20 to the supported markets, should not succeed.
eval dfx canister call fitroller _supportMarket "'($UTOKENID)'"
echo
HOME=$FEE_HOME
echo == Add an FiToken to the supported markets from non Admin Account, should not succeed.
eval dfx canister call fitroller _supportMarket "'($FITOKENID)'"
echo