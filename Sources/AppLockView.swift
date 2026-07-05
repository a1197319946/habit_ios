import SwiftUI
import LocalAuthentication

struct AppLockView<Content: View>: View {
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.scenePhase) var scenePhase
    
    let content: Content
    
    @State private var isUnlocked = false
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
                .allowsHitTesting(isUnlocked || !appSettings.appLockEnabled)
                .blur(radius: (appSettings.appLockEnabled && !isUnlocked) ? 20 : 0)
            
            if appSettings.appLockEnabled && !isUnlocked {
                ZStack {
                    DS.bgPrimary.ignoresSafeArea()
                    
                    VStack(spacing: DS.spacingXL) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 80))
                            .foregroundColor(DS.primary)
                        
                        Text("App Locked".tr(appSettings.resolvedLanguage))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(DS.onSurface)
                        
                        Button(action: {
                            authenticate()
                        }) {
                            Text("Unlock".tr(appSettings.resolvedLanguage))
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, DS.spacingXL)
                                .padding(.vertical, 16)
                                .background(DS.primary)
                                .clipShape(Capsule())
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if appSettings.appLockEnabled {
                if newPhase == .background {
                    isUnlocked = false
                } else if newPhase == .active {
                    if !isUnlocked {
                        authenticate()
                    }
                }
            } else {
                isUnlocked = true
            }
        }
        .onAppear {
            if !appSettings.appLockEnabled {
                isUnlocked = true
            } else {
                authenticate()
            }
        }
    }
    
    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        // Passcode fallback is allowed by default with deviceOwnerAuthentication
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Unlock Little Habit".tr(appSettings.resolvedLanguage)
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        withAnimation {
                            self.isUnlocked = true
                        }
                    } else {
                        // User canceled or failed
                    }
                }
            }
        } else {
            // No biometrics or passcode set
            DispatchQueue.main.async {
                withAnimation {
                    self.isUnlocked = true
                }
            }
        }
    }
}
