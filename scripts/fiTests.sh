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
eval dfx canister install mxtc --argument="'(\"Mock XTC Logo\", \"Mock XTC\", \"mXTC\", 6, "1_000_000_000", $ALICE_PUBLIC_KEY, 0)'"
eval dfx canister install mwicp --argument="'(\"Mock WICP Logo\", \"Mock WICP\", \"mWICP\", 6, "2_000_000_000", $ALICE_PUBLIC_KEY, 0)'"
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
echo
echo == Alice transfers 500 utokens to Fee holder
eval dfx canister call utoken transfer "'($FEE_PUBLIC_KEY, 500_000_000)'"

echo
echo == Initial token balances for Alice and fixtc balance for fee taker
echo Alice uToken Bal = $(eval dfx canister call mxtc balanceOf "'($ALICE_PUBLIC_KEY)'")
echo Alice FiToken Bal = $(eval dfx canister call fixtc balanceOf "'($ALICE_PUBLIC_KEY)'")
echo FeeTo uToken Bal = $(eval dfx canister call mxtc balanceOf "'($FEE_PUBLIC_KEY)'")
echo FeeTo FiToken Bal = $(eval dfx canister call fixtc balanceOf "'($FEE_PUBLIC_KEY)'")

echo
echo
echo
echo ===================== FiTroller functions =====================
echo
echo == Add an FiToken to the supported markets, should succeed.
eval dfx canister call fitroller _supportMarket "'($FIXTCID)'"
eval dfx canister call fitroller _supportMarket "'($FIWICPID)'"
echo

echo
echo
echo
echo ===================== Supply tests =====================
echo
echo == Alice grants FiToken permission to spend 500 of her mxtcs, should succeed.
eval dfx canister call mxtc approve "'($FIXTCID, 500_000_000)'"
echo == Alice mints fixtcs \(exchanging 400 mxtcs\), should succeed.
eval dfx canister call fixtc mintfi "400_000_000"
echo
HOME=$FEE_HOME
echo == Fee holder grants FiToken permission to spend 300 mxtcs, should succeed.
eval dfx canister call mxtc approve "'($FIXTCID, 300_000_000)'"
echo == Fee holder mints fixtcs \(exchanging 200 mxtcs\), should succeed.
eval dfx canister call fixtc mintfi "200_000_000"
echo

echo New balances:
echo Alice uToken Bal = $(eval dfx canister call mxtc balanceOf "'($ALICE_PUBLIC_KEY)'")
echo Alice FiToken Bal = $(eval dfx canister call fixtc balanceOf "'($ALICE_PUBLIC_KEY)'")
echo Fee holder uToken Bal = $(eval dfx canister call mxtc balanceOf "'($FEE_PUBLIC_KEY)'")
echo Fee holder FiToken Bal = $(eval dfx canister call fixtc balanceOf "'($FEE_PUBLIC_KEY)'")
echo
echo FiToken canister uToken Bal = $(eval dfx canister call mxtc balanceOf "'($FIXTCID)'")
echo FiToken Total Supply = $(eval dfx canister call fixtc totalSupply)
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
echo Alice FiToken Bal = $(eval dfx canister call fixtc balanceOf "'($ALICE_PUBLIC_KEY)'")
echo
echo FiToken canister uToken Bal = $(eval dfx canister call mxtc balanceOf "'($FIXTCID)'")
echo FiToken Total Supply = $(eval dfx canister call fixtc totalSupply)
echo

echo
echo == Alice tries to redeem more than the platform\'s balance \(5000 mxtcs\), should not succeed.
eval dfx canister call fixtc redeem "5_000_000_000"
echo
echo == Alice tries to redeem more she has left \(305 mxtcs\), should not succeed.
eval dfx canister call fixtc redeem "305_000_000"
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
echo == Alice borrows 200 mxtcs.
eval dfx canister call fixtc borrow "200_000_000"
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
echo == Alice tries to REDEEM more than her liquidity allows \(70 mxtcs\), should not succeed.
eval dfx canister call fixtc redeem "70_000_000"
echo
echo == Alice tries to BORROW more than her liquidity allows \(70 mxtcs\), should not succeed.
eval dfx canister call fixtc borrow "70_000_000"
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
echo == Alice repays 20 mxtcs.
eval dfx canister call fixtc repayBehalf "'($ALICE_PUBLIC_KEY, 20_000_000)'"
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

# echo
# echo == getTransaction
# echo
# eval dfx canister call mxtc getTransaction "'(1)'"

# echo
# echo == getTransactions
# echo
# eval dfx canister call mxtc getTransactions "'(0,100)'" 

# echo
# echo == getUserTransactionAmount
# echo
# eval dfx canister  call mxtc getUserTransactionAmount "'($ALICE_PUBLIC_KEY)'" 

# echo
# echo == getUserTransactions
# echo
# eval dfx canister call mxtc getUserTransactions "'($ALICE_PUBLIC_KEY, 0, 1000)'"

# echo
# echo == getTokenInfo
# echo
# eval dfx canister  call mxtc getTokenInfo

# echo
# echo == getHolders
# echo
# eval dfx canister  call mxtc getHolders "'(0,100)'"

# echo
# echo == getAllowanceSize
# echo
# eval dfx canister  call mxtc getAllowanceSize

# echo
# echo == getUserApprovals
# echo
# eval dfx canister  call mxtc getUserApprovals "'($ALICE_PUBLIC_KEY)'"

# echo
# echo == get alice getUserTransactions
# echo
# eval dfx canister  call mxtc getUserTransactions "'($ALICE_PUBLIC_KEY, 0, 1000)'"

# echo
# echo == get fee History
# echo
# eval dfx canister  call mxtc getUserTransactions "'($FEE_PUBLIC_KEY, 0, 1000)'"


# echo
# echo == Upgrade mxtc
# echo
# HOME=$ALICE_HOME
# eval dfx canister install mxtc --argument="'(\"test\", \"Test uToken\", \"TT\", 2, 100, $ALICE_PUBLIC_KEY)'" -m=upgrade

# echo
# echo == all History
# echo
# eval dfx canister call mxtc getTransactions "'(0, 1000)'"

# echo
# echo == getTokenInfo
# echo
# dfx canister call mxtc getTokenInfo

# echo
# echo == get alice History
# echo
# eval dfx canister  call mxtc getUserTransactions "'($ALICE_PUBLIC_KEY, 0, 1000)'"

# dfx stop
