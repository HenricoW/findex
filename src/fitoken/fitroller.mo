import Principal "mo:base/Principal";
import Types "../utils/types";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Bool "mo:base/Debug";

import FiTrollerMod "../modules/fitroller_mod"

shared(msg) actor class Fitroller() : async FiTrollerMod.Interface {
    private stable var txCounter = 0;
    func increaseTxCounter() : async FiTrollerMod.TxReceipt {
        let txId = txCounter;
        txCounter += 1;
        #Ok(txId);
    };

    let ftrlr = FiTrollerMod.Fitroller(msg.caller);

    // Add multiple markets to a user's liquidity calculations
    public shared(msg) func enterMarkets(fiTokens: [Principal]) : async [FiTrollerMod.TxStatus] { [#succeeded] };

    // Remove a single market from a user's liquidity calculations
    public shared(msg) func exitMarket(fiToken: Principal) : async FiTrollerMod.TxStatus { #succeeded };

    // Is minting allowed
    public func mintAllowed(fiToken: Principal, minter: Principal, uAmount: Nat) : async FiTrollerMod.TxReceipt { #Ok(0) };
    // Is redeeming allowed
    public func redeemAllowed(fiToken: Principal, redeemer: Principal, uAmount: Nat) : async FiTrollerMod.TxReceipt { #Ok(0) };
    // Is borrowing allowed (affected by user liquidity status)
    public func borrowAllowed(fiToken: Principal, borrower: Principal, uAmount: Nat) : async FiTrollerMod.TxReceipt { #Ok(0) };
    // Is repayBorrowing allowed
    public func repayBorrowAllowed(fiToken: Principal, payer: Principal, borrower: Principal, uAmount: Nat) : async FiTrollerMod.TxReceipt { #Ok(0) };
    // Is transfering of fiTokens allowed (affected by user liquidity status)
    public func transferAllowed(fiToken: Principal, from: Principal, to: Principal, fiAmount: Nat) : async FiTrollerMod.TxReceipt { #Ok(0) };

    public query func getMetadata(): async FiTrollerMod.Metadata { ftrlr.getData() };

    public shared(msg) func _supportMarket(fiToken: Principal) : async FiTrollerMod.TxReceipt {
        // is this the admin calling?
        if(msg.caller != ftrlr.cdata.admin) { return #Err(#Unauthorized); };

        // is it a valid fiToken?
        let fiTkn = actor(Principal.toText(fiToken)): actor {
            isFiToken: () -> async Bool;
        };
        let isFiToken = await fiTkn.isFiToken();
        if(not isFiToken) { return #Err(#Other("Not an fiToken")) };

        // is it already supported?
        let market = Types.unwrap(ftrlr.cdata.markets.get(fiToken));
        if(market.isListed) { return #Err(#Other("Market already listed")) };

        // add it to the supported markets Mapping and allMarkets list
        let isMarketAdded = await ftrlr.addMarket(fiToken);
        switch(isMarketAdded) { 
            case (#succeeded) { return #Ok(0) };
            case (_) { return #Err(#Other("Failed to add market")) };
        };
    };

    // _setPriceOracle : (oracle_id: Principal) -> async TxReceipt;
    public shared(msg) func _setPriceOracle(oracle_id: Principal) : async FiTrollerMod.TxReceipt { #Ok(0) };

    // _setCollateralFactor :(fiToken: Principal, collateralFactorMantissa: Nat) -> async TxReceipt;
    public shared(msg) func _setCollateralFactor(fiToken: Principal, collateralFactorMantissa: Nat) : async FiTrollerMod.TxReceipt { #Ok(0) };
}