import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var reminderTime = Date()
    @State private var showingResetAlert = false
    @State private var showingResetSuccess = false
    
    var body: some View {
        NavigationView {
            Form {
                // Время напоминания
                Section("🕐 Время напоминания") {
                    DatePicker("Время", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .onChange(of: reminderTime) { newTime in
                            saveReminderTime(newTime)
                        }
                    
                    Text("Напоминание будет приходить каждый четверг в указанное время")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Счетчик капучино
                Section("☕ Счетчик капучино") {
                    HStack {
                        Text("Текущий счетчик:")
                        Spacer()
                        Text("\(appState.cappuccinoCount)")
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    Button("🔄 Сбросить счетчик") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.orange)
                }
                
                // Информация о приложении
                Section("ℹ️ О приложении") {
                    HStack {
                        Text("Версия:")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Разработчик:")
                        Spacer()
                        Text("Kapuchino Team")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Описание:")
                        Spacer()
                        Text("Напоминание о денежном четверге")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                // Сброс всех настроек
                Section("⚠️ Опасная зона") {
                    Button("🗑️ Сбросить все настройки") {
                        showingResetAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("⚙️ Настройки")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadReminderTime()
        }
        .alert("Сброс настроек", isPresented: $showingResetAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Сбросить", role: .destructive) {
                resetAllSettings()
            }
        } message: {
            Text("Вы уверены, что хотите сбросить все настройки? Это действие нельзя отменить.")
        }
        .alert("Настройки сброшены", isPresented: $showingResetSuccess) {
            Button("OK") { }
        } message: {
            Text("Все настройки были сброшены к значениям по умолчанию.")
        }
    }
    
    private func loadReminderTime() {
        let calendar = Calendar.current
        let now = Date()
        
        // Устанавливаем время 9:00 по умолчанию
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 9
        components.minute = 0
        
        reminderTime = calendar.date(from: components) ?? now
    }
    
    private func saveReminderTime(_ time: Date) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        
        // Здесь можно сохранить время в UserDefaults
        // и обновить расписание уведомлений
        print("Время напоминания установлено на \(hour):\(minute)")
    }
    
    private func resetAllSettings() {
        // Сбрасываем все настройки к значениям по умолчанию
        appState.resetMessage()
        appState.cappuccinoCount = 0
        appState.removePhoto()
        
        // Сбрасываем время напоминания
        loadReminderTime()
        
        showingResetSuccess = true
    }
}

#Preview {
    SettingsView(appState: AppState())
}
