from pynput.mouse import Controller
import asyncio
import websockets
import ujson  
import uvloop  

# uvloop for better async performance
asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())  

class WebSocketServer:
    def __init__(self, host="0.0.0.0", port=5007):
        self.host = host
        self.port = port
        self.clients = set()

        self.delta_x_buffer = 0  # Accumulate X movements
        self.delta_y_buffer = 0  # Accumulate Y movements
        self.lock = asyncio.Lock()  # Prevent race conditions
        self.max_delta = 7  # Maximum amount to move at once
        self.sensitivity_factor = 1.2  # Adjusted sensitivity factor
        
        self.mouse = Controller()  

    async def handle_connection(self, websocket):
        self.clients.add(websocket)
        print("iOS device connected!")

        try:
            async for message in websocket:
                await self.process_message(message)
        except websockets.exceptions.ConnectionClosed:
            print("Client disconnected.")
        finally:
            self.clients.remove(websocket)

    async def process_message(self, message):
        try:
            data = ujson.loads(message)  
            
            async with self.lock: 
                # Handle batched movements 
                if isinstance(data, list):  
                    for movement in data:
                        self.delta_x_buffer += movement.get("deltaX", 0)
                        self.delta_y_buffer += movement.get("deltaY", 0)
                elif isinstance(data, dict): 
                    # Handle single movement messages
                    self.delta_x_buffer += data.get("deltaX", 0)
                    self.delta_y_buffer += data.get("deltaY", 0)

        except (ValueError, KeyError, TypeError) as e:
            print(f"Error processing message: {e}")

    async def move_cursor_periodically(self):
        """ Moves the cursor every few milliseconds using the accumulated buffer. """
        while True:
            if abs(self.delta_x_buffer) > 0 or abs(self.delta_y_buffer) > 0:
                # Limit movement to avoid excessive jumps
                delta_x = max(min(self.delta_x_buffer, self.max_delta), -self.max_delta)
                delta_y = max(min(self.delta_y_buffer, self.max_delta), -self.max_delta)

                # Scale movement for sensitivity
                scaled_delta_x = delta_x * self.sensitivity_factor
                scaled_delta_y = delta_y * self.sensitivity_factor

                print(f"Moving cursor ΔX: {scaled_delta_x}, ΔY: {scaled_delta_y}")  
                self.mouse.move(scaled_delta_x, scaled_delta_y) 

                self.delta_x_buffer = 0
                self.delta_y_buffer = 0

            await asyncio.sleep(0.001)  

    async def start(self):
        server = await websockets.serve(self.handle_connection, self.host, self.port, ping_interval=None)
        print(f"WebSocket server started on ws://{self.host}:{self.port}")
        asyncio.create_task(self.move_cursor_periodically())
        await asyncio.Future() 
