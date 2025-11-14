import SwiftUI

enum PasswordStrength {
    case weak, medium, strong
    
    var color: Color {
        switch self {
        case .weak: return .red
        case .medium: return .orange
        case .strong: return .green
        }
    }
    
    var description: String {
        switch self {
        case .weak: return "Débil"
        case .medium: return "Media"
        case .strong: return "Fuerte"
        }
    }
    
    var percentage: Double {
        switch self {
        case .weak: return 0.33
        case .medium: return 0.66
        case .strong: return 1.0
        }
    }
}

struct PasswordStrengthMeter: View {
    let password: String
    
    private var strength: PasswordStrength {
        calculateStrength(password)
    }
    
    private func calculateStrength(_ password: String) -> PasswordStrength {
        if password.isEmpty { return .weak }
        
        var score = 0
        
        if password.count >= 8 { score += 1 }
        if password.count >= 12 { score += 1 }
        
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumbers = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSymbols = password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
        
        if hasUppercase && hasLowercase { score += 1 }
        if hasNumbers { score += 1 }
        if hasSymbols { score += 1 }
        
        switch score {
        case 0...2: return .weak
        case 3...4: return .medium
        default: return .strong
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Barra de progreso
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .frame(height: 6)
                    .foregroundColor(Color.gray.opacity(0.3))
                
                RoundedRectangle(cornerRadius: 4)
                    .frame(width: CGFloat(strength.percentage) * 200, height: 6)
                    .foregroundColor(strength.color)
                    // Animación simplificada para Xcode 12
                    .animation(.easeInOut(duration: 0.3))
            }
            .frame(width: 200)
            
            // Texto descriptivo
            HStack {
                Text("Fortaleza:")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text(strength.description)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(strength.color)
            }
            
            // Consejos
            if !password.isEmpty && strength != .strong {
                Text(suggestion)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
    
    private var suggestion: String {
        switch strength {
        case .weak:
            return "Usa al menos 8 caracteres con mayúsculas, minúsculas y números"
        case .medium:
            return "Agrega símbolos (!@#$) para mayor seguridad"
        case .strong:
            return "¡Excelente! Tu contraseña es segura"
        }
    }
}

// Preview compatible con Xcode 12
struct PasswordStrengthMeter_Previews: PreviewProvider {
    static var previews: some View {
        PasswordStrengthPreview()
    }
}

struct PasswordStrengthPreview: View {
    @State private var testPassword = ""
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Escribe una contraseña...", text: $testPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            PasswordStrengthMeter(password: testPassword)
                .padding()
            
            Spacer()
        }
    }
}
