//
//  AddPasswordView.swift
//  Ejemplo
//
//  Created by Dilson Abrego on 9/15/25.
//  Copyright © 2025 Dilson Abrego. All rights reserved.
//

//
//  AddPasswordView.swift
//  Ejemplo
//
//  Created by Dilson Abrego on 9/15/25.
//  Copyright © 2025 Dilson Abrego. All rights reserved.
//

import SwiftUI

struct AddPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var passwordViewModel: PasswordViewModel
    
    @State private var service = ""
    @State private var username = ""
    @State private var password = ""
    @State private var notes = ""
    @State private var isSaving = false
    @State private var showingGeneratedAlert = false
    
    // Colores azules
    let mainBlue = Color(red: 0.1, green: 0.3, blue: 0.7)
    let lightBlue = Color(red: 0.9, green: 0.95, blue: 1.0)
    let darkBlue = Color(red: 0.05, green: 0.2, blue: 0.6)
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo
                lightBlue.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(mainBlue)
                        
                        Text("Nueva Contraseña")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(mainBlue)
                        
                        Text("Completa la información de tu cuenta")
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                    
                    // Formulario
                    ScrollView {
                        VStack(spacing: 16) {
                            // Campo Servicio
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "globe")
                                        .foregroundColor(mainBlue)
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text("Servicio")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(mainBlue)
                                    
                                    Text("*")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.red)
                                }
                                
                                TextField("Ej: Gmail, Facebook, Netflix", text: $service)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(service.isEmpty ? Color.gray.opacity(0.3) : mainBlue, lineWidth: 1)
                                    )
                            }
                            .padding(.horizontal)
                            
                            // Campo Usuario
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "person")
                                        .foregroundColor(mainBlue)
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text("Usuario o Email")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(mainBlue)
                                    
                                    Text("*")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.red)
                                }
                                
                                TextField("usuario@ejemplo.com", text: $username)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(username.isEmpty ? Color.gray.opacity(0.3) : mainBlue, lineWidth: 1)
                                    )
                            }
                            .padding(.horizontal)
                            
                            // Campo Contraseña
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "lock")
                                        .foregroundColor(mainBlue)
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text("Contraseña")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(mainBlue)
                                    
                                    Text("*")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.red)
                                }
                                
                                SecureField("Ingresa tu contraseña", text: $password)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(password.isEmpty ? Color.gray.opacity(0.3) : mainBlue, lineWidth: 1)
                                    )
                                
                                // ✅ BOTÓN GENERAR CONTRASEÑA
                                HStack {
                                    Spacer()
                                    
                                    Button(action: {
                                        // Generar contraseña automáticamente
                                        password = PasswordGenerator.generateSecurePassword()
                                        showingGeneratedAlert = true
                                    }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "key.fill")
                                                .font(.system(size: 12))
                                            Text("Generar Contraseña Segura")
                                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                        }
                                        .foregroundColor(mainBlue)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(mainBlue.opacity(0.1))
                                        .cornerRadius(15)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(mainBlue, lineWidth: 1)
                                        )
                                    }
                                }
                                .padding(.top, 4)
                                
                                // ✅ MEDIDOR DE FORTALEZA (aparece cuando hay contraseña)
                                if !password.isEmpty {
                                    PasswordStrengthMeter(password: password)
                                        .padding(.top, 4)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Campo Notas
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "note.text")
                                        .foregroundColor(mainBlue)
                                        .font(.system(size: 14, weight: .medium))
                                    
                                    Text("Notas (Opcional)")
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(mainBlue)
                                }
                                
                                TextField("Notas adicionales sobre esta cuenta", text: $notes)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .padding(.horizontal)
                            
                            // Botón Guardar
                            Button(action: {
                                savePassword()
                            }) {
                                HStack {
                                    if isSaving {
                                        // ✅ COMPATIBLE CON iOS 13: Activity Indicator personalizado
                                        Text("⏳")
                                            .font(.system(size: 18))
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 18, weight: .medium))
                                    }
                                    
                                    Text(isSaving ? "Guardando..." : "Guardar Contraseña")
                                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                .padding(16)
                                .background(isFormValid && !isSaving ? mainBlue : Color.gray)
                                .cornerRadius(12)
                                .shadow(color: isFormValid && !isSaving ? mainBlue.opacity(0.3) : Color.clear, radius: 5, x: 0, y: 3)
                            }
                            .disabled(!isFormValid || isSaving)
                            .padding(.horizontal)
                            .padding(.top, 10)
                            
                            // Indicador de campos requeridos
                            if !isFormValid {
                                Text("* Campos obligatorios")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(.red)
                                    .padding(.top, 5)
                            }
                            
                            // Leyenda de íconos de servicios
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Servicios populares:")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(mainBlue)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        serviceChip("Gmail", icon: "envelope.fill")
                                        serviceChip("Facebook", icon: "f.circle.fill")
                                        serviceChip("Instagram", icon: "camera.fill")
                                        serviceChip("Twitter/X", icon: "bird.fill")
                                        serviceChip("Netflix", icon: "play.tv.fill")
                                        serviceChip("WhatsApp", icon: "message.fill")
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancelar") {
                    if !isSaving {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .foregroundColor(isSaving ? .gray : .red)
                .font(.system(size: 16, weight: .medium))
            )
            // ✅ ALERTA DE CONTRASEÑA GENERADA
            .alert(isPresented: $showingGeneratedAlert) {
                Alert(
                    title: Text("Contraseña Generada"),
                    message: Text("Se ha creado una contraseña segura. Puedes usarla o editarla."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var isFormValid: Bool {
        !service.isEmpty && !username.isEmpty && !password.isEmpty
    }
    
    private func savePassword() {
        isSaving = true
        
        print("🔍 DEBUG - Guardando contraseña para: \(service)")
        
        passwordViewModel.savePassword(
            service: service,
            username: username,
            password: password,
            notes: notes
        )
        
        // Pequeño delay para asegurar que se guarde en Firestore
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isSaving = false
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    // Chip de servicio rápido
    private func serviceChip(_ name: String, icon: String) -> some View {
        Button(action: {
            service = name
        }) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(mainBlue)
                Text(name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(mainBlue)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(mainBlue.opacity(0.1))
            .cornerRadius(15)
        }
    }
}

struct AddPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        AddPasswordView(passwordViewModel: PasswordViewModel())
    }
}
