import os
import json
import time
import boto3
import psycopg2
from psycopg2.extras import RealDictCursor
from botocore.exceptions import NoCredentialsError, PartialCredentialsError

# Set up environment variables
SQS_QUEUE_URL = os.getenv("SQS_QUEUE_URL")
DB_HOST = os.getenv("DB_HOST", "postgres")  # Kubernetes service name for PostgreSQL
DB_NAME = os.getenv("DB_NAME", "orders")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "password")

# AWS SQS client
sqs = boto3.client("sqs", region_name="us-east-1")

# Connect to PostgreSQL
def connect_db():
    try:
        connection = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD
        )
        print("Connected to PostgreSQL")
        return connection
    except psycopg2.Error as e:
        print("Error connecting to PostgreSQL:", e)
        time.sleep(5)
        return connect_db()

conn = connect_db()

# Create orders table if it doesn't exist
def create_orders_table():
    try:
        with conn.cursor() as cursor:
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS orders (
                    order_id SERIAL PRIMARY KEY,
                    product_id VARCHAR(50) NOT NULL,
                    product_name VARCHAR(100),
                    quantity INTEGER NOT NULL,
                    price NUMERIC(10, 2) NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)
            conn.commit()
            print("Orders table is ready")
    except Exception as e:
        print("Error creating orders table:", e)

create_orders_table()

# Process an individual order
def process_order(order):
    try:
        product_id = order.get("product_id")
        product_name = order.get("product_name")
        quantity = order.get("quantity")
        price = order.get("price")

        # Insert order into PostgreSQL
        with conn.cursor(cursor_factory=RealDictCursor) as cursor:
            insert_query = """
                INSERT INTO orders (product_id, product_name, quantity, price)
                VALUES (%s, %s, %s, %s)
            """
            cursor.execute(insert_query, (product_id, product_name, quantity, price))
            conn.commit()
            print(f"Processed order {order.get('order_id')} for product {product_name}")
    except Exception as e:
        print("Error processing order:", e)
        conn.rollback()

# Main loop for reading messages from SQS and processing orders
def main():
    print("Starting Order Processor...")
    while True:
        try:
            # Receive messages from SQS
            response = sqs.receive_message(
                QueueUrl=SQS_QUEUE_URL,
                MaxNumberOfMessages=10,
                WaitTimeSeconds=20
            )

            messages = response.get("Messages", [])
            if messages:
                for message in messages:
                    order = json.loads(message["Body"])
                    process_order(order)

                    # Delete message from SQS after processing
                    sqs.delete_message(
                        QueueUrl=SQS_QUEUE_URL,
                        ReceiptHandle=message["ReceiptHandle"]
                    )
            else:
                print("No messages in queue. Waiting...")
        except NoCredentialsError:
            print("Error: AWS credentials not found. Check IAM role or AWS credentials.")
            time.sleep(10)
        except PartialCredentialsError:
            print("Error: Incomplete AWS credentials provided.")
            time.sleep(10)
        except Exception as e:
            print("Error receiving messages from SQS:", e)
            time.sleep(5)

if __name__ == "__main__":
    main()
