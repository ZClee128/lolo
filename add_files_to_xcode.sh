#!/bin/bash

# 添加新文件到Xcode项目的说明
# 由于没有安装xcodeproj gem，需要手动在Xcode中添加

echo "📝 需要手动添加以下文件到Xcode项目："
echo ""
echo "========================================="
echo "Models 文件夹:"
echo "========================================="
echo "1. lolo/Models/Report.h"
echo "2. lolo/Models/Report.m"
echo ""
echo "========================================="
echo "Utils 文件夹:"
echo "========================================="
echo "3. lolo/Utils/ReportManager.h"
echo "4. lolo/Utils/ReportManager.m"
echo ""
echo "========================================="
echo "Views/Home 文件夹:"
echo "========================================="
echo "5. lolo/Views/Home/ReportViewController.h"
echo "6. lolo/Views/Home/ReportViewController.m"
echo ""
echo "========================================="
echo "Views 文件夹:"
echo "========================================="
echo "7. lolo/Views/TermsAgreementViewController.h"
echo "8. lolo/Views/TermsAgreementViewController.m"
echo ""
echo "========================================="
echo "如何添加到Xcode："
echo "========================================="
echo ""
echo "1. 打开 Xcode 中的 lolo.xcworkspace"
echo "2. 在左侧项目导航器中，找到对应的文件夹（Models/Utils/Views）"
echo "3. 右键点击文件夹 -> 'Add Files to \"lolo\"...'"
echo "4. 导航到对应的文件"
echo "5. 确保 'Copy items if needed' 是 **未选中** 的"
echo "6. 确保 'Add to targets: lolo' 是 **选中** 的"
echo "7. 点击 'Add'"
echo "8. 对每个文件重复步骤 3-7"
echo ""
echo "或者更简单的方法："
echo "1. 在 Finder 中打开 /Users/lizhicong/Desktop/lolo/lolo/"
echo "2. 将这些 .h 和 .m 文件直接拖拽到 Xcode 对应的文件夹中"
echo "3. 在弹出的对话框中确保 'Add to targets: lolo' 被选中"
echo ""
echo "添加完成后，按 ⌘+B 构建项目"
echo ""

# 检查文件是否存在
echo "========================================="
echo "文件检查："
echo "========================================="

files=(
    "lolo/Models/Report.h"
    "lolo/Models/Report.m"
    "lolo/Utils/ReportManager.h"
    "lolo/Utils/ReportManager.m"
    "lolo/Views/Home/ReportViewController.h"
    "lolo/Views/Home/ReportViewController.m"
    "lolo/Views/TermsAgreementViewController.h"
    "lolo/Views/TermsAgreementViewController.m"
)

all_exist=true
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file - 文件不存在！"
        all_exist=false
    fi
done

echo ""
if [ "$all_exist" = true ]; then
    echo "✅ 所有文件都已创建，可以添加到Xcode了"
else
    echo "❌ 有些文件缺失，请先检查"
fi
