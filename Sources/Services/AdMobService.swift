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
    static let isAdMobEnabled = false

    static let bannerAdUnitID = "ca-app-pub-8174756915786797/4425929739" // aizu_ios_banner (本番)

    /// GADMobileAds.start()の完了を確認できてから初めてtrueになる。
    /// バナー広告はこれがtrueになるまでロードしない。
    @Published private(set) var isInitialized = false

    private var didStart = false

    private init() {}

    func requestTrackingAndInitialize() {
        guard Self.isAdMobEnabled else { return }
        guard !didStart else { return }
        didStart = true
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] _ in
                // 許可/拒否いずれの結果でも、AdMob自体は初期化する(パーソナライズなし広告にフォールバック)
                DispatchQueue.main.async {
                    self?.startSDK()
                }
            }
        } else {
            startSDK()
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
