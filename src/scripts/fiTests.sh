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
echo Alice id = $ALICE_PUBLIC_KEY
echo Fee id = $FEE_PUBLIC_KEY
echo

dfx start --clean --background --emulator
echo
dfx canister create utoken --no-wallet
dfx canister create fitoken --no-wallet
echo
dfx build utoken
dfx build fitoken

UTOKENID_TEXT=$(dfx canister id utoken)
UTOKENID="principal \"$UTOKENID_TEXT\""
echo uToken id: $UTOKENID

FITOKENID=$(dfx canister id fitoken)
FITOKENID="principal \"$FITOKENID\""
echo FiToken id: $FITOKENID

echo
echo == Install canisters
echo

HOME=$ALICE_HOME
eval dfx canister install utoken --argument="'(\"Test uToken Logo\", \"Test uToken Name\", \"Test uToken Symbol\", 6, "1_000_000_000", $ALICE_PUBLIC_KEY, 0)'"
eval dfx canister install fitoken --argument="'(\"Fi Token Logo\", \"Fi Token Name\", \"Fi Token Symbol\", 8, $ALICE_PUBLIC_KEY, \"$UTOKENID_TEXT\", "110_000_000", 0)'"

echo
echo == Initial setting for utoken canister
echo

dfx canister call fitoken setFeeTo "($FEE_PUBLIC_KEY)"
dfx canister call fitoken setFee "(10_000_000)"
echo Verifying fee update
dfx canister call fitoken getTokenFee

echo
echo == Initial token balances for Alice and fitoken balance for fee taker
echo

echo Alice uToken Bal = $( \
    eval dfx canister call utoken balanceOf "'($ALICE_PUBLIC_KEY)'" \
)
echo Alice FiToken Bal = $( \
    eval dfx canister call fitoken balanceOf "'($ALICE_PUBLIC_KEY)'" \
)
echo FeeTo = $( \
    eval dfx canister call fitoken balanceOf "'($FEE_PUBLIC_KEY)'" \
)

echo
echo
echo
echo ===================== Supply tests =====================
echo
echo == Alice grants FiToken permission to spend 500 of her utokens, should succeed.
eval dfx canister call utoken approve "'($FITOKENID, 500_000_000)'"
echo

echo == Alice mints fitokens \(exchanging 300 utokens\), should succeed.
eval dfx canister call fitoken mintfi "300_000_000"
echo

echo New balances:
echo Alice uToken Bal = $( \
    eval dfx canister call utoken balanceOf "'($ALICE_PUBLIC_KEY)'" \
)
echo Alice FiToken Bal = $( \
    eval dfx canister call fitoken balanceOf "'($ALICE_PUBLIC_KEY)'" \
)
echo
echo FiToken canister uToken Bal = $( \
    eval dfx canister call utoken balanceOf "'($FITOKENID)'" \
)
echo FiToken Total Supply = $( \
    eval dfx canister call fitoken totalSupply \
)
echo
echo Fee holder uToken Bal = $( \
    eval dfx canister call fitoken balanceOf "'($FEE_PUBLIC_KEY)'" \
)
echo


echo
echo
echo
echo ===================== Redeem tests =====================
echo
echo == Alice redeems fitokens \(for 100 utokens\), should succeed.
eval dfx canister call fitoken redeem "100_000_000"
echo

echo New balances:
echo Alice uToken Bal = $( \
    eval dfx canister call utoken balanceOf "'($ALICE_PUBLIC_KEY)'" \
)
echo Alice FiToken Bal = $( \
    eval dfx canister call fitoken balanceOf "'($ALICE_PUBLIC_KEY)'" \
)
echo
echo FiToken canister uToken Bal = $( \
    eval dfx canister call utoken balanceOf "'($FITOKENID)'" \
)
echo FiToken Total Supply = $( \
    eval dfx canister call fitoken totalSupply \
)
echo


echo
echo == Alice redeems fitokens \(for 500 utokens\), should not succeed.
eval dfx canister call fitoken redeem "500_000_000"
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

# eval dfx canister call utoken approve "'($DAN_PUBLIC_KEY, 0)'"

# echo
# echo == Bob grants Dan permission to spend 1 of her utokens, should success.
# echo

# HOME=$BOB_HOME
# eval dfx canister call utoken approve "'($DAN_PUBLIC_KEY, 1_000)'"

# echo
# echo == Dan transfer 1 utoken from Bob to Alice, should success.
# echo

# HOME=$DAN_HOME
# eval dfx canister call utoken transferFrom "'($BOB_PUBLIC_KEY, $ALICE_PUBLIC_KEY, 1_000)'"


# echo
# echo == Transfer 40.9 utokens from Bob to Alice, should success.
# echo

# HOME=$BOB_HOME
# eval dfx canister call utoken transfer "'($ALICE_PUBLIC_KEY, 40_900)'"

# echo
# echo == utoken balances for Alice, Bob, Dan and FeeTo.
# echo

# echo Alice = $( \
#     eval dfx canister call utoken balanceOf "'($ALICE_PUBLIC_KEY)'" \
# )
# echo Bob = $( \
#     eval dfx canister call utoken balanceOf "'($BOB_PUBLIC_KEY)'" \
# )
# echo Dan = $( \
#     eval dfx canister call utoken balanceOf "'($DAN_PUBLIC_KEY)'" \
# )
# echo FeeTo = $( \
#     eval dfx canister call utoken balanceOf "'($FEE_PUBLIC_KEY)'" \
# )

# echo
# echo == Alice grants Dan permission to spend 50 of her utokens, should success.
# echo

# HOME=$ALICE_HOME
# eval dfx canister call utoken approve "'($DAN_PUBLIC_KEY, 50_000)'"

# echo
# echo == Alices allowances 
# echo

# echo Alices allowance for Dan = $( \
#     eval dfx canister call utoken allowance "'($ALICE_PUBLIC_KEY, $DAN_PUBLIC_KEY)'" \
# )
# echo Alices allowance for Bob = $( \
#     eval dfx canister call utoken allowance "'($ALICE_PUBLIC_KEY, $BOB_PUBLIC_KEY)'" \
# )

# echo
# echo == Dan transfers 40 utokens from Alice to Bob, should success.
# echo

# HOME=$DAN_HOME
# eval dfx canister call utoken transferFrom "'($ALICE_PUBLIC_KEY, $BOB_PUBLIC_KEY, 40_000)'"

# echo
# echo == Alice transfer 1 utokens To Dan
# echo

# HOME=$ALICE_HOME
# eval dfx canister call utoken transfer "'($DAN_PUBLIC_KEY, 1_000)'"

# echo
# echo == Dan transfers 40 utokens from Alice to Bob, should Return false, as allowance remain 10, smaller than 40.
# echo

# HOME=$DAN_HOME
# eval dfx canister call utoken transferFrom "'($ALICE_PUBLIC_KEY, $BOB_PUBLIC_KEY, 40_000)'"

# echo
# echo == uToken balance for Alice and Bob and Dan
# echo

# echo Alice = $( \
#     eval dfx canister call utoken balanceOf "'($ALICE_PUBLIC_KEY)'" \
# )
# echo Bob = $( \
#     eval dfx canister call utoken balanceOf "'($BOB_PUBLIC_KEY)'" \
# )
# echo Dan = $( \
#     eval dfx canister call utoken balanceOf "'($DAN_PUBLIC_KEY)'" \
# )
# echo Fee = $( \
#     eval dfx canister call utoken balanceOf "'($FEE_PUBLIC_KEY)'" \
# )

# echo
# echo == Alice allowances
# echo

# echo Alices allowance for Bob = $( \
#     eval dfx canister call utoken allowance "'($ALICE_PUBLIC_KEY, $BOB_PUBLIC_KEY)'" \
# )
# echo Alices allowance for Dan = $( \
#     eval dfx canister call utoken allowance "'($ALICE_PUBLIC_KEY, $DAN_PUBLIC_KEY)'" \
# )


# echo
# echo == Alice grants Bob permission to spend 100 of her utokens
# echo

# HOME=$ALICE_HOME
# eval dfx canister call utoken approve "'($BOB_PUBLIC_KEY, 100_000)'"

# echo
# echo == Alice allowances
# echo

# echo Alices allowance for Bob = $( \
#     eval dfx canister call utoken allowance "'($ALICE_PUBLIC_KEY, $BOB_PUBLIC_KEY)'" \
# )
# echo Alices allowance for Dan = $( \
#     eval dfx canister call utoken allowance "'($ALICE_PUBLIC_KEY, $DAN_PUBLIC_KEY)'" \
# )

# echo
# echo == Bob transfers 99 utokens from Alice to Dan
# echo

# HOME=$BOB_HOME
# eval dfx canister call utoken transferFrom "'($ALICE_PUBLIC_KEY, $DAN_PUBLIC_KEY, 99_000)'"

# echo
# echo == Balances
# echo

# echo Alice = $( \
#     eval dfx canister call utoken balanceOf "'($ALICE_PUBLIC_KEY)'" \
# )
# echo Bob = $( \
#     eval dfx canister call utoken balanceOf "'($BOB_PUBLIC_KEY)'" \
# )
# echo Dan = $( \
#     eval dfx canister call utoken balanceOf "'($DAN_PUBLIC_KEY)'" \
# )
# echo Fee = $( \
#     eval dfx canister call utoken balanceOf "'($FEE_PUBLIC_KEY)'" \
# )

# echo
# echo == Alice allowances
# echo

# echo Alices allowance for Bob = $( eval dfx canister call utoken allowance "'($ALICE_PUBLIC_KEY, $BOB_PUBLIC_KEY)'" )
# echo Alices allowance for Dan = $( eval dfx canister call utoken allowance "'($ALICE_PUBLIC_KEY, $DAN_PUBLIC_KEY)'" )

# echo
# echo == Dan grants Bob permission to spend 100 of this utokens, should success.
# echo

# HOME=$DAN_HOME
# eval dfx canister call utoken approve "'($BOB_PUBLIC_KEY, 100_000)'"

# echo
# echo == Dan grants Bob permission to spend 50 of this utokens
# echo

# eval dfx canister call utoken approve "'($BOB_PUBLIC_KEY, 50_000)'"

# echo
# echo == Dan allowances
# echo

# echo Dan allowance for Bob = $( \
#     eval dfx canister call utoken allowance "'($DAN_PUBLIC_KEY, $BOB_PUBLIC_KEY)'" \
# )
# echo Dan allowance for Alice = $( \
#     eval dfx canister call utoken allowance "'($DAN_PUBLIC_KEY, $ALICE_PUBLIC_KEY)'" \
# )

# echo
# echo == Dan change Bobs permission to spend 40 of this utokens instead of 50
# echo

# eval dfx canister call utoken approve "'($BOB_PUBLIC_KEY, 40_000)'"

# echo
# echo == Dan allowances
# echo

# echo Dan allowance for Bob = $( \
#     eval dfx canister call utoken allowance "'($DAN_PUBLIC_KEY, $BOB_PUBLIC_KEY)'" \
# )
# echo Dan allowance for Alice = $( \
#     eval dfx canister call utoken allowance "'($DAN_PUBLIC_KEY, $ALICE_PUBLIC_KEY)'" \
# )

# echo
# echo == logo
# echo
# eval dfx canister call utoken logo

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
# echo == get bob History
# echo
# eval dfx canister  call utoken getUserTransactions "'($BOB_PUBLIC_KEY, 0, 1000)'"

# echo
# echo == get dan History
# echo
# eval dfx canister  call utoken getUserTransactions "'($DAN_PUBLIC_KEY, 0, 1000)'"

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
