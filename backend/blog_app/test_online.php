<?php
require __DIR__.'/vendor/autoload.php';
$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$user = App\Models\User::first();
$token = $user->createToken('test')->plainTextToken;

$ch = curl_init('http://localhost:8000/api/current-user');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'accept: application/json',
    'Authorization: Bearer ' . $token,
]);

$result = curl_exec($ch);
curl_close($ch);

echo "Response 1 (should be true because middleware ran): \n" . $result . "\n\n";

// simulate time passing
Illuminate\Support\Facades\Cache::forget('user-is-online-' . $user->id);

$ch2 = curl_init('http://localhost:8000/api/posts');
curl_setopt($ch2, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch2, CURLOPT_HTTPHEADER, [
    'accept: application/json',
]); // UNAUTHENTICATED REQUEST

$result2 = curl_exec($ch2);
curl_close($ch2);

echo "Response 2 (should be false for author): \n" . $result2 . "\n";
