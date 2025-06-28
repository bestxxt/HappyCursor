# GitHub 编译指南

## 🚀 GitHub Actions 自动编译

### 1. 双架构编译支持

项目现在支持编译两种版本：

- **ARM64**: 仅支持 Apple Silicon (M1/M2/M3)
- **x86_64**: 仅支持 Intel 处理器

### 2. GitHub Actions 工作流

项目配置了两个并行构建任务：

1. **build-arm64**: 构建 Apple Silicon 版本
2. **build-x86_64**: 构建 Intel 版本

**触发条件：**
- 推送到 `main` 或 `master` 分支
- 创建 Pull Request
- 发布 Release

### 3. 配置步骤

#### 3.1 代码签名配置（可选）
如果你有 Apple Developer 账号：

1. 在 `exportOptions.plist` 中替换 `YOUR_TEAM_ID` 为你的 Team ID
2. 在 GitHub 仓库设置中添加代码签名证书

#### 3.2 查看构建结果
1. 推送代码到 GitHub
2. 在仓库页面点击 "Actions" 标签
3. 查看两个构建任务的进度和结果
4. 构建成功后可以下载不同架构的 `.app` 文件

### 4. 本地编译

#### 4.1 使用构建脚本

```bash
# 构建 Apple Silicon 版本 (默认)
./build.sh arm64

# 构建 Intel 版本
./build.sh x86_64

# 默认构建 Apple Silicon 版本
./build.sh
```

#### 4.2 手动编译

```bash
# Apple Silicon 版本
xcodebuild -project HappyCursor.xcodeproj \
           -scheme HappyCursor \
           -configuration Release \
           -destination 'platform=macOS' \
           ONLY_ACTIVE_ARCH=YES \
           ARCHS="arm64" \
           build

# Intel 版本
xcodebuild -project HappyCursor.xcodeproj \
           -scheme HappyCursor \
           -configuration Release \
           -destination 'platform=macOS' \
           ONLY_ACTIVE_ARCH=YES \
           ARCHS="x86_64" \
           build
```

### 5. 架构选择建议

#### 5.1 发布策略
- **推荐**: 同时发布两个版本，用户根据设备选择
- **Apple Silicon 优先**: 默认构建 ARM64 版本

#### 5.2 性能考虑
- **ARM64**: 在 Apple Silicon Mac 上性能最佳，文件较小
- **x86_64**: 在 Intel Mac 上性能最佳，文件较小

### 6. 发布流程

#### 6.1 创建 Release
1. 在 GitHub 仓库页面点击 "Releases"
2. 点击 "Create a new release"
3. 填写版本号和发布说明
4. 上传两个架构的 `.app` 文件

#### 6.2 自动发布（推荐）
1. 推送代码到 GitHub
2. 创建并推送标签：
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. GitHub Actions 会自动编译两个架构并创建 Release

### 7. 故障排除

#### 7.1 常见问题
- **构建失败**：检查 Xcode 版本兼容性
- **签名错误**：确认代码签名配置
- **权限问题**：检查 GitHub Actions 权限设置
- **架构错误**：确认目标架构设置正确

#### 7.2 调试步骤
1. 查看 GitHub Actions 日志
2. 在本地测试构建脚本
3. 检查 Xcode 项目配置
4. 验证架构设置

### 8. 优化建议

#### 8.1 构建优化
- 使用缓存减少构建时间
- 并行构建两个架构
- 优化依赖管理

#### 8.2 发布优化
- 自动版本号管理
- 自动生成更新日志
- 多渠道发布支持
- 架构特定的优化

## 📋 检查清单

- [ ] GitHub Actions 工作流配置完成
- [ ] 双架构编译测试通过
- [ ] 代码签名配置（如需要）
- [ ] 本地构建测试通过
- [ ] Release 流程测试
- [ ] 文档更新完成

## 🔗 相关链接

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Xcode 命令行工具](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)
- [macOS 应用分发](https://developer.apple.com/distribute/)
- [Apple Silicon 开发指南](https://developer.apple.com/documentation/xcode/building-for-apple-silicon) 