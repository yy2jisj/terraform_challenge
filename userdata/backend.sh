#!/bin/bash
set -euxo pipefail

yum update -y
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

mkdir -p /opt/backend
cd /opt/backend

npm init -y
npm install express

cat > /opt/backend/server.js <<'EOF'
const express = require("express");
const http = require("http");

const app = express();
const port = 3000;
const metadataHost = "169.254.169.254";

const catalogItems = [
  { id: 1, name: "VPC", description: "Virtual Private Cloud" },
  { id: 2, service: "ALB", description: "Application Load Balancer" },
  { id: 3, service: "ASG", description: "Auto Scaling Group" },
  { id: 4, service: "IAM", description: "Identity and Access Management" },
  { id: 5, service: "SSM", description: "Systems Manager Parameter Store" }
];

app.use(express.json());

function metadataRequest(options, body) {
  return new Promise((resolve, reject) => {
    const request = http.request(options, (response) => {
      let data = "";

      response.on("data", (chunk) => {
        data += chunk;
      });

      response.on("end", () => {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          resolve(data.trim());
          return;
        }

        reject(new Error("Metadata request failed with status " + response.statusCode));
      });
    });

    request.on("error", reject);

    if (body) {
      request.write(body);
    }

    request.end();
  });
}

async function getMetadataToken() {
  return metadataRequest({
    host: metadataHost,
    path: "/latest/api/token",
    method: "PUT",
    headers: {
      "X-aws-ec2-metadata-token-ttl-seconds": "21600"
    }
  });
}

async function getInstanceMetadata() {
  try {
    const token = await getMetadataToken();
    const headers = {
      "X-aws-ec2-metadata-token": token
    };

    const instanceId = await metadataRequest({
      host: metadataHost,
      path: "/latest/meta-data/instance-id",
      method: "GET",
      headers: headers
    });

    const availabilityZone = await metadataRequest({
      host: metadataHost,
      path: "/latest/meta-data/placement/availability-zone",
      method: "GET",
      headers: headers
    });

    return {
      instanceId: instanceId,
      availabilityZone: availabilityZone
    };
  } catch (error) {
    console.error("Unable to load instance metadata:", error.message);

    return {
      instanceId: "unavailable",
      availabilityZone: "unavailable"
    };
  }
}

app.get("/api/health", async (req, res) => {
  const metadata = await getInstanceMetadata();

  res.status(200).json({
    status: "healthy",
    tier: "backend",
    instanceId: metadata.instanceId,
    availabilityZone: metadata.availabilityZone,
    timestamp: new Date().toISOString()
  });
});

app.get("/api/data", async (req, res) => {
  const metadata = await getInstanceMetadata();

  res.status(200).json({
    message: "Hello from the Backend Tier!",
    instanceId: metadata.instanceId,
    availabilityZone: metadata.availabilityZone,
    timestamp: new Date().toISOString(),
    items: catalogItems
  });
});

app.listen(port, "0.0.0.0", () => {
  console.log("Server listening on port 3000");
});
EOF

cat > /etc/systemd/system/backend.service <<'EOF'
[Unit]
Description=Node.js Express backend
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/backend
ExecStart=/usr/bin/node /opt/backend/server.js
Restart=always
RestartSec=5
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable backend
systemctl start backend
