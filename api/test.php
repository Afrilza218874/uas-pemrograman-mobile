<?php
header('Content-Type: text/plain');
error_reporting(E_ALL);
ini_set('display_errors', '1');

$host   = getenv('DB_HOST');
$port   = getenv('DB_PORT') ?: 4000;
$user   = getenv('DB_USER');
$pass   = getenv('DB_PASS');
$dbname = getenv('DB_NAME');

echo "Testing TiDB Cloud Connection...\n";
echo "Host: $host\n";
echo "User: $user\n";
echo "Pass: " . substr($pass, 0, 2) . "***\n";

$caBundles = [
    '/etc/pki/tls/certs/ca-bundle.crt',
    '/etc/ssl/certs/ca-certificates.crt',
    '/usr/local/etc/openssl/cert.pem',
];
$caPath = '';
foreach ($caBundles as $ca) {
    if (file_exists($ca)) {
        $caPath = $ca;
        break;
    }
}
echo "CA Path: $caPath\n\n";

// Test 1: MySQLi
echo "--- TEST 1: MYSQLI ---\n";
$mysqli = mysqli_init();
mysqli_ssl_set($mysqli, NULL, NULL, $caPath, NULL, NULL);
if (mysqli_real_connect($mysqli, $host, $user, $pass, $dbname, $port, NULL, MYSQLI_CLIENT_SSL)) {
    echo "MySQLi Connection SUCCESS!\n";
    mysqli_close($mysqli);
} else {
    echo "MySQLi Error: " . mysqli_connect_error() . "\n";
}

echo "\n--- TEST 2: PDO ---\n";
try {
    $dsn = "mysql:host=$host;port=$port;dbname=$dbname;charset=utf8mb4";
    $options = [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::MYSQL_ATTR_SSL_CA => $caPath,
        PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => true,
    ];
    $pdo = new PDO($dsn, $user, $pass, $options);
    echo "PDO Connection SUCCESS (Verify=True)!\n";
} catch (Exception $e) {
    echo "PDO Error (Verify=True): " . $e->getMessage() . "\n";
    
    echo "\nTrying PDO with Verify=False...\n";
    try {
        $options[PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT] = false;
        $pdo2 = new PDO($dsn, $user, $pass, $options);
        echo "PDO Connection SUCCESS (Verify=False)!\n";
    } catch (Exception $e2) {
        echo "PDO Error (Verify=False): " . $e2->getMessage() . "\n";
    }
}
