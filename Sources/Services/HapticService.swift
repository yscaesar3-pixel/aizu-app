import UIKit

/// 強めのハプティクスを短い間隔で複数回連続実行し、体感的に「長め」の振動を表現する。
/// (UIImpactFeedbackGeneratorは単発の短い打撃のみで持続時間を指定できないための対策)
enum HapticService {
    static func playLongImpact(pulses: Int = 4, interval: TimeInterval = 0.14) {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        for i in 0..<pulses {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                generator.impactOccurred()
            }
        }
    }
}
