import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var settings = UserSettings()
    @StateObject private var timer = RandomSignalTimer()

    @State private var lastReactionMs: Double?
    @State private var signalShownAt: Date?

    var body: some View {
        currentScreen
            .onChange(of: timer.state) { newState in
                UIApplication.shared.isIdleTimerDisabled = (newState == .waiting || newState == .signal)
            }
            .onAppear {
                timer.onSignal = { handleSignalShown() }
                AdMobService.shared.requestTrackingAndInitialize()
            }
    }

    @ViewBuilder
    private var currentScreen: some View {
        switch timer.state {
        case .setup:
            setupScreen
        case .waiting:
            waitingScreen
        case .signal:
            signalScreen
        }
    }

    private var setupScreen: some View {
        SetupView(settings: settings, onStart: startSession)
    }

    private var waitingScreen: some View {
        WaitingView(
            lastReactionMs: lastReactionMs,
            bestReactionMs: settings.bestReactionMs,
            onEnd: endSession
        )
    }

    private var signalScreen: some View {
        SignalView(
            text: settings.displaySignalText,
            backgroundColor: settings.signalColor,
            onTap: acknowledgeSignal
        )
    }

    private func startSession() {
        lastReactionMs = nil
        timer.startSession(upperLimitSeconds: settings.totalUpperLimitSeconds)
    }

    private func endSession() {
        timer.endSession()
    }

    private func handleSignalShown() {
        signalShownAt = Date()
        if settings.soundOn { SoundService.shared.playBeep() }
        if settings.vibrationOn { HapticService.playLongImpact() }
    }

    private func acknowledgeSignal() {
        if let shownAt = signalShownAt {
            let ms = Date().timeIntervalSince(shownAt) * 1000
            lastReactionMs = ms
            if settings.bestReactionMs == nil || ms < settings.bestReactionMs! {
                settings.bestReactionMs = ms
            }
        }
        timer.acknowledgeSignalAndReschedule()
    }
}
