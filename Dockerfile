FROM runpod/worker-comfyui:5.1.0-base

# Custom nodes required by the Wan2.2-Remix I2V workflow
RUN comfy-node-install \
    comfyui-kjnodes \
    comfyui-videohelpersuite \
    rgthree-comfy \
    comfyui-vrgamedevgirl

# PainterI2VAdvanced is not in the comfy registry yet -- install from GitHub
RUN cd /comfyui/custom_nodes && \
    git clone https://github.com/princepainter/ComfyUI-PainterI2Vadvanced.git

# Models are loaded at runtime from the attached RunPod Network Volume
# (mounted at /runpod-volume/models/).
