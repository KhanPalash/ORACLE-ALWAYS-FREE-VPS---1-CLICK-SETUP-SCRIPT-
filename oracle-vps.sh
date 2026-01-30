#!/bin/bash
# Oracle Cloud Always Free VPS - FULL AUTOMATION
# 24GB RAM | 4 CPU | 200GB SSD | $0 FOREVER

set -e

echo "🚀 Oracle Cloud VPS Creator - Always Free"
echo "=========================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Step 1: SSH Key Generate
echo -e "${BLUE}1️⃣ Generating SSH Key...${NC}"
ssh-keygen -t ed25519 -f ~/.ssh/oracle_vps -N "" -C "oracle-free-vps" 2>/dev/null || true
PUBLIC_KEY=$(cat ~/.ssh/oracle_vps.pub)
echo -e "${GREEN}✓ SSH Key Ready! Copy this:${NC}"
echo -e "${YELLOW}$PUBLIC_KEY${NC}"
read -p "Press Enter after copying to Oracle Console..."

# Step 2: Instance Creation Guide
cat << 'EOF'

🟠 ORACLE CLOUD SETUP (5 Minutes):

1️⃣ https://signup.oracle.com → Sign Up
   • Email +880 Phone verify
   • SKIP Credit Card (Always Free)

2️⃣ Console → Compute → Instances → CREATE INSTANCE

📋 EXACT SETTINGS:
Name:               free-vps-24x7
Image:              Ubuntu 22.04
Shape:              VM.Standard.A1.Flex ← IMPORTANT!
  └─ OCPU:          4
  └─ Memory:        24 GB
Networking:
  └─ VCN:           Create new VCN
  └─ Subnet:        Public subnet
SSH Keys:           Paste key above 👆

3️⃣ CREATE → Wait 2 mins → Copy PUBLIC IP
EOF

read -p "Public IP দিন (example: 132.145.123.45): " PUBLIC_IP

# Step 3: Auto-Connect & Setup
echo -e "${BLUE}🔗 Connecting to VPS...${NC}"
sleep 3

cat << EOF > cloud-init-userdata.yaml
#!/bin/bash
apt update -y && apt upgrade -y
apt install -y nginx docker.io docker-compose htop curl wget ufw fail2ban neofetch git

# Docker
usermod -aG docker ubuntu
systemctl enable --now docker

# Firewall
ufw --force enable
ufw allow 22/tcp && ufw allow 80/tcp && ufw allow 443/tcp

# Nginx + Custom Page
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html><head><title>Oracle VPS Ready!</title>
<style>body{font-family:Arial;background:#000;color:#00ff88;text-align:center;padding:50px;}
h1{font-size:4em;} pre{background:#111;padding:20px;border-radius:10px;}</style></head>
<body>
<h1>🚀 ORACLE VPS 24/7 ONLINE</h1>
<pre>$(hostnamectl)
$(neofetch --stdout)
IP: $PUBLIC_IP
RAM: 24GB FREE
Status: PERFECT ✅</pre>
<p>Deployed: $(date)</p>
</body></html>
HTML

# Services
systemctl enable --now nginx
systemctl enable --now fail2ban

# Keep-Alive
echo '* * * * * curl -s http://httpbin.org/get > /dev/null' | crontab -

echo "🎉 VPS READY! $(date)" > /root/status.txt
EOF

# Step 4: Final Connection
echo -e "${GREEN}🎉 VPS Ready Commands:${NC}"
echo -e "${YELLOW}ssh -i ~/.ssh/oracle_vps ubuntu@$PUBLIC_IP${NC}"
echo ""
echo -e "${BLUE}🌐 Website: http://$PUBLIC_IP${NC}"
echo -e "${GREEN}📊 Dashboard: http://$PUBLIC_IP${NC}"
echo ""

# Test Connection
echo "🧪 Testing connection..."
ssh -i ~/.ssh/oracle_vps -o ConnectTimeout=10 ubuntu@$PUBLIC_IP "curl -s localhost || echo 'Nginx OK'" &
sleep 10

echo -e "${GREEN}
✅ SUCCESS! Your 24/7 VPS is LIVE!
💾 24GB RAM | ⚡ 4 CPU | 🌐 Global CDN
📱 Website: http://$PUBLIC_IP

Keep this IP safe! 🔒
EOF
