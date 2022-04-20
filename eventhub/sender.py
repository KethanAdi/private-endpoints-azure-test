import asyncio
from azure.eventhub.aio import EventHubProducerClient
from azure.eventhub import EventData

async def run():
    # Create a producer client to send messages to the event hub.
    # Specify a connection string to your event hubs namespace and
    # the event hub name.
    producer = EventHubProducerClient.from_connection_string(conn_str="Endpoint=sb://eventhubexamle11.servicebus.windows.net/;SharedAccessKeyName=p1;SharedAccessKey=1/gbEHeQh0Bd4JiF2P3PfC2c3nmu8VAC8KKpoGoPJn8=;EntityPath=eventhub1", eventhub_name="eventhub1")
    async with producer:
        # Create a batch.
        event_data_batch = await producer.create_batch()

        # Add events to the batch.
        event_data_batch.add(EventData('1First event '))
        event_data_batch.add(EventData('2Second event'))
        event_data_batch.add(EventData('3Third event'))

        # Send the batch of events to the event hub.
        await producer.send_batch(event_data_batch)

loop = asyncio.get_event_loop()
loop.run_until_complete(run())
