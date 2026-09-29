FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ১. সিস্টেম টুলস, Nginx, PHP 8.1, Python 3 এবং সুপারভাইজর ইনস্টল
RUN apt-get update && apt-get install -y \
    nginx \
    php8.1-fpm \
    php8.1-cli \
    php8.1-curl \
    php8.1-mbstring \
    php8.1-xml \
    php8.1-zip \
    python3 \
    python3-pip \
    python3-venv \
    supervisor \
    curl \
    wget \
    unzip \
    git \
    nano \
    && rm -rf /var/lib/apt/lists/*

# ২. ওয়েব টার্মিনাল বাইনারি (ttyd) ডাউনলোড
RUN curl -sLk https://github.com/tsl0922/ttyd/releases/download/1.7.4/ttyd.x86_64 -o /usr/local/bin/ttyd \
    && chmod +x /usr/local/bin/ttyd

# ৩. প্রয়োজনীয় ডিরেক্টরি প্রস্তুত করা
RUN mkdir -p /var/www/html/admin /var/log/supervisor /run/php

# ৪. TinyFileManager অ্যাডমিন প্যানেল ডাউনলোড
RUN curl -sLk https://raw.githubusercontent.com/prasathmani/tinyfilemanager/master/tinyfilemanager.php -o /var/www/html/admin/index.php

# ৫. Nginx সার্ভার ব্লক কনফিগারেশন তৈরি
RUN echo 'server {' > /etc/nginx/sites-available/default && \
    echo '    listen __PORT__ default_server;' >> /etc/nginx/sites-available/default && \
    echo '    listen [::]:__PORT__ default_server;' >> /etc/nginx/sites-available/default && \
    echo '    root /var/www/html;' >> /etc/nginx/sites-available/default && \
    echo '    index index.php index.html;' >> /etc/nginx/sites-available/default && \
    echo '    server_name _;' >> /etc/nginx/sites-available/default && \
    echo '    client_max_body_size 512M;' >> /etc/nginx/sites-available/default && \
    echo '    location / {' >> /etc/nginx/sites-available/default && \
    echo '        try_files $uri $uri/ /index.php?$query_string;' >> /etc/nginx/sites-available/default && \
    echo '    }' >> /etc/nginx/sites-available/default && \
    echo '    location ~ \.php$ {' >> /etc/nginx/sites-available/default && \
    echo '        include snippets/fastcgi-php.conf;' >> /etc/nginx/sites-available/default && \
    echo '        fastcgi_pass unix:/run/php/php8.1-fpm.sock;' >> /etc/nginx/sites-available/default && \
    echo '        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;' >> /etc/nginx/sites-available/default && \
    echo '        include fastcgi_params;' >> /etc/nginx/sites-available/default && \
    echo '    }' >> /etc/nginx/sites-available/default && \
    echo '    location /terminal/ {' >> /etc/nginx/sites-available/default && \
    echo '        proxy_pass http://127.0.0.1:7681/;' >> /etc/nginx/sites-available/default && \
    echo '        proxy_http_version 1.1;' >> /etc/nginx/sites-available/default && \
    echo '        proxy_set_header Upgrade $http_upgrade;' >> /etc/nginx/sites-available/default && \
    echo '        proxy_set_header Connection "upgrade";' >> /etc/nginx/sites-available/default && \
    echo '        proxy_set_header Host $host;' >> /etc/nginx/sites-available/default && \
    echo '        proxy_read_timeout 86400;' >> /etc/nginx/sites-available/default && \
    echo '    }' >> /etc/nginx/sites-available/default && \
    echo '    location ~ /\.ht { deny all; }' >> /etc/nginx/sites-available/default && \
    echo '}' >> /etc/nginx/sites-available/default

# ৬. সুপারভাইজর কনফিগারেশন তৈরি (PHP, Nginx ও Terminal ব্যাকগ্রাউন্ড প্রসেস)
RUN echo '[supervisord]' > /etc/supervisor/conf.d/supervisord.conf && \
    echo 'nodaemon=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'user=root' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo '[program:php-fpm]' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'command=/usr/sbin/php-fpm8.1 -F' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'autostart=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'autorestart=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo '[program:nginx]' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'command=/usr/sbin/nginx -g "daemon off;"' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'autostart=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'autorestart=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo '[program:ttyd]' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'command=/usr/local/bin/ttyd -c admin:admin123 -p 7681 -W bash' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'autostart=true' >> /etc/supervisor/conf.d/supervisord.conf && \
    echo 'autorestart=true' >> /etc/supervisor/conf.d/supervisord.conf

# ৭. মোবাইল-অপ্টিমাইজড ড্যাশবোর্ড + রেনিকা এআই কোর (index.html)
RUN echo '<!DOCTYPE html>' > /var/www/html/index.html && \
    echo '<html lang="en">' >> /var/www/html/index.html && \
    echo '<head>' >> /var/www/html/index.html && \
    echo '  <meta charset="UTF-8">' >> /var/www/html/index.html && \
    echo '  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">' >> /var/www/html/index.html && \
    echo '  <title>DRX Nexus Cloud OS</title>' >> /var/www/html/index.html && \
    echo '  <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;600;700&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">' >> /var/www/html/index.html && \
    echo '  <style>' >> /var/www/html/index.html && \
    echo '    :root { --bg: #07090e; --surface: rgba(17, 24, 39, 0.75); --border: rgba(255, 255, 255, 0.08); --cyan: #00f5d4; --violet: #7928ca; --text: #f8fafc; --muted: #94a3b8; }' >> /var/www/html/index.html && \
    echo '    * { box-sizing: border-box; margin: 0; padding: 0; -webkit-tap-highlight-color: transparent; }' >> /var/www/html/index.html && \
    echo '    body { font-family: "Space Grotesk", sans-serif; background: var(--bg); color: var(--text); min-height: 100vh; display: flex; justify-content: center; padding: 16px; background-image: radial-gradient(circle at 10% 10%, rgba(0,245,212,0.08) 0%, transparent 40%), radial-gradient(circle at 90% 90%, rgba(121,40,202,0.12) 0%, transparent 45%); }' >> /var/www/html/index.html && \
    echo '    .wrap { width: 100%; max-width: 440px; display: flex; flex-direction: column; gap: 16px; }' >> /var/www/html/index.html && \
    echo '    .nav { display: flex; align-items: center; justify-content: space-between; padding: 14px 18px; background: var(--surface); border: 1px solid var(--border); border-radius: 16px; backdrop-filter: blur(12px); }' >> /var/www/html/index.html && \
    echo '    .brand { display: flex; align-items: center; gap: 8px; font-weight: 700; font-size: 15px; color: #fff; }' >> /var/www/html/index.html && \
    echo '    .brand svg { width: 22px; height: 22px; color: var(--cyan); }' >> /var/www/html/index.html && \
    echo '    .badge { display: flex; align-items: center; gap: 6px; font-family: "JetBrains Mono", monospace; font-size: 11px; color: var(--cyan); background: rgba(0,245,212,0.1); border: 1px solid rgba(0,245,212,0.3); padding: 4px 10px; border-radius: 20px; }' >> /var/www/html/index.html && \
    echo '    .dot { width: 6px; height: 6px; background: var(--cyan); border-radius: 50%; box-shadow: 0 0 8px var(--cyan); }' >> /var/www/html/index.html && \
    echo '    .cards { display: flex; flex-direction: column; gap: 12px; }' >> /var/www/html/index.html && \
    echo '    .card { display: flex; align-items: center; gap: 14px; padding: 16px; background: var(--surface); border: 1px solid var(--border); border-radius: 16px; text-decoration: none; color: inherit; backdrop-filter: blur(12px); transition: 0.2s; }' >> /var/www/html/index.html && \
    echo '    .card:active { transform: scale(0.98); border-color: var(--cyan); }' >> /var/www/html/index.html && \
    echo '    .icon { width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; background: rgba(255,255,255,0.03); border: 1px solid var(--border); }' >> /var/www/html/index.html && \
    echo '    .icon svg { width: 22px; height: 22px; }' >> /var/www/html/index.html && \
    echo '    .meta { flex: 1; }' >> /var/www/html/index.html && \
    echo '    .meta h3 { font-size: 15px; font-weight: 600; margin-bottom: 2px; }' >> /var/www/html/index.html && \
    echo '    .meta p { font-size: 12px; color: var(--muted); }' >> /var/www/html/index.html && \
    echo '    .ai-box { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 16px; display: flex; flex-direction: column; gap: 12px; }' >> /var/www/html/index.html && \
    echo '    .ai-head { display: flex; align-items: center; justify-content: space-between; font-size: 13px; font-weight: 600; padding-bottom: 8px; border-bottom: 1px solid var(--border); }' >> /var/www/html/index.html && \
    echo '    .ai-head svg { width: 18px; height: 18px; color: var(--cyan); }' >> /var/www/html/index.html && \
    echo '    .ai-tag { font-family: "JetBrains Mono", monospace; font-size: 10px; color: var(--violet); background: rgba(121,40,202,0.15); padding: 2px 6px; border-radius: 4px; }' >> /var/www/html/index.html && \
    echo '    .chat { height: 130px; overflow-y: auto; display: flex; flex-direction: column; gap: 8px; font-size: 12px; }' >> /var/www/html/index.html && \
    echo '    .msg { padding: 8px 12px; border-radius: 10px; max-width: 85%; line-height: 1.4; }' >> /var/www/html/index.html && \
    echo '    .msg.bot { background: rgba(255,255,255,0.05); align-self: flex-start; }' >> /var/www/html/index.html && \
    echo '    .msg.user { background: rgba(0,245,212,0.15); border: 1px solid rgba(0,245,212,0.3); color: var(--cyan); align-self: flex-end; }' >> /var/www/html/index.html && \
    echo '    .input-row { display: flex; gap: 8px; }' >> /var/www/html/index.html && \
    echo '    .input-row input { flex: 1; background: rgba(0,0,0,0.4); border: 1px solid var(--border); border-radius: 10px; padding: 10px 12px; font-size: 13px; color: #fff; outline: none; }' >> /var/www/html/index.html && \
    echo '    .input-row input:focus { border-color: var(--cyan); }' >> /var/www/html/index.html && \
    echo '    .input-row button { background: var(--cyan); border: none; border-radius: 10px; padding: 0 14px; cursor: pointer; font-weight: 700; color: #000; }' >> /var/www/html/index.html && \
    echo '    .guide { background: var(--surface); border: 1px solid var(--border); border-radius: 16px; padding: 14px 16px; font-size: 12px; line-height: 1.6; color: var(--muted); }' >> /var/www/html/index.html && \
    echo '    .guide b { color: #fff; }' >> /var/www/html/index.html && \
    echo '    .guide code { font-family: "JetBrains Mono", monospace; background: rgba(0,0,0,0.4); color: var(--cyan); padding: 2px 6px; border-radius: 4px; }' >> /var/www/html/index.html && \
    echo '    .footer { text-align: center; font-size: 11px; font-family: "JetBrains Mono", monospace; color: #475569; margin-top: auto; padding: 8px 0; }' >> /var/www/html/index.html && \
    echo '  </style>' >> /var/www/html/index.html && \
    echo '</head>' >> /var/www/html/index.html && \
    echo '<body>' >> /var/www/html/index.html && \
    echo '  <div class="wrap">' >> /var/www/html/index.html && \
    echo '    <div class="nav">' >> /var/www/html/index.html && \
    echo '      <div class="brand">' >> /var/www/html/index.html && \
    echo '        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="12 2 2 7 12 12 22 7 12 2"/><polyline points="2 17 12 22 22 17"/><polyline points="2 12 12 17 22 12"/></svg>' >> /var/www/html/index.html && \
    echo '        <span>DRX CLOUD OS</span>' >> /var/www/html/index.html && \
    echo '      </div>' >> /var/www/html/index.html && \
    echo '      <div class="badge"><span class="dot"></span> ONLINE</div>' >> /var/www/html/index.html && \
    echo '    </div>' >> /var/www/html/index.html && \
    echo '    <div class="cards">' >> /var/www/html/index.html && \
    echo '      <a href="/admin" class="card">' >> /var/www/html/index.html && \
    echo '        <div class="icon" style="color:var(--cyan);"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/></svg></div>' >> /var/www/html/index.html && \
    echo '        <div class="meta"><h3>Storage & CPanel</h3><p>Upload ZIP, edit code & manage files</p></div>' >> /var/www/html/index.html && \
    echo '      </a>' >> /var/www/html/index.html && \
    echo '      <a href="/terminal" class="card">' >> /var/www/html/index.html && \
    echo '        <div class="icon" style="color:var(--violet);"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="4 17 10 11 4 5"/><line x1="12" y1="19" x2="20" y2="19"/></svg></div>' >> /var/www/html/index.html && \
    echo '        <div class="meta"><h3>Web Terminal</h3><p>Root Shell • Python bots & Pip</p></div>' >> /var/www/html/index.html && \
    echo '      </a>' >> /var/www/html/index.html && \
    echo '    </div>' >> /var/www/html/index.html && \
    echo '    <div class="ai-box">' >> /var/www/html/index.html && \
    echo '      <div class="ai-head">' >> /var/www/html/index.html && \
    echo '        <div style="display:flex;align-items:center;gap:6px;"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="10" rx="2"/><circle cx="12" cy="5" r="2"/><path d="M12 7v4"/><line x1="8" y1="16" x2="8" y2="16"/><line x1="16" y1="16" x2="16" y2="16"/></svg> RENIKA AI CORE</div>' >> /var/www/html/index.html && \
    echo '        <span class="ai-tag">ACTIVE</span>' >> /var/www/html/index.html && \
    echo '      </div>' >> /var/www/html/index.html && \
    echo '      <div class="chat" id="chat"><div class="msg bot">System online! How can I assist you with your deployment?</div></div>' >> /var/www/html/index.html && \
    echo '      <div class="input-row">' >> /var/www/html/index.html && \
    echo '        <input type="text" id="aiIn" placeholder="Type a message (hi, bot, status)..." onkeydown="if(event.keyCode===13)sendMsg()">' >> /var/www/html/index.html && \
    echo '        <button onclick="sendMsg()">Send</button>' >> /var/www/html/index.html && \
    echo '      </div>' >> /var/www/html/index.html && \
    echo '    </div>' >> /var/www/html/index.html && \
    echo '    <div class="guide">' >> /var/www/html/index.html && \
    echo '      <p>💡 <b>Host Sites:</b> Create folder in Storage (e.g. <code>app1</code>) & put <code>index.html</code>/<code>index.php</code>. Open at <code>/app1</code></p>' >> /var/www/html/index.html && \
    echo '      <p style="margin-top:6px;">🤖 <b>24/7 Python Bot:</b> <code>nohup python3 bot.py &</code></p>' >> /var/www/html/index.html && \
    echo '    </div>' >> /var/www/html/index.html && \
    echo '    <div class="footer">DRX NEXUS CLOUD • RAILWAY CONTAINER</div>' >> /var/www/html/index.html && \
    echo '  </div>' >> /var/www/html/index.html && \
    echo '  <script>' >> /var/www/html/index.html && \
    echo '    const chat=document.getElementById("chat"), inp=document.getElementById("aiIn");' >> /var/www/html/index.html && \
    echo '    function sendMsg(){' >> /var/www/html/index.html && \
    echo '      const t=inp.value.trim(); if(!t)return;' >> /var/www/html/index.html && \
    echo '      addM("user",t); inp.value="";' >> /var/www/html/index.html && \
    echo '      setTimeout(()=>{' >> /var/www/html/index.html && \
    echo '        const q=t.toLowerCase();' >> /var/www/html/index.html && \
    echo '        let r="I am Renika AI. You can manage files via Storage and run Python bots in Terminal.";' >> /var/www/html/index.html && \
    echo '        if(q.includes("hi")||q.includes("hello")) r="Hello Commander! Renika Cloud Core is active and ready.";' >> /var/www/html/index.html && \
    echo '        else if(q.includes("kemon")||q.includes("how are you")) r="All systems operational (100%). Ready for deployment.";' >> /var/www/html/index.html && \
    echo '        else if(q.includes("bot")||q.includes("telegram")) r="To run a Telegram bot 24/7, open Terminal and run: nohup python3 bot.py &";' >> /var/www/html/index.html && \
    echo '        else if(q.includes("host")||q.includes("site")) r="Make a folder in Storage (e.g. site1) with index.html. Access it at /site1";' >> /var/www/html/index.html && \
    echo '        addM("bot",r);' >> /var/www/html/index.html && \
    echo '      },300);' >> /var/www/html/index.html && \
    echo '    }' >> /var/www/html/index.html && \
    echo '    function addM(cls,txt){' >> /var/www/html/index.html && \
    echo '      const d=document.createElement("div"); d.className="msg "+cls; d.innerText=txt;' >> /var/www/html/index.html && \
    echo '      chat.appendChild(d); chat.scrollTop=chat.scrollHeight;' >> /var/www/html/index.html && \
    echo '    }' >> /var/www/html/index.html && \
    echo '  </script>' >> /var/www/html/index.html && \
    echo '</body>' >> /var/www/html/index.html && \
    echo '</html>' >> /var/www/html/index.html

# ৮. রেলওয়ে ডাইনামিক পোর্ট ও সার্ভিস রানার (entrypoint.sh) তৈরি
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'PORT="${PORT:-8080}"' >> /entrypoint.sh && \
    echo 'sed -i "s/__PORT__/$PORT/g" /etc/nginx/sites-available/default' >> /entrypoint.sh && \
    echo 'chown -R www-data:www-data /var/www/html' >> /entrypoint.sh && \
    echo 'chmod -R 775 /var/www/html' >> /entrypoint.sh && \
    echo 'exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# পারমিশন নিশ্চিতকরণ
RUN chown -R www-data:www-data /var/www/html && chmod -R 775 /var/www/html

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
