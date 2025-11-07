conda install pytorch torchvision -c pytorch
pip install -U openmim
mim install mmengine
mim install "mmcv>=2.0.1,<2.2.0"
mim install "mmdet>=3.1.0"
mim install "mmpose>=1.1.0"
mim download mmpose --config td-hm_hrnet-w48_8xb32-210e_coco-256x192  --dest .