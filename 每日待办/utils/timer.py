#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
倒计时计时器
功能：
1. 输入时间和任务名开始倒计时
2. 显示进度条
3. 记录日志
4. 处理中断
5. 任务完成后选择继续或结束
6. 每日学习记录汇总
"""

import time
import datetime
import os
import json
import signal
import sys
from tqdm import tqdm


class TimerApp:
    def __init__(self):
        self.log_dir = r"D:\学习资料\learning_markdown\每日待办\6月\log"
        self.current_task = None
        self.task_start_time = None
        self.task_end_time = None
        self.interrupted = False
        self.total_seconds = 0
        
        # 确保日志目录存在
        os.makedirs(self.log_dir, exist_ok=True)
        
        # 设置信号处理器
        signal.signal(signal.SIGINT, self.signal_handler)
    
    def signal_handler(self, signum, frame):
        """处理 Ctrl+C 中断信号"""
        print("\n\n⚠️  检测到中断信号，正在保存当前任务记录...")
        self.interrupted = True
        self.task_end_time = datetime.datetime.now()
        self.save_task_log()
        self.show_daily_summary()
        print("📝 任务记录已保存，程序已安全退出。")
        sys.exit(0)
    
    def get_log_filename(self, date=None):
        """获取日志文件名"""
        if date is None:
            date = datetime.date.today()
        return os.path.join(self.log_dir, f"{date.strftime('%Y-%m-%d')}.json")
    
    def save_task_log(self):
        """保存任务日志"""
        if not self.current_task or not self.task_start_time:
            return
        
        # 计算实际执行时间
        if self.task_end_time:
            actual_duration = (self.task_end_time - self.task_start_time).total_seconds()
        else:
            actual_duration = (datetime.datetime.now() - self.task_start_time).total_seconds()
        
        task_record = {
            "task_name": self.current_task,
            "start_time": self.task_start_time.strftime("%H:%M:%S"),
            "end_time": (self.task_end_time or datetime.datetime.now()).strftime("%H:%M:%S"),
            "planned_duration": self.total_seconds,
            "actual_duration": actual_duration,
            "completed": not self.interrupted,
            "date": self.task_start_time.strftime("%Y-%m-%d")
        }
        
        # 读取现有日志
        log_file = self.get_log_filename()
        daily_log = []
        if os.path.exists(log_file):
            try:
                with open(log_file, 'r', encoding='utf-8') as f:
                    daily_log = json.load(f)
            except (json.JSONDecodeError, FileNotFoundError):
                daily_log = []
        
        # 添加新记录
        daily_log.append(task_record)
        
        # 保存日志
        with open(log_file, 'w', encoding='utf-8') as f:
            json.dump(daily_log, f, ensure_ascii=False, indent=2)
    
    def format_time(self, seconds):
        """格式化时间显示"""
        hours = int(seconds // 3600)
        minutes = int((seconds % 3600) // 60)
        seconds = int(seconds % 60)
        
        if hours > 0:
            return f"{hours:02d}:{minutes:02d}:{seconds:02d}"
        else:
            return f"{minutes:02d}:{seconds:02d}"
    
    def countdown_timer(self, minutes, task_name):
        """倒计时功能"""
        self.current_task = task_name
        self.task_start_time = datetime.datetime.now()
        self.task_end_time = None
        self.interrupted = False
        self.total_seconds = minutes * 60
        
        print(f"\n🎯 开始任务: {task_name}")
        print(f"⏰ 计划时长: {minutes} 分钟")
        print(f"🕐 开始时间: {self.task_start_time.strftime('%H:%M:%S')}")
        print("=" * 50)
        
        try:
            # 使用 tqdm 显示进度条
            with tqdm(total=self.total_seconds, desc="进度", unit="秒", 
                     bar_format="{desc}: {percentage:3.0f}%|{bar}| {n_fmt}/{total_fmt} [{elapsed}<{remaining}, {rate_fmt}]",
                     ncols=100) as pbar:
                
                for i in range(self.total_seconds):
                    if self.interrupted:
                        break
                    
                    time.sleep(1)
                    pbar.update(1)
                    
                    # 更新进度条描述，显示剩余时间
                    remaining = self.total_seconds - i - 1
                    pbar.set_description(f"⏳ {task_name} - 剩余 {self.format_time(remaining)}")
            
            if not self.interrupted:
                self.task_end_time = datetime.datetime.now()
                print(f"\n🎉 任务完成！")
                print(f"📊 实际用时: {self.format_time((self.task_end_time - self.task_start_time).total_seconds())}")
                self.save_task_log()
                return True
            
        except KeyboardInterrupt:
            # 这里理论上不会执行，因为信号处理器会处理
            self.interrupted = True
            self.task_end_time = datetime.datetime.now()
            self.save_task_log()
            return False
        
        return False
    
    def ask_continue(self):
        """询问是否继续任务"""
        while True:
            choice = input("\n❓ 是否继续这个任务？(y/n): ").lower().strip()
            if choice in ['y', 'yes', '是', '继续']:
                return True
            elif choice in ['n', 'no', '否', '不']:
                return False
            else:
                print("请输入 y/n 或 是/否")
    
    def get_continue_time(self):
        """获取继续任务的时间"""
        while True:
            try:
                minutes = int(input("请输入继续任务的时间（分钟）: "))
                if minutes > 0:
                    return minutes
                else:
                    print("请输入正整数")
            except ValueError:
                print("请输入有效的数字")
    
    def show_daily_summary(self):
        """显示每日汇总"""
        log_file = self.get_log_filename()
        
        if not os.path.exists(log_file):
            print("\n📋 今日暂无任务记录")
            return
        
        try:
            with open(log_file, 'r', encoding='utf-8') as f:
                daily_log = json.load(f)
        except (json.JSONDecodeError, FileNotFoundError):
            print("\n📋 今日暂无任务记录")
            return
        
        if not daily_log:
            print("\n📋 今日暂无任务记录")
            return
        
        print("\n" + "=" * 60)
        print(f"📊 {datetime.date.today().strftime('%Y年%m月%d日')} 学习记录汇总")
        print("=" * 60)
        
        total_planned = 0
        total_actual = 0
        completed_tasks = 0
        
        for i, record in enumerate(daily_log, 1):
            status = "✅ 完成" if record['completed'] else "❌ 中断"
            planned_time = self.format_time(record['planned_duration'])
            actual_time = self.format_time(record['actual_duration'])
            
            print(f"{i:2d}. {record['task_name']}")
            print(f"    时间: {record['start_time']} - {record['end_time']}")
            print(f"    计划: {planned_time} | 实际: {actual_time} | 状态: {status}")
            print()
            
            total_planned += record['planned_duration']
            total_actual += record['actual_duration']
            if record['completed']:
                completed_tasks += 1
        
        print("-" * 60)
        print(f"📈 统计信息:")
        print(f"   任务总数: {len(daily_log)} 个")
        print(f"   完成任务: {completed_tasks} 个")
        print(f"   完成率: {completed_tasks/len(daily_log)*100:.1f}%")
        print(f"   计划总时长: {self.format_time(total_planned)}")
        print(f"   实际总时长: {self.format_time(total_actual)}")
        print(f"   时间利用率: {total_actual/total_planned*100:.1f}%")
        print("=" * 60)
    
    def run(self):
        """主程序运行"""
        print("🕐 欢迎使用倒计时计时器")
        print("提示：使用 Ctrl+C 可以中断当前任务")
        
        while True:
            print("\n" + "-" * 50)
            
            # 获取任务名称
            task_name = input("请输入任务名称: ").strip()
            if not task_name:
                print("任务名称不能为空")
                continue
            
            # 获取时间
            try:
                minutes = int(input("请输入时间（分钟）: "))
                if minutes <= 0:
                    print("时间必须为正整数")
                    continue
            except ValueError:
                print("请输入有效的数字")
                continue
            
            # 开始倒计时
            completed = self.countdown_timer(minutes, task_name)
            
            if completed:
                # 任务完成，询问是否继续
                if self.ask_continue():
                    continue_minutes = self.get_continue_time()
                    # 继续相同任务
                    while True:
                        completed = self.countdown_timer(continue_minutes, task_name)
                        if completed:
                            if self.ask_continue():
                                continue_minutes = self.get_continue_time()
                            else:
                                break
                        else:
                            break
            
            # 询问是否开始新任务
            start_new = input("\n是否开始新任务？(y/n): ").lower().strip()
            if start_new not in ['y', 'yes', '是', '继续']:
                break
        
        # 显示每日汇总
        self.show_daily_summary()
        print("\n👋 感谢使用倒计时计时器，再见！")


def main():
    """主函数"""
    app = TimerApp()
    app.run()


if __name__ == "__main__":
    main()
