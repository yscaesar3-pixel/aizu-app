import SwiftUI

struct WaitingView: View {
    let lastReactionMs: Double?
    let bestReactionMs: Double?
    let onEnd: () -> Void
    @ObservedObject private var adMob = AdMobService.shared

    private let paper = Color(hex: 0xFFFFFF)
    private let line = Color(hex: 0xE4E0DB)

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onEnd) {
                    Text("終了")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: 0x6E6A64))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(paper)
                        .overlay(Capsule().stroke(line, lineWidth: 1.5))
                        .clipShape(Capsule())
                }
                .accessibilityLabel("終了")
                Spacer()
            }
            .padding(16)

            Spacer()
            VStack(spacing: 14) {
                Text("待機中…")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: 0x9A968F))
                    .tracking(2)

                if lastReactionMs != nil || bestReactionMs != nil {
                    Text(reactionText)
                        .font(.system(size: 13))
                        .foregroundColor(Color(hex: 0xB0ADA9))
                }
            }
            Spacer()

            BannerAdView(adUnitID: AdMobService.bannerAdUnitID)
                .frame(height: 50)
        }
        .background(paper.ignoresSafeArea())
    }

    private var reactionText: String {
        var parts: [String] = []
        if let last = lastReactionMs {
            parts.append(String(format: "反応: %.3f秒", last / 1000))
        }
        if let best = bestReactionMs {
            parts.append(String(format: "ベスト: %.3f秒", best / 1000))
        }
        return parts.joined(separator: "　")
    }
}
