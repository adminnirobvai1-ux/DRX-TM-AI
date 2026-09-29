FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RESOLUTION=1280x720
ENV BRAND_NAME="DRX-TM-AI"

# Essential packages, VIP desktop theme and Python environment
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    ca-certificates \
    xfce4 \
    xfce4-terminal \
    xfce4-goodies \
    greybird-gtk-theme \
    tigervnc-standalone-server \
    novnc \
    websockify \
    firefox \
    dbus-x11 \
    feh \
    socat \
    python3 \
    python3-pip \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Install lightweight llama-cpp-python for offline AI execution
RUN pip3 install --no-cache-dir llama-cpp-python \
    --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cpu

# Download 400MB ultra-lightweight Qwen2.5-0.5B GGUF Model
RUN mkdir -p /opt/ai_models && \
    curl -L -s "https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF/resolve/main/qwen2.5-0.5b-instruct-q4_k_m.gguf" \
    -o /opt/ai_models/renika-model.gguf

# Renika Jarvis Desktop Controller Script
RUN echo '#!/usr/bin/env python3\n\
import os, sys, subprocess, readline\n\
from llama_cpp import Llama\n\
\n\
MODEL_PATH = "/opt/ai_models/renika-model.gguf"\n\
AI_NAME = "Renika"\n\
DEVELOPER = "Nayeem (DRX Team Owner)"\n\
\n\
print("\\033[1;36m========================================================\\033[0m")\n\
print(f"\\033[1;32m[+] Hi! I am {AI_NAME}, your DRX-TM-AI assistant.\\033[0m")\n\
print(f"\\033[1;33m[+] Developed by: {DEVELOPER}\\033[0m")\n\
print("How can I assist you today? (Ami apnake kivabe sahajjo korte pari?)")\n\
print("\\033[1;36m========================================================\\033[0m\\n")\n\
\n\
llm = Llama(model_path=MODEL_PATH, n_ctx=1024, n_threads=2, verbose=False)\n\
\n\
SYSTEM_PROMPT = f"""You are {AI_NAME}, a smart, polite, and helpful desktop AI assistant built for DRX-TM-AI.\\nYour developer and creator is {DEVELOPER}.\\nYou can speak English and Bengali fluently. You answer questions, create HTML, and assist with desktop operations."""\n\
\n\
def run_action(query):\n\
    q = query.lower().strip()\n\
    if "open firefox" in q or "browser" in q:\n\
        subprocess.Popen(["firefox", "&"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)\n\
        return "Opening Firefox Browser on DRX-TM-AI..."\n\
    if "create html" in q:\n\
        filename = "index.html"\n\
        sample_html = "<!DOCTYPE html>\\n<html><head><title>DRX-TM-AI</title></head><body style=\"background:#121212;color:#00ffcc;font-family:sans-serif;text-align:center;padding:50px;\"><h1>Welcome to DRX-TM-AI</h1><p>Created by Renika AI</p></body></html>"\n\
        with open(filename, "w") as f:\n\
            f.write(sample_html)\n\
        return f"HTML file generated successfully: {os.path.abspath(filename)}"\n\
    return None\n\
\n\
while True:\n\
    try:\n\
        user_input = input("\\033[1;35m[DRX-TM-AI] You > \\033[0m").strip()\n\
        if not user_input:\n\
            continue\n\
        if user_input.lower() in ["exit", "quit", "q"]:\n\
            print(f"Goodbye from {AI_NAME}!")\n\
            break\n\
        action_res = run_action(user_input)\n\
        if action_res:\n\
            print(f"\\033[1;32m{AI_NAME}:\\033[0m {action_res}\\n")\n\
            continue\n\
        response = llm.create_chat_completion(\n\
            messages=[\n\
                {"role": "system", "content": SYSTEM_PROMPT},\n\
                {"role": "user", "content": user_input}\n\
            ],\n\
            max_tokens=256,\n\
            temperature=0.7\n\
        )\n\
        ans = response["choices"][0]["message"]["content"]\n\
        print(f"\\033[1;32m{AI_NAME}:\\033[0m {ans}\\n")\n\
    except (KeyboardInterrupt, EOFError):\n\
        print("\\nExiting Renika AI...")\n\
        break\n\
' > /usr/local/bin/drx && chmod +x /usr/local/bin/drx && ln -sf /usr/local/bin/drx /usr/local/bin/DRX

# Custom Background image download and replace
RUN mkdir -p /usr/share/backgrounds/xfce /usr/share/images/desktop-base && \
    curl -fsSL "https://raw.githubusercontent.com/adminnirobvai1-ux/drx/refs/heads/main/1789570402521.png" -o /usr/share/backgrounds/custom_bg.png && \
    cp /usr/share/backgrounds/custom_bg.png /usr/share/backgrounds/xfce/xfce-blue.jpg && \
    cp /usr/share/backgrounds/custom_bg.png /usr/share/backgrounds/xfce/xfce-stripes.png && \
    cp /usr/share/backgrounds/custom_bg.png /usr/share/backgrounds/xfce/xfce-teal.jpg && \
    find /usr/share/backgrounds -type f -exec cp /usr/share/backgrounds/custom_bg.png {} + 2>/dev/null || true

# Desktop configuration for background fitting
RUN mkdir -p /etc/xdg/xfce4/xfconf/xfce-perchannel-xml /root/.config/xfce4/xfconf/xfce-perchannel-xml && \
    echo '<?xml version="1.0" encoding="UTF-8"?>\n\
<channel name="xfce4-desktop" version="1.0">\n\
  <property name="backdrop" type="empty">\n\
    <property name="screen0" type="empty">\n\
      <property name="monitor0" type="empty">\n\
        <property name="workspace0" type="empty">\n\
          <property name="image-style" type="int" value="5"/>\n\
          <property name="last-image" type="string" value="/usr/share/backgrounds/custom_bg.png"/>\n\
        </property>\n\
      </property>\n\
    </property>\n\
  </property>\n\
</channel>' > /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml && \
    cp /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml /root/.config/xfce4/xfconf/xfce-perchannel-xml/

# Clean VIP Terminal Prompt (No messy hashtag banners)
RUN echo 'export PS1="\[\e[1;36m\][DRX-TM-AI]\[\e[0m\]:\w# "' >> /root/.bashrc && \
    echo 'echo -e "\033[1;32mDRX-TM-AI Remote System Active.\033[0m Type \033[1;33mdrx\033[0m to launch Renika AI Assistant.\n"' >> /root/.bashrc

# VNC and Startup Script
RUN mkdir -p /root/.vnc && \
    echo "securitytypes=None" > /root/.vnc/config && \
    echo '#!/bin/bash\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
export DISPLAY=:1\n\
( \n\
  sleep 2\n\
  for p in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep "last-image"); do \n\
    xfconf-query -c xfce4-desktop -p "$p" -s /usr/share/backgrounds/custom_bg.png 2>/dev/null \n\
  done \n\
  for p in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep "image-style"); do \n\
    xfconf-query -c xfce4-desktop -p "$p" -s 5 2>/dev/null \n\
  done \n\
  xfconf-query -c xsettings -p /Net/ThemeName -s "Greybird-dark" 2>/dev/null \n\
  xfconf-query -c xfce4-panel -p /plugins/plugin-1/button-title -s "DRX-TM-AI" --create -t string 2>/dev/null \n\
  xfconf-query -c xfce4-panel -p /plugins/plugin-1/show-button-title -s true --create -t bool 2>/dev/null \n\
) &\n\
exec startxfce4' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup && \
    ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# Browser Title branding to DRX-TM-AI
RUN sed -i 's/<title>.*<\/title>/<title>DRX-TM-AI<\/title>/g' /usr/share/novnc/vnc.html && \
    sed -i "s/'resize', 'off'/'resize', 'scale'/g" /usr/share/novnc/app/ui.js 2>/dev/null || true

# Port exposures
EXPOSE 8080 8081 8082 8083 8084 8085 8086 8087 8088 8089 6080 6081 6082 6083 6084 6085 6086 6087 6088 6089

# Railway port forward and startup
CMD ["sh", "-c", "rm -rf /tmp/.X*-lock /tmp/.X11-unix/X* && vncserver :1 -geometry ${RESOLUTION} -depth 24 -SecurityTypes None && for p in 8081 8082 8083 8084 8085 8086 8087 8088 8089 6080 6081 6082 6083 6084 6085 6086 6087 6088 6089; do socat TCP-LISTEN:$p,fork,reuseaddr TCP:localhost:8080 2>/dev/null & done && if [ -n \"$PORT\" ] && [ \"$PORT\" != \"8080\" ]; then socat TCP-LISTEN:$PORT,fork,reuseaddr TCP:localhost:8080 2>/dev/null & fi && websockify --web=/usr/share/novnc/ 8080 localhost:5901"]
