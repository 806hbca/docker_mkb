# MKB

Контейнер предназначен для разработки Python/ROS1/CUDA-проекта в одинаковом окружении у всей команды.

## Версии

- Ubuntu: 20.04
- CUDA: 11.8.0
- cuDNN: 8
- ROS1: Noetic
- Gazebo Classic: 11
- Python: 3.8
- pip: 24.2
- PyTorch: 2.4.1 + cu118
- torchvision: 0.19.1 + cu118
- torchaudio: 2.4.1 + cu118
- NumPy: 1.24.4
- Pillow: 10.4.0
- OpenCV Python: 4.10.0.84
- Transformers: 4.44.2
- Hugging Face Hub: 0.24.6

## Требования на сервере для GPU

- Docker Engine
- Docker Compose v2 или docker-compose 1.29.x
- NVIDIA driver
- NVIDIA Container Toolkit

## Сборка

```bash
docker-compose build
```

Если на сервере установлен Compose v2, можно использовать:

```bash
docker compose build
```

## Запуск без GPU

```bash
docker-compose run --rm dev
```

Этот режим полезен на локальной Windows-машине, где Docker Desktop/WSL не видит NVIDIA GPU. CUDA-библиотеки в образе остаются установленными, но `torch.cuda.is_available()` будет `False`.

## Запуск с GPU

```bash
docker-compose -f docker-compose.yml -f docker-compose.gpu.yml run --rm dev
```

Для Compose v2:

```bash
docker compose -f docker-compose.yml -f docker-compose.gpu.yml run --rm dev
```

Код проекта монтируется в контейнер как `/workspace`.

## Проверка внутри контейнера

```bash
python3 - <<'PY'
import torch
import numpy
import PIL
import cv2
import transformers
import huggingface_hub

print("torch:", torch.__version__)
print("torch cuda:", torch.version.cuda)
print("cuda available:", torch.cuda.is_available())
print("numpy:", numpy.__version__)
print("Pillow:", PIL.__version__)
print("OpenCV:", cv2.__version__)
print("transformers:", transformers.__version__)
print("huggingface_hub:", huggingface_hub.__version__)
PY

rosversion -d
gazebo --version
nvcc --version
```
