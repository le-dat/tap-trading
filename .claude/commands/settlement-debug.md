# Command: settlement-debug

## Mô tả
Debug khi settlement không hoạt động đúng — order không được settle dù price đã touch target.

## Checklist debug theo thứ tự

### 1. Kiểm tra Price Feed có đang update
```bash
# Redis: xem giá mới nhất
redis-cli GET "price:BTC/USD"
# Expected: { "value": "65000.12345678", "updatedAt": 1234567890000 }
# Nếu null → worker price chưa chạy hoặc Chainlink event chưa fire

# Worker logs
docker logs tap-worker --tail 100 | grep "price"
```

### 2. Kiểm tra Settlement Worker đang chạy
```bash
docker logs tap-worker --tail 100 | grep "settlement"
# Expected: "Checking 5 open orders" mỗi 100ms
# Nếu không có log → worker process chết, restart
docker restart tap-worker
```

### 3. Kiểm tra Order status trong DB
```sql
SELECT id, asset, target_price, current_price_at_create,
       is_above, expiry, status, tx_hash
FROM orders
WHERE status = 'OPEN'
ORDER BY created_at DESC;
```

### 4. Kiểm tra Contract trực tiếp
```bash
cd apps/contracts
# Kiểm tra order on-chain
yarn hardhat run scripts/check-order.ts --network base-sepolia
# Expected output: { orderId, status, currentPrice, targetPrice }
```

### 5. Kiểm tra RPC connectivity
```typescript
// scripts/check-rpc.ts
const provider = new ethers.JsonRpcProvider(process.env.RPC);
const blockNumber = await provider.getBlockNumber();
console.log('Block:', blockNumber);
const price = await priceFeed.latestRoundData();
console.log('BTC price:', price.answer.toString());
```

### 6. Common causes & fixes

| Symptom | Cause | Fix |
|---------|-------|-----|
| Price không update | Chainlink WS disconnect | Restart worker, check RPC WebSocket |
| Order không settle dù price touched | Worker không chạy | `docker restart tap-worker` |
| Settlement tx reverts | Stale price (>60s old) | Check `updatedAt` trong price cache |
| Settlement tx reverts | Order đã settled | Check idempotency guard trong contract |
| Payout không về ví user | PayoutPool thiếu liquidity | Nạp thêm ETH vào pool contract |
| Gas estimation fails | RPC rate limit | Upgrade RPC plan hoặc đổi provider |
| batchSettle chỉ settle một phần | Gas limit quá thấp | Giảm batch size xuống còn 10-20 orders |

### 7. Simulate settlement manually
```bash
cd apps/contracts
# Gọi settleOrder trực tiếp để test
yarn hardhat run scripts/manual-settle.ts --network base-sepolia -- --orderId 42
```

### 8. Kiểm tra idempotency
```typescript
// Gọi settleOrder 2 lần cùng orderId → lần 2 phải revert với "Already settled"
// Nếu không revert → bug nghiêm trọng, dừng production ngay
const tx1 = await contract.settleOrder(orderId); // OK
const tx2 = await contract.settleOrder(orderId); // phải throw
```

### 9. Emergency: Pause platform nếu settlement bị exploit
```bash
# Gọi pause() trên contract
yarn hardhat run scripts/pause.ts --network base-sepolia
# Sau đó update frontend banner để thông báo users
```
