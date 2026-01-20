# YARA webshell scanner — multi-arch build (Windows x86/x64, Linux amd64, Linux aarch64/信创)

简介
- 使用官方 YARA (libyara + yara CLI) 做 webshell 静态检测，规则来自社区（Yara-Rules + Loki signature-base），并合并去重生成 all_rules_combined.yar。
- 提供 GitHub Actions 自动构建并产出四个二进制 artifact：
  - yara-win-x64.zip
  - yara-win-x86.zip
  - yara-linux-amd64.tar.gz
  - yara-linux-arm64.tar.gz

兼容性与建议
- Windows Server 2003+: 尽量使用 32-bit 或 64-bit 对应二进制（仓库同时构建 x86/x64），并将 MSVC/MinGW 编译选项设置为 _WIN32_WINNT=0x0502。仍需在目标环境（VM）做验证。
- 信创 ARM64: Actions 产物为 aarch64，建议在生产机同版本操作系统上做 smoke test；若不兼容，请在目标发行版上直接编译（仓库提供 build 脚本）。
- 误报：规则合并后请先在测试站点跑一次，收集误报并把路径/哈希加入白名单。

快速开始（GitHub 构建）
1. 新建仓库，把本项目文件保存并 push 到 main。
2. 在仓库 Actions 页面等待 workflow 自动运行或手动触发（Actions → build-yara）。
3. 构建完成后，进入对应 workflow run，下载 artifacts（四个平台）。
4. 在目标服务器上解压并运行：
   - Linux amd64: tar xzvf yara-linux-amd64.tar.gz && ./out/bin/yara -r all_rules_combined.yar /var/www
   - Linux aarch64: tar xzvf yara-linux-arm64.tar.gz && ./out/bin/yara -r all_rules_combined.yar /var/www
   - Windows: unzip yara-win-x64.zip && .\out\bin\yara.exe -r all_rules_combined.yar C:\inetpub\wwwroot
5. 生产流程建议：将规则放在专门的 rules 仓库并使用 CI 定期更新，扫描任务通过 cron / Scheduled Task 周期执行，发现高危匹配自动报警并取证。

如果需要，我可以：
- 帮你把仓库文件替你生成（你复制粘贴到仓库即可）；
- 或帮助合并并清洗 community rules（我可以运行合并脚本并把合并后的 rules 文件展示给你）。
