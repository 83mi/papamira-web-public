# -*- mode: org; coding: utf-8 -*-
ぱぱみら - (P)ぱいなっぽう (A)あっぽう (P)ぽーたる (A)あしすと (mi) みらーはよ (ra) れいどはよ 略したweb site.

* 要件
**  必須アプリケーション
- ruby 2.7.x later
- rake
- gem
- Bundler
- PostgreSQL
- pgroonga
- groonga
- redis

** インストール方法
- $ gem update --system
- $ gem install bundler
-  $ bundle install
-  $ rake db:migrate
    上手く動かなかったら
-    $ bundle exec rake db:setup
-  $ ./run.sh
    上手く動かなかったら
-    $ bundle exec thin start

** ディレクトリ構成
  - app.rb: 本体スクリプト
  - websocket: websocketライブラリ
  - models: DBモデルファイル
  - secret: テスト用環境設定ファイル
  - tools: テストツール
  - views: ビューファイル
  - middle: ダウンロードファイル等
  - db: DB構造ファイル
  - public: 公開静的リンクファイル
  - config: rake config
  - data: 各種辞書等
  - lib: papamira libs


* ライセンスなど
** ライセンス

v7.6.0以前: FreeBSD license
v8.0.3以降: MIT license

Copyright 2022, papamira web

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
(the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
