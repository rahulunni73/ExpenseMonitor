//
//  NotificationService.swift
//  ExpenseMonitor
//

import Foundation
import UserNotifications

enum NotificationService {
    private static let reminderLeadDays = 1
    private static let reminderHour = 9

    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    static func currentAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    /// Wipes every pending EMI reminder and re-adds one per loan/chit fund — whichever installment
    /// is soonest due, mirroring `Loan.nextDueInstallment`/`ChitFund.nextDueContribution`, the same
    /// computed properties the in-app reminder card already uses. Safe to call as often as needed
    /// (on launch, after any loan/chit/payment change) since it always rebuilds from scratch rather
    /// than diffing — this app never schedules any other kind of notification, so a full wipe is safe.
    static func rescheduleReminders(loans: [Loan], chitFunds: [ChitFund]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        guard UserDefaults.standard.bool(forKey: "emiRemindersEnabled") else { return }

        for loan in loans {
            guard let installment = loan.nextDueInstallment, installment.status == .pending,
                  let request = reminderRequest(
                      identifier: "emi-reminder-loan-\(loan.id)",
                      title: loan.type == .creditCard ? "Credit Card Payment Due Tomorrow" : "EMI Due Tomorrow",
                      body: "\(loan.name): \(loan.installmentAmount.currencyFormatted) is due tomorrow.",
                      dueDate: installment.dueDate
                  )
            else { continue }
            center.add(request)
        }

        for chitFund in chitFunds {
            guard let contribution = chitFund.nextDueContribution, contribution.status == .pending,
                  let request = reminderRequest(
                      identifier: "emi-reminder-chit-\(chitFund.id)",
                      title: "Chit Fund Contribution Due Tomorrow",
                      body: "\(chitFund.name): \(chitFund.monthlyContribution.currencyFormatted) is due tomorrow.",
                      dueDate: contribution.dueDate
                  )
            else { continue }
            center.add(request)
        }
    }

    private static func reminderRequest(identifier: String, title: String, body: String, dueDate: Date) -> UNNotificationRequest? {
        let calendar = Calendar.current
        guard let reminderDate = calendar.date(byAdding: .day, value: -reminderLeadDays, to: dueDate) else { return nil }

        var components = calendar.dateComponents([.year, .month, .day], from: reminderDate)
        components.hour = reminderHour
        components.minute = 0

        // Skip anything whose reminder moment has already passed — a UNCalendarNotificationTrigger
        // built from a past date simply never fires, so bail out explicitly rather than scheduling
        // a request that silently does nothing.
        guard let triggerDate = calendar.date(from: components), triggerDate > Date() else { return nil }

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }

    /// Debug-only: fires a generic reminder ~5 seconds out so the whole permission → schedule →
    /// deliver pipeline can be seen working without waiting for a real due date. Not wired to any
    /// real loan/chit data — remove once the feature has been manually verified end to end.
    static func sendTestReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Test Reminder"
        content.body = "This is what an EMI reminder notification looks like."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "emi-reminder-test", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
