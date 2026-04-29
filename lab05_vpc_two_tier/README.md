

graph TB
    User((🌐 Internet))

    subgraph AWS [" AWS Cloud — us-east-2 "]
        IGW[Internet Gateway]

        subgraph VPC ["VPC 10.0.0.0/16"]

            subgraph PUB ["Public Subnet 10.0.1.0/24 — us-east-2a"]
                EC2["🖥️ EC2 Instance\nnginx via user_data\nKey Pair asociada"]
                SG_EC2["Security Group EC2\n✅ SSH :22 — solo mi IP\n✅ HTTP :80 — 0.0.0.0/0"]
            end

            subgraph PRIV ["Private Subnet 10.0.2.0/24 — us-east-2b"]
                RDS[("🗄️ Amazon RDS\nMySQL 8.0")]
                SG_RDS["Security Group RDS\n✅ MySQL :3306 — solo desde EC2"]
            end

        end
    end

    User -->|HTTPS / SSH| IGW
    IGW --> EC2
    EC2 -->|MySQL :3306| RDS
    SG_EC2 -. asociado .-> EC2
    SG_RDS -. asociado .-> RDS





