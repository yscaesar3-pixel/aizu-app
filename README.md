# 合図！！ (Native SwiftUI版)

App Store Guideline 4.3(a)（スパム判定: 他アプリとバイナリ・メタデータが類似）への対応として、
Capacitor(WebView)ベースから **Native SwiftUI** に全面移行したバージョンです。

## これまでとの違い

- Capacitor / HTML / JS を廃止し、100% Swift + SwiftUIで実装
- AdMob SDKはCocoaPodsではなく、Google公式のSwift Package Managerパッケージを直接使用
- ATT(トラッキング許可)は `AppTrackingTransparency` フレームワークを直接呼び出し（Capacitorプラグイン経由ではない）
- 反応速度計測・カラーテーマ選択・合図文言カスタマイズは前バージョンから引き継ぎ

## プロジェクト構成

`App.xcodeproj` はリポジトリに含めていません。`project.yml`（[XcodeGen](https://github.com/yonaskolb/XcodeGen)の仕様ファイル）から**ビルドの都度Codemagic上で自動生成**されます。ローカルにXcodeがなくても、Codemagic(macOSビルド環境)だけで完結する構成です。

```
project.yml         ← XcodeGenの仕様(プロジェクト定義はここが正)
Info.plist
Assets.xcassets/    ← アプリアイコン・ロゴ画像・アクセントカラー
Resources/
  beep.wav           ← 効果音(生成済み)
Sources/
  AizuApp.swift
  Models/AppState.swift
  Services/
    RandomSignalTimer.swift
    HapticService.swift
    SoundService.swift
    AdMobService.swift
    BannerAdView.swift
  Views/
    ContentView.swift
    SetupView.swift
    WaitingView.swift
    SignalView.swift
  Settings/UserSettings.swift
docs/                ← プライバシーポリシー・サポートページ(GitHub Pages, 変更なし)
codemagic.yaml
```

## ローカルで編集したい場合(Xcodeがある人向け、任意)

```
brew install xcodegen
xcodegen generate
open App.xcodeproj
```

## Codemagicでのビルド

`aizu-native-ios-release` ワークフローが `project.yml` からXcodeプロジェクトを生成し、
`ios_signing`(distribution_type: app_store, bundle_identifier: com.yutaXXX.aizu)で
既存の共有証明書を使って署名、TestFlightへアップロードします。

Bundle ID・AdMob ID・GitHub Pages(プライバシーポリシー/サポート)は前バージョンと同一のものを
引き継いでいるため、Apple Developer / AdMob / GitHub Pages側の追加設定は不要です。
