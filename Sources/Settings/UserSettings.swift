import SwiftUI
import Combine

/// 上限時間・効果音/振動ON/OFF・合図文言・合図画面の色・自己ベスト反応速度を
/// UserDefaultsに永続化する。進行中のセッション状態はここでは保存しない。
final class UserSettings: ObservableObject {
    static let signalColors: [(id: String, color: Color)] = [
        ("red",    Color(hex: 0xE62E2E)),
        ("blue",   Color(hex: 0x2166D8)),
        ("green",  Color(hex: 0x1E9E51)),
        ("purple", Color(hex: 0x7A3FE0)),
        ("orange", Color(hex: 0xE8791E))
    ]
    static let defaultSignalText = "合図！！"
    static let maxSignalTextLength = 10

    @Published var upperLimitMinutes: Int {
        didSet { defaults.set(upperLimitMinutes, forKey: Keys.minutes) }
    }
    @Published var upperLimitSeconds: Int {
        didSet { defaults.set(upperLimitSeconds, forKey: Keys.seconds) }
    }
    @Published var soundOn: Bool {
        didSet { defaults.set(soundOn, forKey: Keys.soundOn) }
    }
    @Published var vibrationOn: Bool {
        didSet { defaults.set(vibrationOn, forKey: Keys.vibrationOn) }
    }
    @Published var signalText: String {
        didSet {
            let trimmed = String(signalText.prefix(Self.maxSignalTextLength))
            if trimmed != signalText { signalText = trimmed; return }
            defaults.set(signalText, forKey: Keys.signalText)
        }
    }
    @Published var signalColorId: String {
        didSet { defaults.set(signalColorId, forKey: Keys.signalColorId) }
    }
    @Published var bestReactionMs: Double? {
        didSet {
            if let v = bestReactionMs {
                defaults.set(v, forKey: Keys.bestReactionMs)
            } else {
                defaults.removeObject(forKey: Keys.bestReactionMs)
            }
        }
    }

    private let defaults: UserDefaults

    private enum Keys {
        static let minutes = "aizu.minutes"
        static let seconds = "aizu.seconds"
        static let soundOn = "aizu.soundOn"
        static let vibrationOn = "aizu.vibrationOn"
        static let signalText = "aizu.signalText"
        static let signalColorId = "aizu.signalColorId"
        static let bestReactionMs = "aizu.bestReactionMs"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        // 初期値: 上限時間5分00秒、効果音ON、振動ON
        self.upperLimitMinutes = defaults.object(forKey: Keys.minutes) as? Int ?? 5
        self.upperLimitSeconds = defaults.object(forKey: Keys.seconds) as? Int ?? 0
        self.soundOn = defaults.object(forKey: Keys.soundOn) as? Bool ?? true
        self.vibrationOn = defaults.object(forKey: Keys.vibrationOn) as? Bool ?? true
        self.signalText = defaults.string(forKey: Keys.signalText) ?? ""
        self.signalColorId = defaults.string(forKey: Keys.signalColorId) ?? Self.signalColors[0].id
        self.bestReactionMs = defaults.object(forKey: Keys.bestReactionMs) as? Double
    }

    var displaySignalText: String {
        let trimmed = signalText.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? Self.defaultSignalText : trimmed
    }

    var signalColor: Color {
        Self.signalColors.first(where: { $0.id == signalColorId })?.color ?? Self.signalColors[0].color
    }

    var totalUpperLimitSeconds: Double {
        max(10, Double(upperLimitMinutes * 60 + upperLimitSeconds))
    }
}

extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
