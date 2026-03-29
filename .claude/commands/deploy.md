# Command: deploy

## Mô tả
Deploy Tap Trading platform lên production — smart contracts trên BASE Mainnet + backend/frontend.

## Pre-deploy checklist
```
[ ] Tất cả tests pass: yarn test (tất cả workspaces)
[ ] Contract đã được internal review kỹ
[ ] .env production đã cấu hình đúng (RPC mainnet, ADMIN_PRIVATE_KEY)
[ ] ADMIN_PRIVATE_KEY wallet có đủ ETH để pay gas (tối thiểu 0.1 ETH)
[ ] PayoutPool contract có đủ liquidity
[ ] Redis và Postgres production backup đã setup
[ ] Monitoring + alert đã configure (uptime, worker heartbeat)
[ ] Rate limiting đã enable trên Nginx
```

## Bước 1: Deploy Smart Contracts lên BASE Mainnet
```bash
cd apps/contracts

# Final test
yarn hardhat test

# Deploy lên mainnet (cẩn thận — không rollback được)
yarn hardhat run scripts/deploy.ts --network base

# Verify source code trên Basescan
yarn hardhat verify --network base DEPLOYED_TAP_ORDER_ADDRESS
yarn hardhat verify --network base DEPLOYED_PAYOUT_POOL_ADDRESS

# Fund PayoutPool với initial liquidity
yarn hardhat run scripts/fund-pool.ts --network base -- --amount 1.0
```

> ⚠ Sau khi deploy xong, **copy contract addresses** vào:
> - `apps/backend/.env` (CONTRACT_TAP_ORDER, CONTRACT_PAYOUT_POOL)
> - `apps/frontend/.env.local` (NEXT_PUBLIC_TAP_ORDER_ADDRESS)

## Bước 2: Deploy Backend (Docker)
```bash
# Build image
docker build -t tap-backend:latest ./apps/backend

# Tag với commit SHA để rollback dễ
GIT_SHA=$(git rev-parse --short HEAD)
docker tag tap-backend:latest your-registry/tap-backend:$GIT_SHA
docker tag tap-backend:latest your-registry/tap-backend:latest

# Push lên registry
docker push your-registry/tap-backend:$GIT_SHA
docker push your-registry/tap-backend:latest

# Deploy lên server
ssh deploy@your-server './deploy.sh'

# Verify
curl https://api.your-domain.com/health
```

## deploy.sh (chạy trên server)
```bash
#!/bin/bash
set -e

echo "=== Tap Trading Deploy ==="
echo "Time: $(date)"

echo "Pulling latest images..."
docker compose pull

echo "Running migrations..."
docker compose run --rm backend yarn migration:up

echo "Restarting services (zero-downtime)..."
docker compose up -d --no-deps --scale backend=2 backend
sleep 10
docker compose up -d --no-deps --scale backend=1 backend

docker compose up -d --no-deps worker

echo "Health check..."
sleep 5
curl -f http://localhost:3001/health || (echo "HEALTH CHECK FAILED" && exit 1)

echo "=== Deploy complete ==="
```

## Bước 3: Deploy Frontend (Vercel)
```bash
cd apps/frontend

# Set production env vars trên Vercel dashboard trước, rồi:
vercel --prod

# Hoặc nếu dùng Vercel CLI với env:
vercel deploy --prod \
  --env NEXT_PUBLIC_API_URL=https://api.your-domain.com \
  --env NEXT_PUBLIC_CHAIN_ID=8453
```

## Post-deploy verification
```
[ ] GET https://api.your-domain.com/health → { status: "ok" }
[ ] WebSocket connect từ browser → không lỗi
[ ] Price feed: worker logs hiện "price updated" mỗi ~30s
[ ] Tạo 1 test order nhỏ với test wallet (0.001 ETH stake)
[ ] Chờ expiry → verify order tự động settled đúng
[ ] Basescan: xem contract events emit đúng
[ ] Check PayoutPool balance còn đủ
```

## Rollback procedure

### Rollback Backend
```bash
# Trên server
docker compose down
# Đổi image tag trong docker-compose.yml về SHA trước đó
docker compose up -d
```

### Rollback Contract
```
⚠ KHÔNG rollback được smart contract trên blockchain.
Nếu có bug nghiêm trọng:
1. Gọi contract.pause() ngay lập tức
2. Deploy contract mới với fix
3. Update địa chỉ trong backend + frontend
4. Migrate open orders sang contract mới (nếu cần)
```

### Rollback Frontend
```bash
# Trên Vercel dashboard: Deployments → chọn version cũ → Redeploy
# Hoặc CLI:
vercel rollback
```
