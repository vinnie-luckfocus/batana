import cv2
import torch
import numpy as np
from pathlib import Path
import matplotlib.pyplot as plt
from matplotlib import animation
from collections import defaultdict, deque
import argparse
import os
import time

class BaseballSwingAnalyzer:
    def __init__(self, model_path='yolov5s.pt', device='cuda' if torch.cuda.is_available() else 'cpu'):
        """
        初始化棒球打击分析器
        
        Args:
            model_path: YOLOv5模型路径
            device: 运行设备
        """
        self.device = device
        # 加载YOLOv5模型
        self.model = torch.hub.load('ultralytics/yolov5', 'custom', path=model_path, force_reload=True)
        self.model.to(device)
        self.model.conf = 0.5  # 检测置信度阈值
        
        # COCO关键点索引 (YOLOv5使用COCO格式)
        self.keypoint_names = [
            'nose', 'left_eye', 'right_eye', 'left_ear', 'right_ear',
            'left_shoulder', 'right_shoulder', 'left_elbow', 'right_elbow',
            'left_wrist', 'right_wrist', 'left_hip', 'right_hip',
            'left_knee', 'right_knee', 'left_ankle', 'right_ankle'
        ]
        
        # 打击相关的关键点索引
        self.swing_keypoints = {
            'left_shoulder': 5,
            'right_shoulder': 6,
            'left_elbow': 7,
            'right_elbow': 8,
            'left_wrist': 9,
            'right_wrist': 10,
            'left_hip': 11,
            'right_hip': 12
        }
        
        # 轨迹存储
        self.trajectories = defaultdict(lambda: deque(maxlen=30))  # 存储最近30帧的轨迹
        self.colors = self.generate_colors()
        
    def generate_colors(self):
        """生成关键点颜色"""
        colors = {}
        keypoint_colors = [
            (255, 0, 0),    # 红色 - 左肩
            (0, 255, 0),    # 绿色 - 右肩
            (255, 255, 0),  # 黄色 - 左肘
            (0, 255, 255),  # 青色 - 右肘
            (255, 0, 255),  # 紫色 - 左手腕
            (0, 0, 255),    # 蓝色 - 右手腕
            (128, 0, 128),  # 深紫色 - 左臀
            (0, 128, 128)   # 深青色 - 右臀
        ]
        
        for i, (name, idx) in enumerate(self.swing_keypoints.items()):
            colors[idx] = keypoint_colors[i % len(keypoint_colors)]
            
        return colors
    
    def detect_pose(self, frame):
        """
        检测单帧中的人体姿态
        
        Args:
            frame: 输入帧
            
        Returns:
            results: 检测结果
        """
        # 转换BGR到RGB
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        
        # 进行推理
        results = self.model(rgb_frame)
        
        return results
    
    def extract_keypoints(self, results, frame_shape):
        """
        提取关键点坐标
        
        Args:
            results: YOLOv5检测结果
            frame_shape: 帧的形状
            
        Returns:
            keypoints_dict: 关键点字典
        """
        keypoints_dict = {}
        
        if len(results.xyxy[0]) > 0:  # 如果检测到人
            # 获取第一个人（假设画面中主要人物是打者）
            person_data = results.xyxy[0][0]
            
            if hasattr(results, 'keypoints') and results.keypoints is not None:
                keypoints = results.keypoints[0]
                
                for idx, name in self.swing_keypoints.items():
                    if idx < len(keypoints):
                        kp = keypoints[idx]
                        if kp[2] > 0.3:  # 关键点置信度阈值
                            x = int(kp[0] * frame_shape[1])
                            y = int(kp[1] * frame_shape[0])
                            keypoints_dict[idx] = (x, y)
        
        return keypoints_dict
    
    def update_trajectories(self, keypoints_dict):
        """
        更新关键点轨迹
        
        Args:
            keypoints_dict: 当前帧的关键点
        """
        for kp_idx, position in keypoints_dict.items():
            self.trajectories[kp_idx].append(position)
    
    def draw_keypoints_and_trajectories(self, frame, keypoints_dict):
        """
        在帧上绘制关键点和轨迹
        
        Args:
            frame: 输入帧
            keypoints_dict: 关键点字典
            
        Returns:
            annotated_frame: 标注后的帧
        """
        annotated_frame = frame.copy()
        
        # 绘制当前关键点
        for kp_idx, (x, y) in keypoints_dict.items():
            color = self.colors.get(kp_idx, (255, 255, 255))
            cv2.circle(annotated_frame, (x, y), 6, color, -1)
            cv2.circle(annotated_frame, (x, y), 8, (255, 255, 255), 2)
            
            # 显示关键点名称
            kp_name = [name for name, idx in self.swing_keypoints.items() if idx == kp_idx][0]
            cv2.putText(annotated_frame, kp_name, (x+10, y-10), 
                       cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
        
        # 绘制轨迹
        for kp_idx, trajectory in self.trajectories.items():
            if len(trajectory) > 1:
                color = self.colors.get(kp_idx, (255, 255, 255))
                
                # 绘制轨迹线
                for i in range(1, len(trajectory)):
                    thickness = max(1, int(3 * (i / len(trajectory))))
                    cv2.line(annotated_frame, trajectory[i-1], trajectory[i], 
                            color, thickness)
                
                # 在轨迹终点添加标记
                if trajectory:
                    last_point = trajectory[-1]
                    cv2.circle(annotated_frame, last_point, 4, (255, 255, 255), -1)
        
        return annotated_frame
    
    def draw_skeleton(self, frame, keypoints_dict):
        """
        绘制骨架连接
        
        Args:
            frame: 输入帧
            keypoints_dict: 关键点字典
            
        Returns:
            frame: 绘制骨架后的帧
        """
        # 骨架连接定义 (起点索引, 终点索引)
        skeleton_connections = [
            (5, 7),   # 左肩-左肘
            (7, 9),   # 左肘-左手腕
            (6, 8),   # 右肩-右肘
            (8, 10),  # 右肘-右手腕
            (5, 6),   # 左肩-右肩
            (5, 11),  # 左肩-左臀
            (6, 12),  # 右肩-右臀
            (11, 12)  # 左臀-右臀
        ]
        
        for start_idx, end_idx in skeleton_connections:
            if start_idx in keypoints_dict and end_idx in keypoints_dict:
                start_point = keypoints_dict[start_idx]
                end_point = keypoints_dict[end_idx]
                
                # 根据关键点类型选择颜色
                color = self.colors.get(start_idx, (200, 200, 200))
                cv2.line(frame, start_point, end_point, color, 3)
        
        return frame
    
    def analyze_swing_mechanics(self, keypoints_dict):
        """
        分析打击力学（基础分析）
        
        Args:
            keypoints_dict: 关键点字典
            
        Returns:
            analysis_text: 分析文本
        """
        analysis_text = []
        
        if 9 in keypoints_dict and 10 in keypoints_dict:  # 两个手腕
            left_wrist = keypoints_dict[9]
            right_wrist = keypoints_dict[10]
            
            # 计算手腕高度差
            height_diff = abs(left_wrist[1] - right_wrist[1])
            if height_diff > 50:
                analysis_text.append(f"手腕高度差: {height_diff}px")
            
            # 计算手腕水平距离
            horizontal_dist = abs(left_wrist[0] - right_wrist[0])
            analysis_text.append(f"手腕间距: {horizontal_dist}px")
        
        return analysis_text
    
    def process_video(self, input_video_path, output_video_path, show_preview=False):
        """
        处理视频文件
        
        Args:
            input_video_path: 输入视频路径
            output_video_path: 输出视频路径
            show_preview: 是否显示实时预览
        """
        # 打开输入视频
        cap = cv2.VideoCapture(input_video_path)
        if not cap.isOpened():
            raise ValueError(f"无法打开视频文件: {input_video_path}")
        
        # 获取视频属性
        fps = cap.get(cv2.CAP_PROP_FPS)
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        
        print(f"视频信息: {width}x{height}, {fps} FPS, 总帧数: {total_frames}")
        
        # 创建视频写入器
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        out = cv2.VideoWriter(output_video_path, fourcc, fps, (width, height))
        
        frame_count = 0
        start_time = time.time()
        
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            
            # 姿态检测
            results = self.detect_pose(frame)
            
            # 提取关键点
            keypoints_dict = self.extract_keypoints(results, frame.shape)
            
            if keypoints_dict:
                # 更新轨迹
                self.update_trajectories(keypoints_dict)
                
                # 绘制关键点和轨迹
                annotated_frame = self.draw_keypoints_and_trajectories(frame, keypoints_dict)
                
                # 绘制骨架
                annotated_frame = self.draw_skeleton(annotated_frame, keypoints_dict)
                
                # 分析打击力学
                analysis_text = self.analyze_swing_mechanics(keypoints_dict)
                
                # 显示分析结果
                for i, text in enumerate(analysis_text):
                    y_position = 30 + i * 25
                    cv2.putText(annotated_frame, text, (10, y_position),
                               cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 255), 2)
            else:
                annotated_frame = frame
            
            # 添加帧计数和信息
            cv2.putText(annotated_frame, f"Frame: {frame_count}/{total_frames}", 
                       (width-200, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
            
            # 写入输出视频
            out.write(annotated_frame)
            
            # 显示预览
            if show_preview:
                cv2.imshow('Baseball Swing Analysis', annotated_frame)
                if cv2.waitKey(1) & 0xFF == ord('q'):
                    break
            
            frame_count += 1
            
            # 显示进度
            if frame_count % 30 == 0:
                elapsed = time.time() - start_time
                progress = (frame_count / total_frames) * 100
                print(f"处理进度: {progress:.1f}% - 已处理 {frame_count}/{total_frames} 帧")
        
        # 释放资源
        cap.release()
        out.release()
        if show_preview:
            cv2.destroyAllWindows()
        
        processing_time = time.time() - start_time
        print(f"处理完成! 输出视频: {output_video_path}")
        print(f"总处理时间: {processing_time:.2f}秒")
        print(f"平均帧率: {frame_count/processing_time:.2f} FPS")

def main():
    """主函数"""
    parser = argparse.ArgumentParser(description='棒球打击动作分析系统')
    parser.add_argument('--input', type=str, required=True, help='输入视频路径')
    parser.add_argument('--output', type=str, default='output_swing_analysis.mp4', help='输出视频路径')
    parser.add_argument('--model', type=str, default='yolov5s.pt', help='YOLOv5模型路径')
    parser.add_argument('--preview', action='store_true', help='显示实时预览')
    
    args = parser.parse_args()
    
    # 检查输入文件是否存在
    if not os.path.exists(args.input):
        print(f"错误: 输入文件不存在: {args.input}")
        return
    
    # 创建分析器
    analyzer = BaseballSwingAnalyzer(model_path=args.model)
    
    try:
        # 处理视频
        analyzer.process_video(
            input_video_path=args.input,
            output_video_path=args.output,
            show_preview=args.preview
        )
        
    except Exception as e:
        print(f"处理过程中发生错误: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()