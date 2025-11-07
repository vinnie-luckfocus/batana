import cv2
import mediapipe as mp
import numpy as np
from collections import defaultdict, deque
import os

class AdvancedBaseballSwingAnalyzer:
    def __init__(self, trajectory_length=30):
        """
        改进的棒球打击分析器，解决髋关节识别问题
        """
        # 初始化MediaPipe Pose
        self.mp_pose = mp.solutions.pose
        self.mp_drawing = mp.solutions.drawing_utils
        self.mp_drawing_styles = mp.solutions.drawing_styles
        
        # 创建Pose模型
        self.pose = self.mp_pose.Pose(
            static_image_mode=False,
            model_complexity=1,
            smooth_landmarks=True,
            enable_segmentation=False,
            smooth_segmentation=True,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        )
        
        # 定义打击相关的关键点
        self.swing_keypoints = {
            'left_shoulder': self.mp_pose.PoseLandmark.LEFT_SHOULDER,
            'right_shoulder': self.mp_pose.PoseLandmark.RIGHT_SHOULDER,
            'left_elbow': self.mp_pose.PoseLandmark.LEFT_ELBOW,
            'right_elbow': self.mp_pose.PoseLandmark.RIGHT_ELBOW,
            'left_wrist': self.mp_pose.PoseLandmark.LEFT_WRIST,
            'right_wrist': self.mp_pose.PoseLandmark.RIGHT_WRIST,
            'left_hip': self.mp_pose.PoseLandmark.LEFT_HIP,
            'right_hip': self.mp_pose.PoseLandmark.RIGHT_HIP,
            'left_knee': self.mp_pose.PoseLandmark.LEFT_KNEE,
            'right_knee': self.mp_pose.PoseLandmark.RIGHT_KNEE
        }
        
        # 存储轨迹点
        self.trajectories = defaultdict(lambda: deque(maxlen=trajectory_length))
        
        # 关键点颜色
        self.keypoint_colors = {
            'left_shoulder': (0, 255, 0),      # 绿色
            'right_shoulder': (0, 255, 255),   # 黄色
            'left_elbow': (255, 0, 0),         # 蓝色
            'right_elbow': (255, 0, 255),      # 粉色
            'left_wrist': (0, 0, 255),         # 红色
            'right_wrist': (255, 255, 0),      # 青色
            'left_hip': (128, 0, 128),         # 紫色
            'right_hip': (0, 128, 128),        # 茶色
            'left_knee': (128, 128, 0),        # 橄榄色
            'right_knee': (128, 0, 0)          # 栗色
        }
        
        # 骨骼连接
        self.connections = [
            ('left_shoulder', 'right_shoulder'),
            ('left_shoulder', 'left_elbow'),
            ('left_elbow', 'left_wrist'),
            ('right_shoulder', 'right_elbow'),
            ('right_elbow', 'right_wrist'),
            ('left_shoulder', 'left_hip'),
            ('right_shoulder', 'right_hip'),
            ('left_hip', 'right_hip'),
            ('left_hip', 'left_knee'),
            ('right_hip', 'right_knee')
        ]
        
        # 髋关节校正相关变量
        self.hip_correction_enabled = True
        self.previous_hips = None
        self.hip_swap_detected = False
        self.correction_history = deque(maxlen=10)
        
        # 打击阶段检测
        self.swing_phase = "setup"  # setup, swing, follow_through
        self.swing_detected = False

    def _detect_hip_swap(self, current_hips, previous_hips, image_shape):
        """
        检测髋关节是否发生左右交换
        """
        if previous_hips is None:
            return False
            
        height, width = image_shape[:2]
        
        # 计算当前帧和上一帧的髋关节位置变化
        left_hip_current = current_hips['left']
        right_hip_current = current_hips['right']
        left_hip_prev = previous_hips['left']
        right_hip_prev = previous_hips['right']
        
        # 计算正常情况下的移动距离
        normal_left_move = np.sqrt((left_hip_current[0] - left_hip_prev[0])**2 + 
                                 (left_hip_current[1] - left_hip_prev[1])**2)
        normal_right_move = np.sqrt((right_hip_current[0] - right_hip_prev[0])**2 + 
                                  (right_hip_current[1] - right_hip_prev[1])**2)
        
        # 计算交换情况下的移动距离
        swapped_left_move = np.sqrt((left_hip_current[0] - right_hip_prev[0])**2 + 
                                  (left_hip_current[1] - right_hip_prev[1])**2)
        swapped_right_move = np.sqrt((right_hip_current[0] - left_hip_prev[0])**2 + 
                                   (right_hip_current[1] - left_hip_prev[1])**2)
        
        # 如果交换后的移动距离更小，说明可能发生了交换
        if (swapped_left_move + swapped_right_move) < (normal_left_move + normal_right_move) * 0.7:
            return True
            
        return False

    def _correct_hip_landmarks(self, landmarks, image_shape):
        """
        校正髋关节关键点
        """
        height, width = image_shape[:2]
        
        # 获取当前髋关节位置
        left_hip_idx = self.mp_pose.PoseLandmark.LEFT_HIP
        right_hip_idx = self.mp_pose.PoseLandmark.RIGHT_HIP
        
        current_hips = {
            'left': (landmarks.landmark[left_hip_idx].x * width, 
                    landmarks.landmark[left_hip_idx].y * height),
            'right': (landmarks.landmark[right_hip_idx].x * width, 
                     landmarks.landmark[right_hip_idx].y * height)
        }
        
        # 检测是否需要交换
        swap_needed = False
        if self.previous_hips is not None:
            swap_needed = self._detect_hip_swap(current_hips, self.previous_hips, image_shape)
        
        # 更新历史记录
        self.correction_history.append(swap_needed)
        
        # 如果连续多帧检测到交换，则进行校正
        if sum(self.correction_history) >= 5:  # 连续5帧检测到交换
            if not self.hip_swap_detected:
                print("检测到髋关节交换，开始校正...")
            self.hip_swap_detected = True
            swap_needed = True
        
        # 如果需要交换，则交换髋关节和相关的下肢关键点
        if swap_needed and self.hip_correction_enabled:
            # 交换髋关节
            left_hip_temp = (
                landmarks.landmark[left_hip_idx].x,
                landmarks.landmark[left_hip_idx].y,
                landmarks.landmark[left_hip_idx].z,
                landmarks.landmark[left_hip_idx].visibility
            )
            
            right_hip_temp = (
                landmarks.landmark[right_hip_idx].x,
                landmarks.landmark[right_hip_idx].y,
                landmarks.landmark[right_hip_idx].z,
                landmarks.landmark[right_hip_idx].visibility
            )
            
            # 交换坐标
            landmarks.landmark[left_hip_idx].x = right_hip_temp[0]
            landmarks.landmark[left_hip_idx].y = right_hip_temp[1]
            landmarks.landmark[left_hip_idx].z = right_hip_temp[2]
            landmarks.landmark[left_hip_idx].visibility = right_hip_temp[3]
            
            landmarks.landmark[right_hip_idx].x = left_hip_temp[0]
            landmarks.landmark[right_hip_idx].y = left_hip_temp[1]
            landmarks.landmark[right_hip_idx].z = left_hip_temp[2]
            landmarks.landmark[right_hip_idx].visibility = left_hip_temp[3]
            
            # 同时交换膝盖（保持下肢一致性）
            left_knee_idx = self.mp_pose.PoseLandmark.LEFT_KNEE
            right_knee_idx = self.mp_pose.PoseLandmark.RIGHT_KNEE
            
            left_knee_temp = (
                landmarks.landmark[left_knee_idx].x,
                landmarks.landmark[left_knee_idx].y,
                landmarks.landmark[left_knee_idx].z,
                landmarks.landmark[left_knee_idx].visibility
            )
            
            right_knee_temp = (
                landmarks.landmark[right_knee_idx].x,
                landmarks.landmark[right_knee_idx].y,
                landmarks.landmark[right_knee_idx].z,
                landmarks.landmark[right_knee_idx].visibility
            )
            
            landmarks.landmark[left_knee_idx].x = right_knee_temp[0]
            landmarks.landmark[left_knee_idx].y = right_knee_temp[1]
            landmarks.landmark[left_knee_idx].z = right_knee_temp[2]
            landmarks.landmark[left_knee_idx].visibility = right_knee_temp[3]
            
            landmarks.landmark[right_knee_idx].x = left_knee_temp[0]
            landmarks.landmark[right_knee_idx].y = left_knee_temp[1]
            landmarks.landmark[right_knee_idx].z = left_knee_temp[2]
            landmarks.landmark[right_knee_idx].visibility = left_knee_temp[3]
        
        # 保存当前帧的髋关节位置供下一帧使用
        self.previous_hips = current_hips
        
        return landmarks

    def _detect_swing_phase(self, landmarks, image_shape):
        """
        检测打击阶段，用于动态调整校正策略
        """
        height, width = image_shape[:2]
        
        # 获取关键点位置
        left_shoulder = landmarks.landmark[self.mp_pose.PoseLandmark.LEFT_SHOULDER]
        right_shoulder = landmarks.landmark[self.mp_pose.PoseLandmark.RIGHT_SHOULDER]
        left_hip = landmarks.landmark[self.mp_pose.PoseLandmark.LEFT_HIP]
        right_hip = landmarks.landmark[self.mp_pose.PoseLandmark.RIGHT_HIP]
        left_wrist = landmarks.landmark[self.mp_pose.PoseLandmark.LEFT_WRIST]
        right_wrist = landmarks.landmark[self.mp_pose.PoseLandmark.RIGHT_WRIST]
        
        # 计算肩膀旋转角度
        shoulder_angle = np.arctan2(
            (left_shoulder.y + right_shoulder.y)/2 - (left_hip.y + right_hip.y)/2,
            (left_shoulder.x + right_shoulder.x)/2 - (left_hip.x + right_hip.x)/2
        )
        
        # 计算手腕速度（简单用位置变化表示）
        if hasattr(self, 'prev_wrist_pos'):
            wrist_speed = np.sqrt(
                (left_wrist.x - self.prev_wrist_pos[0])**2 + 
                (left_wrist.y - self.prev_wrist_pos[1])**2
            )
        else:
            wrist_speed = 0
        
        # 更新手腕位置
        self.prev_wrist_pos = (left_wrist.x, left_wrist.y)
        
        # 判断打击阶段
        if wrist_speed > 0.01 and not self.swing_detected:
            self.swing_phase = "swing"
            self.swing_detected = True
            # 在挥棒阶段增强髋关节校正
            self.hip_correction_enabled = True
        elif self.swing_detected and wrist_speed < 0.005:
            self.swing_phase = "follow_through"
            # 在随挥阶段保持校正
            self.hip_correction_enabled = True
        else:
            self.swing_phase = "setup"
            self.swing_detected = False
        
        return self.swing_phase

    def process_frame(self, image):
        """
        处理单帧图像（包含髋关节校正）
        """
        # 转换BGR到RGB
        image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        image_rgb.flags.writeable = False
        
        # 姿态估计
        results = self.pose.process(image_rgb)
        
        # 转换回BGR
        image_rgb.flags.writeable = True
        image = cv2.cvtColor(image_rgb, cv2.COLOR_RGB2BGR)
        
        if results.pose_landmarks:
            # 检测打击阶段
            swing_phase = self._detect_swing_phase(results.pose_landmarks, image.shape)
            
            # 髋关节校正
            corrected_landmarks = self._correct_hip_landmarks(results.pose_landmarks, image.shape)
            
            # 更新轨迹
            self._update_trajectories(corrected_landmarks, image.shape)
            
            # 绘制姿态
            image = self._draw_pose(image, corrected_landmarks)
            
            # 绘制轨迹
            image = self._draw_trajectories(image)
            
            # 绘制关键点标签
            image = self._draw_keypoint_labels(image, corrected_landmarks)
            
            # 显示打击阶段和校正状态
            image = self._draw_analysis_info(image, swing_phase)
        
        return image

    def _update_trajectories(self, landmarks, image_shape):
        """
        更新关键点轨迹
        """
        height, width = image_shape[:2]
        
        for keypoint_name, landmark_idx in self.swing_keypoints.items():
            landmark = landmarks.landmark[landmark_idx]
            
            if landmark.visibility > 0.5:
                x = int(landmark.x * width)
                y = int(landmark.y * height)
                
                self.trajectories[keypoint_name].append((x, y))

    def _draw_pose(self, image, landmarks):
        """
        绘制姿态骨架
        """
        # 使用MediaPipe的默认绘制
        self.mp_drawing.draw_landmarks(
            image,
            landmarks,
            self.mp_pose.POSE_CONNECTIONS,
            landmark_drawing_spec=self.mp_drawing_styles.get_default_pose_landmarks_style()
        )
        
        # 额外绘制自定义的骨骼连接
        height, width = image.shape[:2]
        
        for start_point, end_point in self.connections:
            start_idx = self.swing_keypoints[start_point]
            end_idx = self.swing_keypoints[end_point]
            
            start_landmark = landmarks.landmark[start_idx]
            end_landmark = landmarks.landmark[end_idx]
            
            if start_landmark.visibility > 0.5 and end_landmark.visibility > 0.5:
                start_x = int(start_landmark.x * width)
                start_y = int(start_landmark.y * height)
                end_x = int(end_landmark.x * width)
                end_y = int(end_landmark.y * height)
                
                cv2.line(image, (start_x, start_y), (end_x, end_y), 
                        self.keypoint_colors[start_point], 3)

        return image

    def _draw_trajectories(self, image):
        """
        绘制关键点轨迹
        """
        for keypoint_name, trajectory in self.trajectories.items():
            if len(trajectory) > 1:
                color = self.keypoint_colors[keypoint_name]
                
                # 绘制轨迹线
                for i in range(1, len(trajectory)):
                    thickness = max(1, int(3 * (i / len(trajectory))))
                    alpha = i / len(trajectory)
                    
                    current_color = tuple(int(c * alpha) for c in color)
                    
                    cv2.line(image, trajectory[i-1], trajectory[i], 
                            current_color, thickness)
                
                # 绘制最新的轨迹点
                if trajectory:
                    latest_point = trajectory[-1]
                    cv2.circle(image, latest_point, 6, color, -1)
                    cv2.circle(image, latest_point, 8, (255, 255, 255), 2)
        
        return image

    def _draw_keypoint_labels(self, image, landmarks):
        """
        绘制关键点标签
        """
        height, width = image.shape[:2]
        
        for keypoint_name, landmark_idx in self.swing_keypoints.items():
            landmark = landmarks.landmark[landmark_idx]
            
            if landmark.visibility > 0.5:
                x = int(landmark.x * width)
                y = int(landmark.y * height)
                
                cv2.putText(image, keypoint_name, (x + 10, y - 10),
                           cv2.FONT_HERSHEY_SIMPLEX, 0.5, 
                           self.keypoint_colors[keypoint_name], 2)
        
        return image

    def _draw_analysis_info(self, image, swing_phase):
        """
        绘制分析信息
        """
        info_lines = [
            f"Swing Phase: {swing_phase}",
            f"Hip Correction: {'ON' if self.hip_correction_enabled else 'OFF'}",
            f"Hip Swap Detected: {'YES' if self.hip_swap_detected else 'NO'}"
        ]
        
        for i, line in enumerate(info_lines):
            y_position = 30 + i * 25
            cv2.putText(image, line, (10, y_position),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
        
        return image

    def process_video(self, input_path, output_path):
        """
        处理整个视频
        """
        if not os.path.exists(input_path):
            raise FileNotFoundError(f"输入视频文件不存在: {input_path}")
        
        cap = cv2.VideoCapture(input_path)
        
        if not cap.isOpened():
            raise ValueError("无法打开视频文件")
        
        # 获取视频属性
        fps = int(cap.get(cv2.CAP_PROP_FPS))
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
        
        print(f"视频信息: {width}x{height}, {fps} FPS, 总帧数: {total_frames}")
        
        # 创建视频写入器
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))
        
        if not out.isOpened():
            raise ValueError("无法创建输出视频文件")
        
        frame_count = 0
        
        try:
            while True:
                ret, frame = cap.read()
                
                if not ret:
                    break
                
                # 处理当前帧
                processed_frame = self.process_frame(frame)
                
                # 添加进度信息
                progress = (frame_count + 1) / total_frames
                cv2.putText(processed_frame, 
                           f"Progress: {progress:.1%}",
                           (width - 200, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, 
                           (255, 255, 255), 2)
                
                # 写入输出视频
                out.write(processed_frame)
                
                frame_count += 1
                
                if frame_count % 30 == 0:
                    print(f"处理进度: {frame_count}/{total_frames} ({progress:.1%})")
                    
        except Exception as e:
            print(f"处理过程中出现错误: {e}")
        finally:
            cap.release()
            out.release()
            cv2.destroyAllWindows()
            self.pose.close()
            
        print(f"视频处理完成! 输出文件: {output_path}")
        print(f"总共处理帧数: {frame_count}")

def main():
    """
    主函数
    """
    # 初始化改进的分析器
    analyzer = AdvancedBaseballSwingAnalyzer(trajectory_length=50)
    
    # 输入和输出文件路径
    input_video = "baseball_swing_input.mp4"
    output_video = "baseball_swing_corrected.mp4"
    
    try:
        analyzer.process_video(input_video, output_video)
    except FileNotFoundError as e:
        print(f"文件错误: {e}")
    except Exception as e:
        print(f"处理错误: {e}")

if __name__ == "__main__":
    main()