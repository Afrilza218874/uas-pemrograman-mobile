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
echo "Host: [$host] (len: " . strlen($host) . ")\n";
echo "User: [$user] (len: " . strlen($user) . ")\n";
echo "Pass: [" . substr($pass, 0, 2) . "***] (len: " . strlen($pass) . ")\n";

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
