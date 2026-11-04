# Chipsailing CS9711 指紋スキャナー — Linux ドライバーインストーラー

[English](README.md) | 日本語

Linux で **Chipsailing CS9711** USB 指紋スキャナーを使えるようにする、ワンコマンドのインストーラーです。

標準の `libfprint` はこのチップに対応して**いません**。このプロジェクトは、ディストリビューションの検出、依存パッケージのインストール、コミュニティ版ドライバーの取得、パッチの適用、ビルド、インストール、PAM の設定までをすべて自動で行います。これで、ログイン、ロック画面、sudo で指紋認証が使えるようになります。

## 対応ハードウェア

| 項目 | 値 |
|--------|-------|
| **チップ** | Chipsailing CS9711 |
| **USB ID** | `2541:0236` |
| **形状** | USB ドングル / 内蔵センサー |
| **照合アルゴリズム** | sigfm（小型センサー向けに最適化） |
| **登録** | 1 本の指につき 15 回タッチ |

お使いのデバイスがこれに該当するかは、次のコマンドで確認できます。

```bash
lsusb | grep 2541:0236
```

### 重要: USB 接続の条件

この USB 指紋センサーの接続方法は 2 通りあります。

**方法 1: PC に直接接続** — スキャナーを PC の USB ポート（前面、背面、PC に接続した USB ハブ）に挿します。この方法は常に動作します。

**方法 2: キーボードの USB パススルーポート経由** — 多くのメカニカルキーボード（例: Royal Kludge RK84）には、このスキャナーのような周辺機器を挿せる USB-A ポートが背面にあります。**これはキーボードを USB ケーブルで PC に接続している場合にのみ動作します。** キーボードを Bluetooth や 2.4GHz ワイヤレスで接続している場合、キーボードの USB ポートは機能しません。スキャナーは給電されるので点灯することはありますが、データ接続がないため PC からは認識されません。

| 接続方法 | スキャナーは動作するか |
|---|---|
| スキャナー → PC の USB ポートに直接 | はい（常に） |
| スキャナー → キーボードの USB ポート、キーボードは有線で PC に接続 | はい |
| スキャナー → キーボードの USB ポート、キーボードは Bluetooth | **いいえ** — 給電のみでデータなし |
| スキャナー → キーボードの USB ポート、キーボードは 2.4GHz ワイヤレス | **いいえ** — 給電のみでデータなし |
| スキャナー → **セルフパワーでない** USB ハブ | **動作しない**ことがある — 下記参照 |

`lsusb | grep 2541:0236` で何も表示されない場合は、まず USB の接続を確認してください。

> **電源についての注意:** CS9711 は電源の影響を受けやすいデバイスです。機種によっては、背面ポートや
> 直接接続では正しく認識されるのに、**セルフパワーでない USB ハブ経由では検出されない**ことがあります。
> LED は点灯します（わずかに給電されるため）が、PC からデータデバイスとして認識されません。
> ハブ経由で `lsusb` に表示されない場合は、PC に直接挿すか、**独自の電源を持つハブ**を使ってください。

## 対応ディストリビューション

| ディストリビューション系統 | 動作確認環境 | パッケージマネージャー |
|---------------|-----------|-----------------|
| **Ubuntu / Kubuntu / Debian** | Ubuntu 24.04、**26.04 LTS**、Kubuntu 26.04（Plasma 6.6.4、基準ハードウェア）、Debian 12+ / **13 Trixie** | apt |
| **Linux Mint / Pop!_OS** | **Mint 22**、Mint 21+、Pop 22.04+ | apt |
| **Fedora / RHEL** | **Fedora 44**（+ Rawhide/F45）、RHEL 9+ | dnf |
| **Arch / Manjaro** | Arch、Manjaro、EndeavourOS | pacman |
| **openSUSE** | Tumbleweed、Leap 15.5+ | zypper |

上記のすべてのディストリビューションで、**コンテナ内でのビルドを確認済み**です（v2.0.0、2026-05-30）。開発版ブランチ（Fedora Rawhide/F45、Debian sid、Ubuntu devel）でも問題なくビルドできます。詳しくは `COMPAT-CHECKLIST.md` を参照してください。

`.desktop` ファイルには SVG アイコンが同梱されており、絶対パスで参照しています。そのため、ユーザーのアイコンテーマに依存せず、freedesktop 準拠のすべてのデスクトップ環境（KDE Plasma、GNOME、Cinnamon（Mint）、MATE、XFCE）でランチャー項目が正しく表示されます。

インストーラーはディストリビューションを自動で検出し、適切なパッケージマネージャーを使います。

## クイックスタート（全ディストリビューション共通）

> ⚠️ **Chipsailing CS9711 をお持ちの場合（`lsusb` に `2541:0236` が表示される場合）にのみ実行してください。**
> インストーラーは **CS9711 専用**の `libfprint` を `/usr/local` にビルドします。これはシステムの
> `libfprint` より優先されます。お使いの PC に**別の**指紋リーダー（多くのノート PC に搭載されている
> Goodix、Synaptics、ELAN など）がある場合、これを実行すると**そのリーダーに必要なドライバーが隠れてしまい、
> 動作しなくなります**。CS9711 が検出されない場合、インストーラーは処理を中止します（`CS9711_FORCE=1` で
> 強制実行できます）。`./uninstall.sh` を実行すれば、標準の `libfprint` に完全に戻せます。

```bash
git clone https://github.com/mmhfarooque/chipsailing-cs9711-fingerprint-linux.git
cd chipsailing-cs9711-fingerprint-linux
chmod +x install.sh setup-gui.sh
./install.sh
```

インストーラーは次の処理を行います。

1. Linux ディストリビューションとパッケージマネージャーを検出
2. ビルドに必要な依存パッケージをすべてインストール
3. コミュニティ版ドライバー [archeYR/libfprint-CS9711](https://github.com/archeYR/libfprint-CS9711) を取得
4. **1500ms 再試行間隔パッチ**を適用（下記参照）
5. パッチ適用済みの `libfprint` をビルドしてインストール
6. 指紋認証用に PAM を設定
7. スキャナーが検出されることを確認

続いて指紋を登録します。

```bash
fprintd-enroll          # 15 回のタッチが必要
fprintd-verify          # 動作確認
```

## 完全セットアップ（ドライバー + GUI）

ドライバーのインストール、指紋の登録、GUI マネージャーまでをまとめて行う場合:

```bash
git clone https://github.com/mmhfarooque/chipsailing-cs9711-fingerprint-linux.git
cd chipsailing-cs9711-fingerprint-linux
chmod +x install.sh setup-gui.sh

# ステップ 1: ドライバーをインストール（ソースからビルドし、PAM を設定）
./install.sh

# ステップ 2: 指紋を登録（15 回タッチ）
fprintd-enroll
fprintd-verify

# ステップ 3: GUI マネージャーをインストール（デスクトップショートカットを追加）
./setup-gui.sh

# ステップ 4: 起動 — またはアプリメニューで「CS9711」を検索
python3 cs9711-manager.py
```

セットアップ後は、指紋の登録、再試行の間隔、PAM の設定、ドライバーのメンテナンスをすべて GUI から行えます。

## .deb パッケージでのインストール（Ubuntu / Debian / Mint / Pop!_OS）

ビルド済みの `.deb` パッケージは [Releases](https://github.com/mmhfarooque/chipsailing-cs9711-fingerprint-linux/releases) から入手できます。自分でビルドすることもできます。

```bash
# まずビルドに必要な依存パッケージをインストール
sudo apt install -y git meson ninja-build libfprint-2-dev libglib2.0-dev \
  libgusb-dev libpixman-1-dev libcairo2-dev libssl-dev libopencv-dev \
  doctest-dev gobject-introspection libgirepository1.0-dev fprintd libpam-fprintd

# .deb をビルド
chmod +x packaging/deb/build-deb.sh
./packaging/deb/build-deb.sh

# インストール
sudo apt install ./cs9711-fingerprint_1.0.0_amd64.deb
```

削除: `sudo apt remove cs9711-fingerprint`

## RPM でのインストール（Fedora / RHEL / openSUSE）

```bash
# RPM をビルド
chmod +x packaging/rpm/build-rpm.sh
./packaging/rpm/build-rpm.sh

# インストール（Fedora/RHEL）
sudo dnf install ~/rpmbuild/RPMS/x86_64/cs9711-fingerprint-1.0.0-1.*.rpm

# インストール（openSUSE）
sudo zypper install ~/rpmbuild/RPMS/x86_64/cs9711-fingerprint-1.0.0-1.*.rpm
```

## PKGBUILD でのインストール（Arch / Manjaro / EndeavourOS）

```bash
cd packaging/arch
makepkg -si
```

ヘルパースクリプトを使うこともできます。

```bash
chmod +x packaging/arch/build-arch.sh
./packaging/arch/build-arch.sh
```

## システム更新の後

パッケージマネージャーが `libfprint` を更新すると、パッチ適用済みのライブラリが上書きされることがあります。その場合は次を実行するだけです。

```bash
./reinstall.sh
```

既存のローカルソースから再ビルドするので、再ダウンロードは不要です。

apt、dnf、pacman のシステムでは、`install.sh` が導入する更新ガードがこれを自動で監視し、各トランザクションの後に root 所有のキャッシュからパッチ適用済みライブラリを復元します。

### OpenCV のメジャーアップグレード（例: CachyOS 4.13 → 5.0）

ドライバーはディストリビューションの OpenCV にリンクしています。ディストリビューションが OpenCV の新しい**メジャー**バージョンに移行すると、古いライブラリがなくなり、ドライバーを読み込めなくなります。このとき `lsusb` にはスキャナーが表示されたままなのに、`fprintd` はデバイスがないと報告します。キャッシュからの復元ではこれを直せない（キャッシュも同じ消えたライブラリに対してビルドされている）ため、v2.1.0 から次のように対処しています。

- 更新ガードが読み込めない状態を検出して、なくなったライブラリをログに記録します。GUI のドライバー状態の表示ではそのライブラリ名を示し、**メンテナンス → ドライバーを再ビルド**へ案内します。
- pacman/dnf のフックは `opencv` のトランザクションでも動作します。
- ビルドは OpenCV を `opencv4` → `opencv5` → `opencv` → CMake の `OpenCV` の順に探すので、再ビルドすればディストリビューションが現在提供しているバージョンにリンクされます。

OpenCV のアップグレード後に `./reinstall.sh`（または GUI の再ビルドボタン）を 1 回実行すれば、元どおりに動作します。

## 1500ms 再試行間隔パッチ

上流のドライバーは、スキャンの再試行の間隔に 250ms を使っています。これでは速すぎて、指を置き直す前に再試行の回数を使い切ってしまいます。

このプロジェクトでは `CS9711_DEFAULT_RESET_SLEEP` を `250` から `1500`（ミリ秒）に変更し、スキャンの間に十分な余裕を持たせています。

パッチは `patches/cs9711-retry-delay-1500ms.patch` にあります。

## スキャンキャンセルの修正（上流の testing ブランチより）

`patches/cs9711-scan-cancel-cleanup.patch` は上流のコミット [`256ad3d`](https://github.com/archeYR/libfprint-CS9711/commit/256ad3d70d13e4d6949f09e5018602b352d8f82f)（"Fix CS9711 scan cancellation cleanup"）で、現時点ではドライバーの `cs9711-rebase-testing` ブランチにしかありません。以前はスキャンをキャンセルすると読み取りエラーとして扱われていました。この修正により、スキャンの状態遷移が正常に完了し、停止処理は実行中のスキャンの終了を待ち、スキャン後のコマンドは実際にスキャンが始まった場合にのみ送られるようになります。すべてのビルド経路（`install.sh`、`reinstall.sh`、.deb、Arch、RPM パッケージ）が、既定の `cs9711-rebase` ブランチに対して、再試行間隔パッチの後に `helpers/scan-cancel-patch.sh` 経由でこのパッチを適用します。適用できなくてもビルドは止まりません。将来の上流の変更でパッチが当たらなくなった場合は、警告を表示してパッチなしでビルドを続けます。上流がこの修正を `cs9711-rebase` に取り込めば、自動的に何もしなくなります。

## PAM の設定

v2.0.2 から、指紋認証はグローバルではなく**サービスごと**に設定されます。各認証場所（ログイン画面、ロック画面、`sudo`、polkit）の**それぞれの** PAM サービスファイルに、`# cs9711-managed` の印を付けた `pam_fprintd` の行が追加され、GUI の 4 つのスイッチでそれぞれを個別に切り替えられます。共有の `common-auth`/`system-auth` スタックには何も書き込みません。そのため、`/etc/pam.d/common-auth` がそもそも存在しない **Arch/CachyOS** でも同じように動作します（v2.1.0 で「PAM 設定を適用」をこれに合わせて修正しました。issue #1）。

この行は必ず `sufficient` として追加され、ディストリビューション標準のスタックはすべて保持されます。そのため、**パスワード認証が使えなくなることはありません**。また、すべての変更は元に戻せます（オフにすると、管理対象の行やオーバーライドだけが削除されます）。

既定値:
- **max-tries=7** — パスワードに切り替える前に指紋を 7 回まで試行（標準は 1 回）
- **timeout=30** — すべての試行を合わせて 30 秒（標準は 10 秒）

GUI の「PAM 設定を適用」を押すと、現在有効になっているすべての場所にこれらのオプションを書き込み直します。

## 有効になる機能

- 指紋によるロック画面の解除
- `sudo` の認証（パスワードの前に指紋を求める）
- ログイン画面での指紋認証
- いずれも `libpam-fprintd` を使用

## GUI マネージャー

簡単に設定できる GTK4 の GUI マネージャーが付属しています。

```bash
./setup-gui.sh       # GUI の依存パッケージとデスクトップショートカットをインストール
python3 cs9711-manager.py   # 起動
```

セットアップ後は、アプリランチャーで **「CS9711」** または **「Fingerprint Manager」** を検索して起動することもできます。日本語環境では「CS9711 指紋マネージャー」として表示されます。

GUI では次のことができます。
- 指紋が使える状態かをひと目で確認 — スキャナー、ドライバー、登録済みの指を 1 つの状態カードに表示
- 進捗を表示しながら指紋を登録・削除・照合
- 再試行の間隔を調整（250ms〜3000ms のスライダー）
- PAM の最大試行回数とタイムアウトを設定
- ログイン、ロック画面、`sudo`、polkit それぞれで指紋認証を個別にオン・オフ
- ドライバーの再ビルド・インストール・アンインストール
- GNOME キーリングの自動ロック解除を設定

**レスポンシブなレイアウト（v2.2.0 から）。** 幅に余裕があるときは、左に操作の流れ、右に設定とメンテナンスを置いた 2 列で表示し、880sp より狭くなると 1 列に切り替わります。KDE Plasma、GNOME、Cinnamon の広いウィンドウにも、画面半分に並べたウィンドウや狭いモバイル風のウィンドウにも収まり、以前のバージョンのように延々とスクロールする必要はありません。色を固定していないので、ライトとダークの両方でテーマに従います。

システム更新でドライバーが使えなくなった場合は、GUI がそのことを直接伝えます。上部のバナーになくなったライブラリ名を表示して再ビルドを促すので、USB の不具合かどうかを推測する必要はありません。

**言語。** GUI はデスクトップの言語設定に従い、日本語、ドイツ語、フランス語、スペイン語、簡体字中国語に翻訳されています（それ以外の言語では英語で表示されます）。`setup-gui.sh` と `install.sh` が `po/` の翻訳カタログをスクリプトと同じ場所の `locale/` にコンパイルし、アプリ内の更新機能も更新後にコンパイルし直します。これには gettext の `msgfmt` が必要で、どちらのスクリプトもインストールします。別の言語で試すには: `LANGUAGE=ja python3 cs9711-manager.py`

翻訳を更新または追加するには:

```bash
# GUI の文字列を変更したら、テンプレートを作り直す
xgettext --language=Python --from-code=UTF-8 --keyword=_ --keyword=N_ \
  --keyword=ngettext:1,2 --add-comments=Translators: \
  --package-name=cs9711-manager -o po/cs9711-manager.pot cs9711-manager.py
# 各カタログにマージし、新しい項目・未訳の項目を翻訳する
for l in $(cat po/LINGUAS); do msgmerge --update --backup=none po/$l.po po/cs9711-manager.pot; done
# 新しい言語: msginit -i po/cs9711-manager.pot -l <lang> -o po/<lang>.po を実行し、po/LINGUAS に <lang> を追加
bash helpers/gui-setup.sh   # locale/ にコンパイル
```

デスクトップ項目の名前、説明、キーワードの翻訳は `cs9711-manager.desktop` にあります。

![CS9711 Fingerprint Manager](screenshot.png)

## オプション: GNOME キーリングの自動ロック解除

GNOME キーリングは、既定ではロック解除にパスワードが必要です（指紋でログインすると、この解除が行われません）。キーリングのパスワードを空にして自動でロック解除されるようにするには:

```bash
python3 helpers/set-empty-keyring-password.py
```

## オプション: KDE ウォレットの自動ロック解除

KWallet にも裏返しの同じ問題があります。KWallet はログイン*パスワード*を受け取る PAM モジュールによって開かれるため、指紋でログインするとそこを通らず、ウォレットと、ブラウザーに保存したパスワードなどそれに依存するものすべてがロックされたままになります。@Himalian による [autokdewallet](https://github.com/Himalian/autokdewallet) は、TPM で保護したウォレットのパスワードをログイン時に（指紋ログインでも）自動で解除することで、これをきちんと解決します。[#1](https://github.com/mmhfarooque/chipsailing-cs9711-fingerprint-linux/issues/1) で @popy2k14 さんが、動作している Fedora 44 KDE 環境をもとに推薦してくれたものです。

## ファイル構成

```
.
├── install.sh                   # 汎用インストーラー（ディストリビューションを自動検出）
├── reinstall.sh                 # 簡易再ビルド（システム更新の後）
├── uninstall.sh                 # ドライバーを削除し、標準の libfprint に戻す
├── cs9711-manager.py            # GTK4 GUI マネージャー
├── setup-gui.sh                 # GUI の依存パッケージ + デスクトップショートカットのインストーラー
├── cs9711-manager.desktop       # デスクトップ項目のテンプレート（翻訳した Name/Comment を含む）
├── po/                          # GUI の翻訳（ja, de, fr, es, zh_CN）+ テンプレート
├── patches/
│   ├── cs9711-retry-delay-1500ms.patch
│   └── cs9711-scan-cancel-cleanup.patch   # 上流の 256ad3d（testing ブランチ）
├── helpers/
│   ├── gui-setup.sh             # po/ を locale/ にコンパイルし、デスクトップ項目を書き出す
│   ├── scan-cancel-patch.sh     # スキャンキャンセル修正パッチを適用（全ビルド経路）
│   └── set-empty-keyring-password.py
├── packaging/
│   ├── deb/
│   │   └── build-deb.sh        # .deb パッケージをビルド
│   ├── rpm/
│   │   ├── build-rpm.sh        # RPM パッケージをビルド
│   │   └── cs9711-fingerprint.spec
│   └── arch/
│       ├── build-arch.sh       # Arch パッケージをビルド
│       └── PKGBUILD
├── VERSION                      # 現在のバージョン番号
├── CHANGELOG.md                 # バージョン履歴とリリースノート
├── LICENSE
├── README.md
└── README_ja.md                 # README の日本語訳
```

## トラブルシューティング

| 問題 | 対処 |
|---------|-----|
| `No devices available` | USB の接続を確認してください。`sudo ldconfig` を実行し、`lsusb \| grep 2541` を実行します。 |
| ディストリビューションの OpenCV アップグレード後、`lsusb` には出るが `fprintd` に出ない | ドライバーを読み込めなくなっています（パッチ適用済みの `libfprint-2.so.2` に `ldd` を実行すると、OpenCV のライブラリが `not found` と表示されます）。`./reinstall.sh` を実行してください。v2.1.0 以降は新しい OpenCV にリンクし直します。GUI ではこの状態を *BROKEN — missing libopencv_…* と表示します。 |
| `verify-no-match` | 古い登録データが原因です。`fprintd-delete $(whoami) && fprintd-enroll` を実行してください。 |
| システム更新で動かなくなった | `./reinstall.sh` を実行するか、.deb/.rpm パッケージを入れ直してください。 |
| スキャナーが検出されない | キーボードの USB ポートに挿している場合、キーボードは **USB ケーブルで接続**されている必要があります（Bluetooth やワイヤレスは不可）。上記の「USB 接続の条件」を参照してください。 |
| 再試行をすぐに使い切ってしまう | パッチを確認してください。`cs9711.c` を `grep CS9711_DEFAULT_RESET_SLEEP` して `1500` と表示されるはずです。 |
| 対応していないディストリビューション | 依存パッケージを手動でインストールしてから（ソースを参照）、`install.sh` を実行してください。 |

## 便利なコマンド

```bash
fprintd-enroll                        # 既定の指（右手の人差し指）を登録
fprintd-enroll -f left-index-finger   # 指を指定して登録
fprintd-list $(whoami)                # 登録済みの指を一覧表示
fprintd-verify                        # 指紋をテスト
fprintd-delete $(whoami)              # 登録済みの指紋をすべて削除
lsusb | grep 2541                     # スキャナーが接続されているか確認
```

## クレジット

- **コミュニティ版ドライバー:** [archeYR/libfprint-CS9711](https://github.com/archeYR/libfprint-CS9711)（メンテナンスされているフォーク。元は [ddlsmurf](https://github.com/ddlsmurf) によるもの）

> **インストーラーとドライバーの違い:** このリポジトリは*インストーラー / セットアップ*の層です。ドライバーと指紋の**照合**（例: `verify-no-match`）は上流の [archeYR/libfprint-CS9711](https://github.com/archeYR/libfprint-CS9711) にあります。照合やドライバーの問題はそちらに報告してください。インストール後は、きれいなテンプレートにするために**登録し直して**ください: `fprintd-delete $(whoami) && fprintd-enroll`
- **再試行間隔パッチと Linux への統合:** [mmhfarooque](https://github.com/mmhfarooque)

## 変更履歴

全バージョンの履歴とリリースノートは [CHANGELOG.md](CHANGELOG.md)（英語）を参照してください。

## ライセンス

libfprint ドライバーは LGPL-2.1 でライセンスされています（上流の libfprint と同じ）。このリポジトリのインストーラースクリプトは MIT ライセンスです。
