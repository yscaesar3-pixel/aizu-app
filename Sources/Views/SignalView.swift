import SwiftUI

struct SignalView: View {
    let text: String
    let backgroundColor: Color
    let onTap: () -> Void

    @State private var tapGuard = false

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            Text(text)
                .font(.system(size: fontSize(for: text), weight: .black))
                .foregroundColor(.white)
                .tracking(1)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.3)
                .lineLimit(2)
                .padding(.horizontal, 16)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            guard !tapGuard else { return } // 連打で複数抽選されないようガード
            tapGuard = true
            onTap()
        }
        .onAppear { tapGuard = false }
        .accessibilityLabel("タップして合図を閉じる")
    }

    private func fontSize(for text: String) -> CGFloat {
        let len = max(1, text.count)
        // 画面内に収まる最大級サイズを優先しつつ、長い文字列では縮小する
        let screenWidth = UIScreen.main.bounds.width
        let base = screenWidth * 0.22
        let capped = min(base, 96)
        let scaled = capped * min(1.0, 4.0 / CGFloat(len))
        return max(40, scaled)
    }
}
