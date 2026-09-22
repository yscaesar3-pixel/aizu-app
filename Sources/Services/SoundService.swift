import AVFoundation

/// 短い効果音を1回だけ再生する。ループ禁止。
/// AVAudioSessionのカテゴリを.ambientにすることで、端末のサイレントスイッチを尊重する。
final class SoundService {
    static let shared = SoundService()
    private var player: AVAudioPlayer?

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
    }

    func playBeep() {
        guard let url = Bundle.main.url(forResource: "beep", withExtension: "wav") else { return }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = 0
            player?.play()
        } catch {
            // 失敗してもアプリ機能は通常どおり動作させる
        }
    }
}
