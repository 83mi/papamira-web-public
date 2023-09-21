class Papamira_Status
  VERSION = '8.4.8'
  def Papamira_Status::Version
    VERSION
  end

  def Papamira_Status::Update
    vfile = File::Stat.new(__FILE__)
    vfile.mtime
  end

  def Papamira_Status::Init
    #'Tue, 22 Nov 2016 10:48:02 +0900'
    '2016-11-22 10:48:02 +0900'
  end
end

class Papamira_Doc
  def Papamira_Doc::ReleaseNote
    data = <<~EOF
      <span class="oi oi-badge text-info"></span> 2023/09/17 Update 8.4.8<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>機能外の細かい調整をしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2023/09/16 Update 8.4.7<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>統計情報のSQLを調整しました!<br>
        <span class="oi oi-moon text-warning"></span>サーバ死活のSQLを調整しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2023/09/15 Update 8.4.5<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>検索APIを変更しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2023/09/14 Update 8.4.4<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>名前検索時の表示限度を外しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2023/09/14 Update 8.4.3<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>検索時のロックを調整しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2023/09/13 Update 8.4.2<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>検索の履歴表示を見直しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2023/09/12 Update 8.4.1<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>検索の履歴を見直しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2023/09/12 Update 8.4.0<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>検索の処理を見直しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2023/09/12 Update 8.3.0<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>一部の処理をworkerに移動してレスポンスを速くしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2023/09/09 Update 8.2.1<br>
      <div class="container">
        <span class="oi oi-pulse text-danger"></span>配布ソースコードを最新にしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2023/09/02 Update 8.2.0<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>検索時に検索履歴から候補を表示するようにしました!<br>
        <span class="oi oi-fire text-primary"></span>検索の履歴にカレンダーを追加しました!<br>
        <span class="oi oi-moon text-warning"></span>検索ワードで最近のキーワードだけを表示するようにしました!<br>
        <span class="oi oi-moon text-warning"></span>検索ワードを検索の履歴に変更しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2023/09/01 Update 8.1.5<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>必要なくなった処理を削除しました!<br>
        <span class="oi oi-moon text-warning"></span>レイアウトを調整しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2023/08/26 Update 8.1.4<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>各サーバのストリーミング時の初期表示されるおたけびの調整しました!<br>
        <span class="oi oi-bug text-danger"></span>音声出力が再生されない不具合を修正しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2023/08/18 Update 8.1.3<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>ALLストリーミング時の初期表示されるおたけびの調整しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2022/11/08 Update 8.1.1<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>chatが重複して表示されるので修正しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2022/11/08 Update 8.1.0<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>レイアウトを変更しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2022/11/07 Update 8.0.8<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>Streamのwebsocketが切れる現象を調整しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2022/11/04 Update 8.0.7<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>起動時のData読み込みを速くしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2022/11/04 Update 8.0.6<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>お問い合わせが必ず届くようにしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2022/11/03 Update 8.0.5<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>チャット周りを調整しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2022/11/02 Update 8.0.4<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>SQL周りのセキュリティ対策しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2022/11/01 Update 8.0.3<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>起動時のキャッシュ周りを調整しました!<br>
        <span class="oi oi-pulse text-danger"></span>配布ソースコードを最新にしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2022/10/30 Update 8.0.2<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>キーワード補完に利用するアイテム辞書を更新しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2022/10/30 Update 8.0.1<br>
      <div class="container">
        <span class="oi oi-bug text-danger"></span>名前のショートカットリンク選択時のメニュー挙動を修正しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2022/10/29 Update 8.0.0<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>各種機能追加とリファクタリングしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2022/10/26 お引越し<br>
      <div class="container">
        <span class="oi oi-pulse text-danger"></span>お引っ越し完了<br>
        <div class="container">
          https://papamira.herokuapp.com から<br>
          https://papamira.onrender.com に引っ越ししました!<br>
        </div>
      </div>
      <br>
    EOF
  end

  def Papamira_Doc::ReleaseNoteOld
    data = <<~EOF
      <span class="oi oi-badge text-info"></span> 2022/09/30 Update 7.5.0<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>Ruby 3.1.2対応<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2021/05/26 Update 7.4.1<br>
      <div class="container">
        <span class="oi oi-bug text-danger"></span>検索時のunescapeを調整しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2021/05/26 Update 7.4.0<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>Ruby 3.0.1対応<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2019/10/16 Update 7.3.0<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>get_webchatのAPIを実装しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2019/10/15<br>
      <div class="container">
        <span class="oi oi-pulse text-danger"></span>開店のお知らせ<br>
        <div class="container">
          またぼちぼちがんばります!<br>
          トップリンクを変更しました!<br>
        </div>
        <br>
        <span class="oi oi-pulse text-danger"></span>ぱぱみら for GUI x86_develライブラリを追加しました!<br>
        <span class="oi oi-pulse text-danger"></span>ぱぱみら for GUIを自分でビルドする手順を追加しました!<br>
        <span class="oi oi-moon text-warning"></span>トップリンクを変更しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2019/01/30<br>
      <div class="container">
        <span class="oi oi-pulse text-danger"></span>ぱぱみら for GUI更新しました!<br>
        <div class="container">
          手が空いたのでGUIだけ手をつけました.<br>
          ぱぱみらを解析するスレ 2PPAPでも建ったらがんばりまする.<br>
        </div>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2019/01/08<br>
      <div class="container">
        <span class="oi oi-pulse text-danger"></span>閉店のお知らせ<br>
        <div class="container">
          あけましておめでとうございます!!<br>
          この度は"ぱぱみら for Web" を閉店することになりました!<br>
          以前からの予定でしたが伸びに伸びてここまで続いておりました.<br>
          気力があればまた開店するかもしれませんが,2018年いっぱいで〆ました.<br>
          <br>
          またどこかでお会いしましょう!<br>
        </div>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/11/13<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>Topのレイアウトを変更しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/11/01 Update 7.2.0<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>ItemDropのAPIを実装しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/10/31<br>
      <div class="container">
        <span class="oi oi-pulse text-danger"></span>ぱぱみら for GUI オール・インインストーラーテスト版を公開しました!<br>
        <span class="oi oi-pulse text-danger"></span>ぱぱみら for GUI オール・インインストーラーテスト版のインストール方法を追記しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/10/30 Update 7.1.4<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>middleを最新にしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/10/23<br>
      <div class="container">
        <span class="oi oi-pulse text-danger"></span>ぱぱみら for GUI v1.0.0をリリースしました!<br>
        <div class="container">
          お手伝い,議論,様々な形で助けていただき無事リリースすることが出来ました!<br>
          ありがとうございます!!<br>
        </div>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/10/22 Update 7.1.3<br>
      <div class="container">
        <span class="oi oi-pulse text-danger"></span>ぱぱみら for GUIのリリース候補をアップデートしました!<br>
        <span class="oi oi-moon text-warning"></span>YourShopのAPIを調整しました!<br>
        <span class="oi oi-fire text-primary"></span>middleを最新にしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/10/17 Update 7.1.2<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>YourShopのAPIを調整しました!<br>
        <span class="oi oi-moon text-warning"></span>ぱぱみら for GUIをアップデートしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/10/16 Update 7.1.1<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>YourShopのAPIを調整しました!<br>
        <span class="oi oi-moon text-warning"></span>ぱぱみら for GUIをアップデートしました!<br>
        <span class="oi oi-moon text-warning"></span>ぱぱみら for GUIをヘルプ更新しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/10/15 Update 7.1.0<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>APIを追加しました!<br>
        <div class="container">
          ぱぱみら for GUIのクラウド露店機能対応のためです<br>
        </div>
        <span class="oi oi-moon text-warning"></span>ぱぱみら for GUIをアップデートしました!<br>
        <span class="oi oi-moon text-warning"></span>ぱぱみら for GUIをヘルプ更新しました!<br>
        <div class="container">
          アンインストール方法を追記しています<br>
        </div>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/10/10 Update 7.0.2<br>
      <div class="container">
        <span class="oi oi-bug text-danger"></span>URL指定の日付ごとの叫びまとめが上手く表示されない不具合を修正しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/10/10 Update 7.0.1<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>middleを最新にしました!<br>
        <span class="oi oi-moon text-warning"></span>ぱぱみら for GUIをアップデートしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/10/03<br>
      <div class="container">
        <span class="oi oi-pulse text-danger"></span>2周年記念で検索範囲を一時的に拡大しました!<br>
        <span class="oi oi-moon text-warning"></span>ぱぱみら for GUIをアップデートしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/10/02<br>
      <div class="container">
        <span class="oi oi-pulse text-danger"></span>ぱぱみら for GUIをマージしました!<br>
        <span class="oi oi-fire text-primary"></span>GUI版のヘルプを追加しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/10/01<br>
      <div class="container">
        <span class="oi oi-pulse text-danger"></span>ぱぱみら for GUIを近々マージします!<br>
        <span class="oi oi-pulse text-danger"></span>検索範囲の制限についてご意見ください!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/09/07 Update 7.0.0<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>最新の構造追従しました!<br>
        <span class="oi oi-fire text-primary"></span>middleを最新にしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/07/09 Update 6.7.2<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>middleを最新にしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/05/22 Update 6.7.1<br>
      <div class="container">
        <span class="oi oi-bug text-danger"></span>検索時の参照用URL[日付毎]の表示修正をしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/05/15 Update 6.7.0<br>
      <div class="container">
        <span class="oi oi-pulse text-danger"></span>開発者が増えました! <br>
        <div class="container">
          今後は新しい方が開発の中心になります!
          私の方は運用保守を行います!
        </div>
        <span class="oi oi-bug text-danger"></span>参照用個別URL作成を修正しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/05/10 Update 6.6.12<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>middleの構成を変更しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/20 Update 6.6.11<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>LiveChatの欄を高解像度用に調整しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/19 Update 6.6.10<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>ストリーミングのonline,offlineステータス表示場所変更しました!<br>
        <span class="oi oi-fire text-primary"></span>各鯖ストリーミングのマッチテキストエリアのフォーカス挙動を変更しました!<br>
        <span class="oi oi-fire text-primary"></span>一部の機能をAPIに移動しました!<br>
        <span class="oi oi-moon text-warning"></span>各鯖ストリーミングのレイアウトを変更しました!<br>
        <span class="oi oi-moon text-warning"></span>リファクタリングしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/15 Update 6.6.9<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>統計情報,グラフのレイアウト調整,処理中のメッセージを追加しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/13 Update 6.6.8<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>雄叫び,ストリーミング等で鯖名を押すとツールが隠れるようにしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/13 Update 6.6.7<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>雄叫び,ストリーミングのレイアウトを更新しました!<br>
        <span class="oi oi-moon text-warning"></span>ヘルプの目次から移動した場合のスクロールを調整しました!<br>
        <span class="oi oi-moon text-warning"></span>公開ソースコードを最新に更新しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/13 Update 6.6.6<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>正規表現ツールに通知キーワードに追記を追加しました!<br>
        <div class="container">
          6 6 6 だみあんだね!!
        </div>
      </div>
      <br>

      <span class="oi oi-badge text-info"></span> 2018/03/12 Update 6.6.5<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>全体のレイアウトを変更しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/12 Update 6.6.4<br>
      <div class="container">
        <span class="oi oi-bug text-danger"></span>ストリーミング表示時にキーワードマッチした場合のエフェクトを修正しました!<br>
        <span class="oi oi-fire text-primary"></span>各鯖ストリーミングに表示ストリーム最大件数設定を追加しました!<br>
        <div class="container">
          環境によっては重くなりそうなため,削除するように調整しています!<br>
        </div>
        <span class="oi oi-fire text-primary"></span>middleの構成を変更しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/12 Update 6.6.3<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>正規表現組み立てツールに数値範囲作成ツールをマージしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/12 Update 6.6.2<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>正規表現組み立てツールを調整しました!(thank you for idea)<br>
        <span class="oi oi-moon text-warning"></span>ヘルプを更新しました!(thank you for report)<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/11 Update 6.6.1<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>正規表現組み立てツールを更新しました!(thank you for idea)<br>
        <span class="oi oi-moon text-warning"></span>ヘルプを更新しました!(thank you for report)<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/09 Update 6.6.0<br>
      <div class="container">
        <span class="oi oi-bug text-danger"></span>ストリーミングの設定類で関係ない項目を非表示としました!<br>
        <span class="oi oi-fire text-primary"></span>統計グラフ情報をAPIにしました!<br>
        <span class="oi oi-fire text-primary"></span>APIページに目次を追加しました!<br>
        <span class="oi oi-moon text-warning"></span>公開ソースコードを最新に更新しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/08 Update 6.5.0<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>内部の統計,グラフ関係を分離しました!<br>
        <div class="container">
          統計用API実装の前段階処理です.たぶんきっと利用には影響はありません<br>
        </div>
        <span class="oi oi-fire text-primary"></span>middleの構成を変更しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/08 Update 6.4.7<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>Liveチャットのレイアウトを変更しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/08 Update 6.4.6<br>
      <div class="container">
        <span class="oi oi-pulse text-danger"></span>イースター・エッグが入りました!<br>
        <span class="oi oi-fire text-primary"></span>バージョンアップ通知をリロードするまで消せなくしました!<br>
        <span class="oi oi-fire text-primary"></span>おたけびのタグとHELPの位置を変更しました!<br>
        <span class="oi oi-fire text-primary"></span>ストリーミングの音量調整レイアウトを変更しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/08 Update 6.4.5<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>ストリーミングの各種設定をモーダルダイアログに移動させました!<br>
        <span class="oi oi-fire text-primary"></span>ナビメニューにID入力欄を作りました!(未実装)<br>
        <span class="oi oi-moon text-warning"></span>トップ等をリファクタリングをしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/07 Update 6.4.4<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>メニューのPPAPがひとりごというようになりました!<br>
        <span class="oi oi-moon text-warning"></span>ストリーミング表示時のエフェクトを調整しました!<br>
        <span class="oi oi-moon text-warning"></span>HTMLの構文を見直しました!<br>
        <span class="oi oi-moon text-warning"></span>公開ソースコードを最新に更新しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/07 Update 6.4.3<br>
      <div class="container">
        <span class="oi oi-pulse text-danger"></span>外部リンクが一部http接続だったので更に修正しました!<br>
        <span class="oi oi-bug text-danger"></span>統計グラフのカレンダーから選択したグラフの色を修正しました!<br>
        <span class="oi oi-fire text-primary"></span>トップ画面を軽くしました!<br>
        <span class="oi oi-fire text-primary"></span>ストリーミング表示時にエフェクトを追加しました!<br>
        <div class="container">
          なんとなく左から右へ光ります<br>
        </div>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/07 Update 6.4.2<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>ストリーミングのクリップボード機能をデフォルトオフにしました!<br>
        <div class="container">
          フリーモードのチェックを追加しています.これがデフォルトオンとなっています<br>
        </div>
        <span class="oi oi-moon text-warning"></span>ヘルプを更新しました!<br>
        <span class="oi oi-moon text-warning"></span>Liveチャットのレイアウトを更新しました!<br>
        <span class="oi oi-moon text-warning"></span>公開ソースコードを最新に更新しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/06 Update 6.4.1<br>
      <div class="container">
        <span class="oi oi-bug text-danger"></span>ユーザ検索語のcookie読み込みを修正しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/06 Update 6.4.0<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>ユーザ検索語からの検索用語の補完対応しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/06 Update 6.3.0<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>タグ検索にクレスト項目を追加しました!<br>
        <span class="oi oi-fire text-primary"></span>ストリーミングにクリップボードへコピー機能,組み立てツールへ送る機能追加しました!<br>
        <div class="container">
          改悪の可能性あるためご意見お待ちしております!<br>
          特に何もなければおたけび機能にもマージ予定<br>
        </div>
        <span class="oi oi-moon text-warning"></span>検索,正規表現組み立てツールアイコンのレイアウト調整しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/06 Update 6.2.7<br>
      <div class="container">
        <span class="oi oi-pulse text-danger"></span>APIのリンクを/devに移動しました!<br>
        <span class="oi oi-fire text-primary"></span>middleの構成を変更しました!<br>
        <span class="oi oi-moon text-warning"></span>おたけび,各鯖ストリーミング,全鯖ストリーミングのリファクタリングをしました!<br>
        <span class="oi oi-moon text-warning"></span>各ページのLiveレイアウトを更新しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/05 Update 6.2.6<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>参照用個別URLのAPI拡張しました!<br>
        <div class="container">
          範囲指定が細かくできるようにしました!<br>
        </div>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/04 Update 6.2.5<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>参照用個別URLのAPI拡張しました!<br>
        <div class="container">
          範囲指定ができるようにしました!<br>
        </div>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/04 Update 6.2.4<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>各鯖おたけびのタグ検索からの名前欄に参照用個別URLを作成するようにしました!<br>
        <span class="oi oi-fire text-primary"></span>各鯖おたけびのカレンダーからの名前欄に参照用個別URLを作成するようにしました!<br>
        <span class="oi oi-moon text-warning"></span>トップのナビメニューのリンクを調整しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/03 Update 6.2.3<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>各鯖おたけびの名前欄に参照用個別URLを作成するようにしました!<br>
        <span class="oi oi-fire text-primary"></span>各鯖おたけびの検索からの名前欄に参照用個別URLを作成するようにしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/02 Update 6.2.2<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>参照用個別URLのURL変更しました!<br>
        <span class="oi oi-moon text-warning"></span>使われてない過去の互換URLを削除しました!<br>
        <span class="oi oi-moon text-warning"></span>スクロールアップ時のアイコンを変更しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/02 Update 6.2.1<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>各鯖ストリーミングの名前欄に参照用個別URLを作成するようにしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/02 Update 6.2.0<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>全鯖ストリーミングの名前欄に参照用個別URLを作成するようにしました!<br>
        <span class="oi oi-fire text-primary"></span>DB記録と各クライアント送信の順序を逆にして叫びのINDEXを取得するようにしました!<br>
        <span class="oi oi-bug text-danger"></span>検索用データがDBに記録されていたので記録しなくしました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/02 Update 6.1.8<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>select_shoutのAPIを追加しました!<br>
        <span class="oi oi-fire text-primary"></span>select_shoutをサイト側で対応しました!<br>
        <div class="container">
          select_shoutのAPIURLを参照しなくても直接アクセスできるようにしています<br>
        </div>
        <span class="oi oi-moon text-warning"></span>公開ソースコードを最新に更新しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/02 Update 6.1.7<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>送受信JSONデータの最適化を行いました!<br>
        <span class="oi oi-fire text-primary"></span>正規表現組み立てツールの1つ戻すボタンの動作範囲を拡張しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/02 Update 6.1.6<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>ストリーミング通知時の文字サイズを大きくしました!<br>
        <span class="oi oi-fire text-primary"></span>ストリーミング通知時に画像も表示するようにしました!<br>
        <span class="oi oi-fire text-primary"></span>必要ないビューファイルを削除しました!<br>
        <span class="oi oi-moon text-warning"></span>各ページのLiveレイアウトを更新しました!<br>
        <span class="oi oi-moon text-warning"></span>検索のプログレスバーを調整しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/01 Update 6.1.5<br>
      <div class="container">
        <span class="oi oi-bug text-danger"></span>正規表現組み立てツールのNOTボタンの動作を更に修正しました!<br>
        <span class="oi oi-moon text-warning"></span>モーダル検索、雄叫び、ストリーミングのレイアウトを調整しました!<br>
        <span class="oi oi-moon text-warning"></span>ストリーミングのボリュームレイアウトを調整しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/01 Update 6.1.4<br>
      <div class="container">
        <span class="oi oi-pulse text-danger"></span>外部リンクが一部http接続だったので修正しました!<br>
        <span class="oi oi-bug text-danger"></span>各ストリーミングでHELPリンクが作動しなかったので修正しました!<br>
        <span class="oi oi-fire text-primary"></span>正規表現組み立てツールにhttps://scriptular.com/のリンクを追加しました!(thank you for idea)<br>
        <span class="oi oi-moon text-warning"></span>正規表現組み立てツールのレイアウトを調整しました!<br>
        <span class="oi oi-moon text-warning"></span>正規表現組み立てツールの最適化をしました!<br>
        <span class="oi oi-moon text-warning"></span>メニューのレイアウトを更新しました!<br>
        <span class="oi oi-moon text-warning"></span>公開ソースコードを最新に更新しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/03/01 Update 6.1.3<br>
      <div class="container">
        <span class="oi oi-bug text-danger"></span>正規表現組み立てツールでprefix.suffixの動作を修正しました!(thank you for report)<br>
        <span class="oi oi-bug text-danger"></span>正規表現組み立てツールのNOTボタンの動作を修正しました! (thank you for report)<br>
        <span class="oi oi-moon text-warning"></span>正規表現組み立てツールのレイアウトを調整しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/02/28 Update 6.1.2<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>各お叫びから別タブで開くHELPリンクを追加<br>
        <span class="oi oi-moon text-warning"></span>各ストリーミングから別タブで開くHELPリンクを追加<br>
        <span class="oi oi-moon text-warning"></span>ヘルプを更新しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/02/28 Update 6.1.1<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>正規表現組み立てツールのレイアウトを調整しました!<br>
        <span class="oi oi-moon text-warning"></span>トップページを更新しました!<br>
        <span class="oi oi-moon text-warning"></span>ヘルプを更新しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/02/28 Update 6.1.0<br>
      <div class="container">
        <span class="oi oi-fire text-primary"></span>正規表現組み立てツールを追加しました!(thank you for idea)<br>
        <div class="container">
          各ストリーミングページの通知条件の横に設置しています
        </div>
        <span class="oi oi-fire text-primary"></span>正規表現用のAND,OR,NOTのプリセットを削除しました!<br>
        <span class="oi oi-bug text-danger"></span>全体の接続人数が減って表示されるので修正しました!<br>
        <span class="oi oi-moon text-warning"></span>ヘルプ更新しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/02/26 Update 6.0.1<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>WebSpeechの辞書を更新しました!<br>
        <div class="container">
          ゲーム内用語に近づけるように調整しています
        </div>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/02/26 Update 6.0.0<br>
      <div class="container">
        <span class="oi oi-pulse text-danger"></span>検索結果に制限を設けました! (thank you BBS peoples)<br>
        <span class="oi oi-bug text-danger"></span>音声再生が上手く再生出来なかった修正をしました!<br>
        <span class="oi oi-fire text-primary"></span>ストリーミングの通知音源を指定できるようにしました!<br>
        <span class="oi oi-fire text-primary"></span>UIモジュールを最新にアップデートしました!<br>
        <span class="oi oi-fire text-primary"></span>ストリーミングに音量調整を実装しました!<br>
        <span class="oi oi-fire text-primary"></span>ストリーミングに通知キーワードのプリセット追加しました!<br>
        <span class="oi oi-fire text-primary"></span>雄叫びのタグを追加しました! (thank you ID:xgXB1Wpo0)<br>
        <span class="oi oi-fire text-primary"></span>WebSpeechAPIに対応しました! (thank you ID:embJzNxg0)<br>
        <span class="oi oi-moon text-warning"></span>ヘルプ更新しました!<br>
        <span class="oi oi-moon text-warning"></span>APIを更新しました!<br>
      </div>
      <br>
      <span class="oi oi-badge text-info"></span> 2018/02/24 Update 5.x.x<br>
      <div class="container">
        <span class="oi oi-moon text-warning"></span>雄叫びにカレンダ機能統合しました!<br>
        <span class="oi oi-moon text-warning"></span>ソースコードを公開しました!<br>
      </div>
    EOF
  end
end
