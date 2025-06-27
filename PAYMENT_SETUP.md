# HappyCursor 支付功能设置指南

本指南将帮助您设置 HappyCursor 的 Stripe 支付功能。

## 目录

1. [Stripe 账户设置](#stripe-账户设置)
2. [客户端配置](#客户端配置)
3. [服务器端配置](#服务器端配置)
4. [测试支付流程](#测试支付流程)
5. [生产环境部署](#生产环境部署)

## Stripe 账户设置

### 1. 创建 Stripe 账户

1. 访问 [Stripe 官网](https://stripe.com) 注册账户
2. 完成账户验证和激活
3. 获取测试密钥和发布密钥

### 2. 创建产品和服务

1. 在 Stripe Dashboard 中创建产品
2. 设置订阅价格（例如：¥19.99/月）
3. 记录产品 ID 和价格 ID

### 3. 配置 Webhook

1. 在 Stripe Dashboard 中设置 Webhook 端点
2. 添加以下事件：
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
3. 记录 Webhook 签名密钥

## 客户端配置

### 1. 更新 PaymentManager.swift

在 `HappyCursor/PaymentManager.swift` 中更新以下配置：

```swift
// 替换为您的 Stripe 发布密钥
private let publishableKey = "pk_test_your_actual_publishable_key"

// 替换为您的服务器 URL
private let apiBaseURL = "https://your-server.com/api"

// 替换为您的价格 ID
"priceId": "price_your_actual_price_id"
```

### 2. 添加 Stripe SDK

在 Xcode 项目中添加 Stripe iOS SDK：

1. 打开 Xcode 项目
2. 选择 File > Add Package Dependencies
3. 输入 URL: `https://github.com/stripe/stripe-ios`
4. 选择版本并添加

### 3. 配置 URL Scheme

在 Xcode 项目中配置 URL Scheme：

1. 选择项目 > Info > URL Types
2. 添加新的 URL Type
3. URL Schemes: `happycursor`
4. Identifier: `com.yourcompany.happycursor`

## 服务器端配置

### 1. 安装依赖

```bash
cd server
npm install
```

### 2. 配置环境变量

复制 `env.example` 为 `.env` 并填写您的配置：

```bash
cp env.example .env
```

编辑 `.env` 文件：

```env
STRIPE_SECRET_KEY=sk_test_your_actual_secret_key
STRIPE_PUBLISHABLE_KEY=pk_test_your_actual_publishable_key
STRIPE_WEBHOOK_SECRET=whsec_your_actual_webhook_secret
PORT=3000
NODE_ENV=development
```

### 3. 启动服务器

```bash
npm run dev
```

服务器将在 `http://localhost:3000` 启动。

## 测试支付流程

### 1. 使用测试卡号

Stripe 提供测试卡号：

- Visa: `4242424242424242`
- Mastercard: `5555555555554444`
- 任何未来日期作为过期日期
- 任何 3 位数字作为 CVC

### 2. 测试流程

1. 启动 HappyCursor 应用
2. 点击"升级到 Pro"
3. 填写测试卡信息
4. 完成支付流程
5. 验证订阅状态

### 3. 查看测试数据

在 Stripe Dashboard 的测试模式中查看：
- 客户信息
- 订阅状态
- 支付记录
- Webhook 事件

## 生产环境部署

### 1. 切换到生产模式

1. 在 Stripe Dashboard 中切换到生产模式
2. 获取生产环境的密钥
3. 更新客户端和服务器配置

### 2. 服务器部署

推荐使用以下平台部署服务器：

- **Vercel**: 适合无服务器部署
- **Heroku**: 简单易用
- **AWS/GCP**: 企业级部署
- **DigitalOcean**: 经济实惠

### 3. 域名和 SSL

1. 配置自定义域名
2. 启用 HTTPS
3. 更新客户端中的 API URL

### 4. 数据库集成

生产环境建议使用数据库存储订阅信息：

```javascript
// 示例：使用 PostgreSQL
const { Pool } = require('pg');
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// 存储订阅信息
async function saveSubscription(customerId, subscriptionId, status) {
  const query = `
    INSERT INTO subscriptions (customer_id, subscription_id, status, created_at)
    VALUES ($1, $2, $3, NOW())
    ON CONFLICT (customer_id) DO UPDATE SET
    subscription_id = $2, status = $3, updated_at = NOW()
  `;
  await pool.query(query, [customerId, subscriptionId, status]);
}
```

## 安全考虑

### 1. 密钥管理

- 永远不要在客户端代码中包含密钥
- 使用环境变量存储敏感信息
- 定期轮换密钥

### 2. Webhook 验证

- 始终验证 Webhook 签名
- 使用 HTTPS 端点
- 实现幂等性处理

### 3. 错误处理

- 实现完善的错误处理
- 记录详细的日志
- 设置监控和告警

## 常见问题

### Q: 支付失败怎么办？

A: 检查以下项目：
- 网络连接
- Stripe 密钥配置
- 服务器状态
- 银行卡信息

### Q: 如何取消订阅？

A: 用户可以通过以下方式取消：
- 应用内取消
- 访问 Stripe 客户门户
- 联系客服

### Q: 如何处理退款？

A: 在 Stripe Dashboard 中处理退款，或通过 API 实现自动退款逻辑。

## 支持

如果您在设置过程中遇到问题，请：

1. 查看 [Stripe 文档](https://stripe.com/docs)
2. 检查服务器日志
3. 联系技术支持

---

**注意**: 本指南仅用于开发目的。生产环境部署前请确保遵循所有安全最佳实践。 