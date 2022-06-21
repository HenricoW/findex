#!/bin/bash

# set -e

# clear
dfx stop
rm -rf .dfx

echo
echo ====== Running tests for fiToken ======
echo

ALICE_HOME=$(mktemp -d)
FEE_HOME=$(mktemp -d)
HOME=$ALICE_HOME

ALICE_PUBLIC_KEY="principal \"$( \
    HOME=$ALICE_HOME dfx identity get-principal
)\""
FEE_PUBLIC_KEY="principal \"$( \
    HOME=$FEE_HOME dfx identity get-principal
)\""

echo
echo $ALICE_HOME
echo Alice id = $ALICE_PUBLIC_KEY
echo Fee id = $FEE_PUBLIC_KEY
echo

dfx start --background --emulator --clean
echo
dfx canister create mxtc --no-wallet
dfx canister create mwicp --no-wallet
dfx canister create interestRate --no-wallet
dfx canister create fitroller --no-wallet
dfx canister create fixtc --no-wallet
dfx canister create fiwicp --no-wallet
echo
dfx build mxtc
dfx build mwicp
dfx build interestRate
dfx build fitroller
dfx build fixtc
dfx build fiwicp

MXTCID_TEXT=$(dfx canister id mxtc)
MXTCID="principal \"$MXTCID_TEXT\""
echo mXTC id: $MXTCID

MWICPID_TEXT=$(dfx canister id mwicp)
MWICPID="principal \"$MWICPID_TEXT\""
echo mWICP id: $MWICPID

IRATEID_TEXT=$(dfx canister id interestRate)
IRATEID="principal \"$IRATEID_TEXT\""
echo interestRate id: $IRATEID

FITROLLER_TEXT=$(dfx canister id fitroller)
FITROLLERID="principal \"$FITROLLER_TEXT\""
echo FiTroller id: $FITROLLERID

FIXTCID=$(dfx canister id fixtc)
FIXTCID="principal \"$FIXTCID\""
echo fiXTC id: $FIXTCID

FIWICPID=$(dfx canister id fiwicp)
FIWICPID="principal \"$FIWICPID\""
echo fiWICP id: $FIWICPID

echo
echo == Install canisters
echo

HOME=$ALICE_HOME
eval dfx canister install mxtc --argument="'(\"Mock XTC Logo\", \"Mock XTC\", \"mXTC\", 6, "3_000_000_000", $ALICE_PUBLIC_KEY, 0)'"
eval dfx canister install mwicp --argument="'(\"Mock WICP Logo\", \"Mock WICP\", \"mWICP\", 6, "3_000_000_000", $ALICE_PUBLIC_KEY, 0)'"
eval dfx canister install interestRate --argument="'(6.0, 24.0)'"
eval dfx canister install fitroller
eval dfx canister install fixtc --argument="'(\"fiXTC Logo\", \"Finitrade XTC\", \"fiXTC\", 8, $ALICE_PUBLIC_KEY, \"$MXTCID_TEXT\", \"$FITROLLER_TEXT\", "110_000_000", \"$IRATEID_TEXT\", 0)'"
eval dfx canister install fiwicp --argument="'(\"fiWICP Logo\", \"Finitrade WICP\", \"fiWICP\", 8, $ALICE_PUBLIC_KEY, \"$MWICPID_TEXT\", \"$FITROLLER_TEXT\", "110_000_000", \"$IRATEID_TEXT\", 0)'"

echo
echo == Set up
echo
dfx canister call fixtc setFeeTo "($FEE_PUBLIC_KEY)"
dfx canister call fixtc setFee "(10_000_000)"
echo Verifying fee update
dfx canister call fixtc getTokenFee
eval dfx canister call mxtc transfer "'($FEE_PUBLIC_KEY, 500_000_000)'"
echo
echo == Alice transfers some of each token to each of the demo EOAs \(\"User 1\" and \"User 2\" in the front-end\)
eval dfx canister call mxtc transfer "'(principal \"h4ln2-qsfaz-na6by-g6fu6-vizab-bvlnv-h3hdq-5yjr3-vgwvt-bh5ka-tqe\", 500_000_000)'"
eval dfx canister call mwicp transfer "'(principal \"h4ln2-qsfaz-na6by-g6fu6-vizab-bvlnv-h3hdq-5yjr3-vgwvt-bh5ka-tqe\", 1_000_000_000)'"
echo
echo == Alice transfers 300 xtc to the fee holder
eval dfx canister call mxtc transfer "'($FEE_PUBLIC_KEY, 300_000_000)'"

echo
echo == Initial token balances for Alice and fixtc balance for fee taker
echo Alice uToken Bal = $(eval dfx canister call mxtc balanceOf "'($ALICE_PUBLIC_KEY)'")
echo Alice FiXTC Bal = $(eval dfx canister call fixtc balanceOf "'($ALICE_PUBLIC_KEY)'")
echo FeeTo uToken Bal = $(eval dfx canister call mxtc balanceOf "'($FEE_PUBLIC_KEY)'")
echo FeeTo FiXTC Bal = $(eval dfx canister call fixtc balanceOf "'($FEE_PUBLIC_KEY)'")

echo
echo
echo
echo ===================== FiTroller functions =====================
echo
echo == Add an FiXTC to the supported markets, should succeed.
eval dfx canister call fitroller _supportMarket "'($FIXTCID)'"
eval dfx canister call fitroller _supportMarket "'($FIWICPID)'"
echo

echo
echo
echo
echo ===================== Supply tests =====================
echo
echo == Alice grants FiXTC permission to spend 1000 of her mxtc and mwicp, should succeed.
eval dfx canister call mxtc approve "'($FIXTCID, 1_000_000_000)'"
eval dfx canister call mwicp approve "'($FIWICPID, 1_500_000_000)'"
echo == Alice mints fixtcs \(exchanging 1000 mxtcs\), should succeed.
eval dfx canister call fixtc mintfi "1_000_000_000"
eval dfx canister call fiwicp mintfi "1_500_000_000"
echo
HOME=$FEE_HOME
echo == Fee holder grants FiToken permission to spend 250 mxtcs, should succeed.
eval dfx canister call mxtc approve "'($FIXTCID, 250_000_000)'"
echo == Fee holder mints fixtcs \(exchanging 200 mxtcs\), should succeed.
eval dfx canister call fixtc mintfi "200_000_000"
echo

echo New balances:
echo Alice mxtc Bal = $(eval dfx canister call mxtc balanceOf "'($ALICE_PUBLIC_KEY)'")
echo Alice FiXTC Bal = $(eval dfx canister call fixtc balanceOf "'($ALICE_PUBLIC_KEY)'")
echo Alice mwicp Bal = $(eval dfx canister call mwicp balanceOf "'($ALICE_PUBLIC_KEY)'")
echo Alice FiWICP Bal = $(eval dfx canister call fiwicp balanceOf "'($ALICE_PUBLIC_KEY)'")
echo
echo Fee holder mxtc Bal = $(eval dfx canister call mxtc balanceOf "'($FEE_PUBLIC_KEY)'")
echo Fee holder FiXTC Bal = $(eval dfx canister call fixtc balanceOf "'($FEE_PUBLIC_KEY)'")
echo
echo FiXTC canister mxtc Bal = $(eval dfx canister call mxtc balanceOf "'($FIXTCID)'")
echo FiXTC Total Supply = $(eval dfx canister call fixtc totalSupply)
echo

echo
echo
echo
echo ===================== Redeem tests =====================
echo
HOME=$ALICE_HOME
echo == Alice redeems fixtcs \(for 100 mxtcs\), should succeed.
eval dfx canister call fixtc redeem "100_000_000"
echo

echo New balances:
echo Alice uToken Bal = $(eval dfx canister call mxtc balanceOf "'($ALICE_PUBLIC_KEY)'")
echo Alice FiXTC Bal = $(eval dfx canister call fixtc balanceOf "'($ALICE_PUBLIC_KEY)'")
echo
echo FiXTC canister uToken Bal = $(eval dfx canister call mxtc balanceOf "'($FIXTCID)'")
echo FiXTC Total Supply = $(eval dfx canister call fixtc totalSupply)
echo

echo
echo == Alice tries to redeem more than the platform\'s balance \(5000 mxtcs\), should not succeed.
eval dfx canister call fixtc redeem "5_000_000_000"
echo
echo == Alice tries to redeem more she has left \(3500 mxtcs\), should not succeed.
eval dfx canister call fixtc redeem "3_500_000_000"
echo

echo
echo
echo
echo ===================== Borrow tests =====================
echo
echo == Fitoken total Liquidity values \(supply, borrows, reserves, interestIndex\).
eval dfx canister call fixtc getTotLiqInfo
echo == Fitoken exchange rate = $(dfx canister call fixtc getExchangeRate)
echo
echo == Get Alice\'s account liquidity.
eval dfx canister call fitroller getHypotheticalLiquidity "'($ALICE_PUBLIC_KEY, $FIXTCID, 0, 0)'"
echo
echo == Alice borrows 100 mxtcs.
eval dfx canister call fixtc borrow "100_000_000"
echo
# echo == Accrue interest.
# eval dfx canister call fixtc accrueInterest
# echo
echo == Fitoken total Liquidity values \(supply, borrows, reserves, interestIndex\).
eval dfx canister call fixtc getTotLiqInfo
echo == Fitoken exchange rate = $(dfx canister call fixtc getExchangeRate)
echo
echo == Get Alice\'s account liquidity.
eval dfx canister call fitroller getHypotheticalLiquidity "'($ALICE_PUBLIC_KEY, $FIXTCID, 0, 0)'"
echo
echo == Alice tries to REDEEM more than her liquidity allows \(800 mxtcs\), should not succeed.
eval dfx canister call fixtc redeem "800_000_000"
echo
echo == Alice tries to BORROW more than her liquidity allows \(800 mxtcs\), should not succeed.
eval dfx canister call fixtc borrow "800_000_000"
echo

echo
echo ===================== Simulate passage of time =====================
# one month in mins (30 days):         43 200
# three months in mins (90 days):     129 600
# six months in mins (180 days):      259 200
eval dfx canister call fixtc accrueInterestTest "129_600"

echo
echo
echo ===================== Helpers check =====================
echo == Get market supply rate \(per minute\).
eval dfx canister call fixtc getSupplyRatePerMin

echo == Get market borrow rate \(per minute\).
eval dfx canister call fixtc getBorrowRatePerMin
echo

echo
echo
echo
echo ===================== Repay tests =====================
echo
echo == Get Alice\'s account liquidity.
eval dfx canister call fitroller getHypotheticalLiquidity "'($ALICE_PUBLIC_KEY, $FIXTCID, 0, 0)'"
echo Alice uToken Bal = $(eval dfx canister call mxtc balanceOf "'($ALICE_PUBLIC_KEY)'")
echo
echo == Alice repays 50 mxtcs.
eval dfx canister call mxtc approve "'($FIXTCID, 50_000_000)'"
eval dfx canister call fixtc repayBehalf "'($ALICE_PUBLIC_KEY, 50_000_000)'"
echo
echo Alice uToken Bal = $(eval dfx canister call mxtc balanceOf "'($ALICE_PUBLIC_KEY)'")
echo == Fitoken total Liquidity values \(supply, borrows, reserves, interestIndex\).
eval dfx canister call fixtc getTotLiqInfo
echo == Fitoken exchange rate = $(dfx canister call fixtc getExchangeRate)
echo
echo == Get Alice\'s account liquidity.
eval dfx canister call fitroller getHypotheticalLiquidity "'($ALICE_PUBLIC_KEY, $FIXTCID, 0, 0)'"
echo






# echo
# echo == name
# echo
# eval dfx canister call mxtc name

# echo
# echo == symbol
# echo
# eval dfx canister call mxtc symbol

# echo
# echo == decimals
# echo
# eval dfx canister call mxtc decimals

# echo
# echo == totalSupply
# echo
# eval dfx canister call mxtc totalSupply

# echo
# echo == getMetadata
# echo
# eval dfx canister call mxtc getMetadata

# echo
# echo == historySize
# echo
# eval dfx canister call mxtc historySize

# dfx stop
