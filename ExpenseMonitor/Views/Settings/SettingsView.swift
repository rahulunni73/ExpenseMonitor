//
//  SettingsView.swift
//  ExpenseMonitor
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    let entitlements: EntitlementsProviding
    let expenseRepository: ExpenseRepository
    let categoryRepository: CategoryRepository
    let loanRepository: LoanRepository
    let chitFundRepository: ChitFundRepository

    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeColors) private var themeColors
    @Environment(\.typography) private var typography
    @Environment(ThemeManager.self) private var themeManager

    @State private var isExporting = false
    @State private var exportDocument: BackupDocument?
    @State private var isImporting = false
    @State private var pendingImportURL: URL?
    @State private var isRestoreConfirmationPresented = false
    @State private var isRestoreCompleteAlertPresented = false
    @State private var isImportErrorAlertPresented = false
    @State private var importErrorMessage = ""
    @State private var isManageCategoriesPresented = false
    @State private var isThemePickerPresented = false
    @AppStorage("emiRemindersEnabled") private var emiRemindersEnabled = false
    @State private var isNotificationPermissionDeniedAlertPresented = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var backupService: BackupService {
        BackupService(
            expenseRepository: expenseRepository,
            categoryRepository: categoryRepository,
            loanRepository: loanRepository,
            chitFundRepository: chitFundRepository
        )
    }

    private var exportFilename: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "ExpenseMonitor-Backup-\(formatter.string(from: Date()))"
    }

    private var emiRemindersToggleBinding: Binding<Bool> {
        Binding(
            get: { emiRemindersEnabled },
            set: { newValue in
                if newValue {
                    NotificationService.requestAuthorization { granted in
                        if granted {
                            emiRemindersEnabled = true
                            rescheduleReminders()
                        } else {
                            emiRemindersEnabled = false
                            isNotificationPermissionDeniedAlertPresented = true
                        }
                    }
                } else {
                    emiRemindersEnabled = false
                    rescheduleReminders()
                }
            }
        )
    }

    private func rescheduleReminders() {
        NotificationService.rescheduleReminders(loans: loanRepository.fetchAll(), chitFunds: chitFundRepository.fetchAll())
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Done") {
                    dismiss()
                }
                Spacer()
                Text("Settings")
                    .font(typography.headline)
                Spacer()
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()

            List {
                Section("Appearance") {
                    Button {
                        isThemePickerPresented = true
                    } label: {
                        settingsActionRow(icon: "paintbrush.fill", iconColor: Color(.systemPurple), title: "Theme", detail: themeManager.currentTheme.name)
                    }
                    .buttonStyle(.plain)
                }

                Section("Categories") {
                    Button {
                        isManageCategoriesPresented = true
                    } label: {
                        settingsActionRow(icon: "tag.fill", iconColor: Color(.systemBlue), title: "Manage Categories")
                    }
                    .buttonStyle(.plain)
                }

                Section("Preferences") {
                    settingsRow(icon: "indianrupeesign.circle.fill", iconColor: Color(.systemGreen), title: "Currency", detail: "INR (₹)")
                }

                Section {
                    Toggle(isOn: emiRemindersToggleBinding) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundStyle(.white)
                                .frame(width: 28, height: 28)
                                .background(Color(.systemRed))
                                .clipShape(RoundedRectangle(cornerRadius: 7))
                            Text("EMI Reminders")
                                .font(typography.body)
                        }
                    }
                    .padding(.vertical, 4)

                    if emiRemindersEnabled {
                        Button {
                            NotificationService.sendTestReminder()
                        } label: {
                            settingsActionRow(icon: "hammer.fill", iconColor: Color(.systemGray), title: "Send Test Reminder (Debug)")
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Get a reminder the day before each EMI or chit fund installment is due.")
                }

                Section {
                    Button {
                        exportDocument = BackupDocument(data: (try? BackupData.jsonEncoder.encode(backupService.exportData())) ?? Data())
                        isExporting = true
                    } label: {
                        settingsActionRow(icon: "square.and.arrow.up.fill", iconColor: Color(.systemBlue), title: "Export Backup")
                    }
                    .buttonStyle(.plain)

                    Button {
                        isImporting = true
                    } label: {
                        settingsActionRow(icon: "square.and.arrow.down.fill", iconColor: Color(.systemOrange), title: "Restore from Backup")
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text("Data")
                } footer: {
                    Text("Export a complete backup of your expenses, categories, EMIs, and chit funds, or restore from a previously saved backup file.")
                }

                Section("Premium") {
                    settingsRow(
                        icon: "icloud.fill",
                        iconColor: Color(.systemBlue),
                        title: "Cloud Sync",
                        detail: entitlements.isUnlocked(.cloudSync) ? "Unlocked" : "Locked"
                    )
                }

                Section("About") {
                    settingsRow(icon: "info.circle.fill", iconColor: Color(.systemGray), title: "Version", detail: appVersion)
                }
            }
            .listStyle(.insetGrouped)
        }
        .background(themeColors.background)
        .onAppear {
            guard emiRemindersEnabled else { return }
            NotificationService.currentAuthorizationStatus { status in
                if status != .authorized {
                    emiRemindersEnabled = false
                }
            }
        }
        .sheet(isPresented: $isManageCategoriesPresented) {
            ManageCategoriesView(categoryRepository: categoryRepository, expenseRepository: expenseRepository)
        }
        .sheet(isPresented: $isThemePickerPresented) {
            ThemePickerView()
        }
        .fileExporter(isPresented: $isExporting, document: exportDocument, contentType: .json, defaultFilename: exportFilename) { result in
            if case .failure = result {
                importErrorMessage = "Couldn't save the backup file."
                isImportErrorAlertPresented = true
            }
        }
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url):
                pendingImportURL = url
                isRestoreConfirmationPresented = true
            case .failure:
                importErrorMessage = "Couldn't read this backup file."
                isImportErrorAlertPresented = true
            }
        }
        .confirmationDialog(
            "Replace all data?",
            isPresented: $isRestoreConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("Replace Everything", role: .destructive) {
                performImport()
            }
            Button("Cancel", role: .cancel) {
                pendingImportURL = nil
            }
        } message: {
            Text("This will permanently replace all your expenses, categories, EMIs, and chit funds with the contents of this backup. This can't be undone.")
        }
        .alert("Restore Complete", isPresented: $isRestoreCompleteAlertPresented) {
            Button("OK") { dismiss() }
        } message: {
            Text("Please close and reopen ExpenseMonitor to see your restored data.")
        }
        .alert("Import Failed", isPresented: $isImportErrorAlertPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(importErrorMessage)
        }
        .alert("Notifications Disabled", isPresented: $isNotificationPermissionDeniedAlertPresented) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("EMI Reminders needs notification permission. You can enable it for ExpenseMonitor in iOS Settings.")
        }
    }

    private func performImport() {
        guard let url = pendingImportURL else { return }
        pendingImportURL = nil
        guard url.startAccessingSecurityScopedResource() else {
            importErrorMessage = "Couldn't access this backup file."
            isImportErrorAlertPresented = true
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        do {
            let data = try Data(contentsOf: url)
            let backup = try BackupData.jsonDecoder.decode(BackupData.self, from: data)
            backupService.importData(backup)
            isRestoreCompleteAlertPresented = true
        } catch {
            importErrorMessage = "Couldn't read this backup file."
            isImportErrorAlertPresented = true
        }
    }

    private func settingsRow(icon: String, iconColor: Color, title: String, detail: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(iconColor)
                .clipShape(RoundedRectangle(cornerRadius: 7))
            Text(title)
                .font(typography.body)
            Spacer()
            Text(detail)
                .font(typography.body)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func settingsActionRow(icon: String, iconColor: Color, title: String, detail: String? = nil) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(iconColor)
                .clipShape(RoundedRectangle(cornerRadius: 7))
            Text(title)
                .font(typography.body)
                .foregroundStyle(.primary)
            Spacer()
            if let detail {
                Text(detail)
                    .font(typography.body)
                    .foregroundStyle(.secondary)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Expense.self, Category.self, Loan.self, ChitFund.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    SettingsView(
        entitlements: StubEntitlementsProvider(),
        expenseRepository: DefaultExpenseRepository(modelContext: container.mainContext, entitlements: StubEntitlementsProvider()),
        categoryRepository: DefaultCategoryRepository(modelContext: container.mainContext),
        loanRepository: DefaultLoanRepository(modelContext: container.mainContext),
        chitFundRepository: DefaultChitFundRepository(modelContext: container.mainContext)
    )
    .environment(ThemeManager())
}
