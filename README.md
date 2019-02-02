# OSXVpnL2tp
A UI implementation of through L2TP VPN setup and connection on Mac OS X platform.

# Application process
The process simulate whole process of l2tp vpn setup and connection on OS X platform. First, write a file /etc/ppp/options. Then, complete l2tp vpn management. 

# Projects
VPNManager and MacVpnL2tp. VPNManager is the project for VPN creation exec. MacVpnL2tp arranges commandlines, VPNManager, UI and other trivias together as the final app.

# Initial server IP is 10.5.1.7, 
Initial IP represents Zhejiang University. Feel free to change IP value in the source code if necessary.

# Drawback
The application occupies system vpn tunnel while running. Consequence is that vpn apps such as shadowsocks will be invalid. Instead we can use SwitchyOmega on Chrome to access outer vpns.  

# Vendors
Our project VPNManager is a simplified oc version of macosvpn: https://github.com/halo/macosvpn
We use STPrivilegedTask to gain privileged system access: https://github.com/sveinbjornt/STPrivilegedTask

# License
MIT 2018 jiangyangshen.
