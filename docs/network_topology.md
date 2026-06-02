# 3-AZ VPC Network Topology Diagram

## Overall Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        VPC: 10.0.0.0/16                                  │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                    Internet Gateway                               │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                           │                                              │
│                           │                                              │
│  ┌────────────────────────┼──────────────────────────────────────────┐  │
│  │                        │                                          │  │
│  │              AZ1       │         AZ2           │        AZ3       │  │
│  │  ┌─────────────────────┴──┐  ┌────────────────┴──┐  ┌────────────┴──┐ │
│  │  │  Public Subnet         │  │  Public Subnet    │  │  Public Subnet│ │
│  │  │  10.0.1.0/24           │  │  10.0.2.0/24      │  │  10.0.3.0/24  │ │
│  │  │  (NAT Gateway)         │  │  (NAT Gateway)    │  │  (NAT Gateway)│ │
│  │  └─────────────────────┬──┘  └────────────────┬──┘  └────────────┬──┘ │
│  │                        │                      │                   │     │
│  │                        │ NAT                  │ NAT               │ NAT │
│  │                        ▼                      ▼                   ▼     │
│  │  ┌─────────────────────────┐  ┌─────────────────────────┐  ┌──────────┐│
│  │  │  Private Subnet         │  │  Private Subnet         │  │ Private  ││
│  │  │  10.0.101.0/24          │  │  10.0.102.0/24          │  │ 10.0.103.││
│  │  │  (App Servers)          │  │  (App Servers)          │  │ (App Srv)││
│  │  └─────────────────────────┘  └─────────────────────────┘  └──────────┘│
│  │                                                                          │
│  └──────────────────────────────────────────────────────────────────────────┘
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

## CIDR Allocation Details

### VPC
- **CIDR**: `10.0.0.0/16` (65,536 IP addresses)

### Public Subnets - Total 3
```
├── AZ1: us-east-1a
│   └── 10.0.1.0/24  - Public Subnet (NAT Gateway)
├── AZ2: us-east-1b
│   └── 10.0.2.0/24  - Public Subnet (NAT Gateway)
└── AZ3: us-east-1c
    └── 10.0.3.0/24  - Public Subnet (NAT Gateway)
```

### Private Subnets - Total 3
```
├── AZ1: us-east-1a
│   └── 10.0.101.0/24 - Private Subnet (Application Servers)
├── AZ2: us-east-1b
│   └── 10.0.102.0/24 - Private Subnet (Application Servers)
└── AZ3: us-east-1c
    └── 10.0.103.0/24 - Private Subnet (Application Servers)
```

## Traffic Flow Diagram

### Outbound Traffic (Private → Internet)
```
Private Subnet (App Servers)
    ↓
NAT Gateway (corresponding AZ's public subnet)
    ↓
Internet Gateway
    ↓
Internet
```

### Inbound Traffic (Internet → Public)
```
Internet
    ↓
Internet Gateway
    ↓
Public Subnet (Load Balancer)
    ↓
Private Subnet (Application)
```

### AZ-to-AZ Traffic
```
Private Subnet AZ1 ←→ Private Subnet AZ2 ←→ Private Subnet AZ3
         (through VPC internal routing, no NAT required)
```

## High Availability Notes

### Single AZ Failure Scenario
```
AZ1 failure → traffic automatically switches to AZ2 and AZ3
AZ2 failure → traffic automatically switches to AZ1 and AZ3
AZ3 failure → traffic automatically switches to AZ1 and AZ2
```

### NAT Gateway Redundancy
- Each AZ has its own NAT Gateway
- Failure of one AZ does not affect internet access in other AZs
- Supports cross-AZ disaster recovery

## Expansion Suggestions

### Reserved Space
Currently using approximately 8,192 IP addresses, with ample space available for:
- Additional subnets
- Larger subnets (/23 or /22)
- VPC Peering
- Transit Gateway attachments

### Future Expansion Areas
```
10.0.200.0/20 -可用于DMZ area
10.0.220.0/20 -可用于database dedicated area
10.0.240.0/20 -可用于test/dev environment
```

