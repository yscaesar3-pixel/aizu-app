import GoogleMobileAds
import AppTrackingTransparency
import SwiftUI
import Combine

/// AdMob初期化とATT(トラッキング許可)を担当する。
/// 重要: ATT許可ダイアログは、データ収集を伴う処理(広告SDKの初期化)より前に必ず表示すること。
///
/// ADMOB_ENABLED が false の場合、ATT許可・SDK初期化・バナー広告表示を
/// すべて無効化する(原因切り分け用のビルドフラグ)。
final class AdMobService: ObservableObject {
    static let shared = AdMobService()

    /// 原因切り分け用フラグ。false にするとAdMob関連処理を一切実行しない。
    static let isAdMobEnabled = true

    static let bannerAdUnitID = "ca-app-pub-8174756915786797/4425929739" // aizu_ios_banner (本番)

    /// GADMobileAds.start()の完了を確認できてから初めてtrueになる。
    /// バナー広告はこれがtrueになるまでロードしない。
    @Published private(set) var isInitialized = false

    /// バナー広告のロード失敗時のエラー内容(原因確認用。実機で直接読めるよう画面にも表示する)。
    @Published var lastBannerError: String?

    /// ATT許可ダイアログの現在の許可状態(原因確認用)。
    @Published var trackingStatusDescription: String = "未確認"

    private var didStart = false

    private init() {}

    func requestTrackingAndInitialize() {
        guard Self.isAdMobEnabled else { return }
        guard !didStart else { return }
        didStart = true
        if #available(iOS 14, *) {
            trackingStatusDescription = Self.describe(ATTrackingManager.trackingAuthorizationStatus)
            ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    self?.trackingStatusDescription = Self.describe(status)
                    // 許可/拒否いずれの結果でも、AdMob自体は初期化する(パーソナライズなし広告にフォールバック)
                    self?.startSDK()
                }
            }
        } else {
            startSDK()
        }
    }

    @available(iOS 14, *)
    private static func describe(_ status: ATTrackingManager.AuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "未確定(notDetermined) - ダイアログが出るはずの状態"
        case .restricted: return "制限あり(restricted)"
        case .denied: return "拒否済み(denied) - 端末に既に記録されダイアログは出ません"
        case .authorized: return "許可済み(authorized) - 端末に既に記録されダイアログは出ません"
        @unknown default: return "不明"
        }
    }

    private func startSDK() {
        GADMobileAds.sharedInstance().start { [weak self] _ in
            DispatchQueue.main.async {
                self?.isInitialized = true
            }
        }
    }
}
