#!/bin/bash
set -euxo pipefail

yum update -y
yum install -y nginx

cat > /usr/share/nginx/html/index.html <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Two-Tier App</title>
  <style>
    :root {
      color-scheme: light;
      --page-bg: #f3f6fb;
      --card-bg: #ffffff;
      --ink: #142033;
      --muted: #5c6b80;
      --border: #d8e0eb;
      --accent: #0f766e;
      --accent-soft: #ccfbf1;
      --table-stripe: #f8fafc;
      --shadow: 0 18px 38px rgba(15, 23, 42, 0.08);
    }

    * {
      box-sizing: border-box;
    }

    body {
      margin: 0;
      min-height: 100vh;
      font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
      background: linear-gradient(180deg, #eef4fb 0%, #f7fbff 100%);
      color: var(--ink);
    }

    .page {
      max-width: 1100px;
      margin: 0 auto;
      padding: 40px 20px 48px;
    }

    .hero {
      margin-bottom: 28px;
      padding: 28px;
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 20px;
      box-shadow: var(--shadow);
    }

    h1 {
      margin: 0 0 10px;
      font-size: 2.2rem;
      line-height: 1.2;
    }

    .subtitle {
      margin: 0;
      color: var(--muted);
      font-size: 1.05rem;
    }

    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
      gap: 20px;
    }

    .card {
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 20px;
      padding: 24px;
      box-shadow: var(--shadow);
    }

    .card h2 {
      margin-top: 0;
      margin-bottom: 18px;
      font-size: 1.3rem;
    }

    .status-pill {
      display: inline-block;
      margin-bottom: 18px;
      padding: 8px 14px;
      border-radius: 999px;
      background: var(--accent-soft);
      color: var(--accent);
      font-weight: 700;
    }

    .meta-list {
      display: grid;
      grid-template-columns: 120px 1fr;
      gap: 10px 12px;
      margin: 0;
    }

    .meta-list dt {
      color: var(--muted);
      font-weight: 600;
    }

    .meta-list dd {
      margin: 0;
      word-break: break-word;
    }

    .message {
      margin: 0 0 18px;
      font-size: 1rem;
      color: var(--ink);
    }

    .table-wrap {
      overflow-x: auto;
      border: 1px solid var(--border);
      border-radius: 14px;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      min-width: 440px;
    }

    th,
    td {
      padding: 12px 14px;
      text-align: left;
      border-bottom: 1px solid var(--border);
    }

    thead {
      background: #eef2f7;
    }

    tbody tr:nth-child(even) {
      background: var(--table-stripe);
    }

    tbody tr:last-child td {
      border-bottom: 0;
    }

    .error {
      color: #b91c1c;
      font-weight: 600;
    }

    @media (max-width: 700px) {
      h1 {
        font-size: 1.8rem;
      }

      .meta-list {
        grid-template-columns: 1fr;
      }
    }
  </style>
</head>
<body>
  <main class="page">
    <section class="hero">
      <h1>Two-Tier App — Youssef Al Hajj Youness</h1>
      <p class="subtitle">Web Tier → Nginx Reverse Proxy → Backend API</p>
    </section>

    <section class="grid">
      <article class="card">
        <h2>Backend Health Check</h2>
        <div id="health-status" class="status-pill">Loading...</div>
        <dl class="meta-list">
          <dt>Instance ID</dt>
          <dd id="health-instance">Loading...</dd>
          <dt>AZ</dt>
          <dd id="health-az">Loading...</dd>
          <dt>Timestamp</dt>
          <dd id="health-timestamp">Loading...</dd>
        </dl>
      </article>

      <article class="card">
        <h2>Backend Data</h2>
        <p id="data-message" class="message">Loading...</p>
        <dl class="meta-list">
          <dt>Instance ID</dt>
          <dd id="data-instance">Loading...</dd>
          <dt>AZ</dt>
          <dd id="data-az">Loading...</dd>
          <dt>Timestamp</dt>
          <dd id="data-timestamp">Loading...</dd>
        </dl>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Description</th>
              </tr>
            </thead>
            <tbody id="items-body">
              <tr>
                <td colspan="3">Loading...</td>
              </tr>
            </tbody>
          </table>
        </div>
      </article>
    </section>
  </main>

  <script>
    function setText(id, value) {
      document.getElementById(id).textContent = value;
    }

    function renderItems(items) {
      var tableBody = document.getElementById("items-body");
      tableBody.innerHTML = "";

      items.forEach(function (item) {
        var row = document.createElement("tr");

        row.innerHTML =
          "<td>" + item.id + "</td>" +
          "<td>" + item.name + "</td>" +
          "<td>" + item.description + "</td>";

        tableBody.appendChild(row);
      });
    }

    async function loadHealth() {
      var response = await fetch("/api/health");

      if (!response.ok) {
        throw new Error("Health request failed with status " + response.status);
      }

      var data = await response.json();

      setText("health-status", data.status);
      setText("health-instance", data.instanceId);
      setText("health-az", data.availabilityZone);
      setText("health-timestamp", data.timestamp);
    }

    async function loadData() {
      var response = await fetch("/api/data");

      if (!response.ok) {
        throw new Error("Data request failed with status " + response.status);
      }

      var data = await response.json();

      setText("data-message", data.message);
      setText("data-instance", data.instanceId);
      setText("data-az", data.availabilityZone);
      setText("data-timestamp", data.timestamp);
      renderItems(data.items);
    }

    async function initializePage() {
      try {
        await loadHealth();
      } catch (error) {
        setText("health-status", "Unavailable");
        setText("health-instance", "Request failed");
        setText("health-az", "Request failed");
        setText("health-timestamp", error.message);
        document.getElementById("health-status").classList.add("error");
      }

      try {
        await loadData();
      } catch (error) {
        setText("data-message", "Backend data unavailable");
        setText("data-instance", "Request failed");
        setText("data-az", "Request failed");
        setText("data-timestamp", error.message);
        document.getElementById("items-body").innerHTML =
          '<tr><td colspan="3" class="error">Unable to load backend items.</td></tr>';
      }
    }

    document.addEventListener("DOMContentLoaded", initializePage);
  </script>
</body>
</html>
HTML

rm -f /etc/nginx/conf.d/default.conf

cat > /etc/nginx/conf.d/app.conf <<EOF
server {
    listen 80;
    server_name _;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://${internal_alb_dns};
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

systemctl enable nginx
systemctl restart nginx
