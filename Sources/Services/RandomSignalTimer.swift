import Foundation
import Combine
import UIKit

/// ランダム待機タイマー。
/// - 1.0秒〜上限時間の間で一様乱数抽選し、その秒数が経過したら合図を発火する。
/// - アプリがバックグラウンド/非アクティブになった間は計測を一時停止し、
///   フォアグラウンド復帰時に残り時間から再開する(待機時間としてカウントしない)。
/// - 合図画面表示中にバックグラウンドへ移行しても、復帰後は合図画面のまま(新規抽選しない)。
final class RandomSignalTimer: ObservableObject {
    @Published private(set) var state: AppState = .setup

    private var upperLimitSeconds: Double = 300
    private var remainingSeconds: Double = 0
    private var lastTickDate: Date?
    private var displayLink: Timer?
    private var isRunning = false

    private var willResignObserver: NSObjectProtocol?
    private var didBecomeActiveObserver: NSObjectProtocol?

    var onSignal: (() -> Void)?

    init() {
        willResignObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification, object: nil, queue: .main
        ) { [weak self] _ in self?.handleWillResignActive() }

        didBecomeActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main
        ) { [weak self] _ in self?.handleDidBecomeActive() }
    }

    deinit {
        if let o = willResignObserver { NotificationCenter.default.removeObserver(o) }
        if let o = didBecomeActiveObserver { NotificationCenter.default.removeObserver(o) }
        displayLink?.invalidate()
    }

    func startSession(upperLimitSeconds: Double) {
        self.upperLimitSeconds = max(10, upperLimitSeconds)
        state = .waiting
        scheduleNextSignal()
    }

    func endSession() {
        cancelTimer()
        state = .setup
    }

    /// 合図確認後の再抽選(次の待機へ)
    func acknowledgeSignalAndReschedule() {
        guard state == .signal else { return }
        state = .waiting
        scheduleNextSignal()
    }

    private func scheduleNextSignal() {
        cancelTimer()
        let delay = Double.random(in: 1.0...upperLimitSeconds)
        remainingSeconds = delay
        startTicking()
    }

    private func startTicking() {
        isRunning = true
        lastTickDate = Date()
        displayLink?.invalidate()
        displayLink = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard isRunning, state == .waiting else { return }
        let now = Date()
        let delta = now.timeIntervalSince(lastTickDate ?? now)
        lastTickDate = now
        remainingSeconds -= delta
        if remainingSeconds <= 0 {
            isRunning = false
            displayLink?.invalidate()
            displayLink = nil
            state = .signal
            onSignal?()
        }
    }

    private func cancelTimer() {
        isRunning = false
        displayLink?.invalidate()
        displayLink = nil
    }

    private func handleWillResignActive() {
        // 待機中のみ一時停止(合図画面表示中はそのまま/セットアップ中は何もしない)
        guard state == .waiting, isRunning else { return }
        isRunning = false
        displayLink?.invalidate()
        displayLink = nil
        // remainingSecondsはtick()内で直近まで減算済みなのでそのまま保持される
    }

    private func handleDidBecomeActive() {
        guard state == .waiting, !isRunning else { return }
        startTicking()
    }
}
