import GoogleMobileAds
import AppTrackingTransparency

/// AdMob初期化とATT(トラッキング許可)を担当する。
/// 重要: ATT許可ダイアログは、データ収集を伴う処理(広告SDKの初期化)より前に必ず表示すること。
enum AdMobService {
    static let bannerAdUnitID = "ca-app-pub-8174756915786797/4425929739" // aizu_ios_banner (本番)

    private static var didInitialize = false

    static func requestTrackingAndInitialize() {
        guard !didInitialize else { return }
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { _ in
                // 許可/拒否いずれの結果でも、AdMob自体は初期化する(パーソナライズなし広告にフォールバック)
                DispatchQueue.main.async {
                    initializeAdMob()
                }
            }
        } else {
            initializeAdMob()
        }
    }

    private static func initializeAdMob() {
        guard !didInitialize else { return }
        didInitialize = true
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
}
