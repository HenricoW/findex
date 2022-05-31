import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Types "../utils/types";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Order "mo:base/Order";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Result "mo:base/Result";
import Text "mo:base/Text";
import ExperimentalCycles "mo:base/ExperimentalCycles";
import Cap "../cap/Cap";
import Root "../cap/Root";
import Bool "mo:base/Debug";

module {
    public type Interface = actor {
        transfer: shared (to: Principal, value: Nat) -> async Types.TxReceipt;
        transferFrom: shared (from: Principal, to: Principal, value: Nat) -> async Types.TxReceipt;
        approve: shared (spender: Principal, value: Nat) -> async Types.TxReceipt;
        
        balanceOf: query (who: Principal) -> async Nat;
        allowance: query (owner: Principal, spender: Principal) -> async Nat;
        totalSupply: query () -> async Nat;

        name: query () -> async Text;
        symbol: query () -> async Text;
        logo: query () -> async Text;
        decimals: query () -> async Nat8;
        getTokenFee: query () -> async Nat;
        // name: query () -> async Text;

        setFeeTo: shared (to: Principal) -> ();
        setFee: shared (_fee: Nat) -> ();
        setOwner: shared (_owner: Principal) -> ();
    };

    public class FiToken(
        _logo: Text,
        _name: Text,
        _symbol: Text,
        _decimals: Nat8,
        _owner: Principal,
        _underlying: Text,
        _initialExchangeRateMantissa: Nat,
        _fee: Nat
    ) = this {
        public var cdata = {
            var owner_ : Principal = _owner;
            var logo_ : Text = _logo;
            var name_ : Text = _name;
            var decimals_ : Nat8 = _decimals;
            var symbol_ : Text = _symbol;
            var totalSupply_ : Nat = 0;
            var blackhole : Principal = Principal.fromText("aaaaa-aa");
            var feeTo : Principal = _owner;
            var fee : Nat = _fee;

            var balances = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);
            var allowances = HashMap.HashMap<Principal, HashMap.HashMap<Principal, Nat>>(1, Principal.equal, Principal.hash);
        };

        public var underlyingId: Text = _underlying;
        public var exchangeRateMantissa: Nat = _initialExchangeRateMantissa;
        public var ONE: Nat = 100_000_000;
        // public var thisCanister = Principal.fromActor(this);

        public func _balanceOf(who: Principal) : Nat {
            switch (cdata.balances.get(who)) {
                case (?balance) { return balance; };
                case (_) { return 0; };
            }
        };

        public func _transfer(from: Principal, to: Principal, value: Nat) {
            let from_balance = _balanceOf(from);
            let from_balance_new : Nat = from_balance - value;
            if (from_balance_new != 0) { cdata.balances.put(from, from_balance_new); }
            else { cdata.balances.delete(from); };

            let to_balance = _balanceOf(to);
            let to_balance_new : Nat = to_balance + value;
            if (to_balance_new != 0) { cdata.balances.put(to, to_balance_new); };
        };

        public func _chargeFee(from: Principal, fee: Nat) {
            if(fee > 0) {
                _transfer(from, cdata.feeTo, fee);
            };
        };

        public func _allowance(owner: Principal, spender: Principal) : Nat {
            switch(cdata.allowances.get(owner)) {
                case (?allowance_owner) {
                    switch(allowance_owner.get(spender)) {
                        case (?allowance) { return allowance; };
                        case (_) { return 0; };
                    }
                };
                case (_) { return 0; };
            }
        };

        public func transfer(caller: Principal, to: Principal, value: Nat) : async Types.TxReceipt {
            if (_balanceOf(caller) < value + cdata.fee) { return #Err(#InsufficientBalance) };
            _chargeFee(caller, cdata.fee);
            _transfer(caller, to, value);

            return #Ok(0);
        };

        public func transferFrom(caller: Principal, from: Principal, to: Principal, value: Nat) : async Types.TxReceipt {
            if (_balanceOf(from) < value + cdata.fee) { return #Err(#InsufficientBalance) };

            let allowed : Nat = _allowance(from, caller);
            if (allowed < value + cdata.fee) { return #Err(#InsufficientAllowance) };

            _chargeFee(from, cdata.fee);
            _transfer(from, to, value);

            let allowed_new : Nat = allowed - value - cdata.fee;
            if (allowed_new != 0) {
                let allowance_from = Types.unwrap(cdata.allowances.get(from));
                allowance_from.put(caller, allowed_new);
                cdata.allowances.put(from, allowance_from);
            } else {
                if (allowed != 0) {
                    let allowance_from = Types.unwrap(cdata.allowances.get(from));
                    allowance_from.delete(caller);
                    if (allowance_from.size() == 0) { cdata.allowances.delete(from); }
                    else { cdata.allowances.put(from, allowance_from); };
                };
            };

            return #Ok(0)
        };

        public func approve(caller: Principal, spender: Principal, value: Nat) : async Types.TxReceipt {
            if(_balanceOf(caller) < cdata.fee) { return #Err(#InsufficientBalance) };

            _chargeFee(caller, cdata.fee);

            let v = value + cdata.fee;
            if (value == 0 and Option.isSome(cdata.allowances.get(caller))) {
                let allowance_caller = Types.unwrap(cdata.allowances.get(caller));
                allowance_caller.delete(spender);

                if (allowance_caller.size() == 0) { cdata.allowances.delete(caller); }
                else { cdata.allowances.put(caller, allowance_caller); };

            } else if (value != 0 and Option.isNull(cdata.allowances.get(caller))) {
                var temp = HashMap.HashMap<Principal, Nat>(1, Principal.equal, Principal.hash);
                temp.put(spender, v);

                cdata.allowances.put(caller, temp);
            } else if (value != 0 and Option.isSome(cdata.allowances.get(caller))) {
                let allowance_caller = Types.unwrap(cdata.allowances.get(caller));
                allowance_caller.put(spender, v);

                cdata.allowances.put(caller, allowance_caller);
            };
            
            return #Ok(0);
        };
    };
}