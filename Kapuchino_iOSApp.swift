import SwiftUI
import UserNotifications

@main
struct Kapuchino_iOSApp: App {
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
                .onAppear {
                    notificationManager.requestPermission()
                }
        }
    }
}

class NotificationManager: ObservableObject {
    @Published var isAuthorized = false
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
            if granted {
                self.scheduleNotifications()
            }
        }
    }
    
    func scheduleNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "☕ Kapuchino"
        content.body = "Госпожа, не забудь капучино с корицей! ☕️ 💰"
        content.sound = .default
        
        // Создаем триггер для каждого четверга в 9:00
        var dateComponents = DateComponents()
        dateComponents.weekday = 5 // Четверг
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "kapuchino_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
