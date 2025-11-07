import os
import sys
import cv2
import time
import math
import json
import numpy as np
import matplotlib
matplotlib.use('Agg')  # Non-interactive backend for speed and headless support
import matplotlib.pyplot as plt
from collections import deque
from typing import List, Tuple, Dict, Optional

# Try to import MMPose inferencer
try:
    from mmpose.apis import MMPoseInferencer
except ImportError:
    print("ERROR: mmpose not installed or version incompatible. Please install with requirements.txt.")
    sys.exit(1)

# -----------------------------
# Configurable parameters
# -----------------------------
COCO_EDGES = [
    (5, 7), (7, 9),      # left arm: shoulder->elbow->wrist
    (6, 8), (8, 10),     # right arm
    (5, 6),              # shoulders
    (5, 11), (6, 12),    # shoulders to hips
    (11, 12),            # hips
    (11, 13), (13, 15),  # left leg: hip->knee->ankle
    (12, 14), (14, 16),  # right leg
    (0, 5), (0, 6)       # nose to shoulders
]
# Key indices for trajectories (COCO 17):
KEYS_TRAJ = {
    'L_shoulder': 5,
    'R_shoulder': 6,
    'L_elbow': 7,
    'R_elbow': 8,
    'L_wrist': 9,
    'R_wrist': 10,
    'L_hip': 11,
    'R_hip': 12
}

# Colors for key trajectories (BGR)
TRAJ_COLORS = {
    'L_shoulder': (0, 255, 0),
    'R_shoulder': (0, 200, 255),
    'L_elbow': (255, 100, 0),
    'R_elbow': (255, 0, 100),
    'L_wrist': (0, 0, 255),
    'R_wrist': (255, 0, 0),
    'L_hip': (200, 200, 0),
    'R_hip': (200, 0, 200)
}

# 3D skeleton edges (Human3.6M-like, 17 joints)
# This is a typical H36M skeleton order; MMPoseInferencer handles internal mapping.
H36M_EDGES = [
    (0, 1), (0, 2),       # pelvis to left/right hip
    (1, 4), (2, 5),       # hips to knees
    (4, 6), (5, 7),       # knees to ankles
    (0, 3),               # pelvis to spine
    (3, 8),               # spine to neck
    (8, 9), (8, 10),      # neck to shoulders
    (9, 11), (10, 12),    # shoulders to elbows
    (11, 13), (12, 14),   # elbows to wrists
    (8, 15), (15, 16)     # neck to head/top
]

def draw_skeleton_2d(image: np.ndarray, keypoints: np.ndarray, edges: List[Tuple[int, int]],
                     kpt_score: Optional[np.ndarray]=None,
                     score_thr: float=0.2) -> np.ndarray:
    """Draws 2D keypoints and edges on image."""
    img = image.copy()
    # draw keypoints
    for i, (x, y) in enumerate(keypoints):
        if kpt_score is not None and i < len(kpt_score):
            if kpt_score[i] < score_thr:
                continue
        cv2.circle(img, (int(x), int(y)), 3, (0, 255, 255), -1)
    # draw edges
    for (a, b) in edges:
        if a < len(keypoints) and b < len(keypoints):
            xa, ya = keypoints[a]
            xb, yb = keypoints[b]
            if kpt_score is not None:
                sa = kpt_score[a] if a < len(kpt_score) else 1.0
                sb = kpt_score[b] if b < len(kpt_score) else 1.0
                if min(sa, sb) < score_thr:
                    continue
            cv2.line(img, (int(xa), int(ya)), (int(xb), int(yb)), (0, 255, 0), 2)
    return img

def update_and_draw_trajectories(img: np.ndarray,
                                 traj_buffers: Dict[str, deque],
                                 kpts: np.ndarray,
                                 keys_to_track: Dict[str, int],
                                 max_len: int=150) -> None:
    """Update trajectory buffers and draw polylines."""
    h, w = img.shape[:2]
    for name, idx in keys_to_track.items():
        if idx >= len(kpts):
            continue
        x, y = kpts[idx]
        # clamp
        x = max(0, min(w-1, int(x)))
        y = max(0, min(h-1, int(y)))
        traj_buffers[name].append((x, y))
        while len(traj_buffers[name]) > max_len:
            traj_buffers[name].popleft()
        # draw polyline
        pts = np.array(traj_buffers[name], dtype=np.int32)
        if len(pts) > 1:
            cv2.polylines(img, [pts], False, TRAJ_COLORS[name], 2)

def render_3d_skeleton_image(keypoints_3d: np.ndarray,
                             edges_3d: List[Tuple[int, int]],
                             fig: plt.Figure,
                             ax: plt.Axes,
                             canvas_width: int,
                             canvas_height: int) -> np.ndarray:
    """Render 3D skeleton using matplotlib, return BGR image."""
    ax.clear()
    # If keypoints_3d has shape (N, 3)
    xs = keypoints_3d[:, 0]
    ys = keypoints_3d[:, 1]
    zs = keypoints_3d[:, 2]

    # normalize scale for consistent viewing
    # center around pelvis (joint 0 if available)
    cx, cy, cz = xs.mean(), ys.mean(), zs.mean()
    xs = xs - cx
    ys = ys - cy
    zs = zs - cz

    # set limits
    max_range = max(np.ptp(xs), np.ptp(ys), np.ptp(zs))
    if max_range < 1e-5:
        max_range = 1.0
    r = max_range / 2.0 + 0.5
    ax.set_xlim3d(-r, r)
    ax.set_ylim3d(-r, r)
    ax.set_zlim3d(-r, r)

    # draw edges
    for (a, b) in edges_3d:
        if a < len(keypoints_3d) and b < len(keypoints_3d):
            ax.plot([xs[a], xs[b]], [ys[a], ys[b]], [zs[a], zs[b]], c='blue', linewidth=2)

    # draw points
    ax.scatter(xs, ys, zs, c='red', s=20)
    ax.view_init(elev=15, azim=45)
    ax.set_axis_off()

    fig.canvas.draw()
    img = np.frombuffer(fig.canvas.tostring_rgb(), dtype=np.uint8)
    img = img.reshape(fig.canvas.get_width_height()[1], fig.canvas.get_width_height()[0], 3)
    # Convert RGB to BGR for OpenCV
    img_bgr = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)
    # resize to desired canvas size
    img_bgr = cv2.resize(img_bgr, (canvas_width, canvas_height))
    return img_bgr

def select_main_person(predictions: List[Dict]) -> Dict:
    """Select the main batter by largest bbox area."""
    if len(predictions) == 0:
        return {}
    best = predictions[0]
    best_area = -1
    for p in predictions:
        bbox = p.get('bbox', None)
        if bbox is None:
            # try nested path
            bbox = p.get('bbox', None)
        if bbox is None:
            # fallback: no bbox, pick first
            return predictions[0]
        # bbox format: [x1, y1, x2, y2] or [x,y,w,h]
        if len(bbox) == 4:
            x1, y1, x2, y2 = bbox
            w = max(0, x2 - x1)
            h = max(0, y2 - y1)
            area = w * h
        elif len(bbox) == 5:
            x1, y1, x2, y2, _ = bbox
            w = max(0, x2 - x1)
            h = max(0, y2 - y1)
            area = w * h
        else:
            area = 0
        if area > best_area:
            best_area = area
            best = p
    return best

def extract_keypoints_from_result(result: Dict) -> Tuple[Optional[np.ndarray], Optional[np.ndarray], Optional[np.ndarray]]:
    """
    Extract 2D keypoints, 2D scores, and 3D keypoints from MMPoseInferencer result item.
    Returns (kpts2d, scores2d, kpts3d) where each is np.ndarray or None.
    """
    kpts2d = None
    scores2d = None
    kpts3d = None

    try:
        predictions = result.get('predictions', None)
        if predictions is None:
            # sometimes result['predictions'] is a list of lists
            if 'outputs' in result:
                predictions = result['outputs']
        if predictions is None:
            return None, None, None

        # predictions is list per frame; typically predictions[0] is a list of instances
        frame_preds = predictions[0] if isinstance(predictions, list) else predictions
        if isinstance(frame_preds, dict):
            instances = [frame_preds]
        elif isinstance(frame_preds, list):
            instances = frame_preds
        else:
            instances = []

        if len(instances) == 0:
            return None, None, None

        main = select_main_person(instances)

        # 2D keypoints
        if 'keypoints' in main:
            kpts2d = np.array(main['keypoints'], dtype=np.float32)
        elif 'pred_instances' in main and 'keypoints' in main['pred_instances']:
            kpts2d = np.array(main['pred_instances']['keypoints'], dtype=np.float32)
        # 2D scores
        if 'keypoint_scores' in main:
            scores2d = np.array(main['keypoint_scores'], dtype=np.float32)
        elif 'pred_instances' in main and 'keypoint_scores' in main['pred_instances']:
            scores2d = np.array(main['pred_instances']['keypoint_scores'], dtype=np.float32)

        # 3D keypoints
        # MMPoseInferencer may output 'keypoints_3d' or under 'pred_instances'
        if 'keypoints_3d' in main:
            kpts3d = np.array(main['keypoints_3d'], dtype=np.float32)
        elif 'pred_instances' in main and 'keypoints_3d' in main['pred_instances']:
            kpts3d = np.array(main['pred_instances']['keypoints_3d'], dtype=np.float32)

    except Exception as e:
        print(f"[WARN] Failed to parse predictions: {e}")

    return kpts2d, scores2d, kpts3d

def process_video(
    input_video_path: str,
    output_video_path: str = "output/swing_analysis.mp4",
    preview: bool = True,
    device: str = "cuda"
):
    # Check input
    if not os.path.exists(input_video_path):
        raise FileNotFoundError(f"Input video not found: {input_video_path}")
    os.makedirs(os.path.dirname(output_video_path), exist_ok=True)

    # Initialize video reader
    cap = cv2.VideoCapture(input_video_path)
    if not cap.isOpened():
        raise RuntimeError("Failed to open input video.")
    fps = cap.get(cv2.CAP_PROP_FPS)
    in_w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    in_h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))

    # Initialize MMPose Inferencer
    # This will automatically download suitable models and handle mapping
    # detector: rtmdet (default), pose2d: rtmpose-m (COCO), pose3d: mixste (H36M)
    inferencer = MMPoseInferencer(
        # detector='rtmdet',
        pose2d='human',
        # pose3d='mixste',
        pose3d='human3d',
        device=device
    )

    # Prepare 3D render figure
    # size of 3D canvas roughly equal to input frame
    fig_w = in_w
    fig_h = in_h
    dpi = 100
    fig = plt.figure(figsize=(fig_w / dpi, fig_h / dpi), dpi=dpi)
    ax = fig.add_subplot(111, projection='3d')

    # Output writer: side-by-side -> width = in_w + fig_w, height = max(in_h, fig_h)
    out_w = in_w + fig_w
    out_h = max(in_h, fig_h)
    fourcc = cv2.VideoWriter_fourcc(*'mp4v')
    writer = cv2.VideoWriter(output_video_path, fourcc, fps if fps > 1e-2 else 25.0, (out_w, out_h))

    # Trajectory buffers
    traj_buffers = {name: deque(maxlen=300) for name in KEYS_TRAJ.keys()}

    paused = False
    frame_idx = 0
    t0 = time.time()

    while True:
        if not paused:
            ret, frame = cap.read()
            if not ret:
                break

            # Inference on current frame
            # MMPoseInferencer returns a generator; we pull single result
            try:
                result_gen = inferencer(frame)
                infer_res = next(result_gen)  # dict with keys: 'predictions', 'visualization', ...
            except Exception as e:
                print(f"[ERROR] Inference failed at frame {frame_idx}: {e}")
                break

            # Extract keypoints
            kpts2d, scores2d, kpts3d = extract_keypoints_from_result(infer_res)

            # Draw 2D skeleton and trajectories
            overlay_frame = frame.copy()
            if kpts2d is not None:
                overlay_frame = draw_skeleton_2d(overlay_frame, kpts2d, COCO_EDGES, scores2d, score_thr=0.2)
                update_and_draw_trajectories(overlay_frame, traj_buffers, kpts2d, KEYS_TRAJ, max_len=200)
                # Add info text
                cv2.putText(overlay_frame, "2D Pose + Trajectories", (10, 25), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 255), 2)
            else:
                cv2.putText(overlay_frame, "No 2D pose", (10, 25), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)

            # Render 3D skeleton image
            if kpts3d is not None and kpts3d.ndim == 2 and kpts3d.shape[1] >= 3:
                try:
                    img3d = render_3d_skeleton_image(kpts3d[:, :3], H36M_EDGES, fig, ax, fig_w, fig_h)
                    cv2.putText(img3d, "3D Pose (Pose Lifter)", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1.0, (0, 255, 255), 2)
                except Exception as e:
                    print(f"[WARN] 3D render failed: {e}")
                    img3d = np.zeros((fig_h, fig_w, 3), dtype=np.uint8)
                    cv2.putText(img3d, "3D pose unavailable", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1.0, (0, 0, 255), 2)
            else:
                img3d = np.zeros((fig_h, fig_w, 3), dtype=np.uint8)
                cv2.putText(img3d, "3D pose warming up (sequence)", (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1.0, (0, 255, 0), 2)

            # Compose side-by-side
            if overlay_frame.shape[0] != out_h:
                overlay_frame = cv2.resize(overlay_frame, (in_w, out_h))
            if img3d.shape[0] != out_h:
                img3d = cv2.resize(img3d, (fig_w, out_h))
            combined = cv2.hconcat([overlay_frame, img3d])

            # Write frame
            writer.write(combined)

            # Real-time preview
            if preview:
                cv2.imshow("Swing Analysis (2D+Traj | 3D)", combined)
                key = cv2.waitKey(1) & 0xFF
                if key == ord('q'):
                    break
                elif key == ord('p'):
                    paused = True

            frame_idx += 1
        else:
            # paused
            if preview:
                key = cv2.waitKey(30) & 0xFF
                if key == ord('p'):
                    paused = False
                elif key == ord('q'):
                    break
            else:
                # If not previewing, no need to pause; continue processing
                paused = False

    cap.release()
    writer.release()
    if preview:
        cv2.destroyAllWindows()

    t1 = time.time()
    print(f"Done. Processed {frame_idx} frames in {t1 - t0:.2f}s.")
    print(f"Output saved to: {output_video_path}")

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Baseball swing pose analysis with MMPose (2D+3D).")
    parser.add_argument("--input", type=str, required=True, help="Path to input video (side view of right-handed batter).")
    parser.add_argument("--output", type=str, default="output/swing_analysis.mp4", help="Path to output video file.")
    parser.add_argument("--preview", action="store_true", help="Enable real-time preview window.")
    parser.add_argument("--cpu", action="store_true", help="Force CPU inference.")
    args = parser.parse_args()

    device = "cpu" if args.cpu else ("cuda" if cv2.ocl.haveOpenCL() else "cpu")
    try:
        process_video(args.input, args.output, preview=args.preview, device=device)
    except Exception as e:
        print(f"ERROR: {e}")
        sys.exit(1)
