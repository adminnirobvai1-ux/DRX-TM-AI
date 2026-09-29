FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PORT=8080
ENV RESOLUTION=1280x720

# প্যাকেজ আপডেট, আপগ্রেড এবং শুধুমাত্র পাইথন ও নো-ভিএনসির ন্যূনতম টুলস ইনস্টল
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    xvfb \
    x11vnc \
    openbox \
    novnc \
    websockify \
    curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# টাইটেল পরিবর্তন করে "DRX-TM" সেট করা
RUN sed -i 's/<title>.*<\/title>/<title>DRX-TM<\/title>/g' /usr/share/novnc/vnc.html && \
    cp /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# কানেক্ট বাটনে গ্লোয়িং বর্ডার অ্যানিমেশন (Glowing Border Effect) যোগ করা
RUN echo '\
<style>\
@keyframes borderGlow {\
  0% { border-color: #00f2fe; box-shadow: 0 0 6px #00f2fe, inset 0 0 4px #00f2fe; }\
  50% { border-color: #4facfe; box-shadow: 0 0 20px #00f2fe, 0 0 30px #4facfe, inset 0 0 10px #4facfe; }\
  100% { border-color: #00f2fe; box-shadow: 0 0 6px #00f2fe, inset 0 0 4px #00f2fe; }\
}\
#noVNC_connect_button, .noVNC_button {\
  border: 2px solid #00f2fe !important;\
  border-radius: 8px !important;\
  animation: borderGlow 1.8s infinite ease-in-out !important;\
}\
</style>' >> /usr/share/novnc/index.html

# স্ক্রিপ্ট সেটআপ ও এক্সিকিউশন
RUN echo '#!/bin/bash\n\
Xvfb :0 -screen 0 ${RESOLUTION}x24 &\n\
sleep 2\n\
DISPLAY=:0 openbox &\n\
x11vnc -display :0 -nopw -forever -shared -rfbport 5900 &\n\
websockify --web /usr/share/novnc 0.0.0.0:${PORT:-8080} localhost:5900\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 8080

CMD ["/entrypoint.sh"]
