import Principal "mo:base/Principal";
import Types "../utils/types";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Bool "mo:base/Debug";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";

import FiTrollerMod "../modules/fitroller_mod"

shared(msg) actor class Fitroller() : async FiTrollerMod.Interface {
    let ONE: Nat = 100_000_000;

    private stable var txCounter = 0;
    // func increaseTxCounter() : async FiTrollerMod.TxReceipt {
    //     let txId = txCounter;
    //     txCounter += 1;
    //     #Ok(txId);
    // };

    let ftrlr = FiTrollerMod.Fitroller(msg.caller);

    let fiOracle = actor(Principal.toText(ftrlr.cdata.oracle)): actor {
        getPrice: (ticker: Text) -> async (Nat, Nat8, Time.Time);
    };

    // Add multiple markets to a user's liquidity calculations
    public shared(msg) func enterMarkets(fiTokens: [Principal]) : async [FiTrollerMod.TxStatus] {
        let results = Buffer.Buffer<FiTrollerMod.TxStatus>(1);

        label l for(token in fiTokens.vals()) {
            // is this market supported?
            switch(ftrlr.cdata.markets.get(token)) {
                case null { results.add(#failed) };                     // market not supported
                case (?market) {
                    // was this market entered by this user already?
                    switch(market.accountMembership.get(msg.caller)){
                        case (?record) {
                            results.add(#failed);                       // user already entered this market
                            continue l;
                        };
                        case null {
                            market.accountMembership.put(msg.caller, true);     // update market's accounts entered. Update by reference? Yes
                        };
                    };

                    // update user's markets entered list
                    let added = await ftrlr.addAssetToAccount(msg.caller, token);

                    results.add(#succeeded);
                };
            };
        };

        results.toArray()
    };

    // helpers
    public query func getAccountAssets(user: Principal): async [Principal] {
        switch(ftrlr.cdata.accountAssets.get(user)){
            case null { return [] };
            case (?enteredList) { return enteredList.toArray() };
        };
    };

    public query func getMarketUsers(fitoken: Principal): async [(Principal, Bool)] {
        switch(ftrlr.cdata.markets.get(fitoken)) {
            case null { return [] };
            case (?market) {
                return (Iter.toArray(market.accountMembership.entries()))
            };
        };
    };

    // Remove a single market from a user's liquidity calculations
    public shared(msg) func exitMarket(fiToken: Principal) : async FiTrollerMod.TxStatus { #succeeded };

    // Is minting allowed
    public func mintAllowed(fiToken: Principal, minter: Principal, uAmount: Nat) : async FiTrollerMod.TxReceipt {
        switch(ftrlr.cdata.markets.get(fiToken)) {
            case null { return #Err(#Other("Market not supported")) };
            case (?mkt) { #Ok(0) };
        };

        // check if minting is paused (when pause fnality is added)
    };
    // Is redeeming allowed
    public func redeemAllowed(fiToken: Principal, redeemer: Principal, uAmount: Nat) : async FiTrollerMod.TxReceipt {
        let mintAllowRx = await mintAllowed(fiToken, redeemer, uAmount);            // same basic checks
        switch(mintAllowRx) {
            case (#Err errType) { return #Err(errType) };
            case (#Ok(_)) { };
        };

        // check if redeem is paused (when pause fnality is added)
        let userLiqRx = await getHypotheticalLiquidity(redeemer, fiToken, uAmount, 0);
        let (_, shortfall) = switch(userLiqRx) {
            case (#Err(_)) { return #Err(#Other("Error getting liquidity")) };
            case (#Ok val) { val };
        };

        if(shortfall > 0) { return #Err(#Other("Insufficient collateral")) };

        #Ok(0) 
    };

    // Is borrowing allowed (affected by user liquidity status)
    public shared(msg) func borrowAllowed(fiToken: Principal, borrower: Principal, uAmount: Nat) : async FiTrollerMod.TxReceipt {
        // is the market supported?
        let market = switch(ftrlr.cdata.markets.get(fiToken)) {
            case (?mkt) { mkt };
            case null { return #Err(#Other("Market not supported")) };
        };

        // has the borrower entered the market being requested for?
        switch(market.accountMembership.get(borrower)){
            case (?record) { };
            case null {
                // if user has not entered this market, call must be from the fitoken concerned
                if(msg.caller != fiToken) { return #Err(#Other("Caller not fiToken")) };

                // add to this market, as assets list is used to calculate liquidity, else this borrow will be overlooked in estimation
                let added = await ftrlr.addAssetToAccount(borrower, fiToken);           // add market to user's entered assets
                market.accountMembership.put(borrower, true);                           // add user to market
            };
        };

        // check if redeem is paused (when pause fnality is added)

        // check effect on user's liquidity
        let userLiqRx = await getHypotheticalLiquidity(borrower, fiToken, 0, uAmount);
        let (_, shortfall) = switch(userLiqRx) {
            case (#Err(_)) { return #Err(#Other("Error getting liquidity")) };
            case (#Ok val) { val };
        };

        if(shortfall > 0) { return #Err(#Other("Insufficient collateral")) };

        #Ok(0) 
    };

    // Is repayBorrowing allowed
    public func repayAllowed(fiToken: Principal, payer: Principal, borrower: Principal, uAmount: Nat) : async FiTrollerMod.TxReceipt {
        let mintAllowRx = await mintAllowed(fiToken, payer, uAmount);            // same basic checks
        switch(mintAllowRx) {
            case (#Err errType) { return #Err(errType) };
            case (#Ok(_)) { #Ok(0) };
        };
    };
    // Is transfering of fiTokens allowed (affected by user liquidity status)
    public func transferAllowed(fiToken: Principal, from: Principal, to: Principal, fiAmount: Nat) : async FiTrollerMod.TxReceipt { #Ok(0) };

    public func getHypotheticalLiquidity(user: Principal, fitoken: Principal, redeemAmount: Nat, borrowAmount: Nat) : async Types.LiqReceipt {
        let userAssets = await getAccountAssets(user);

        // tally up all assets for which markets were entered
        var totCollateral: Nat = 0;
        var totBorrows: Nat = 0;
        label l for(asset in userAssets.vals()) {
            let marketRx = ftrlr.cdata.markets.get(asset);
            let market = switch(marketRx) {
                case null { continue l; };
                case (?mkt) { mkt };
            };

            let fiAsset = actor(Principal.toText(asset)): actor {
                getAccountSnapshot: (user: Principal) -> async (Nat, Nat, Nat);
            };

            let (fiBalance, borrowBal, exchRate) = await fiAsset.getAccountSnapshot(user);
            let collateralFactor = market.collateralFactorMantissa;

            // call oracle to get icp price of underlying token
            let priceInICP = 100_000_000; // 1.00 ICP                               // TODO: to be fixed

            // This assets collateral contribution:
            // fitoken balance * exch rate * price in ICP * collateral factor
            let uAmount = fiBalance * exchRate / ONE;
            let icpVal = uAmount * priceInICP / ONE;                                // TODO: double check for utoken decimals != 8
            let collContribution = icpVal * collateralFactor / ONE;

            totCollateral += collContribution;

            // accumulate borrows
            let icpBorrowVal = borrowBal * priceInICP / ONE;                        // TODO: double check for utoken decimals != 8
            
            totBorrows += icpBorrowVal;

            // hypothetical action
            if(asset == fitoken) {
                // borrow effect
                totBorrows += borrowAmount * priceInICP / ONE;

                // redeem effect actually decreases total collateral, but adding to borrows has same effect w.r.t. the final comparison
                // this way also reduces risk of underflow panic
                let icpRedeem = redeemAmount * priceInICP / ONE;                    // TODO: double check for utoken decimals != 8
                totBorrows += icpRedeem * collateralFactor / ONE;
            };
        };

        if(totBorrows <= totCollateral) {
            return #Ok((totCollateral - totBorrows, 0))
        } else {
            return #Ok((0, totBorrows - totCollateral))
        };

    };

    public query func getMetadata(): async FiTrollerMod.Metadata { ftrlr.getData() };

    public shared(msg) func _supportMarket(fiToken: Principal) : async FiTrollerMod.TxReceipt {
        // is this the admin calling?
        if(msg.caller != ftrlr.cdata.admin) { return #Err(#Unauthorized); };

        // is it a valid fiToken?
        let fiTkn = actor(Principal.toText(fiToken)): actor {               // TODO: abstract away?? appears in multiple places in this file
            isFiToken: () -> async Bool;
        };
        try {
            let isFiToken = await fiTkn.isFiToken();
        } catch error {
            return #Err(#Other("Not an fiToken"))
        };

        // is it already supported?
        switch(ftrlr.cdata.markets.get(fiToken)) {
            case null {  };
            case (?mkt_) { return #Err(#Other("Market already listed")) };
        };

        // add it to the supported markets Mapping and allMarkets list
        let isMarketAdded = await ftrlr.addMarket(fiToken);
        switch(isMarketAdded) { 
            case (#succeeded) { return #Ok(0) };
            case (_) { return #Err(#Other("Failed to add market")) };
        };

        #Ok(0)
    };

    // _setPriceOracle : (oracle_id: Principal) -> async TxReceipt;
    public shared(msg) func _setPriceOracle(oracle_id: Principal) : async FiTrollerMod.TxReceipt { #Ok(0) };

    // _setCollateralFactor :(fiToken: Principal, collateralFactorMantissa: Nat) -> async TxReceipt;
    public shared(msg) func _setCollateralFactor(fiToken: Principal, collateralFactorMantissa: Nat) : async FiTrollerMod.TxReceipt { #Ok(0) };
}