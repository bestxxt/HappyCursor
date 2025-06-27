import SwiftUI

struct LanguageSelectorView: View {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        HStack {
            Image(systemName: "globe")
                .foregroundColor(.secondary)
            
            Picker("Language", selection: $localizationManager.currentLanguage) {
                ForEach(localizationManager.supportedLanguages, id: \.code) { language in
                    Text(localizationManager.localizedLanguageName(for: language.code))
                        .tag(language.code)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
        .cornerRadius(8)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    LanguageSelectorView()
} 