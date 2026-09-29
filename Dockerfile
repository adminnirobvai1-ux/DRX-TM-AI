FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV RESOLUTION=1280x720
ENV BRAND_NAME="DRX OS"
ENV MODEL_NAME="llama3.2:1b"

# ১. সিস্টেম আপডেট, নেটিভ ফায়ারফক্স (Snap ছাড়া) ও প্রয়োজনীয় প্যাকেজ ইনস্টল
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    gnupg \
    wget \
    zstd \
    curl \
    git \
    ca-certificates \
    python3 \
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
    && update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/firefox 100 \
    && update-alternatives --set x-www-browser /usr/bin/firefox \
    && rm -rf /var/lib/apt/lists/*

# ২. লোকাল LLaMA ইঞ্জিন (Ollama) ইনস্টল
RUN curl -fsSL https://ollama.com/install.sh | sh

# ৩. GitHub থেকে আপনার দেওয়া মূল ব্যানার ছবি ব্যাকগ্রাউন্ড হিসেবে ডাউনলোড
RUN mkdir -p /usr/share/backgrounds/xfce /root/.config/xfce4/xfconf/xfce-perchannel-xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml && \
    curl -fsSL "https://raw.githubusercontent.com/adminnirobvai1-ux/drx/refs/heads/main/1789570402521.png" -o /usr/share/backgrounds/custom_bg.png && \
    cp /usr/share/backgrounds/custom_bg.png /usr/share/backgrounds/xfce/xfce-blue.jpg && \
    cp /usr/share/backgrounds/custom_bg.png /usr/share/backgrounds/xfce/xfce-stripes.png && \
    cp /usr/share/backgrounds/custom_bg.png /usr/share/backgrounds/xfce/xfce-teal.jpg

# XFCE ডার্ক থিম কনফিগারেশন
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

# ৪. DRX টার্মিনাল এআই স্ক্রিপ্ট (ভারী ব্যানার ছাড়া শুধু সাধারণ টেক্সট লোগো)
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

# সাধারণ টেক্সট হেডার (কোনো ভারী আর্ট ব্যানার ছাড়া)
BANNER = f"""
{RED}{BOLD}>>> DRX AI <<<{RESET}
{CYAN}--------------------------------------------------{RESET}
{YELLOW}System: DRX Offline Engine | Model: LLaMA 3.2{RESET}
{YELLOW}Owner / Developer: নাইম (Naim){RESET}
{CYAN}--------------------------------------------------{RESET}
{GREEN}Type your prompt, ask for HTML code, or say 'hi'!{RESET}
Type {RED}'exit'{RESET} to return to terminal.\n
"""

print(BANNER)

# Ollama সার্ভিস প্রস্তুত কি না যাচাই
try:
    urllib.request.urlopen("http://127.0.0.1:11434", timeout=3)
except Exception:
    print(f"{RED}[!] Ollama ব্যাকগ্রাউন্ডে শুরু হচ্ছে। ৫ সেকেন্ড পর আবার 'drx' লিখুন।{RESET}\n")
    sys.exit(0)

# মডেল ডাউনলোড নিশ্চিত করা (500 Error রোধে)
def ensure_model():
    try:
        req = urllib.request.Request("http://127.0.0.1:11434/api/tags")
        with urllib.request.urlopen(req, timeout=5) as res:
            data = json.loads(res.read().decode())
            models = [m.get("name", "") for m in data.get("models", [])]
            return any("llama3.2:1b" in m for m in models)
    except Exception:
        return False

if not ensure_model():
    print(f"{YELLOW}[*] AI মডেল প্রথমবার প্রস্তুত হচ্ছে, দয়া করে একটু অপেক্ষা করুন...{RESET}")
    os.system("ollama pull llama3.2:1b")
    print(f"{GREEN}[✓] মডেল প্রস্তুত!{RESET}\n")

SYSTEM_PROMPT = (
    "You are DRX, a fast and smart offline AI assistant running on LLaMA 3.2. "
    "Your creator, boss, and developer is নাইম (Naim). Always acknowledge নাইম with respect if asked. "
    "When someone says 'hi' or greets you, greet them warmly and ask how you can help. "
    "You are an expert coder. When asked for HTML or programming code, always provide clean, functional, and complete code."
)

OLLAMA_URL = "http://127.0.0.1:11434/api/chat"
history = [{"role": "system", "content": SYSTEM_PROMPT}]

while True:
    try:
        user_input = input(f"{RED}DRX{RESET} > ").strip()
        if not user_input:
            continue
        if user_input.lower() in ['exit', 'quit', 'q']:
            print(f"\n{YELLOW}[*] DRX বন্ধ করা হলো।{RESET}\n")
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

        print(f"\n{GREEN}[DRX]{RESET}: ", end="", flush=True)
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
        print(f"\n\n{YELLOW}[*] সেশন সমাপ্ত।{RESET}\n")
        break
    except urllib.error.HTTPError as e:
        err = e.read().decode('utf-8', errors='ignore')
        print(f"\n{RED}[Error {e.code}]: {err}{RESET}\n")
    except Exception as e:
        print(f"\n{RED}[Error]: {e}{RESET}\n")
EOF

RUN chmod +x /usr/local/bin/drx

# ৫. টার্মিনাল প্রম্পট ও টেক্সট ব্যানার
RUN echo 'export PS1="\[\e[1;31m\][DRX]\[\e[0m\]:\w# "' >> /root/.bashrc && \
    echo 'echo -e "\n============================================\n   Welcome to DRX Desktop\n   Type \"drx\" to launch Offline AI\n============================================\n"' >> /root/.bashrc

# ৬. VNC ও ডেস্কটপ প্যানেল কনফিগারেশন
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
  xfconf-query -c xfce4-panel -p /plugins/plugin-1/button-title -s "DRX" --create -t string 2>/dev/null \n\
  xfconf-query -c xfce4-panel -p /plugins/plugin-1/show-button-title -s true --create -t bool 2>/dev/null \n\
) &\n\
exec startxfce4' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup && \
    ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# ৭. noVNC স্টাইলিং ও টাইটেল
RUN sed -i 's/<title>noVNC<\/title>/<title>DRX OS<\/title>/g' /usr/share/novnc/vnc.html && \
    sed -i "s/'resize', 'off'/'resize', 'scale'/g" /usr/share/novnc/app/ui.js 2>/dev/null || true

# ৮. পোর্ট এক্সপোজ
EXPOSE 8080 8081 8082 8083 8084 8085 8086 8087 8088 8089 6080 6081 6082 6083 6084 6085 6086 6087 6088 6089

# ৯. এন্ট্রি পয়েন্ট স্ক্রিপ্ট
RUN echo '#!/bin/bash\n\
rm -rf /tmp/.X*-lock /tmp/.X11-unix/X*\n\
ollama serve > /var/log/ollama.log 2>&1 &\n\
( \n\
  until curl -s http://127.0.0.1:11434/api/tags > /dev/null 2>&1; do sleep 1; done\n\
  ollama pull llama3.2:1b > /dev/null 2>&1 \n\
) &\n\
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
