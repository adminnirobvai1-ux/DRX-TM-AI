FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RESOLUTION=1280x720
ENV BRAND_NAME="DRX-TM OS"
ENV MODEL_NAME="llama3.2:1b"

# 1. PPA setup for native Firefox (without Snap) ebong basic tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    wget \
    zstd \
    curl \
    git \
    ca-certificates \
    imagemagick \
    && add-apt-repository -y ppa:mozillateam/ppa \
    && echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox \
    && echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox \
    && echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox \
    && apt-get update && apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-terminal \
    xfce4-goodies \
    arc-theme \
    papirus-icon-theme \
    tigervnc-standalone-server \
    novnc \
    websockify \
    firefox \
    dbus-x11 \
    socat \
    htop \
    nano \
    tmux \
    net-tools \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# 2. Local LLaMA Engine (Ollama) install ebong Build-time Model Pre-pull
RUN curl -fsSL https://ollama.com/install.sh | sh && \
    (ollama serve > /dev/null 2>&1 &) && \
    sleep 5 && \
    ollama pull llama3.2:1b && \
    pkill ollama

# 3. Image Banner er poriborte Cyberpunk Text Logo Wallpaper generate
RUN mkdir -p /usr/share/backgrounds/xfce /root/.config/xfce4/xfconf/xfce-perchannel-xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml && \
    convert -size 1280x720 xc:#0d1117 \
    -gravity center \
    -fill '#00ffcc' -font DejaVu-Sans-Bold -pointsize 56 -annotate -50 'DRX-TM CORE OS' \
    -fill '#ff0055' -font DejaVu-Sans-Bold -pointsize 24 -annotate +20 '[ OFFLINE AI & CYBER TERMINAL ]' \
    -fill '#8892b0' -font DejaVu-Sans -pointsize 18 -annotate +80 'Type "drx" in terminal to chat with LLaMA 3.2' \
    /usr/share/backgrounds/custom_bg.png && \
    cp /usr/share/backgrounds/custom_bg.png /usr/share/backgrounds/xfce/xfce-blue.jpg && \
    cp /usr/share/backgrounds/custom_bg.png /usr/share/backgrounds/xfce/xfce-stripes.png && \
    cp /usr/share/backgrounds/custom_bg.png /usr/share/backgrounds/xfce/xfce-teal.jpg

# XFCE Dark Theme Config
RUN echo '<?xml version="1.0" encoding="UTF-8"?>\n\
<channel name="xsettings" version="1.0">\n\
  <property name="Net" type="empty">\n\
    <property name="ThemeName" type="string" value="Arc-Dark"/>\n\
    <property name="IconThemeName" type="string" value="Papirus-Dark"/>\n\
  </property>\n\
</channel>' > /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml && \
    echo '<?xml version="1.0" encoding="UTF-8"?>\n\
<channel name="xfwm4" version="1.0">\n\
  <property name="general" type="empty">\n\
    <property name="theme" type="string" value="Arc-Dark"/>\n\
    <property name="use_compositing" type="bool" value="false"/>\n\
  </property>\n\
</channel>' > /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml

# 4. DRX-TM Terminal AI Script
RUN cat << 'EOF' > /usr/local/bin/drx
#!/usr/bin/env python3
import os
import sys
import json
import urllib.request
import urllib.error

os.system('clear')

RED = "\033[1;31m"
CYAN = "\033[1;36m"
GREEN = "\033[1;32m"
YELLOW = "\033[1;33m"
BOLD = "\033[1m"
RESET = "\033[0m"

BANNER = f"""{RED}
  ██████╗  ██████╗ ██╗  ██╗       ████████╗███╗   ███╗
  ██╔══██╗██╔══██╗╚██╗██╔╝       ╚══██╔══╝████╗ ████║
  ██║  ██║██████╔╝ ╚███╔╝  █████╗   ██║   ██╔████╔██║
  ██║  ██║██╔══██╗ ██╔██╗  ╚════╝   ██║   ██║╚██╔╝██║
  ██████╔╝██║  ██║██╔╝ ██╗          ██║   ██║ ╚═╝ ██║
  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝          ╚═╝   ╚═╝     ╚═╝{RESET}
{CYAN}======================================================{RESET}
{YELLOW}   System: DRX-TM Core AI Engine | Model: LLaMA 3.2 (1B){RESET}
{YELLOW}   Owner / Developer: নাইম (Naim){RESET}
{CYAN}======================================================{RESET}
{GREEN}Type your prompt, request HTML/web code, or say hi!{RESET}
Type {RED}'exit'{RESET} or {RED}'quit'{RESET} to return to terminal.\n
"""

print(BANNER)

SYSTEM_PROMPT = (
    "You are DRX-TM, a smart and helpful offline AI assistant. "
    "Your creator and owner is নাইম (Naim). Always acknowledge নাইম (Naim) as your boss with utmost respect. "
    "When greeted with 'hi' or 'hello', reply politely, introducing yourself and offering help. "
    "You are an expert coder. When asked for HTML or code, provide complete, clean, and modern code directly."
)

OLLAMA_URL = "http://127.0.0.1:11434/api/chat"

try:
    urllib.request.urlopen("http://127.0.0.1:11434", timeout=3)
except Exception:
    print(f"{RED}[!] Ollama service is initializing. Please wait a few seconds and run 'drx' again.{RESET}")
    sys.exit(0)

history = [{"role": "system", "content": SYSTEM_PROMPT}]

while True:
    try:
        user_input = input(f"{RED}DRX-TM{RESET} > ").strip()
        if not user_input:
            continue
        if user_input.lower() in ['exit', 'quit', 'q']:
            print(f"\n{YELLOW}[*] Exiting DRX-TM...{RESET}\n")
            break

        history.append({"role": "user", "content": user_input})

        payload = {
            "model": "llama3.2:1b",
            "messages": history,
            "stream": True
        }

        req = urllib.request.Request(
            OLLAMA_URL,
            data=json.dumps(payload).encode('utf-8'),
            headers={'Content-Type': 'application/json'}
        )

        print(f"\n{GREEN}[DRX-TM]{RESET}: ", end="", flush=True)
        assistant_response = ""

        with urllib.request.urlopen(req) as response:
            for line in response:
                if line:
                    chunk = json.loads(line.decode('utf-8'))
                    msg = chunk.get("message", {}).get("content", "")
                    assistant_response += msg
                    print(msg, end="", flush=True)

        print("\n")
        history.append({"role": "assistant", "content": assistant_response})

    except KeyboardInterrupt:
        print(f"\n\n{YELLOW}[*] Session closed.{RESET}\n")
        break
    except urllib.error.HTTPError as e:
        err_msg = e.read().decode('utf-8', errors='ignore')
        print(f"\n{RED}[Error {e.code}]: {err_msg}{RESET}\n")
    except Exception as e:
        print(f"\n{RED}[Error]: {e}{RESET}\n")
EOF

RUN chmod +x /usr/local/bin/drx

# 5. Terminal Banner
RUN echo 'export PS1="\[\e[1;31m\][DRX-TM]\[\e[0m\]:\w# "' >> /root/.bashrc && \
    echo 'echo -e "\n============================================\n   Welcome to DRX-TM Cyber Desktop\n   Type \"drx\" to launch Offline AI\n============================================\n"' >> /root/.bashrc

# 6. VNC Configuration
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
  xfconf-query -c xfce4-panel -p /plugins/plugin-1/button-title -s "DRX-TM" --create -t string 2>/dev/null \n\
  xfconf-query -c xfce4-panel -p /plugins/plugin-1/show-button-title -s true --create -t bool 2>/dev/null \n\
) &\n\
exec startxfce4' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup && \
    ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# 7. noVNC Styling
RUN sed -i 's/<title>noVNC<\/title>/<title>DRX-TM OS<\/title>/g' /usr/share/novnc/vnc.html && \
    sed -i "s/'resize', 'off'/'resize', 'scale'/g" /usr/share/novnc/app/ui.js 2>/dev/null || true

# 8. Ports Expose
EXPOSE 8080 8081 8082 8083 8084 8085 8086 8087 8088 8089 6080 6081 6082 6083 6084 6085 6086 6087 6088 6089

# 9. Entrypoint Script (Ollama readiness check er sathe)
RUN echo '#!/bin/bash\n\
rm -rf /tmp/.X*-lock /tmp/.X11-unix/X*\n\
ollama serve > /var/log/ollama.log 2>&1 &\n\
until curl -s http://127.0.0.1:11434/api/tags > /dev/null 2>&1; do\n\
  sleep 1\n\
done\n\
vncserver :1 -geometry ${RESOLUTION} -depth 24 -SecurityTypes None\n\
for p in 8081 8082 8083 8084 8085 8086 8087 8088 8089 6080 6081 6082 6083 6084 6085 6086 6087 6088 6089; do\n\
  socat TCP-LISTEN:$p,fork,reuseaddr TCP:localhost:8080 2>/dev/null &\n\
done\n\
if [ -n "$PORT" ] && [ "$PORT" != "8080" ]; then\n\
  socat TCP-LISTEN:$PORT,fork,reuseaddr TCP:localhost:8080 2>/dev/null &\n\
fi\n\
exec websockify --web=/usr/share/novnc/ 8080 localhost:5901' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
