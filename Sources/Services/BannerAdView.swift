import SwiftUI
import GoogleMobileAds
import UIKit

/// GADBannerView(アダプティブバナー)をSwiftUIで使うためのラッパー。
/// - AdMob SDKの初期化完了(AdMobService.isInitialized)を確認してから生成・ロードする。
/// - rootViewControllerが取得できない(起動直後でnilの)場合はロードを開始せず、
///   updateUIViewで取得できたタイミングで改めてロードする。
/// - 広告ロード失敗時もクラッシュせず、エラー内容をAdMobService.lastBannerErrorに記録するのみ。
struct BannerAdView: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> GADBannerView {
        let width = UIScreen.main.bounds.width
        let size = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width)
        let banner = GADBannerView(adSize: size)
        banner.adUnitID = adUnitID
        banner.delegate = context.coordinator
        // ここではrootViewControllerの設定・load()は行わない(updateUIViewに一本化する)
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {
        guard AdMobService.shared.isInitialized else { return } // SDK初期化完了前は何もしない
        guard !context.coordinator.didLoad else { return }      // 二重ロード防止
        guard let rootVC = rootViewController() else { return } // 起動直後などrootVCが無ければ待つ

        uiView.rootViewController = rootVC
        uiView.load(GADRequest())
        context.coordinator.didLoad = true
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, GADBannerViewDelegate {
        var didLoad = false

        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            DispatchQueue.main.async {
                AdMobService.shared.lastBannerError = nil
            }
        }

        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            didLoad = false // 次回の再描画時に再ロードを試みられるようにする
            DispatchQueue.main.async {
                AdMobService.shared.lastBannerError = error.localizedDescription
            }
        }
    }

    private func rootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?.rootViewController
    }
}
