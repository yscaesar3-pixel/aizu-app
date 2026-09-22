import SwiftUI

struct SetupView: View {
    @ObservedObject var settings: UserSettings
    let onStart: () -> Void

    @State private var starting = false

    private let paper = Color(hex: 0xFFFFFF)
    private let ink = Color(hex: 0x2B2B2B)
    private let line = Color(hex: 0xE4E0DB)
    private let labelGray = Color(hex: 0x7A7670)

    var body: some View {
        VStack(spacing: 0) {
            Image("LogoImage")
                .resizable()
                .scaledToFit()
                .frame(height: 46)
                .padding(.top, 28)
                .padding(.bottom, 4)

            Spacer()

            VStack(spacing: 26) {
                // 上限時間ピッカー
                VStack(spacing: 10) {
                    Text("上限時間")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: 0xA6A29D))
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Picker("分", selection: $settings.upperLimitMinutes) {
                            ForEach(0...60, id: \.self) { m in Text("\(m)").tag(m) }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80, height: 100)
                        Text("分").font(.system(size: 15, weight: .semibold)).foregroundColor(labelGray)
                        Picker("秒", selection: $settings.upperLimitSeconds) {
                            ForEach(0...59, id: \.self) { s in Text(String(format: "%02d", s)).tag(s) }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 80, height: 100)
                        Text("秒").font(.system(size: 15, weight: .semibold)).foregroundColor(labelGray)
                    }
                    Text("10秒〜60分の範囲で設定できます")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: 0xB0ADA9))
                }
                .padding(.top, 4)

                // 合図の文字 + カラーテーマ
                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("合図の文字（10文字まで）")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: 0xA6A29D))
                        TextField(UserSettings.defaultSignalText, text: $settings.signalText)
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundColor(Color(hex: 0xE62E2E))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .onChange(of: settings.signalText) { newValue in
                                if newValue.count > UserSettings.maxSignalTextLength {
                                    settings.signalText = String(newValue.prefix(UserSettings.maxSignalTextLength))
                                }
                            }
                    }
                    VStack(spacing: 8) {
                        Text("合図画面の色")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: 0xA6A29D))
                        HStack(spacing: 14) {
                            ForEach(UserSettings.signalColors, id: \.id) { entry in
                                Button(action: { settings.signalColorId = entry.id }) {
                                    Circle()
                                        .fill(entry.color)
                                        .frame(width: 34, height: 34)
                                        .overlay(
                                            Circle()
                                                .stroke(ink, lineWidth: settings.signalColorId == entry.id ? 3 : 0)
                                        )
                                }
                                .accessibilityLabel("合図画面の色: \(entry.id)")
                            }
                        }
                    }
                }
                .padding(18)
                .frame(maxWidth: 320)
                .background(paper)
                .overlay(RoundedRectangle(cornerRadius: 28).stroke(line, lineWidth: 1.5))

                // トグル
                VStack(spacing: 0) {
                    toggleRow(label: "効果音", isOn: $settings.soundOn)
                    Divider().background(line)
                    toggleRow(label: "振動", isOn: $settings.vibrationOn)
                }
                .frame(maxWidth: 320)
            }
            .padding(.horizontal, 24)

            Spacer()

            Button(action: startTapped) {
                Text("スタート")
                    .font(.system(size: 19, weight: .heavy))
                    .foregroundColor(.white)
                    .frame(maxWidth: 320)
                    .padding(.vertical, 19)
                    .background(Color(hex: 0xE62E2E))
                    .cornerRadius(26)
                    .shadow(color: Color(hex: 0xC21F1F), radius: 0, x: 0, y: 4)
            }
            .accessibilityLabel("スタート")
            .padding(.horizontal, 24)
            .padding(.bottom, 8)

            BannerAdView(adUnitID: AdMobService.bannerAdUnitID)
                .frame(height: 50)
        }
        .background(paper.ignoresSafeArea())
    }

    private func toggleRow(label: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Text(label).font(.system(size: 16, weight: .medium)).foregroundColor(ink)
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Color(hex: 0xE62E2E))
                .accessibilityLabel("\(label) ON/OFF")
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 6)
    }

    private func startTapped() {
        guard !starting else { return }
        starting = true
        onStart()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { starting = false }
    }
}
