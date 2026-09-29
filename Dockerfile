FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ১. সিস্টেম ডিপেনডেন্সি, Nginx, PHP 8.1, Python 3 এবং সুপারভাইজর ইনস্টল
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

# ২. ওয়েব টার্মিনাল বাইনারি (ttyd) সংগ্রহ
RUN curl -sLk https://github.com/tsl0922/ttyd/releases/download/1.7.4/ttyd.x86_64 -o /usr/local/bin/ttyd \
    && chmod +x /usr/local/bin/ttyd

# ৩. ফোল্ডার স্ট্রাকচার প্রস্তুতকরণ
RUN mkdir -p /var/www/html/admin /var/log/supervisor /run/php

# ৪. TinyFileManager অ্যাডমিন প্যানেল ডাউনলোড
RUN curl -sLk https://raw.githubusercontent.com/prasathmani/tinyfilemanager/master/tinyfilemanager.php -o /var/www/html/admin/index.php

# ৫. Nginx সার্ভার ব্লক কনফিগারেশন তৈরি (পোর্ট ৮০৮০ / ডাইনামিক পোর্ট)
RUN echo 'server {' > /etc/nginx/sites-available/default && \
    echo '    listen __PORT__ default_server;' >> /etc/nginx/sites-available/default && \
    echo '    listen [::]:__PORT__ default_server;' >> /etc/nginx/sites-available/default && \
    echo '    root /var/www/html;' >> /etc/nginx/sites-available/default && \
    echo '    index index.html index.php;' >> /etc/nginx/sites-available/default && \
    echo '    server_name _;' >> /etc/nginx/sites-available/default && \
    echo '    client_max_body_size 512M;' >> /etc/nginx/sites-available/default && \
    echo '    location / {' >> /etc/nginx/sites-available/default && \
    echo '        try_files $uri$uri/ /index.html;' >> /etc/nginx/sites-available/default && \
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

# ৬. সুপারভাইজর কনফিগারেশন তৈরি
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

# ৭. লোকাল এআই ইন্টারফেস তৈরি (কোড কপি + ভয়েস স্পিচ প্লেয়ার সংযুক্ত)
RUN echo '<!DOCTYPE html>' > /var/www/html/index.html && \
    echo '<html lang="bn">' >> /var/www/html/index.html && \
    echo '<head>' >> /var/www/html/index.html && \
    echo '  <meta charset="UTF-8">' >> /var/www/html/index.html && \
    echo '  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">' >> /var/www/html/index.html && \
    echo '  <title>Nexus Local AI Console</title>' >> /var/www/html/index.html && \
    echo '  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">' >> /var/www/html/index.html && \
    echo '  <style>' >> /var/www/html/index.html && \
    echo '    :root { --bg: #090b10; --card: #111622; --border: #1f293d; --accent: #00f0ff; --accent-glow: rgba(0,240,255,0.15); --text: #f1f5f9; --text-dim: #94a3b8; }' >> /var/www/html/index.html && \
    echo '    * { box-sizing: border-box; margin: 0; padding: 0; -webkit-tap-highlight-color: transparent; }' >> /var/www/html/index.html && \
    echo '    body { font-family: "Plus Jakarta Sans", sans-serif; background: var(--bg); color: var(--text); min-height: 100vh; display: flex; justify-content: center; padding: 12px; }' >> /var/www/html/index.html && \
    echo '    .container { width: 100%; max-width: 520px; display: flex; flex-direction: column; height: calc(100vh - 24px); gap: 10px; }' >> /var/www/html/index.html && \
    echo '    .header { display: flex; justify-content: space-between; align-items: center; padding: 10px 14px; background: var(--card); border: 1px solid var(--border); border-radius: 12px; }' >> /var/www/html/index.html && \
    echo '    .logo { font-weight: 700; font-size: 15px; color: var(--accent); letter-spacing: 0.5px; }' >> /var/www/html/index.html && \
    echo '    .links { display: flex; gap: 8px; }' >> /var/www/html/index.html && \
    echo '    .link-btn { text-decoration: none; font-size: 12px; font-weight: 600; padding: 6px 10px; border-radius: 8px; background: #1a2233; color: var(--text); border: 1px solid var(--border); }' >> /var/www/html/index.html && \
    echo '    .chat-box { flex: 1; overflow-y: auto; display: flex; flex-direction: column; gap: 12px; padding: 12px; background: var(--card); border: 1px solid var(--border); border-radius: 14px; }' >> /var/www/html/index.html && \
    echo '    .msg { display: flex; flex-direction: column; gap: 6px; max-width: 90%; font-size: 13px; line-height: 1.5; }' >> /var/www/html/index.html && \
    echo '    .msg.user { align-self: flex-end; background: var(--accent-glow); border: 1px solid rgba(0,240,255,0.3); color: var(--accent); padding: 8px 12px; border-radius: 12px 12px 2px 12px; }' >> /var/www/html/index.html && \
    echo '    .msg.bot { align-self: flex-start; background: #161d2b; border: 1px solid var(--border); padding: 10px 12px; border-radius: 12px 12px 12px 2px; }' >> /var/www/html/index.html && \
    echo '    .actions-row { display: flex; gap: 6px; margin-top: 4px; }' >> /var/www/html/index.html && \
    echo '    .act-btn { background: #222c3d; border: none; color: var(--text-dim); padding: 4px 8px; border-radius: 6px; font-size: 11px; cursor: pointer; display: flex; align-items: center; gap: 4px; }' >> /var/www/html/index.html && \
    echo '    .act-btn:hover { color: var(--accent); }' >> /var/www/html/index.html && \
    echo '    .code-block { background: #080a0f; border: 1px solid #2d3748; border-radius: 8px; margin: 6px 0; overflow: hidden; font-family: "JetBrains Mono", monospace; }' >> /var/www/html/index.html && \
    echo '    .code-head { display: flex; justify-content: space-between; align-items: center; background: #131924; padding: 4px 10px; font-size: 11px; color: var(--text-dim); }' >> /var/www/html/index.html && \
    echo '    .copy-btn { background: var(--accent); color: #000; border: none; padding: 2px 8px; border-radius: 4px; font-size: 11px; font-weight: 700; cursor: pointer; }' >> /var/www/html/index.html && \
    echo '    .code-block pre { padding: 10px; font-size: 12px; overflow-x: auto; color: #38bdf8; white-space: pre-wrap; word-break: break-all; }' >> /var/www/html/index.html && \
    echo '    .input-bar { display: flex; gap: 8px; padding-bottom: 4px; }' >> /var/www/html/index.html && \
    echo '    .input-bar input { flex: 1; background: var(--card); border: 1px solid var(--border); border-radius: 12px; padding: 12px; font-size: 13px; color: #fff; outline: none; }' >> /var/www/html/index.html && \
    echo '    .input-bar button { background: var(--accent); border: none; border-radius: 12px; padding: 0 16px; font-weight: 700; color: #000; cursor: pointer; }' >> /var/www/html/index.html && \
    echo '  </style>' >> /var/www/html/index.html && \
    echo '</head>' >> /var/www/html/index.html && \
    echo '<body>' >> /var/www/html/index.html && \
    echo '  <div class="container">' >> /var/www/html/index.html && \
    echo '    <div class="header">' >> /var/www/html/index.html && \
    echo '      <div class="logo">⚡ NEXUS AI LOCAL</div>' >> /var/www/html/index.html && \
    echo '      <div class="links">' >> /var/www/html/index.html && \
    echo '        <a href="/admin" class="link-btn">Storage</a>' >> /var/www/html/index.html && \
    echo '        <a href="/terminal" class="link-btn">Terminal</a>' >> /var/www/html/index.html && \
    echo '      </div>' >> /var/www/html/index.html && \
    echo '    </div>' >> /var/www/html/index.html && \
    echo '    <div class="chat-box" id="box">' >> /var/www/html/index.html && \
    echo '      <div class="msg bot">' >> /var/www/html/index.html && \
    echo '        <div class="text">আমি আপনার লোকাল সার্ভার এআই। কোনো এপিআই ছাড়া অফলাইনে কোড তৈরি, সাহায্য বা টেক্সট ভয়েসে পড়ে শোনানোর জন্য আমি প্রস্তুত।</div>' >> /var/www/html/index.html && \
    echo '        <div class="actions-row">' >> /var/www/html/index.html && \
    echo '          <button class="act-btn" onclick="speakMsg(this)">🔊 শুনুন</button>' >> /var/www/html/index.html && \
    echo '          <button class="act-btn" onclick="copyMsg(this)">📋 কপি</button>' >> /var/www/html/index.html && \
    echo '        </div>' >> /var/www/html/index.html && \
    echo '      </div>' >> /var/www/html/index.html && \
    echo '    </div>' >> /var/www/html/index.html && \
    echo '    <div class="input-bar">' >> /var/www/html/index.html && \
    echo '      <input type="text" id="userInput" placeholder="মেসেজ বা কোড তৈরির অনুরোধ লিখুন..." onkeydown="if(event.key===\"Enter\")send()">' >> /var/www/html/index.html && \
    echo '      <button onclick="send()">Send</button>' >> /var/www/html/index.html && \
    echo '    </div>' >> /var/www/html/index.html && \
    echo '  </div>' >> /var/www/html/index.html && \
    echo '  <script>' >> /var/www/html/index.html && \
    echo '    const box = document.getElementById("box");' >> /var/www/html/index.html && \
    echo '    const input = document.getElementById("userInput");' >> /var/www/html/index.html && \
    echo '    function send() {' >> /var/www/html/index.html && \
    echo '      const val = input.value.trim(); if (!val) return;' >> /var/www/html/index.html && \
    echo '      renderUser(val); input.value = "";' >> /var/www/html/index.html && \
    echo '      setTimeout(() => processAi(val), 350);' >> /var/www/html/index.html && \
    echo '    }' >> /var/www/html/index.html && \
    echo '    function renderUser(txt) {' >> /var/www/html/index.html && \
    echo '      const div = document.createElement("div"); div.className = "msg user";' >> /var/www/html/index.html && \
    echo '      div.innerText = txt; box.appendChild(div); box.scrollTop = box.scrollHeight;' >> /var/www/html/index.html && \
    echo '    }' >> /var/www/html/index.html && \
    echo '    function processAi(query) {' >> /var/www/html/index.html && \
    echo '      const q = query.toLowerCase();' >> /var/www/html/index.html && \
    echo '      let reply = "";' >> /var/www/html/index.html && \
    echo '      let code = "";' >> /var/www/html/index.html && \
    echo '      let lang = "code";' >> /var/www/html/index.html && \
    echo '      if (q.includes("python") || q.includes("bot") || q.includes("টেলিগ্রাম")) {' >> /var/www/html/index.html && \
    echo '        reply = "আপনার জন্য পাইথন টেলিগ্রাম বটের বেসিক কোড নিচে দেওয়া হলো:";' >> /var/www/html/index.html && \
    echo '        lang = "python";' >> /var/www/html/index.html && \
    echo '        code = "import telebot\n\nTOKEN = \"YOUR_BOT_TOKEN\"\nbot = telebot.TeleBot(TOKEN)\n\n@bot.message_handler(commands=[\x27start\x27])\ndef start(msg):\n    bot.reply_to(msg, \"বট সক্রিয় আছে!\")\n\nbot.infinity_polling()";' >> /var/www/html/index.html && \
    echo '      } else if (q.includes("html") || q.includes("ওয়েবসাইট") || q.includes("site")) {' >> /var/www/html/index.html && \
    echo '        reply = "এখানে একটি সুন্দর ডার্ক মোড HTML পেজের কোড দেওয়া হলো:";' >> /var/www/html/index.html && \
    echo '        lang = "html";' >> /var/www/html/index.html && \
    echo '        code = "<!DOCTYPE html>\n<html>\n<head><title>My App</title></head>\n<body style=\"background:#111;color:#fff;text-align:center;\">\n  <h1>স্বাগতম</h1>\n</body>\n</html>";' >> /var/www/html/index.html && \
    echo '      } else if (q.includes("hi") || q.includes("hello") || q.includes("হ্যালো") || q.includes("হাই")) {' >> /var/www/html/index.html && \
    echo '        reply = "হ্যালো! আমি লোকাল সিস্টেম এআই। আপনি যেকোনো কোড তৈরি বা কমান্ডের সাহায্য চাইতে পারেন।";' >> /var/www/html/index.html && \
    echo '      } else if (q.includes("কেমন আছো") || q.includes("how are you")) {' >> /var/www/html/index.html && \
    echo '        reply = "আমি সম্পূর্ণ সক্রিয় এবং ১০০% প্রস্তুত। আপনার কি কোনো কোড বা স্ক্রিপ্ট প্রয়োজন?";' >> /var/www/html/index.html && \
    echo '      } else if (q.includes("run") || q.includes("চালাব") || q.includes("রান")) {' >> /var/www/html/index.html && \
    echo '        reply = "টার্মিনালে ব্যাকগ্রাউন্ডে কোড রান রাখতে এই কমান্ডটি দিন:";' >> /var/www/html/index.html && \
    echo '        lang = "bash";' >> /var/www/html/index.html && \
    echo '        code = "nohup python3 bot.py > bot.log 2>&1 &";' >> /var/www/html/index.html && \
    echo '      } else {' >> /var/www/html/index.html && \
    echo '        reply = \"আমি আপনার বার্তা বুঝতে পেরেছি: \\\"\" + query + \"\\\"। ফাইল সংরক্ষণ করতে /admin এবং পাইথন বা ব্যাশ স্ক্রিপ্ট চালাতে /terminal ব্যবহার করুন।\";' >> /var/www/html/index.html && \
    echo '      }' >> /var/www/html/index.html && \
    echo '      renderBot(reply, code, lang);' >> /var/www/html/index.html && \
    echo '    }' >> /var/www/html/index.html && \
    echo '    function renderBot(text, code, lang) {' >> /var/www/html/index.html && \
    echo '      const div = document.createElement("div"); div.className = "msg bot";' >> /var/www/html/index.html && \
    echo '      let h = `<div class="text">${text}</div>`;' >> /var/www/html/index.html && \
    echo '      if (code) {' >> /var/www/html/index.html && \
    echo '        h += `<div class="code-block"><div class="code-head"><span>${lang}</span><button class="copy-btn" onclick="copySnippet(this)">কপি কোড</button></div><pre><code>${escapeHtml(code)}</code></pre></div>`;' >> /var/www/html/index.html && \
    echo '      }' >> /var/www/html/index.html && \
    echo '      h += `<div class="actions-row"><button class="act-btn" onclick="speakMsg(this)">🔊 শুনুন</button><button class="act-btn" onclick="copyMsg(this)">📋 কপি</button></div>`;' >> /var/www/html/index.html && \
    echo '      div.innerHTML = h; box.appendChild(div); box.scrollTop = box.scrollHeight;' >> /var/www/html/index.html && \
    echo '    }' >> /var/www/html/index.html && \
    echo '    function escapeHtml(s) { return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;"); }' >> /var/www/html/index.html && \
    echo '    function copySnippet(btn) {' >> /var/www/html/index.html && \
    echo '      const code = btn.closest(".code-block").querySelector("code").innerText;' >> /var/www/html/index.html && \
    echo '      navigator.clipboard.writeText(code).then(() => { btn.innerText = "কপি হয়েছে!"; setTimeout(() => btn.innerText = "কপি কোড", 2000); });' >> /var/www/html/index.html && \
    echo '    }' >> /var/www/html/index.html && \
    echo '    function copyMsg(btn) {' >> /var/www/html/index.html && \
    echo '      const txt = btn.closest(".msg").querySelector(".text").innerText;' >> /var/www/html/index.html && \
    echo '      navigator.clipboard.writeText(txt).then(() => { btn.innerText = "কপি হয়েছে!"; setTimeout(() => btn.innerText = "📋 কপি", 2000); });' >> /var/www/html/index.html && \
    echo '    }' >> /var/www/html/index.html && \
    echo '    function speakMsg(btn) {' >> /var/www/html/index.html && \
    echo '      if (!("speechSynthesis" in window)) { alert("আপনার ব্রাউজারে স্পিচ সিন্থেসিস সমর্থন নেই"); return; }' >> /var/www/html/index.html && \
    echo '      window.speechSynthesis.cancel();' >> /var/www/html/index.html && \
    echo '      const txt = btn.closest(".msg").querySelector(".text").innerText;' >> /var/www/html/index.html && \
    echo '      const utter = new SpeechSynthesisUtterance(txt);' >> /var/www/html/index.html && \
    echo '      utter.lang = "bn-BD";' >> /var/www/html/index.html && \
    echo '      window.speechSynthesis.speak(utter);' >> /var/www/html/index.html && \
    echo '    }' >> /var/www/html/index.html && \
    echo '  </script>' >> /var/www/html/index.html && \
    echo '</body>' >> /var/www/html/index.html && \
    echo '</html>' >> /var/www/html/index.html

# ৮. রেলওয়ে পোর্ট এবং সার্ভিস রানার স্ক্রিপ্ট (entrypoint.sh)
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'PORT="${PORT:-8080}"' >> /entrypoint.sh && \
    echo 'sed -i "s/__PORT__/$PORT/g" /etc/nginx/sites-available/default' >> /entrypoint.sh && \
    echo 'chown -R www-data:www-data /var/www/html' >> /entrypoint.sh && \
    echo 'chmod -R 775 /var/www/html' >> /entrypoint.sh && \
    echo 'exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# ফাইল পারমিশন নিশ্চিতকরণ
RUN chown -R www-data:www-data /var/www/html && chmod -R 775 /var/www/html

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
