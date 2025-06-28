# GitHub 编译指南

## 🚀 GitHub Actions 自动编译

### 1. 设置 GitHub Actions

项目已经配置了 GitHub Actions 工作流，位于 `.github/workflows/build.yml`。

**触发条件：**
- 推送到 `main` 或 `master` 分支
- 创建 Pull Request
- 发布 Release

### 2. 配置步骤

#### 2.1 代码签名配置（可选）
如果你有 Apple Developer 账号：

1. 在 `exportOptions.plist` 中替换 `YOUR_TEAM_ID` 为你的 Team ID
2. 在 GitHub 仓库设置中添加代码签名证书

#### 2.2 查看构建结果
1. 推送代码到 GitHub
2. 在仓库页面点击 "Actions" 标签
3. 查看构建进度和结果
4. 构建成功后可以下载 `.app` 文件

### 3. 本地编译

#### 3.1 使用构建脚本
```bash
./build.sh
```

#### 3.2 手动编译
```bash
# 清理项目
xcodebuild clean -project HappyCursor.xcodeproj -scheme HappyCursor

# 编译项目
xcodebuild -project HappyCursor.xcodeproj \
           -scheme HappyCursor \
           -configuration Release \
           -destination 'platform=macOS' \
           build
```

### 4. 发布流程

#### 4.1 创建 Release
1. 在 GitHub 仓库页面点击 "Releases"
2. 点击 "Create a new release"
3. 填写版本号和发布说明
4. 上传编译好的 `.app` 文件

#### 4.2 自动发布（推荐）
1. 推送代码到 GitHub
2. 创建并推送标签：
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. GitHub Actions 会自动编译并创建 Release

### 5. 故障排除

#### 5.1 常见问题
- **构建失败**：检查 Xcode 版本兼容性
- **签名错误**：确认代码签名配置
- **权限问题**：检查 GitHub Actions 权限设置

#### 5.2 调试步骤
1. 查看 GitHub Actions 日志
2. 在本地测试构建脚本
3. 检查 Xcode 项目配置

### 6. 优化建议

#### 6.1 构建优化
- 使用缓存减少构建时间
- 并行构建多个配置
- 优化依赖管理

#### 6.2 发布优化
- 自动版本号管理
- 自动生成更新日志
- 多渠道发布支持

## 📋 检查清单

- [ ] GitHub Actions 工作流配置完成
- [ ] 代码签名配置（如需要）
- [ ] 本地构建测试通过
- [ ] Release 流程测试
- [ ] 文档更新完成

## 🔗 相关链接

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Xcode 命令行工具](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)
- [macOS 应用分发](https://developer.apple.com/distribute/) 