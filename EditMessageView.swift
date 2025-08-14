import SwiftUI

struct EditMessageView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var messageText: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    private let emojis = ["☕️", "💰", "🎉", "🎊", "💎", "🌟", "✨", "🔥", "💪", "🎯", "🏆", "💖", "😊", "🥳", "🎁", "🎈"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Заголовок
                Text("✏️ Редактирование текста")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                // Поле ввода текста
                VStack(alignment: .leading, spacing: 10) {
                    Text("Введите новый текст напоминания:")
                        .font(.headline)
                    
                    TextEditor(text: $messageText)
                        .frame(minHeight: 120)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 20)
                
                // Эмодзи
                VStack(alignment: .leading, spacing: 10) {
                    Text("Добавить эмодзи:")
                        .font(.headline)
                        .padding(.horizontal, 20)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 10) {
                        ForEach(emojis, id: \.self) { emoji in
                            Button(emoji) {
                                messageText += emoji
                            }
                            .font(.title2)
                            .frame(width: 40, height: 40)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Кнопки управления
                VStack(spacing: 15) {
                    HStack(spacing: 15) {
                        Button("💾 Сохранить") {
                            saveMessage()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        
                        Button("🔄 Сбросить") {
                            resetMessage()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                    
                    Button("❌ Отмена") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("")
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
            messageText = appState.customMessage
        }
        .alert("Сообщение", isPresented: $showingAlert) {
            Button("OK") {
                if alertMessage.contains("успешно") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func saveMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedText.isEmpty {
            alertMessage = "Текст не может быть пустым!"
            showingAlert = true
            return
        }
        
        appState.updateMessage(trimmedText)
        alertMessage = "Текст напоминания обновлен! ✨"
        showingAlert = true
    }
    
    private func resetMessage() {
        let defaultMessage = "Луиза, не забудь про денежный четверг! ☕️ 💰 🎉"
        messageText = defaultMessage
    }
}

#Preview {
    EditMessageView(appState: AppState())
}
