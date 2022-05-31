import Nat "mo:base/Nat";
import Float "mo:base/Float";
import Bool "mo:base/Debug";
import IiRateModel "./IInterestRateModel"

actor class IntRateModel(annualBaseRate: Float, annualSlopeRate: Float) : async IiRateModel.Interface {
    // supplied rates to be in normal annual %ge values (ex. 35.6 %)
    let irate = IiRateModel.InterestRateModel(annualBaseRate, annualSlopeRate);

    public func isInterestRateModel() : async Bool { irate.isInterestRateModel };

    public func utilizationRate(cash: Nat, borrows: Nat, reserves: Nat) : async Nat {
        // any borrows?
        if(borrows == 0) { return 0 };

        borrows * irate.ONE / (cash + borrows - reserves)                               // fraction to mantissa
    };

    // get current borrow rate per second, scaled up by 10e8 (8 decimals places)
    public func getBorrowRate(cash: Nat, borrows: Nat, reserves: Nat) : async Nat {
        let utilRate = await utilizationRate(cash, borrows, reserves);

        irate.baseRatePerMin + ( utilRate * irate.slopeRatePerMin / irate.ONE )
    };

    // get current supply rate per second, scaled up by 10e8 (8 decimals places)
    public func getSupplyRate(cash: Nat, borrows: Nat, reserves: Nat, reserveFactorMantissa: Nat) : async Nat {
        let borrwoRate = await getBorrowRate(cash, borrows, reserves);
        let utilRate = await utilizationRate(cash, borrows, reserves);

        borrwoRate * (irate.ONE - reserveFactorMantissa) * utilRate / ( irate.ONE * irate.ONE )
    };
};