import SwiftUI

@main
struct AizuApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light) // 通常画面/合図画面とも白ベース+アクセントカラー前提のデザインのため固定
        }
    }
}
