import Nat "mo:base/Nat";
import Float "mo:base/Float";
import Int "mo:base/Int";

module {
    public type Interface = actor {
        utilizationRate : shared (cash: Nat, borrows: Nat, reserves: Nat) -> async Nat;
        
        getBorrowRate : shared (cash: Nat, borrows: Nat, reserves: Nat) -> async Nat;

        getSupplyRate : shared (cash: Nat, borrows: Nat, reserves: Nat, reserveFactorMantissa: Nat) -> async Nat;
    };

    public class InterestRateModel(annualBaseRate: Float, annualSlopeRate: Float) {
        // per minute or per second basis? => per minute gives higher resolution per time unit
        // per second: smallest annual % that can reasonably be represented = 0.40% (at 10e8 mantissa)
        // per minute: smallest annual % that can reasonably be represented = 0.01% (at 10e8 mantissa)
        let minutesPerYear = 365 * 24 * 60;
        
        public let ONE = 100_000_000;
        let baseRatePerMinInt = Float.toInt(annualBaseRate * Float.fromInt(ONE)) / minutesPerYear;
        let slopeRatePerMinInt = Float.toInt(annualSlopeRate * Float.fromInt(ONE)) / minutesPerYear;

        public let baseRatePerMin: Nat = Int.abs(baseRatePerMinInt);
        public let slopeRatePerMin: Nat = Int.abs(slopeRatePerMinInt);

        public let isInterestRateModel = true;          // basic check, helps prevents mistakes
    };
}