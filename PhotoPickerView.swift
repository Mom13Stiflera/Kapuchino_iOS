import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Заголовок
                Text("📁 Добавление фото")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                // Текущее фото
                if let image = appState.motivationalPhoto {
                    VStack(spacing: 15) {
                        Text("Текущее фото:")
                            .font(.headline)
                        
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(15)
                        
                        Button("🗑️ Удалить фото") {
                            removePhoto()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                } else {
                    VStack(spacing: 15) {
                        Text("Фото не выбрано")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.systemGray5))
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 50))
                                    .foregroundColor(.secondary)
                            )
                    }
                }
                
                Spacer()
                
                // Выбор фото
                VStack(spacing: 15) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text("Выбрать фото из галереи")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .onChange(of: selectedItem) { item in
                        Task {
                            await loadImage(from: item)
                        }
                    }
                    
                    Button("Готово") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Фото", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                
                // Сжимаем изображение для экономии памяти
                let compressedImage = compressImage(image)
                
                DispatchQueue.main.async {
                    appState.setMotivationalPhoto(compressedImage)
                    alertMessage = "Фото успешно добавлено! ✨"
                    showingAlert = true
                }
            }
        } catch {
            DispatchQueue.main.async {
                alertMessage = "Ошибка загрузки фото: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
    
    private func removePhoto() {
        appState.removePhoto()
        alertMessage = "Фото удалено"
        showingAlert = true
    }
    
    private func compressImage(_ image: UIImage) -> UIImage {
        let maxSize: CGFloat = 1024
        
        let scale = min(maxSize / image.size.width, maxSize / image.size.height)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let compressedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return compressedImage ?? image
    }
}

#Preview {
    PhotoPickerView(appState: AppState())
}
