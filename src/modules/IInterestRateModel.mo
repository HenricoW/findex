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
        // per second: smallest annual % that can reasonably be represented = 31.5% (at 10e8 mantissa) = 1_nat * 365 * 24 * 60 * 60
        // per minute: smallest annual % that can reasonably be represented = 0.52% (at 10e8 mantissa) = 1_nat * 365 * 24 * 60
        let minutesPerYear = 365.0 * 24.0 * 60.0;
        
        public let ONE = 100_000_000;
        // percentages used as whole numbers, not fractions
        let baseRatePerMinInt = Float.nearest( (annualBaseRate * Float.fromInt(ONE) / 100) / minutesPerYear );
        let slopeRatePerMinInt = Float.nearest( (annualSlopeRate * Float.fromInt(ONE) / 100) / minutesPerYear );

        public let baseRatePerMin: Nat = Int.abs(Float.toInt(baseRatePerMinInt));
        public let slopeRatePerMin: Nat = Int.abs(Float.toInt(slopeRatePerMinInt));

        public let isInterestRateModel = true;          // basic check, helps prevents mistakes
    };
}