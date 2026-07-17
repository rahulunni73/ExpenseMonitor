//
//  EntitlementsProviding.swift
//  ExpenseMonitor
//

enum PremiumFeature {
    case cloudSync
}

protocol EntitlementsProviding {
    func isUnlocked(_ feature: PremiumFeature) -> Bool
}

class StubEntitlementsProvider: EntitlementsProviding {
    func isUnlocked(_ feature: PremiumFeature) -> Bool {
        false
    }
}
