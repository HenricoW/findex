#!/bin/bash

# set -e

# clear
dfx stop
rm -rf .dfx

ALICE_HOME=$(mktemp -d)

HOME=$ALICE_HOME
ALICE_PUBLIC_KEY="principal \"$( \
    HOME=$ALICE_HOME dfx identity get-principal
)\""

echo Alice id = $ALICE_PUBLIC_KEY
echo

dfx start --background --emulator # --clean
echo
dfx canister create interestRate --no-wallet
echo
dfx build interestRate

IRATEID_TEXT=$(dfx canister id interestRate)
IRATEID="principal \"$IRATEID_TEXT\""
echo interestRate id: $IRATEID

echo
echo == Install \(Deploy\) canisters
echo

HOME=$ALICE_HOME
BASE_RATE_ANNUAL=6.0
SLOPE_RATE_ANNUAL=24.0
eval dfx canister install interestRate --argument="'($BASE_RATE_ANNUAL, $SLOPE_RATE_ANNUAL)'"

echo
echo
echo
echo ===================== Rate value tests =====================
echo
echo == test utilizationRate, should yield 50% in mantissa \(10e8\).
CASH=55_000
BORROWS=50_000
RESERVES=5_000
eval dfx canister call interestRate utilizationRate "'($CASH, $BORROWS, $RESERVES)'"

echo
echo == test borrow rate, should yield 18% \(3,424 per minute\) in mantissa \(10e8\).
eval dfx canister call interestRate getBorrowRate "'($CASH, $BORROWS, $RESERVES)'"
# URATE=$(dfx canister call interestRate getBorrowRate "($CASH, $BORROWS, $RESERVES)")
# eval $URATE * 365 * 24 * 60
echo
echo == test supply rate, should yield 3.6% \(685 per minute\) in mantissa \(10e8\).
RESERVE_FACOTR=60_000_000
eval dfx canister call interestRate getSupplyRate "'($CASH, $BORROWS, $RESERVES, $RESERVE_FACOTR)'"
echo
echo
echo == test utilizationRate, should yield 0%.
BORROWS=0
eval dfx canister call interestRate utilizationRate "'($CASH, $BORROWS, $RESERVES)'"
echo
echo == test borrow rate, should yield 6% \(1,141 per minute\) in mantissa \(10e8\).
eval dfx canister call interestRate getBorrowRate "'($CASH, $BORROWS, $RESERVES)'"
echo
echo == test supply rate, should yield 0% \(0 per minute\) in mantissa \(10e8\).
RESERVE_FACOTR=60_000_000
eval dfx canister call interestRate getSupplyRate "'($CASH, $BORROWS, $RESERVES, $RESERVE_FACOTR)'"
echo