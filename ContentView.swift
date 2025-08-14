import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    @EnvironmentObject var notificationManager: NotificationManager
    @State private var showingEditMessage = false
    @State private var showingPhotoPicker = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Заголовок приложения
                    VStack(spacing: 10) {
                        Text("☕ Kapuchino")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Напоминание о денежном четверге")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Основное сообщение
                    VStack(spacing: 15) {
                        Text(appState.customMessage)
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                        
                        Button("✏️ Изменить текст") {
                            showingEditMessage = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    // Прогресс до следующего четверга
                    VStack(spacing: 10) {
                        Text(appState.progressText)
                            .font(.headline)
                        
                        ProgressView(value: appState.progressValue)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    
                    // Счетчик капучино
                    VStack(spacing: 15) {
                        Text("📅 Было выпито капучино в четверг")
                            .font(.headline)
                        
                        Text("Успешно выпитых капучино: \(appState.cappuccinoCount) раз")
                            .font(.title3)
                            .foregroundColor(.green)
                        
                        HStack(spacing: 15) {
                            Button("☕ Отметить выпитый капучино") {
                                appState.markCappuccinoDrunk()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                            
                            Button("🔧 Исправить счетчик") {
                                appState.fixCappuccinoCount()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    
                    // Фото
                    VStack(spacing: 15) {
                        if let image = appState.motivationalPhoto {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: 200)
                                .cornerRadius(15)
                        } else {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemGray5))
                                .frame(height: 200)
                                .overlay(
                                    Text("📁 Добавить фото")
                                        .foregroundColor(.secondary)
                                )
                        }
                        
                        Button("📁 Добавить фото") {
                            showingPhotoPicker = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                    }
                    
                    // Статус уведомлений
                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: notificationManager.isAuthorized ? "bell.fill" : "bell.slash")
                                .foregroundColor(notificationManager.isAuthorized ? .green : .red)
                            
                            Text(notificationManager.isAuthorized ? "Уведомления включены" : "Уведомления отключены")
                                .font(.subheadline)
                        }
                        
                        if !notificationManager.isAuthorized {
                            Button("Включить уведомления") {
                                notificationManager.requestPermission()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("⚙️") {
                        showingSettings = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditMessage) {
            EditMessageView(appState: appState)
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPickerView(appState: appState)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(appState: appState)
        }
        .onAppear {
            appState.updateProgress()
        }
        .onReceive(Timer.publish(every: 300, on: .main, in: .common).autoconnect()) { _ in
            appState.updateProgress()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NotificationManager())
}
