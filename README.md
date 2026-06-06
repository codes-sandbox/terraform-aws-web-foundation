#### 概要
AWSというクラウド上に、インターネットから見えるWebサーバーを自動で立ち上げるための設計図

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
