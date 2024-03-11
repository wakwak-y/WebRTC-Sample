# WebRTC Sample App

<br>

## Signalingサーバーの起動
WebRTC-Server配下で下記コマンドを実行

```bash
$ docker-copmose build
$ docker-compose up -d
```

<br>

## クライアントのビルド
WebRTC-iOSプロジェクトの`Confg.swift`の`defaultSignalingServerUrl`のホスト名を自分のIPアドレスに書き換える 。

