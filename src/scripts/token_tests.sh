#!/bin/bash

# set -e

# clear
dfx stop
rm -rf .dfx

ALICE_HOME=$(mktemp -d)
# BOB_HOME=$(mktemp -d)
# DAN_HOME=$(mktemp -d)
FEE_HOME=$(mktemp -d)

HOME=$ALICE_HOME
ALICE_PUBLIC_KEY="principal \"$( \
    HOME=$ALICE_HOME dfx identity get-principal
)\""
# BOB_PUBLIC_KEY="principal \"$( \
#     HOME=$BOB_HOME dfx identity get-principal
# )\""
# DAN_PUBLIC_KEY="principal \"$( \
#     HOME=$DAN_HOME dfx identity get-principal
# )\""
FEE_PUBLIC_KEY="principal \"$( \
    HOME=$FEE_HOME dfx identity get-principal
)\""

echo Alice id = $ALICE_PUBLIC_KEY
# echo Bob id = $BOB_PUBLIC_KEY
# echo Dan id = $DAN_PUBLIC_KEY
echo Fee id = $FEE_PUBLIC_KEY

dfx start --clean --background --emulator
echo
dfx canister create utoken --no-wallet
echo
dfx build utoken

TOKENID=$(dfx canister id utoken)
TOKENID="principal \"$TOKENID\""

echo Token id: $TOKENID

echo
echo == Install token canister
echo

HOME=$ALICE_HOME
eval dfx canister install utoken --argument="'(\"Test Token Logo\", \"Test Token Name\", \"Test Token Symbol\", 6, "1_000_000_000", $ALICE_PUBLIC_KEY, 0)'"

echo
echo == Initial setting for utoken canister
echo

dfx canister call utoken setFeeTo "$FEE_PUBLIC_KEY"
dfx canister call utoken setFee "(100_000)"
echo Verifying fee update
dfx canister call utoken getTokenFee

echo
echo == Initial token balances for Alice and Bob, Dan, FeeTo
echo

echo Alice uToken Bal = $( \
    eval dfx canister call utoken balanceOf "'($ALICE_PUBLIC_KEY)'" \
)
# echo Bob = $( \
#     eval dfx canister call token balanceOf "'($BOB_PUBLIC_KEY)'" \
# )
# echo Dan = $( \
#     eval dfx canister call token balanceOf "'($DAN_PUBLIC_KEY)'" \
# )
echo Fee holder uToken Bal = $( \
    eval dfx canister call utoken balanceOf "'($FEE_PUBLIC_KEY)'" \
)

echo
echo == Transfer 100 tokens from Alice to Fee holder, should succeed
echo

eval dfx canister call utoken transfer "'($FEE_PUBLIC_KEY, "100_000_000")'"
echo Alice uToken Bal = $( \
    eval dfx canister call utoken balanceOf "'($ALICE_PUBLIC_KEY)'" \
)
echo Fee holder uToken Bal = $( \
    eval dfx canister call utoken balanceOf "'($FEE_PUBLIC_KEY)'" \
)

echo
echo == Transfer 0 tokens from Alice to Alice, should Return false, as value is smaller than fee.
echo

eval dfx canister call utoken transfer "'($ALICE_PUBLIC_KEY, 0)'"