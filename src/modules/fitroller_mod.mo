import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Bool "mo:base/Debug";
import Types "../utils/types";
import Buffer "mo:base/Buffer";

module {
    public type Interface = actor {
        // Add multiple markets to a user's liquidity calculations
        enterMarkets : shared (fiTokens: [Principal]) -> async [TxStatus];
        // Remove a single market from a user's liquidity calculations
        exitMarket : shared (fiToken: Principal) -> async TxStatus;

        // Is minting allowed
        mintAllowed : (fiToken: Principal, minter: Principal, uAmount: Nat) -> async TxReceipt;
        // Is redeeming allowed
        redeemAllowed : (fiToken: Principal, redeemer: Principal, uAmount: Nat) -> async TxReceipt;
        // Is borrowing allowed (affected by user liquidity status)
        borrowAllowed : (fiToken: Principal, borrower: Principal, uAmount: Nat) -> async TxReceipt;
        // Is repayBorrowing allowed
        repayAllowed : (fiToken: Principal, payer: Principal, borrower: Principal, uAmount: Nat) -> async TxReceipt;
        // Is transfering of fiTokens allowed (affected by user liquidity status)
        transferAllowed : (fiToken: Principal, from: Principal, to: Principal, fiAmount: Nat) -> async TxReceipt;
    
        // Returns the metadata of the token.
        getMetadata : query () -> async Metadata;

        // ADMIN functions
        _setPriceOracle : (oracle_id: Principal) -> async TxReceipt;
        _setCollateralFactor :(fiToken: Principal, collateralFactorMantissa: Nat) -> async TxReceipt;
        _supportMarket : (fiToken: Principal) -> async TxReceipt;
    };

    // Metadata: basic canister information.
    public type Metadata = {
        // Owner of the fitroller.
        admin       : Principal;

        // gives the price of any given asset in ICP
        oracle      : Principal;
        // for calculating repayAmount when liquidating a borrow
        closeFactorMantissa     : Nat;
        // max number of markets a user can enter
        maxAssets   : Nat8;
    };

    public type Market = {
        // is this market active 
        isListed                    : Bool;
        // fraction of user supply equating to max borrow allowance
        collateralFactorMantissa    : Nat;
        // user accounts that have entered this particular market
        accountMembership           : HashMap.HashMap<Principal, Bool>;
    };

    // TxReceipt: receipt for update calls, contains the transaction index or an error message.
    public type TxReceipt = {
        #Ok: Nat;
        #Err: {
            #InsufficientAllowance;
            #InsufficientBalance;
            #ErrorOperationStyle;
            #Unauthorized;
            #LedgerTrap;
            #ErrorTo;
            #Other: Text;
            #BlockUsed;
            #AmountTooSmall;
            #ReadDataError;
        };
    };

    public type TxStatus = {
        #succeeded;
        #failed;
    };

    public class Fitroller(_admin: Principal) {
        // detailed canister data
        public let cdata : internal.Metadata = {
            var admin               = _admin;

            var oracle              = Principal.fromText("aaaaa-aa");
            var closeFactorMantissa = 0;
            var maxAssets           = 2;
            var accountAssets       = HashMap.HashMap<Principal, Buffer.Buffer<Principal>>(1, Principal.equal, Principal.hash);
            var markets             = HashMap.HashMap<Principal, Market>(1, Principal.equal, Principal.hash);
            var allMarkets          = Buffer.Buffer<Principal>(1);
        };

        private var defaultCollateralFactor = 70_000_000;   // 70 %
        private var maxCollateralFactor = 90_000_000;       // 90 %
        private var minCollateralFactor = 40_000_000;       // 40 %

        // Add support for a new market to market data and market list
        public func addMarket(fitoken: Principal): async TxStatus {
            cdata.markets.put(
                fitoken, 
                { 
                    isListed = true;                        // TODO: Remove, redundant for non-Solidity map
                    collateralFactorMantissa = defaultCollateralFactor; 
                    accountMembership = HashMap.HashMap<Principal, Bool>(1, Principal.equal, Principal.hash);
                }
            );

            cdata.allMarkets.add(fitoken);

            #succeeded
        };

        // Add market to be used as collateral for a user
        public func addAssetToAccount(user: Principal, fitoken: Principal): async TxStatus {
            switch(cdata.accountAssets.get(user)){
                case null {
                    let tmpBuffer = Buffer.Buffer<Principal>(1);
                    tmpBuffer.add(fitoken);
                    cdata.accountAssets.put(user, tmpBuffer);
                };
                case (?aList) { aList.add(fitoken); };
            };

            #succeeded
        };

        public func getData() : Metadata = {
            admin                   = cdata.admin;
            oracle                  = cdata.oracle;
            closeFactorMantissa     = cdata.closeFactorMantissa;
            maxAssets               = cdata.maxAssets;
        };

        public func getStableMarket(market: Market) : {
            isListed                    : Bool;
            collateralFactorMantissa    : Nat;
            accountMembership           : [(Principal, Bool)];
        } = {
            isListed = market.isListed;
            collateralFactorMantissa = market.collateralFactorMantissa;
            accountMembership = Iter.toArray(market.accountMembership.entries());
        };
    };

    private module internal {
        public type Metadata = {
            var admin       : Principal;

            var oracle      : Principal;
            var closeFactorMantissa     : Nat;
            var maxAssets   : Nat8;
            // user accounts => fiToken - the markets a user has entered
            var accountAssets           : HashMap.HashMap<Principal, Buffer.Buffer<Principal>>;
            var allMarkets  : Buffer.Buffer<Principal>;     // List of all supported fitoken markets

            // market data for each fiToken
            var markets     : HashMap.HashMap<Principal, Market>; 
        };
    };
}