FROM runpod/worker-comfyui:5.1.0-base

# Install all custom nodes from GitHub (matching the working pod setup)
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-KJNodes.git && \
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git && \
    git clone https://github.com/rgthree/rgthree-comfy.git && \
    git clone https://github.com/vrgamegirl19/comfyui-vrgamedevgirl.git && \
    git clone https://github.com/princepainter/ComfyUI-PainterI2Vadvanced.git

# Remove registry-installed duplicates (lowercase names) that conflict with GitHub clones
# Only remove names that differ from the GitHub clone directory names
RUN rm -rf /comfyui/custom_nodes/comfyui-kjnodes \
           /comfyui/custom_nodes/comfyui-videohelpersuite 2>/dev/null || true

# Install pip dependencies for all custom nodes
RUN for dir in /comfyui/custom_nodes/*/; do \
      [ -f "$dir/requirements.txt" ] && pip install -r "$dir/requirements.txt" || true; \
    done

# Install ffmpeg for VideoHelperSuite
RUN apt-get update -qq && apt-get install -y -qq ffmpeg && rm -rf /var/lib/apt/lists/*

# RealESRGAN x2 upscaler (~64 MB) — baked into the image for instant access
RUN mkdir -p /comfyui/models/upscale_models && \
    wget -q -O /comfyui/models/upscale_models/RealESRGAN_x2plus.pth \
      "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.1/RealESRGAN_x2plus.pth"

# Override extra_model_paths to also map diffusion_models/ from the volume
COPY extra_model_paths.yaml /comfyui/extra_model_paths.yaml

# Large models (WAN 2.2 diffusion, CLIP, VAE) are loaded at runtime from
# the attached RunPod Network Volume (mounted at /runpod-volume/models/).
# UNETLoader scans: models/unet/ AND models/diffusion_models/
