import socket
import struct

# IP, die vergeben werden soll
LEASE_IP = "192.168.1.100"
SERVER_IP = "192.168.1.1"

# UDP Socket auf Port 67 (DHCP Server)
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
sock.bind(('', 67))

while True:
    data, addr = sock.recvfrom(1024)
    # Einfach die Nachricht bestätigen, ohne echte DHCP-Optionen zu prüfen
    if data[240:244] == b'\x35\x01\x01':  # DHCPDISCOVER
        # DHCP OFFER zusammenbauen
        transaction_id = data[4:8]
        offer = b''
        offer += b'\x02'              # Message type: BOOTREPLY
        offer += b'\x01'              # Hardware type: Ethernet
        offer += b'\x06'              # Hardware address length
        offer += b'\x00'              # Hops
        offer += transaction_id       # Transaction ID
        offer += b'\x00\x00'          # Seconds elapsed
        offer += b'\x00\x00'          # Flags
        offer += socket.inet_aton(SERVER_IP)  # Client IP
        offer += socket.inet_aton(LEASE_IP)   # Your IP
        offer += socket.inet_aton(SERVER_IP)  # Server IP
        offer += b'\x00'*16           # Gateway address + padding
        offer += data[28:34]          # Client MAC
        offer += b'\x00' * (236 - len(offer))  # Pad to 236 bytes
        offer += b'\x63\x82\x53\x63'  # Magic cookie
        offer += b'\x35\x01\x02'      # Option: DHCPOFFER
        offer += b'\xff'              # End
        sock.sendto(offer, ('<broadcast>', 68))

