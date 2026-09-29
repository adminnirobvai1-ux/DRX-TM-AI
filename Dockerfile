FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# ১. সিস্টেম ডিপেনডেন্সি, Nginx, PHP-FPM, Python ও প্যাকেজ ইনস্টল
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

# ৫. Nginx সার্ভার ব্লক কনফিগারেশন তৈরি
RUN /bin/bash -c "cat << 'EOF' > /etc/nginx/sites-available/default
server {
    listen __PORT__ default_server;
    listen [::]:__PORT__ default_server;

    root /var/www/html;
    index index.php index.html;

    server_name _;
    client_max_body_size 512M;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location /terminal/ {
        proxy_pass http://127.0.0.1:7681/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \"upgrade\";
        proxy_set_header Host \$host;
        proxy_read_timeout 86400;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF"

# ৬. সুপারভাইজর কনফিগারেশন তৈরি (ব্যাকগ্রাউন্ড সার্ভিস)
RUN /bin/bash -c "cat << 'EOF' > /etc/supervisor/conf.d/supervisord.conf
[supervisord]
nodaemon=true
user=root

[program:php-fpm]
command=/usr/sbin/php-fpm8.1 -F
autostart=true
autorestart=true

[program:nginx]
command=/usr/sbin/nginx -g 'daemon off;'
autostart=true
autorestart=true

[program:ttyd]
command=/usr/local/bin/ttyd -c admin:admin123 -p 7681 -W bash
autostart=true
autorestart=true
EOF"

# ৭. আল্ট্রা-প্রিমিয়াম মোবাইল-ফার্স্ট ড্যাশবোর্ড + বিল্ট-ইন AI অ্যাসিস্ট্যান্ট
RUN /bin/bash -c "cat << 'EOF' > /var/www/html/index.html
<!DOCTYPE html>
<html lang=\"en\">
<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no\">
    <title>DRX Nexus Cloud Control</title>
    <link rel=\"preconnect\" href=\"https://fonts.googleapis.com\">
    <link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin>
    <link href=\"https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap\" rel=\"stylesheet\">
    <style>
        :root {
            --bg: #07090e;
            --surface: rgba(17, 24, 39, 0.75);
            --surface-hover: rgba(30, 41, 59, 0.85);
            --border: rgba(255, 255, 255, 0.08);
            --accent-cyan: #00f5d4;
            --accent-blue: #00bbf9;
            --accent-violet: #7928ca;
            --text-primary: #f8fafc;
            --text-secondary: #94a3b8;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            -webkit-tap-highlight-color: transparent;
        }

        body {
            font-family: 'Space Grotesk', sans-serif;
            background-color: var(--bg);
            color: var(--text-primary);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            padding: 16px;
            background-image: 
                radial-gradient(circle at 15% 10%, rgba(0, 245, 212, 0.08) 0%, transparent 40%),
                radial-gradient(circle at 85% 85%, rgba(121, 40, 202, 0.12) 0%, transparent 45%);
            background-attachment: fixed;
        }

        .wrapper {
            width: 100%;
            max-width: 460px;
            display: flex;
            flex-direction: column;
            gap: 18px;
        }

        /* Top Header */
        .top-nav {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 14px 18px;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 16px;
            backdrop-filter: blur(16px);
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .brand-icon {
            width: 24px;
            height: 24px;
            color: var(--accent-cyan);
        }

        .brand-name {
            font-size: 15px;
            font-weight: 700;
            letter-spacing: 0.5px;
            background: linear-gradient(135deg, #ffffff 30%, var(--accent-cyan));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .status-pill {
            display: flex;
            align-items: center;
            gap: 6px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 11px;
            font-weight: 600;
            color: var(--accent-cyan);
            background: rgba(0, 245, 212, 0.08);
            border: 1px solid rgba(0, 245, 212, 0.25);
            padding: 5px 12px;
            border-radius: 24px;
        }

        .dot {
            width: 6px;
            height: 6px;
            background-color: var(--accent-cyan);
            border-radius: 50%;
            box-shadow: 0 0 10px var(--accent-cyan);
        }

        /* Action Cards */
        .cards-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .nav-card {
            display: flex;
            align-items: center;
            gap: 16px;
            padding: 16px 18px;
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 18px;
            text-decoration: none;
            color: inherit;
            backdrop-filter: blur(12px);
            transition: all 0.2s ease;
        }

        .nav-card:active {
            transform: scale(0.98);
            border-color: var(--accent-cyan);
            background: var(--surface-hover);
        }

        .icon-box {
            width: 46px;
            height: 46px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid var(--border);
        }

        .icon-box svg {
            width: 22px;
            height: 22px;
        }

        .card-meta {
            flex-grow: 1;
        }

        .card-meta h3 {
            font-size: 15px;
            font-weight: 600;
            margin-bottom: 2px;
        }

        .card-meta p {
            font-size: 12px;
            color: var(--text-secondary);
        }

        .chevron svg {
            width: 18px;
            height: 18px;
            color: var(--text-secondary);
        }

        /* AI Interactive Chat Console */
        .ai-console {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 18px;
            padding: 16px;
            backdrop-filter: blur(16px);
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .ai-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--border);
        }

        .ai-title {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            font-weight: 600;
            color: var(--text-primary);
        }

        .ai-title svg {
            width: 18px;
            height: 18px;
            color: var(--accent-cyan);
        }

        .ai-badge {
            font-family: 'JetBrains Mono', monospace;
            font-size: 10px;
            color: var(--accent-violet);
            background: rgba(121, 40, 202, 0.15);
            border: 1px solid rgba(121, 40, 202, 0.3);
            padding: 2px 8px;
            border-radius: 6px;
        }

        .chat-box {
            height: 150px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 8px;
            padding-right: 4px;
        }

        .chat-box::-webkit-scrollbar {
            width: 4px;
        }
        .chat-box::-webkit-scrollbar-thumb {
            background: rgba(255,255,255,0.1);
            border-radius: 4px;
        }

        .msg {
            max-width: 85%;
            padding: 8px 12px;
            border-radius: 12px;
            font-size: 12px;
            line-height: 1.4;
        }

        .msg.bot {
            align-self: flex-start;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid var(--border);
            color: var(--text-primary);
        }

        .msg.user {
            align-self: flex-end;
            background: linear-gradient(135deg, rgba(0, 245, 212, 0.15), rgba(0, 187, 249, 0.15));
            border: 1px solid rgba(0, 245, 212, 0.3);
            color: var(--accent-cyan);
        }

        .chat-input-row {
            display: flex;
            gap: 8px;
        }

        .chat-input {
            flex-grow: 1;
            background: rgba(0, 0, 0, 0.3);
            border: 1px solid var(--border);
            border-radius: 12px;
            padding: 10px 14px;
            font-size: 13px;
            color: var(--text-primary);
            font-family: inherit;
            outline: none;
            transition: border-color 0.2s;
        }

        .chat-input:focus {
            border-color: var(--accent-cyan);
        }

        .chat-send-btn {
            background: var(--accent-cyan);
            border: none;
            border-radius: 12px;
            padding: 0 16px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: opacity 0.2s;
        }

        .chat-send-btn svg {
            width: 16px;
            height: 16px;
            color: #000;
        }

        /* Routing Guide Info */
        .specs-panel {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: 18px;
            padding: 14px 16px;
            font-size: 12px;
            line-height: 1.6;
        }

        .specs-panel h4 {
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--text-secondary);
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .specs-panel code {
            font-family: 'JetBrains Mono', monospace;
            background: rgba(0,0,0,0.4);
            color: var(--accent-cyan);
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 11px;
            border: 1px solid rgba(255,255,255,0.06);
        }

        .footer {
            text-align: center;
            font-size: 11px;
            font-family: 'JetBrains Mono', monospace;
            color: #475569;
            margin-top: auto;
            padding: 10px 0;
        }
    </style>
</head>
<body>

    <div class=\"wrapper\">
        <!-- Top Nav -->
        <div class=\"top-nav\">
            <div class=\"brand\">
                <svg class=\"brand-icon\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\">
                    <polygon points=\"12 2 2 7 12 12 22 7 12 2\"/>
                    <polyline points=\"2 17 12 22 22 17\"/>
                    <polyline points=\"2 12 12 17 22 12\"/>
                </svg>
                <span class=\"brand-name\">NEXUS HOSTING OS</span>
            </div>
            <div class=\"status-pill\">
                <span class=\"dot\"></span>
                ONLINE
            </div>
        </div>

        <!-- Action Links -->
        <div class=\"cards-list\">
            <a href=\"/admin\" class=\"nav-card\">
                <div class=\"icon-box\" style=\"color: var(--accent-cyan); border-color: rgba(0, 245, 212, 0.2);\">
                    <svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\">
                        <path d=\"M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z\"/>
                    </svg>
                </div>
                <div class=\"card-meta\">
                    <h3>Storage & File Manager</h3>
                    <p>Web CPanel • Deploy, ZIP, Edit & Organize</p>
                </div>
                <div class=\"chevron\">
                    <svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><polyline points=\"9 18 15 12 9 6\"/></svg>
                </div>
            </a>

            <a href=\"/terminal\" class=\"nav-card\">
                <div class=\"icon-box\" style=\"color: var(--accent-violet); border-color: rgba(121, 40, 202, 0.3);\">
                    <svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\">
                        <polyline points=\"4 17 10 11 4 5\"/>
                        <line x1=\"12\" y1=\"19\" x2=\"20\" y2=\"19\"/>
                    </svg>
                </div>
                <div class=\"card-meta\">
                    <h3>Web Terminal Console</h3>
                    <p>Root Shell • Python Bots, Pip & Background Tasks</p>
                </div>
                <div class=\"chevron\">
                    <svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><polyline points=\"9 18 15 12 9 6\"/></svg>
                </div>
            </a>
        </div>

        <!-- Integrated Renika AI Assistant -->
        <div class=\"ai-console\">
            <div class=\"ai-header\">
                <div class=\"ai-title\">
                    <svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\">
                        <rect x=\"3\" y=\"11\" width=\"18\" height=\"10\" rx=\"2\"/>
                        <circle cx=\"12\" cy=\"5\" r=\"2\"/>
                        <path d=\"M12 7v4\"/>
                        <line x1=\"8\" y1=\"16\" x2=\"8\" y2=\"16\"/>
                        <line x1=\"16\" y1=\"16\" x2=\"16\" y2=\"16\"/>
                    </svg>
                    <span>RENIKA CORE AI</span>
                </div>
                <span class=\"ai-badge\">ACTIVE NODE</span>
            </div>

            <div class=\"chat-box\" id=\"chatBox\">
                <div class=\"msg bot\">Greetings! I am Renika. How may I assist your cloud environment today?</div>
            </div>

            <div class=\"chat-input-row\">
                <input type=\"text\" id=\"aiInput\" class=\"chat-input\" placeholder=\"Type a message (e.g. hi, help, bot)...\" autocomplete=\"off\" onkeydown=\"if(event.key === 'Enter') handleSend()\">
                <button class=\"chat-send-btn\" onclick=\"handleSend()\">
                    <svg viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\">
                        <line x1=\"22\" y1=\"2\" x2=\"11\" y2=\"13\"/>
                        <polygon points=\"22 2 15 22 11 13 2 9 22 2\"/>
                    </svg>
                </button>
            </div>
        </div>

        <!-- System Architecture / Routing Guide -->
        <div class=\"specs-panel\">
            <h4>
                <svg width=\"14\" height=\"14\" viewBox=\"0 0 24 24\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"2\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><circle cx=\"12\" cy=\"12\" r=\"10\"/><line x1=\"12\" y1=\"16\" x2=\"12\" y2=\"12\"/><line x1=\"12\" y1=\"8\" x2=\"12.01\" y2=\"8\"/></svg>
                Routing & Setup Guide
            </h4>
            <p>1. Open <b>Storage</b> and create any folder (e.g. <code>app1</code>).</p>
            <p>2. Upload your <code>index.html</code> or <code>index.php</code> inside.</p>
            <p>3. Directly open: <code>your-url.railway.app/app1</code></p>
            <p style=\"margin-top: 6px;\">To run Python Bots 24/7 in Terminal:<br><code>nohup python3 bot.py &</code></p>
        </div>

        <div class=\"footer\">
            SYS_ENV: UBUNTU 22.04 • NGINX PHP8.1 • TTYD ACTIVE
        </div>
    </div>

    <!-- AI Core Engine Logic -->
    <script>
        const chatBox = document.getElementById('chatBox');
        const aiInput = document.getElementById('aiInput');

        function appendMessage(sender, text) {
            const msg = document.createElement('div');
            msg.className = 'msg ' + sender;
            msg.innerText = text;
            chatBox.appendChild(msg);
            chatBox.scrollTop = chatBox.scrollHeight;
        }

        function handleSend() {
            const query = aiInput.value.trim();
            if (!query) return;

            appendMessage('user', query);
            aiInput.value = '';

            setTimeout(() => {
                const response = getAiResponse(query.toLowerCase());
                appendMessage('bot', response);
            }, 300);
        }

        function getAiResponse(q) {
            if (q.includes('hi') || q.includes('hello') || q.includes('hey')) {
                return \"Hello Commander! Renika system is fully online and awaiting your command.\";
            }
            if (q.includes('how are you') || q.includes('kemon')) {
                return \"All system diagnostics are green (100% operational). How is your deployment going?\";
            }
            if (q.includes('who are you') || q.includes('tumi ke')) {
                return \"I am Renika AI Core, your smart hosting and cloud console supervisor.\";
            }
            if (q.includes('bot') || q.includes('telegram') || q.includes('python')) {
                return \"To run your Telegram bot 24/7, open Web Terminal and type: nohup python3 your_bot.py &\";
            }
            if (q.includes('site') || q.includes('host') || q.includes('folder')) {
                return \"Create a folder in File Manager (e.g. 'myproject') and put your index.php/html there. It will load instantly at /myproject!\";
            }
            if (q.includes('status') || q.includes('ping')) {
                return \"Status: OK. Services Active: Nginx, PHP-FPM, Python3, TTYD Console.\";
            }
            return \"Understood. You can configure and run full Python, PHP, or HTML projects via the Storage and Terminal panels above.\";
        }
    </script>
</body>
</html>
EOF"

# ৮. এন্ট্রি পয়েন্ট স্ক্রিপ্ট তৈরি
RUN /bin/bash -c "cat << 'EOF' > /entrypoint.sh
#!/bin/bash
PORT=\"\${PORT:-8080}\"
sed -i \"s/__PORT__/\$PORT/g\" /etc/nginx/sites-available/default
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
EOF"

RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
