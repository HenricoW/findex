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

dfx start --background --emulator #--clean
echo
dfx canister create utoken --no-wallet
dfx canister create interestRate --no-wallet
dfx canister create fitroller --no-wallet
dfx canister create fitoken --no-wallet
echo
dfx build utoken
dfx build interestRate
dfx build fitroller
dfx build fitoken

UTOKENID_TEXT=$(dfx canister id utoken)
UTOKENID="principal \"$UTOKENID_TEXT\""
echo uToken id: $UTOKENID

IRATEID_TEXT=$(dfx canister id interestRate)
IRATEID="principal \"$IRATEID_TEXT\""
echo interestRate id: $IRATEID

FITROLLER_TEXT=$(dfx canister id fitroller)
FITROLLERID="principal \"$FITROLLER_TEXT\""
echo FiTroller id: $FITROLLERID

FITOKENID=$(dfx canister id fitoken)
FITOKENID="principal \"$FITOKENID\""
echo FiToken id: $FITOKENID

echo
echo == Install canisters
echo

HOME=$ALICE_HOME
eval dfx canister install utoken --argument="'(\"Test uToken Logo\", \"Test uToken Name\", \"Test uToken Symbol\", 6, "1_000_000_000", $ALICE_PUBLIC_KEY, 0)'"
eval dfx canister install interestRate --argument="'(6.0, 24.0)'"
eval dfx canister install fitroller
eval dfx canister install fitoken --argument="'(\"Fi Token Logo\", \"Fi Token Name\", \"Fi Token Symbol\", 8, $ALICE_PUBLIC_KEY, \"$UTOKENID_TEXT\", \"$FITROLLER_TEXT\", "110_000_000", \"$IRATEID_TEXT\", 0)'"

echo
echo == Set up
echo
dfx canister call fitoken setFeeTo "($FEE_PUBLIC_KEY)"
dfx canister call fitoken setFee "(10_000_000)"
echo Verifying fee update
dfx canister call fitoken getTokenFee
echo
echo == Alice transfers 500 utokens to Fee holder
eval dfx canister call utoken transfer "'($FEE_PUBLIC_KEY, 500_000_000)'"

echo
echo == Initial token balances for Alice and fitoken balance for fee taker
echo Alice uToken Bal = $(eval dfx canister call utoken balanceOf "'($ALICE_PUBLIC_KEY)'")
echo Alice FiToken Bal = $(eval dfx canister call fitoken balanceOf "'($ALICE_PUBLIC_KEY)'")
echo FeeTo uToken Bal = $(eval dfx canister call utoken balanceOf "'($FEE_PUBLIC_KEY)'")
echo FeeTo FiToken Bal = $(eval dfx canister call fitoken balanceOf "'($FEE_PUBLIC_KEY)'")

echo
echo
echo
echo ===================== FiTroller functions =====================
echo
echo == Add an FiToken to the supported markets, should succeed.
eval dfx canister call fitroller _supportMarket "'($FITOKENID)'"
echo

echo
echo
echo
echo ===================== Supply tests =====================
echo
echo == Alice grants FiToken permission to spend 500 of her utokens, should succeed.
eval dfx canister call utoken approve "'($FITOKENID, 500_000_000)'"
echo == Alice mints fitokens \(exchanging 400 utokens\), should succeed.
eval dfx canister call fitoken mintfi "400_000_000"
echo
HOME=$FEE_HOME
echo == Fee holder grants FiToken permission to spend 300 utokens, should succeed.
eval dfx canister call utoken approve "'($FITOKENID, 300_000_000)'"
echo == Fee holder mints fitokens \(exchanging 200 utokens\), should succeed.
eval dfx canister call fitoken mintfi "200_000_000"
echo

echo New balances:
echo Alice uToken Bal = $(eval dfx canister call utoken balanceOf "'($ALICE_PUBLIC_KEY)'")
echo Alice FiToken Bal = $(eval dfx canister call fitoken balanceOf "'($ALICE_PUBLIC_KEY)'")
echo Fee holder uToken Bal = $(eval dfx canister call utoken balanceOf "'($FEE_PUBLIC_KEY)'")
echo Fee holder FiToken Bal = $(eval dfx canister call fitoken balanceOf "'($FEE_PUBLIC_KEY)'")
echo
echo FiToken canister uToken Bal = $(eval dfx canister call utoken balanceOf "'($FITOKENID)'")
echo FiToken Total Supply = $(eval dfx canister call fitoken totalSupply)
echo

echo
echo
echo
echo ===================== Redeem tests =====================
echo
HOME=$ALICE_HOME
echo == Alice redeems fitokens \(for 100 utokens\), should succeed.
eval dfx canister call fitoken redeem "100_000_000"
echo

echo New balances:
echo Alice uToken Bal = $(eval dfx canister call utoken balanceOf "'($ALICE_PUBLIC_KEY)'")
echo Alice FiToken Bal = $(eval dfx canister call fitoken balanceOf "'($ALICE_PUBLIC_KEY)'")
echo
echo FiToken canister uToken Bal = $(eval dfx canister call utoken balanceOf "'($FITOKENID)'")
echo FiToken Total Supply = $(eval dfx canister call fitoken totalSupply)
echo

echo
echo == Alice tries to redeem more than the platform\'s balance \(5000 utokens\), should not succeed.
eval dfx canister call fitoken redeem "5_000_000_000"
echo
echo == Alice tries to redeem more she has left \(305 utokens\), should not succeed.
eval dfx canister call fitoken redeem "305_000_000"
echo

echo
echo
echo
echo ===================== Borrow tests =====================
echo
echo == Fitoken total Liquidity values \(supply, borrows, reserves, interestIndex\).
eval dfx canister call fitoken getTotLiqInfo
echo == Fitoken exchange rate = $(dfx canister call fitoken getExchangeRate)
echo
echo == Get Alice\'s account liquidity.
eval dfx canister call fitroller getHypotheticalLiquidity "'($ALICE_PUBLIC_KEY, $FITOKENID, 0, 0)'"
echo == Alice borrows 200 utokens.
eval dfx canister call fitoken borrow "200_000_000"
echo
# echo == Accrue interest.
# eval dfx canister call fitoken accrueInterest
# echo
echo == Fitoken total Liquidity values \(supply, borrows, reserves, interestIndex\).
eval dfx canister call fitoken getTotLiqInfo
echo == Fitoken exchange rate = $(dfx canister call fitoken getExchangeRate)
echo
echo == Get Alice\'s account liquidity.
eval dfx canister call fitroller getHypotheticalLiquidity "'($ALICE_PUBLIC_KEY, $FITOKENID, 0, 0)'"
echo
echo == Alice tries to REDEEM more than her liquidity allows \(70 utokens\), should not succeed.
eval dfx canister call fitoken redeem "70_000_000"
echo
echo == Alice tries to BORROW more than her liquidity allows \(70 utokens\), should not succeed.
eval dfx canister call fitoken borrow "70_000_000"
echo








# echo
# echo == Transfer 0 utokens from Alice to Bob, should Return false, as value is smaller than fee.
# echo

# eval dfx canister call fitoken transfer "'($BOB_PUBLIC_KEY, 0)'"

# echo
# echo == Transfer 0 utokens from Alice to Alice, should Return false, as value is smaller than fee.
# echo

# eval dfx canister call fitoken transfer "'($ALICE_PUBLIC_KEY, 0)'"

# echo
# echo == Transfer 0.1 utokens from Alice to Bob, should success, revieve 0, as value = fee.
# echo

# eval dfx canister call utoken transfer "'($BOB_PUBLIC_KEY, 100)'"

# echo
# echo == Transfer 0.1 utokens from Alice to Alice, should success, revieve 0, as value = fee.
# echo

# eval dfx canister call utoken transfer "'($ALICE_PUBLIC_KEY, 100)'"

# echo
# echo == Transfer 100 utokens from Alice to Alice, should success.
# echo

# eval dfx canister call utoken transfer "'($ALICE_PUBLIC_KEY, 100_000)'"

# echo
# echo == Transfer 2000 utokens from Alice to Alice, should Return false, as no enough balance.
# echo

# eval dfx canister call utoken transfer "'($ALICE_PUBLIC_KEY, 2_000_000)'"

# echo
# echo == Transfer 0 utokens from Bob to Bob, should Return false, as value is smaller than fee.
# echo

# HOME=$BOB_HOME
# eval dfx canister call utoken transfer "'($ALICE_PUBLIC_KEY, 10)'"

# echo
# echo == Transfer 42 utokens from Alice to Bob, should success.
# echo

# HOME=$ALICE_HOME
# eval dfx canister call utoken transfer "'($BOB_PUBLIC_KEY, 42_000)'"

# echo
# echo == Alice grants Dan permission to spend 1 of her utokens, should success.
# echo

# eval dfx canister call utoken approve "'($DAN_PUBLIC_KEY, 1_000)'"

# echo
# echo == Alice grants Dan permission to spend 0 of her utokens, should success.
# echo









# echo
# echo == name
# echo
# eval dfx canister call utoken name

# echo
# echo == symbol
# echo
# eval dfx canister call utoken symbol

# echo
# echo == decimals
# echo
# eval dfx canister call utoken decimals

# echo
# echo == totalSupply
# echo
# eval dfx canister call utoken totalSupply

# echo
# echo == getMetadata
# echo
# eval dfx canister call utoken getMetadata

# echo
# echo == historySize
# echo
# eval dfx canister call utoken historySize

# echo
# echo == getTransaction
# echo
# eval dfx canister call utoken getTransaction "'(1)'"

# echo
# echo == getTransactions
# echo
# eval dfx canister call utoken getTransactions "'(0,100)'" 

# echo
# echo == getUserTransactionAmount
# echo
# eval dfx canister  call utoken getUserTransactionAmount "'($ALICE_PUBLIC_KEY)'" 

# echo
# echo == getUserTransactions
# echo
# eval dfx canister call utoken getUserTransactions "'($ALICE_PUBLIC_KEY, 0, 1000)'"

# echo
# echo == getTokenInfo
# echo
# eval dfx canister  call utoken getTokenInfo

# echo
# echo == getHolders
# echo
# eval dfx canister  call utoken getHolders "'(0,100)'"

# echo
# echo == getAllowanceSize
# echo
# eval dfx canister  call utoken getAllowanceSize

# echo
# echo == getUserApprovals
# echo
# eval dfx canister  call utoken getUserApprovals "'($ALICE_PUBLIC_KEY)'"

# echo
# echo == get alice getUserTransactions
# echo
# eval dfx canister  call utoken getUserTransactions "'($ALICE_PUBLIC_KEY, 0, 1000)'"

# echo
# echo == get fee History
# echo
# eval dfx canister  call utoken getUserTransactions "'($FEE_PUBLIC_KEY, 0, 1000)'"


# echo
# echo == Upgrade utoken
# echo
# HOME=$ALICE_HOME
# eval dfx canister install utoken --argument="'(\"test\", \"Test uToken\", \"TT\", 2, 100, $ALICE_PUBLIC_KEY)'" -m=upgrade

# echo
# echo == all History
# echo
# eval dfx canister call utoken getTransactions "'(0, 1000)'"

# echo
# echo == getTokenInfo
# echo
# dfx canister call utoken getTokenInfo

# echo
# echo == get alice History
# echo
# eval dfx canister  call utoken getUserTransactions "'($ALICE_PUBLIC_KEY, 0, 1000)'"

# dfx stop
