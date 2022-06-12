import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Types "../utils/types";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Order "mo:base/Order";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";
import Result "mo:base/Result";
import Text "mo:base/Text";
import ExperimentalCycles "mo:base/ExperimentalCycles";
import Cap "../cap/Cap";
import Root "../cap/Root";
import Bool "mo:base/Debug";

import IfiToken "../modules/IfiToken"

shared(msg) actor class FiToken(
    _logo: Text,
    _name: Text,
    _symbol: Text,
    _decimals: Nat8,
    _owner: Principal,
    _underlying: Text,
    _fitroller: Text,
    _initialExchangeRateMantissa: Nat,
    _interestRateModelID: Text,
    _fee: Nat
    ) : async IfiToken.Interface = this {

    private let fiTkn = IfiToken.FiToken(
        _logo,
        _name,
        _symbol,
        _decimals,
        _owner,
        _underlying,
        _fitroller,
        _initialExchangeRateMantissa,
        _interestRateModelID,
        _fee
    );
    private stable var balanceEntries : [(Principal, Nat)] = [];
    private stable var allowanceEntries : [(Principal, [(Principal, Nat)])] = [];

    private stable let genesis : Types.TxRecord = {
        caller = ?_owner;
        op = #mint;
        index = 0;
        from = fiTkn.cdata.blackhole;
        to = _owner;
        amount = fiTkn.cdata.totalSupply_;
        fee = 0;
        timestamp = Time.now();
        status = #succeeded;
    };
    
    private stable var txcounter: Nat = 0;
    // private var cap: ?Cap.Cap = null;
    // private func addRecord(
    //     caller: Principal,
    //     op: Text, 
    //     details: [(Text, Root.DetailValue)]
    //     ): async () {
    //     let c = switch(cap) {
    //         case(?c) { c };
    //         case(_) { Cap.Cap(Principal.fromActor(this), 2_000_000_000_000) };
    //     };
    //     cap := ?c;
    //     let record: Root.IndefiniteEvent = {
    //         operation = op;
    //         details = details;
    //         caller = caller;
    //     };
    //     // don't wait for result, faster
    //     ignore c.insert(record);
    // };


    /*
    *   Core interfaces:
    */

    private func processReceipt(rcpt: Types.TxReceipt) : Types.TxReceipt {
        switch(rcpt){
            case (#Err err) { return #Err(err) };
            case (#Ok val) {
                txcounter += 1;
                return #Ok(txcounter - 1)
            };
        };
    };

    /// Transfers value amount of tokens to Principal to.
    public shared(msg) func transfer(to: Principal, value: Nat) : async Types.TxReceipt {
        let rcpt = await fiTkn.transfer(msg.caller, to, value);

        // ignore addRecord(
        //     msg.caller, "transfer",
        //     [
        //         ("to", #Principal(to)),
        //         ("value", #U64(Nat64.fromNat(value))),
        //         ("fee", #U64(Nat64.fromNat(fiTkn.cdata.fee)))
        //     ]
        // );
        
        processReceipt(rcpt)
    };

    /// Transfers value amount of tokens from Principal from to Principal to.
    public shared(msg) func transferFrom(from: Principal, to: Principal, value: Nat) : async Types.TxReceipt {
        let rcpt = await fiTkn.transferFrom(msg.caller, from, to, value);

        // ignore addRecord(
        //     msg.caller, "transferFrom",
        //     [
        //         ("from", #Principal(from)),
        //         ("to", #Principal(to)),
        //         ("value", #U64(Nat64.fromNat(value))),
        //         ("fee", #U64(Nat64.fromNat(fiTkn.cdata.fee)))
        //     ]
        // );

        processReceipt(rcpt)
    };

    /// Allows spender to withdraw from your account multiple times, up to the value amount.
    /// If this function is called again it overwrites the current allowance with value.
    public shared(msg) func approve(spender: Principal, value: Nat) : async Types.TxReceipt {
        let rcpt = await fiTkn.approve(msg.caller, spender, value);

        // ignore addRecord(
        //     msg.caller, "approve",
        //     [
        //         ("to", #Principal(spender)),
        //         ("value", #U64(Nat64.fromNat(value))),
        //         ("fee", #U64(Nat64.fromNat(fiTkn.cdata.fee)))
        //     ]
        // );

        processReceipt(rcpt)
    };

    public query func isFiToken(): async Bool { true };

    let uToken = actor(fiTkn.underlyingId): actor {
        transferFrom: (Principal, Principal, Nat) -> async Types.TxReceipt;
        transfer: (Principal, Nat) -> async Types.TxReceipt;
        balanceOf: (Principal) -> async Nat;
    };

    let ftrlr = actor(fiTkn.cdata.fitroller): actor {
        mintAllowed : (fiToken: Principal, minter: Principal, uAmount: Nat) -> async Types.TxReceipt;
        redeemAllowed : (fiToken: Principal, redeemer: Principal, uAmount: Nat) -> async Types.TxReceipt;
        borrowAllowed : (fiToken: Principal, borrower: Principal, uAmount: Nat) -> async Types.TxReceipt;
        repayAllowed : (fiToken: Principal, payer: Principal, borrower: Principal, uAmount: Nat) -> async Types.TxReceipt;
    };

    let interestRateModel = actor(fiTkn.cdata.irateModel): actor {
        utilizationRate : shared (cash: Nat, borrows: Nat, reserves: Nat) -> async Nat;
        getBorrowRate : shared (cash: Nat, borrows: Nat, reserves: Nat) -> async Nat;
        getSupplyRate : shared (cash: Nat, borrows: Nat, reserves: Nat, reserveFactorMantissa: Nat) -> async Nat;
    };

    // mintfi - TODO: incomplete
    public shared(msg) func mintfi(uAmount: Nat): async Types.TxReceipt {
      // check if mint allowed { main pj cannister }
        let allowedRx = await ftrlr.mintAllowed(Principal.fromActor(this), msg.caller, uAmount);
        switch(allowedRx) {
            case(#Ok val) { };
            case(#Err errType)  { return #Err(errType) };
        };

        let exchRateRx = await getExchangeRate();

        let transferRx = await uToken.transferFrom(msg.caller, Principal.fromActor(this), uAmount);
        switch(transferRx) {
            case(#Ok val) { };
            case(#Err errType)  { return #Err(errType) };
        };

        // accrue interest
        let accrueRx = await accrueInterest();                                  // current error cond's in accrueInterest are not critical
        let exchRate = switch(exchRateRx){
            case(#Ok val) { val };
            case(#Err errType)  { return #Err(errType) };
        };

        let to_balance = fiTkn._balanceOf(msg.caller);
        let fiAmount = uAmount * fiTkn.ONE / exchRate;
        fiTkn.cdata.totalSupply_ += fiAmount;
        fiTkn.cdata.balances.put(msg.caller, to_balance + fiAmount);

        // ignore addRecord(
        //     msg.caller, "mintfi",
        //     [
        //         ("to", #Principal(msg.caller)),
        //         ("value", #U64(Nat64.fromNat(fiAmount))),
        //         ("fee", #U64(Nat64.fromNat(0)))
        //     ]
        // );

        txcounter += 1;
        return #Ok(txcounter - 1);
    };

    // redeem - TODO: incomplete
    public shared(msg) func redeem(uAmount: Nat): async Types.TxReceipt {
      // check if redeem allowed { main pj cannister }
        let allowedRx = await ftrlr.redeemAllowed(Principal.fromActor(this), msg.caller, uAmount);
        switch(allowedRx) {
            case(#Ok val) { };
            case(#Err errType)  { return #Err(errType) };
        };

      // not needed but extra safety check
      let canisterBal = await uToken.balanceOf(Principal.fromActor(this));
      if(uAmount > canisterBal) { return #Err(#InvalidAmount) };
      
        // accrue interest
        let accrueRx = await accrueInterest();                                  // current error cond's in accrueInterest are not critical

        let exchRateRx = await getExchangeRate();
        let exchRate = switch(exchRateRx){
            case(#Ok val) { val };
            case(#Err errType)  { return #Err(errType) };
        };

      let fiAmount = uAmount * fiTkn.ONE / exchRate;
      let fi_balance = fiTkn._balanceOf(msg.caller);
      if(fiAmount > fi_balance) { return #Err(#InsufficientBalance) };
      
      let transferRx = await uToken.transfer(msg.caller, uAmount);
        switch(transferRx) {
            case(#Ok val)   { };
            case(#Err errType)  { return #Err(errType) };
        };

      fiTkn.cdata.totalSupply_ -= fiAmount;
        fiTkn.cdata.balances.put(msg.caller, fi_balance - fiAmount);

        // ignore addRecord(
        //     msg.caller, "redeem",
        //     [
        //         ("from", #Principal(msg.caller)),
        //         ("value", #U64(Nat64.fromNat(fiAmount))),
        //         ("fee", #U64(Nat64.fromNat(0)))
        //     ]
        // );

        txcounter += 1;
        return #Ok(txcounter - 1);
    };

    // borrow - TODO: incomplete
    public shared(msg) func borrow(uAmount: Nat): async Types.TxReceipt {
        // check if borrow allowed { main pj cannister }
        let allowedRx = await ftrlr.borrowAllowed(Principal.fromActor(this), msg.caller, uAmount);
        switch(allowedRx) {
            case(#Ok val) { };
            case(#Err errType)  { return #Err(errType) };
        };

        // check cash available
        let canisterBal = await uToken.balanceOf(Principal.fromActor(this));
        if(uAmount > canisterBal) { return #Err(#InvalidAmount) };
        
        // accrue interest
        let accrueRx = await accrueInterest();                                  // current error cond's in accrueInterest are not critical
        // switch(accrueRx) {
        //     case(#Ok val) { };
        //     case(#Err errType)  { return #Err(errType) };
        // };

        // transfer out
        let transferRx = await uToken.transfer(msg.caller, uAmount);            // re-entrancy risk???
        switch(transferRx) {
            case(#Ok val) { };
            case(#Err errType)  { return #Err(errType) };
        };

        // update state
        fiTkn.cdata.totalBorrows_ += uAmount;
        switch(fiTkn.cdata.accountBorrows.get(msg.caller)){
            case(?borrowRec) {
                // get updated borrow bal
                let borrBalRx = await getBorrowBalance(msg.caller);
                let principal_j = switch(borrBalRx){
                    case (#Ok val) { val };
                    case (#Err errType) { return #Err(errType) };
                };
                fiTkn.cdata.accountBorrows.put(msg.caller, { principal = principal_j + uAmount; borrowIndex = fiTkn.cdata.borrowIndex; });
            };
            case(_) {
                fiTkn.cdata.accountBorrows.put(msg.caller, { principal = uAmount; borrowIndex = fiTkn.cdata.borrowIndex; });
            };
        };
      
        txcounter += 1;
        return #Ok(txcounter - 1);
    };

    // repay - TODO: incomplete
    public shared(msg) func repayBehalf(borrower: Principal, uAmount: Nat): async Types.TxReceipt {
        // accrue interest
        let accrueRx = await accrueInterest();                                  // current error cond's in accrueInterest are not critical

        // check if repay allowed { main pj cannister }
        let allowedRx = await ftrlr.repayAllowed(Principal.fromActor(this), msg.caller, borrower, uAmount);
        switch(allowedRx) {
            case(#Ok val) { };
            case(#Err errType)  { return #Err(errType) };
        };

        // get updated borrow bal
        let borrBalRx = await getBorrowBalance(borrower);
        let principal_j = switch(borrBalRx){
            case (#Ok val) { val };
            case (#Err errType) { return #Err(errType) };
        };

        // if uAmount > updated borrow bal, transfer only amount needed
        let repayVal = if(uAmount >= principal_j) { principal_j } else { uAmount };

        // do transfer
        let transferRx = await uToken.transferFrom(msg.caller, Principal.fromActor(this), repayVal);
        switch(transferRx) {
            case(#Ok val) { };
            case(#Err errType)  { return #Err(errType) };
        };

        // update state
        fiTkn.cdata.totalBorrows_ -= repayVal;
        fiTkn.cdata.accountBorrows.put(borrower, { principal = principal_j - repayVal; borrowIndex = fiTkn.cdata.borrowIndex; });
      
        txcounter += 1;
        return #Ok(txcounter - 1);
    };

    public shared(msg) func repay(uAmount: Nat): async Types.TxReceipt {
        let repayRx = await repayBehalf(msg.caller, uAmount);
        switch(repayRx) {
            case(#Ok val) { return #Ok(val) };
            case(#Err errType)  { return #Err(errType) };
        };
    };

    // get user's up to date fitoken bal, borrow bal & exch rate
    public func getAccountSnapshot(user: Principal): async (Nat, Nat, Nat) {
        let fiBalance = switch(fiTkn.cdata.balances.get(user)){
            case (?val) { val };
            case (_) { 0 };
        };
        
        let borrowRecRx = await getBorrowBalance(user);
        let borrowBal = switch(borrowRecRx){
            case(#Ok principal) { principal };
            case(#Err errType) { 0 };
        };
        if(fiBalance == 0) assert(borrowBal == 0);
        
        let exchRateRx = await getExchangeRate();
        let exchRate = switch(exchRateRx){
            case(#Ok val) { val };
            case(#Err errType) { fiTkn.exchangeRateMantissa };
        };

        (fiBalance, borrowBal, exchRate)
    };

    // get updated user borrow balance
    public func getBorrowBalance(user: Principal): async Types.TxReceipt {
        // recorded borrow state
        let borrowRec = switch(fiTkn.cdata.accountBorrows.get(user)){
            case (?val) { val };
            case (_) { return #Err(#Other("Account info not found")) };
        };

        // calc updated principal
        let newPrincipal = (borrowRec.principal * fiTkn.cdata.borrowIndex) / borrowRec.borrowIndex;

        #Ok(newPrincipal)
    };

    // accrue interest, TODO: move to private after testing
    public func accrueInterest(): async Types.TxReceipt {
        // get time diff to last accrual time diff < tolerance?
        let oneSecNat = 1_000_000_000;
        let oneMinNat = 60 * oneSecNat;
        let tooSoon = Int.abs(Time.now()) < Int.abs(fiTkn.cdata.accrualTime) + Nat8.toNat(fiTkn.cdata.temporalMargin) * oneSecNat;      // no underflow possible

        if(tooSoon) { return #Err(#Other("Too soon")) };
        let timeDiffMins = Int.abs(Time.now() - fiTkn.cdata.accrualTime) / oneMinNat;                                       // underflow possible, but already checked

        // get current parameters
        let cash_i = await uToken.balanceOf(Principal.fromActor(this));                             // TODO: may need to update this
        let supply_i = fiTkn.cdata.totalSupply_;
        let borrows_i = fiTkn.cdata.totalBorrows_;
        let reserves_i = fiTkn.cdata.totalReserves_;
        let index_i = fiTkn.cdata.borrowIndex;

        // calc interest accumulation
        let borrowRateMantissa = await interestRateModel.getBorrowRate(cash_i, borrows_i, reserves_i);
        // if underlying uses < 8 decimals, the following accInterest calc will yield 0 (smaller than 8 dec definition of ONE)
        // thus, another test is needed to not artificially move accrual time forward
        let accInterest = borrows_i * borrowRateMantissa * timeDiffMins / fiTkn.ONE;
        // if(accInterest == 0) { return #Err(#Other("Accumulation too small")) };
        if(accInterest == 0) { return #Err(#Other("Accumulation too small")) };

        // update accrual time, borrow, reserves and index values
        fiTkn.cdata.totalBorrows_ := borrows_i + accInterest;
        fiTkn.cdata.totalReserves_ := reserves_i + (accInterest * fiTkn.reserveFactorMantissa / fiTkn.ONE);
        fiTkn.cdata.borrowIndex := index_i + borrowRateMantissa * timeDiffMins;
        fiTkn.cdata.accrualTime := Time.now();

        #Ok(0)
    };

    // get up to date exchange rate
    public func getExchangeRate(): async Types.TxReceipt {
        // supply 0?
        if(fiTkn.cdata.totalSupply_ == 0) { return #Ok(fiTkn.exchangeRateMantissa) };               // will be initial exch rate

        // calculate and store
        let cash_i = await uToken.balanceOf(Principal.fromActor(this));
        if(fiTkn.cdata.totalReserves_ > (cash_i + fiTkn.cdata.totalBorrows_)) { return #Err(#Other("Neg exch rate - Draw down reserves")) };  // w.r.t warning for next line

        let exchRate = fiTkn.ONE * (cash_i + fiTkn.cdata.totalBorrows_ - fiTkn.cdata.totalReserves_) / fiTkn.cdata.totalSupply_;
        fiTkn.exchangeRateMantissa := exchRate;

        #Ok(exchRate)
    };

    // get borrow balance internal

    public query func logo() : async Text { fiTkn.cdata.logo_ };
    public query func name() : async Text { fiTkn.cdata.name_ };
    public query func symbol() : async Text { fiTkn.cdata.symbol_ };
    public query func decimals() : async Nat8 { fiTkn.cdata.decimals_ };
    public query func totalSupply() : async Nat { fiTkn.cdata.totalSupply_ };
    public query func getTokenFee() : async Nat { fiTkn.cdata.fee };
    public query func balanceOf(who: Principal) : async Nat { fiTkn._balanceOf(who) };
    public query func allowance(owner: Principal, spender: Principal) : async Nat { fiTkn._allowance(owner, spender) };

    // FOR TESTING ONLY
    public query func getTotLiqInfo() : async (Nat, Nat, Nat, Nat) {
        (fiTkn.cdata.totalSupply_, fiTkn.cdata.totalBorrows_, fiTkn.cdata.totalReserves_, fiTkn.cdata.borrowIndex)
    };

    // FOR TESTING ONLY
    public func accrueInterestTest(mins: Nat): async Types.TxReceipt {
        // get current parameters
        let cash_i = await uToken.balanceOf(Principal.fromActor(this));                             // TODO: may need to update this
        let supply_i = fiTkn.cdata.totalSupply_;
        let borrows_i = fiTkn.cdata.totalBorrows_;
        let reserves_i = fiTkn.cdata.totalReserves_;
        let index_i = fiTkn.cdata.borrowIndex;

        // calc interest accumulation
        let borrowRateMantissa = await interestRateModel.getBorrowRate(cash_i, borrows_i, reserves_i);
        // if underlying uses < 8 decimals, the following accInterest calc will yield 0 (smaller than 8 dec definition of ONE)
        // thus, another test is needed to not artificially move accrual time forward
        let accInterest = borrows_i * borrowRateMantissa * mins / fiTkn.ONE;
        // if(accInterest == 0) { return #Err(#Other("Accumulation too small")) };
        if(accInterest == 0) { return #Err(#Other("Accumulation too small")) };

        // update accrual time, borrow, reserves and index values
        fiTkn.cdata.totalBorrows_ := borrows_i + accInterest;
        fiTkn.cdata.totalReserves_ := reserves_i + (accInterest * fiTkn.reserveFactorMantissa / fiTkn.ONE);
        fiTkn.cdata.borrowIndex := index_i + borrowRateMantissa * mins;
        fiTkn.cdata.accrualTime := Time.now();

        #Ok(0)
    };


    public query func getMetadata() : async Types.Metadata {
        return {
            logo = fiTkn.cdata.logo_;
            name = fiTkn.cdata.name_;
            symbol = fiTkn.cdata.symbol_;
            decimals = fiTkn.cdata.decimals_;
            totalSupply = fiTkn.cdata.totalSupply_;
            owner = fiTkn.cdata.owner_;
            fee = fiTkn.cdata.fee;
        };
    };

    /// Get transaction history size
    public query func historySize() : async Nat { txcounter };

    /*
    *   Optional interfaces:
    */
    public shared(msg) func setFeeTo(to: Principal) {
        assert(msg.caller == fiTkn.cdata.owner_);
        fiTkn.cdata.feeTo := to;
    };

    public shared(msg) func setFee(_fee: Nat) {
        assert(msg.caller == fiTkn.cdata.owner_);
        fiTkn.cdata.fee := _fee;
    };

    public shared(msg) func setOwner(_owner: Principal) {
        assert(msg.caller == fiTkn.cdata.owner_);
        fiTkn.cdata.owner_ := _owner;
    };

    public query func getTokenInfo(): async Types.TokenInfo {
        {
            metadata = {
                logo = fiTkn.cdata.logo_;
                name = fiTkn.cdata.name_;
                symbol = fiTkn.cdata.symbol_;
                decimals = fiTkn.cdata.decimals_;
                totalSupply = fiTkn.cdata.totalSupply_;
                owner = fiTkn.cdata.owner_;
                fee = fiTkn.cdata.fee;
            };
            feeTo = fiTkn.cdata.feeTo;
            historySize = txcounter;
            deployTime = genesis.timestamp;
            holderNumber = fiTkn.cdata.balances.size();
            cycles = ExperimentalCycles.balance();
        }
    };

    /*
    * upgrade functions
    */
    system func preupgrade() {
        balanceEntries := Iter.toArray(fiTkn.cdata.balances.entries());
        var size : Nat = fiTkn.cdata.allowances.size();
        var temp : [var (Principal, [(Principal, Nat)])] = Array.init<(Principal, [(Principal, Nat)])>(size, (fiTkn.cdata.owner_, []));
        size := 0;
        for ((k, v) in fiTkn.cdata.allowances.entries()) {
            temp[size] := (k, Iter.toArray(v.entries()));
            size += 1;
        };
        allowanceEntries := Array.freeze(temp);
    };

    system func postupgrade() {
        fiTkn.cdata.balances := HashMap.fromIter<Principal, Nat>(balanceEntries.vals(), 1, Principal.equal, Principal.hash);
        balanceEntries := [];
        for ((k, v) in allowanceEntries.vals()) {
            let allowed_temp = HashMap.fromIter<Principal, Nat>(v.vals(), 1, Principal.equal, Principal.hash);
            fiTkn.cdata.allowances.put(k, allowed_temp);
        };
        allowanceEntries := [];
    };
};
