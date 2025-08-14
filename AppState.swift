import SwiftUI
import Foundation

class AppState: ObservableObject {
    @Published var customMessage: String = "Госпожа, не забудь капучино с корицей! ☕️ 💰"
    @Published var cappuccinoCount: Int = 0
    @Published var motivationalPhoto: UIImage?
    @Published var progressValue: Double = 0.0
    @Published var progressText: String = "До следующего четверга:"
    
    private let userDefaults = UserDefaults.standard
    private let messageKey = "customMessage"
    private let countKey = "cappuccinoCount"
    private let photoKey = "motivationalPhoto"
    
    init() {
        loadData()
    }
    
    // MARK: - Message Management
    
    func updateMessage(_ newMessage: String) {
        customMessage = newMessage
        userDefaults.set(newMessage, forKey: messageKey)
    }
    
    func resetMessage() {
        let defaultMessage = "Луиза, не забудь про денежный четверг! ☕️ 💰 🎉"
        updateMessage(defaultMessage)
    }
    
    // MARK: - Cappuccino Counter
    
    func markCappuccinoDrunk() {
        cappuccinoCount += 1
        userDefaults.set(cappuccinoCount, forKey: countKey)
    }
    
    func fixCappuccinoCount() {
        if cappuccinoCount > 0 {
            cappuccinoCount -= 1
            userDefaults.set(cappuccinoCount, forKey: countKey)
        }
    }
    
    // MARK: - Photo Management
    
    func setMotivationalPhoto(_ image: UIImage) {
        motivationalPhoto = image
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            userDefaults.set(imageData, forKey: photoKey)
        }
    }
    
    func removePhoto() {
        motivationalPhoto = nil
        userDefaults.removeObject(forKey: photoKey)
    }
    
    // MARK: - Progress Calculation
    
    func updateProgress() {
        let calendar = Calendar.current
        let now = Date()
        
        // Находим следующий четверг
        var nextThursday = now
        let weekday = calendar.component(.weekday, from: now)
        
        // Если сегодня четверг (5), то следующий через неделю
        if weekday == 5 {
            nextThursday = calendar.date(byAdding: .day, value: 7, to: now) ?? now
        } else {
            // Иначе находим следующий четверг
            let daysUntilThursday = (5 - weekday + 7) % 7
            nextThursday = calendar.date(byAdding: .day, value: daysUntilThursday, to: now) ?? now
        }
        
        // Устанавливаем время 9:00
        var components = calendar.dateComponents([.year, .month, .day], from: nextThursday)
        components.hour = 9
        components.minute = 0
        components.second = 0
        
        nextThursday = calendar.date(from: components) ?? nextThursday
        
        // Вычисляем прогресс
        let totalSeconds = nextThursday.timeIntervalSince(now)
        let weekInSeconds: TimeInterval = 7 * 24 * 3600
        
        if totalSeconds > 0 {
            progressValue = max(0, min(1, (1 - totalSeconds / weekInSeconds)))
            
            let days = Int(totalSeconds / (24 * 3600))
            let hours = Int((totalSeconds.truncatingRemainder(dividingBy: 24 * 3600)) / 3600)
            let minutes = Int((totalSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
            
            if days > 0 {
                progressText = "До следующего четверга: \(days) дн. \(hours) ч. \(minutes) мин. ⏳"
            } else {
                progressText = "До следующего четверга: \(hours) ч. \(minutes) мин. ⏳"
            }
        } else {
            progressValue = 1.0
            progressText = "Сегодня четверг! ☕️"
        }
    }
    
    // MARK: - Data Persistence
    
    private func loadData() {
        // Загружаем сообщение
        if let savedMessage = userDefaults.string(forKey: messageKey) {
            customMessage = savedMessage
        }
        
        // Загружаем счетчик
        cappuccinoCount = userDefaults.integer(forKey: countKey)
        
        // Загружаем фото
        if let imageData = userDefaults.data(forKey: photoKey) {
            motivationalPhoto = UIImage(data: imageData)
        }
    }
    
    func saveData() {
        userDefaults.set(customMessage, forKey: messageKey)
        userDefaults.set(cappuccinoCount, forKey: countKey)
        if let image = motivationalPhoto,
           let imageData = image.jpegData(compressionQuality: 0.8) {
            userDefaults.set(imageData, forKey: photoKey)
        }
    }
}
