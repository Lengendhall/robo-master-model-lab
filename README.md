# RoboMaster Simulation

基于 Godot 4 的 RoboMaster 仿真项目。

## 1. 项目简介

本项目使用 Godot 构建 RoboMaster 场地与机器人仿真环境，
逐步实现机器人运动、碰撞、局内机制以及视觉通信等功能。

## 2. 主要功能

- RoboMaster 场地与模型加载
- 步兵机器人场景
- 子弹场景与发射功能
- 据点相关场景
- HUD 用户界面
- Godot 与 Python 之间的图像通信
- Godot 与 Python 之间的命令通信

注：以上为项目当前实现方向，具体完成情况以实际运行结果为准。

## 3. 项目结构

```text
robo-master-model-lab/
├── assets/                 # 模型和纹理资源
├── config/                 # 配置文件
├── scenes/                 # Godot 场景
├── scripts/                # GDScript 脚本
├── project.godot           # Godot 项目配置
├── .gitignore              # Git 忽略规则
└── README.md               # 项目说明
```

## 4. 环境要求

- Godot 4.x
- Python 3（用于相关视觉通信功能）

具体版本和依赖项将在项目验证后补充。

## 5. 运行方法

1. 安装 Godot 4。
2. 启动 Godot 项目管理器。
3. 导入本仓库中的 `project.godot`。
4. 等待资源导入完成。
5. 打开项目并运行主场景。

## 6. 通信说明

项目包含图像发送与命令接收相关脚本，
用于实现 Godot 仿真环境与 Python 视觉程序之间的通信。

通信地址、端口、数据格式和启动顺序将在后续文档中说明。

## 7. 项目文档

后续将补充以下文档：

- 操作说明表
- 比赛规则与简化内容
- 视觉通信协议
- 已知问题
- 演示录像与参考资料

## 8. 发布版本

可运行程序计划通过 GitHub Releases 发布，
不直接将大型二进制发布文件放入源码仓库。

