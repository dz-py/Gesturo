import asyncio
import websockets
import json

class WebSocketServer:
    def __init__(self, host="0.0.0.0", port=5007):
        self.host = host
        self.port = port
        self.clients = set()

    async def handle_connection(self, websocket):  # Remove path parameter
        self.clients.add(websocket)
        print("iOS device connected!")
        try:
            async for message in websocket:
                print(f"Received: {message}")
                await self.on_message(message)
        finally:
            self.clients.remove(websocket)

    async def on_message(self, message):
        # You can process the message here
        try:
            data = json.loads(message)
            print(f"Processed data: {data}")
        except json.JSONDecodeError as e:
            print(f"Error processing JSON: {e}")

    async def start(self):
        server = await websockets.serve(self.handle_connection, self.host, self.port)
        print(f"WebSocket server started on ws://{self.host}:{self.port}")
        await asyncio.Future()  # Run forever

# Main execution
if __name__ == "__main__":
    server = WebSocketServer()
    print("Starting Gesturo server and cursor controller...")
    asyncio.run(server.start())