FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RESOLUTION=1280x720
ENV BRAND_NAME="DRX-TM OS"
ENV MODEL_NAME="llama3.2:1b"

# ১. সিস্টেম প্যাকেজ, প্রিমিয়াম ডার্ক থিম ও নো-ভিএনসি ইনস্টল
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    git \
    ca-certificates \
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
    build-essential \
    python3 \
    python3-pip \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# ২. পাইথন টেলিগ্রাম বট ও প্রয়োজনীয় সকল লাইব্রেরি ইনস্টল
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel && \
    pip3 install --no-cache-dir \
    telethon \
    pyrogram \
    tgcrypto \
    python-telegram-bot \
    requests \
    aiohttp \
    flask \
    fastapi \
    uvicorn \
    beautifulsoup4 \
    rich \
    colorama \
    psutil

# ৩. লোকাল LLaMA ইঞ্জিন (Ollama) ইনস্টলেশন (কোনো API কি ছাড়া অফলাইনে চলবে)
RUN curl -fsSL https://ollama.com/install.sh | sh

# ৪. প্রিমিয়াম ডার্ক ব্যাকগ্রাউন্ড ও থিম কনফিগারেশন
RUN mkdir -p /usr/share/backgrounds/xfce /root/.config/xfce4/xfconf/xfce-perchannel-xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml && \
    curl -fsSL "https://raw.githubusercontent.com/adminnirobvai1-ux/drx/refs/heads/main/1789570402521.png" -o /usr/share/backgrounds/custom_bg.png && \
    cp /usr/share/backgrounds/custom_bg.png /usr/share/backgrounds/xfce/xfce-blue.jpg && \
    cp /usr/share/backgrounds/custom_bg.png /usr/share/backgrounds/xfce/xfce-stripes.png && \
    cp /usr/share/backgrounds/custom_bg.png /usr/share/backgrounds/xfce/xfce-teal.jpg

# XFCE ডার্ক থিম এবং র‍্যাম সেভিং কনফিগ
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

# ৫. DRX-TM টার্মিনাল এআই স্ক্রিপ্ট তৈরি (/usr/local/bin/drx)
RUN cat << 'EOF' > /usr/local/bin/drx
#!/usr/bin/env python3
import os
import sys
import json
import urllib.request
import urllib.error

# স্ক্রিন ক্লিয়ার
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
{YELLOW}   System: DRX-TM Core AI Engine | Model: LLaMA 3.2{RESET}
{YELLOW}   Owner / Developer: নাইম (Naim){RESET}
{CYAN}======================================================{RESET}
{GREEN}Type your prompt, website request or code below.{RESET}
Type {RED}'exit'{RESET} or {RED}'quit'{RESET} to return to terminal.\n
"""

print(BANNER)

SYSTEM_PROMPT = (
    "You are DRX-TM, a supreme and elite AI system. You run completely offline and locally using LLaMA technology. "
    "Your creator, owner, and developer is নাইম (Naim). If anyone asks who made you or who your owner/boss is, "
    "always answer with high respect that your owner is নাইম (Naim). "
    "You are a master coder, full-stack website builder, and intelligent assistant. You can speak fluently "
    "in Bengali, English, and any language the user uses. You always provide complete, production-ready, clean code."
)

OLLAMA_URL = "http://127.0.0.1:11434/api/chat"

# মডেল সক্রিয় আছে কি না চেক
try:
    urllib.request.urlopen("http://127.0.0.1:11434", timeout=2)
except Exception:
    print(f"{RED}[!] Ollama service is starting up... Please wait 5 seconds and run 'drx' again.{RESET}")
    sys.exit(0)

history = [{"role": "system", "content": SYSTEM_PROMPT}]

while True:
    try:
        user_input = input(f"{RED}DRX-TM{RESET} > ").strip()
        if not user_input:
            continue
        if user_input.lower() in ['exit', 'quit', 'q']:
            print(f"\n{YELLOW}[*] Exiting DRX-TM. Returning to shell...{RESET}\n")
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
    except Exception as e:
        print(f"\n{RED}[Error]: {e}{RESET}\n")
EOF

RUN chmod +x /usr/local/bin/drx

# ৬. টার্মিনাল স্টাইল ও ব্যানার
RUN echo 'export PS1="\[\e[1;31m\][DRX-TM]\[\e[0m\]:\w# "' >> /root/.bashrc && \
    echo 'echo -e "\n============================================\n   Welcome to DRX-TM Cyber Desktop\n   Type \"drx\" to launch Offline AI\n============================================\n"' >> /root/.bashrc

# ৭. VNC ও স্টার্টআপ কনফিগারেশন
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

# ৮. noVNC ব্র্যান্ডিং
RUN sed -i 's/<title>noVNC<\/title>/<title>DRX-TM Cyber Desktop<\/title>/g' /usr/share/novnc/vnc.html && \
    sed -i "s/'resize', 'off'/'resize', 'scale'/g" /usr/share/novnc/app/ui.js 2>/dev/null || true

# ৯. পোর্ট এক্সপোজ
EXPOSE 8080 8081 8082 8083 8084 8085 8086 8087 8088 8089 6080 6081 6082 6083 6084 6085 6086 6087 6088 6089

# ১০. রানটাইম এন্ট্রি স্ক্রিপ্ট
RUN echo '#!/bin/bash\n\
rm -rf /tmp/.X*-lock /tmp/.X11-unix/X*\n\
ollama serve > /dev/null 2>&1 &\n\
sleep 3\n\
ollama pull llama3.2:1b > /dev/null 2>&1 &\n\
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
