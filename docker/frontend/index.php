<?php
require 'vendor/autoload.php';

use Aws\Sqs\SqsClient;
use Aws\Exception\AwsException;

// Start the session
session_start();

// AWS SQS configuration
$region = 'us-east-1';
$queueUrl = getenv('SQS_QUEUE_URL'); // Get SQS queue URL from environment variable

// Create an SQS client
$sqsClient = new SqsClient([
    'region' => $region,
    'version' => 'latest',
    // Credentials are picked up from the EC2 IAM role
]);

$messageSent = false;
$errorMessage = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $orderId = $_POST['order_id'];
    $productId = $_POST['product_id'];
    $productName = $_POST['product_name'];
    $price = $_POST['price'];
    $quantity = $_POST['quantity'];

    $messageBody = json_encode([
        'order_id' => $orderId,
        'product_id' => $productId,
        'product_name' => $productName,
        'price' => $price,
        'quantity' => $quantity,
    ]);

    try {
        $result = $sqsClient->sendMessage([
            'QueueUrl' => $queueUrl,
            'MessageBody' => $messageBody,
        ]);
        $messageSent = true;
    } catch (AwsException $e) {
        $errorMessage = $e->getMessage();
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>SQS Message Sender</title>
</head>
<body>
    <h1>SQS Message Sender</h1>
    <?php if ($messageSent): ?>
        <p style="color: green;">Message sent successfully!</p>
    <?php elseif ($errorMessage): ?>
        <p style="color: red;">Error: <?= htmlspecialchars($errorMessage) ?></p>
    <?php endif; ?>
    <form method="post">
        <label for="order_id">Order ID:</label><br>
        <input type="text" id="order_id" name="order_id" required><br><br>

        <label for="product_id">Product ID:</label><br>
        <input type="text" id="product_id" name="product_id" required><br><br>

        <label for="product_name">Product Name:</label><br>
        <input type="text" id="product_name" name="product_name" required><br><br>

        <label for="price">Price:</label><br>
        <input type="number" step="0.01" id="price" name="price" required><br><br>

        <label for="quantity">Quantity:</label><br>
        <input type="number" id="quantity" name="quantity" required><br><br>

        <input type="submit" value="Send Message">
    </form>
</body>
</html>
