const { WebSocketServer } = require('ws');

const PORT = process.env.PORT || 8080;
const wss = new WebSocketServer({ port: PORT });

// Map of registered device_id -> WebSocket instance
const deviceSessions = new Map();

console.log(`[Linko Relay] E2EE Zero-Knowledge Relay Server running on port ${PORT}`);

wss.on('connection', (ws) => {
  let boundDeviceId = null;

  ws.on('message', (message) => {
    try {
      const data = JSON.parse(message.toString());

      if (data.action === 'REGISTER') {
        boundDeviceId = data.device_id;
        deviceSessions.set(boundDeviceId, ws);
        console.log(`[Linko Relay] Device registered: ${boundDeviceId}`);
        ws.send(JSON.stringify({ status: 'REGISTERED', device_id: boundDeviceId }));
      } else if (data.action === 'RELAY') {
        const targetId = data.target_id;
        const targetSession = deviceSessions.get(targetId);

        if (targetSession && targetSession.readyState === 1) {
          // Zero-knowledge forwarding: relay encrypted payload without inspection
          targetSession.send(JSON.stringify({
            action: 'INCOMING_RELAY',
            sender_id: data.sender_id,
            encrypted_blob: data.encrypted_blob,
            timestamp: new Date().toISOString()
          }));
          console.log(`[Linko Relay] E2EE Blob forwarded from ${data.sender_id} -> ${targetId}`);
        } else {
          ws.send(JSON.stringify({ status: 'UNDELIVERABLE', target_id: targetId }));
        }
      }
    } catch (err) {
      console.error('[Linko Relay] Packet parse error:', err.message);
    }
  });

  ws.on('close', () => {
    if (boundDeviceId) {
      deviceSessions.delete(boundDeviceId);
      console.log(`[Linko Relay] Device disconnected: ${boundDeviceId}`);
    }
  });
});
