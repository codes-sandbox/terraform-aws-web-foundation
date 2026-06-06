### 概要
AWSというクラウド上に、インターネットから見えるWebサーバーを自動で立ち上げるための設計図

### 構成
ネットワークの構築
VPC: クラウド上の仮想ネットワーク空間を作る
Subnet: その土地の中に、サーバーを置くための区画を用意する
Internet Gateway & Route Table: インターネットからその区画へつながるゲートウェ）を作り迷わずアクセスできるようにルートテーブルを敷く

セキュリティの設定
Security Group: サーバーの周囲に門番を配置する
Ingress (80番ポート): 誰でもWebサイトを見られるように80番ポートだけをフルオープンにする
Egress (全許可): サーバーがアップデートなどで外に情報を出しに行くための通信を許可する

Webサーバーの構築
EC2 Instance: Amazon Linux 2023という最新のOSを搭載した仮想サーバーを建てる
User Data: サーバーが立ち上がった瞬間に自動的にWebサーバーソフト (Apache)をインストールし自動起動設定を行い「Hello from Terraform Web Server!」という最初のWebページを設置するスクリプトが動く

### CI/CD Pipeline Flow
GitHubへのPushをトリガーに、自動検証パイプラインが実行される流れ。
```mermaid
graph LR
    Push[Git Push] --> Actions[GitHub Actions]
    subgraph Validation
        Actions --> Init[terraform init]
        Init --> Validate[terraform validate]
    end
    Validate --> Pass((Success))
    Validate -- Error --> Fail((Failed/Notify))

### Architecture Overview
```mermaid
graph TD
    User((User)) --> CF(CloudFront)
    CF --> ALB(ALB)
    subgraph VPC
        ALB --> ASG(ASG/EC2)
        ASG --> RDS[(RDS)]
    end
    S3[(S3)] -.-> CF
