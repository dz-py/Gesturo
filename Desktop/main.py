import asyncio
from websocket_server import WebSocketServer
from cursor_controller import CursorController  # Ensure this import is correct

class GesturoServer(WebSocketServer):
    def __init__(self, cursor_controller, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.cursor_controller = cursor_controller

    async def on_message(self, message):
        # Delegate message handling to the cursor controller
        self.cursor_controller.handle_message(message)

async def main():
    cursor_controller = CursorController()
    server = GesturoServer(cursor_controller, host="0.0.0.0", port=5007)
    await server.start()

if __name__ == "__main__":
    print("Starting Gesturo server and cursor controller...")
    asyncio.run(main())