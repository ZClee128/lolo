# GitHub Actions 自动打包设置指南

## 📋 概述

使用GitHub Actions可以完全避免设备和IP关联，每次打包都在GitHub的云服务器上进行。

## 🔑 第一步：准备证书和密钥

### 1. 导出Apple Distribution证书（.p12文件）

```bash
# 在Keychain Access中:
# 1. 找到 "Apple Distribution: XXX"
# 2. 右键 -> Export
# 3. 保存为 Certificates.p12
# 4. 设置密码（记住这个密码）
```

### 2. 导出Base64编码

```bash
# 证书
base64 -i Certificates.p12 | pbcopy
# 现在证书的Base64编码已复制到剪贴板

# Provisioning Profile
base64 -i /path/to/your/profile.mobileprovision | pbcopy
```

## 🔐 第二步：配置GitHub Secrets

进入您的GitHub仓库：**Settings → Secrets and variables → Actions → New repository secret**

添加以下secrets：

| Secret名称 | 值 | 说明 |
|-----------|---|------|
| `BUILD_CERTIFICATE_BASE64` | 粘贴证书的Base64 | 从步骤1获取 |
| `P12_PASSWORD` | 证书密码 | 导出.p12时设置的密码 |
| `BUILD_PROVISION_PROFILE_BASE64` | 粘贴Profile的Base64 | Provisioning Profile |
| `KEYCHAIN_PASSWORD` | 随机密码 | 例如：`gh_keychain_2024` |
| `TEAM_ID` | `2A8RZ725U2` | 您的Team ID |
| `APPLE_ID` | `doquangminh0404@icloud.com` | Apple ID |
| `APP_SPECIFIC_PASSWORD` | `ebup-kfjt-bjpr-zppg` | App专用密码 |

### 快速获取Provisioning Profile路径

```bash
# 查找profile
find ~/Library/MobileDevice/Provisioning\ Profiles -name "*.mobileprovision"

# 或在Xcode中下载后
open ~/Library/MobileDevice/Provisioning\ Profiles
```

## 📤 第三步：推送代码到GitHub

```bash
cd /Users/lizhicong/Desktop/Lolo/lolo

# 初始化git（如果还没有）
git init
git add .
git commit -m "Initial commit with GitHub Actions"

# 添加远程仓库
git remote add origin https://github.com/你的用户名/lolo.git

# 推送代码
git branch -M main
git push -u origin main
```

## 🚀 第四步：运行打包

### 方式1：手动触发（推荐）

1. 进入GitHub仓库
2. 点击 **Actions** 标签
3. 选择 **Build and Upload to App Store**
4. 点击 **Run workflow**
5. 选择是否上传到App Store Connect
6. 点击 **Run workflow**

### 方式2：自动触发

编辑 `.github/workflows/build-and-upload.yml`，取消注释：

```yaml
push:
  branches:
    - main
  tags:
    - 'v*'
```

## 📊 运行过程

GitHub Actions会自动：

1. ✅ 使用干净的macOS虚拟机
2. ✅ Clone您的代码
3. ✅ 安装CocoaPods依赖
4. ✅ 清理所有xcuserdata
5. ✅ 导入证书和Profile
6. ✅ 构建Archive（无设备关联）
7. ✅ 导出IPA
8. ✅ 验证IPA清洁度
9. ✅ 上传到App Store Connect
10. ✅ 清理所有临时文件

## 🔍 查看结果

1. 在Actions页面查看运行日志
2. 检查每个步骤的输出
3. 如果上传成功，前往App Store Connect查看

## 💾 下载IPA（可选）

如果需要本地测试：

1. 进入Actions运行详情
2. 向下滚动到 **Artifacts**
3. 下载 `lolo-ipa`

## ⚠️ 常见问题

### Q: 证书导入失败
**A**: 检查P12_PASSWORD是否正确

### Q: Archive失败
**A**: 检查TEAM_ID是否正确，确保Provisioning Profile匹配

### Q: 上传失败
**A**: 确认APP_SPECIFIC_PASSWORD正确，在Apple ID账户生成

### Q: 如何生成App专用密码？
**A**: 
1. 访问 https://appleid.apple.com
2. 登录
3. 安全 → App专用密码 → 生成
4. 复制密码（格式：xxxx-xxxx-xxxx-xxxx）

## 🎯 优势总结

| 项目 | 本地打包 | GitHub Actions |
|------|---------|----------------|
| IP关联 | ❌ 您的IP | ✅ GitHub服务器IP |
| 设备关联 | ❌ 您的Mac | ✅ 虚拟机（无关联） |
| 环境隔离 | ❌ 本地缓存 | ✅ 每次全新环境 |
| 自动化 | ❌ 手动操作 | ✅ 完全自动 |
| 审核风险 | ⚠️ 中等 | ✅ 极低 |

## 📝 维护

**定期更新证书**：
- 证书过期前需要更新Base64编码
- 更新GitHub Secrets中的值

**更新Provisioning Profile**：
- Profile过期或添加设备后需要重新导出
- 更新Base64编码

## 🔒 安全提示

- ✅ 永远不要在代码中hard-code密钥
- ✅ 使用GitHub Secrets存储敏感信息
- ✅ 定期更换App专用密码
- ✅ 限制仓库访问权限

---

完成设置后，每次打包都将在GitHub的云端进行，完全避免与您的设备和IP关联！
