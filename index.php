<?php
declare(strict_types=1);

define('VYVE_VERSION', '24.0.0');
define('DATA_DIR', __DIR__ . '/data');
define('MAX_FILE_SIZE', 10 * 1024 * 1024);
define('ALLOWED_EXTENSIONS', [
    'lua', 'luau', 'php', 'js', 'ts', 'py', 'json', 'yaml', 'yml', 
    'xml', 'toml', 'ini', 'txt', 'md', 'sh', 'bat', 'ps1', 'sql'
]);
define('AGENT_MARKER', '.agent_upload');
define('SECURITY_SALT', 'vyve_roblox_2024');

// Security functions - XOR encoded API key
function _d(string $h, string $k): string {
    $k = pack('H*', $k);
    $r = '';
    for ($i = 0; $i < strlen($h); $i += 2) {
        $b = hexdec(substr($h, $i, 2));
        $r .= chr($b ^ ord($k[($i / 2) % strlen($k)]));
    }
    return $r;
}

function getCfg(): array {
    return [
        'token' => _d('1111063a1936212d1b2a373263474661381a20061b4500130f1c080b5a7c425a171045521a4a2a03', '767976655f726f626c6f785f32303234'),
        'repo' => 'vyvegroup/StorageScripts'
    ];
}

// Anti-fake detection
function detectFakeAgent(): array {
    $ua = $_SERVER['HTTP_USER_AGENT'] ?? '';
    $ip = $_SERVER['REMOTE_ADDR'] ?? '';
    
    $suspectScore = 0;
    $reasons = [];
    
    if (empty($ua)) {
        $suspectScore += 30;
        $reasons[] = 'Empty User-Agent';
    }
    
    $botPatterns = ['/bot/i', '/crawler/i', '/spider/i', '/scraper/i'];
    foreach ($botPatterns as $pattern) {
        if (preg_match($pattern, $ua)) {
            $suspectScore += 15;
            $reasons[] = "Bot pattern detected";
            break;
        }
    }
    
    // Roblox executors have specific UA patterns
    $robloxPatterns = ['/synapse/i', '/script-ware/i', '/krnl/i', '/fluxus/i', '/electron/i', '/roblox/i'];
    $isRoblox = false;
    foreach ($robloxPatterns as $pattern) {
        if (preg_match($pattern, $ua)) {
            $isRoblox = true;
            break;
        }
    }
    
    return [
        'score' => $suspectScore,
        'is_suspect' => $suspectScore >= 50,
        'is_roblox' => $isRoblox,
        'reasons' => $reasons,
        'ua' => $ua,
        'ip' => $ip
    ];
}

function generateSecurityToken(): string {
    $ts = time();
    $ip = $_SERVER['REMOTE_ADDR'] ?? '0.0.0.0';
    $rand = bin2hex(random_bytes(8));
    return hash('sha256', $ts . $ip . $rand . SECURITY_SALT) . '.' . $ts;
}

if (!is_dir(DATA_DIR)) mkdir(DATA_DIR, 0755, true);

// Parse request - use query params to avoid dot issues
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$method = $_SERVER['REQUEST_METHOD'];
$query = $_GET;

// IMPORTANT: Routes without dots to avoid Wasmer static file handling
// /api/list, /api/upload, /api/delete - no dots
// /s/scriptname - for raw script access (no extension in URL)
// /?raw=script.lua - query param approach

// Handle raw script access via query param (avoids dot in path)
if (isset($query['raw'])) {
    serveRaw($query['raw']);
    exit;
}

// Handle raw script access via /s/{slug} (no extension in URL)
if (preg_match('#^/s/([a-zA-Z0-9_-]+)$#', $path, $matches)) {
    serveRawBySlug($matches[1]);
    exit;
}

// Handle loadstring info endpoint
if ($path === '/ls' || $path === '/loadstring') {
    showLoadstringInfo();
    exit;
}

// API routes
if (str_starts_with($path, '/api/')) {
    header('Content-Type: application/json');
    handleApi($path, $method);
    exit;
}

if ($path === '/docs' || $path === '/skill') {
    header('Content-Type: text/markdown');
    echo getDocsMd();
    exit;
}

if ($path === '/security') {
    header('Content-Type: application/json');
    echo json_encode([
        'security_token' => generateSecurityToken(),
        'fake_detection' => detectFakeAgent(),
        'timestamp' => time()
    ]);
    exit;
}

// Debug endpoint
if ($path === '/debug') {
    header('Content-Type: application/json');
    echo json_encode([
        'success' => true,
        'version' => VYVE_VERSION,
        'php' => PHP_VERSION,
        'data_dir' => DATA_DIR,
        'writable' => is_writable(DATA_DIR),
        'scripts_count' => count(getScripts()),
        'security' => detectFakeAgent()
    ]);
    exit;
}

renderUI();

function handleApi(string $path, string $method): void {
    $fakeCheck = detectFakeAgent();
    
    try {
        if (str_contains($path, '/list')) apiList();
        elseif (str_contains($path, '/upload')) apiUpload($method);
        elseif (str_contains($path, '/delete')) apiDelete($method);
        else jsonError('Not found. Use /api/list, /api/upload, /api/delete', 404);
    } catch (Exception $e) {
        jsonError($e->getMessage(), 500);
    }
}

function apiList(): void {
    $scripts = getScripts();
    echo json_encode([
        'success' => true,
        'count' => count($scripts),
        'scripts' => $scripts
    ]);
}

function getScripts(): array {
    $scripts = [];
    foreach (glob(DATA_DIR . '/*.*') as $f) {
        if (basename($f) === AGENT_MARKER) continue;
        $scripts[] = [
            'name' => basename($f),
            'slug' => pathinfo($f, PATHINFO_FILENAME),
            'size' => filesize($f),
            'modified' => filemtime($f),
            'extension' => pathinfo($f, PATHINFO_EXTENSION),
            'is_agent' => isAgent(basename($f)),
        ];
    }
    usort($scripts, fn($a, $b) => $b['modified'] - $a['modified']);
    return $scripts;
}

function isAgent(string $name): bool {
    $mf = DATA_DIR . '/' . AGENT_MARKER;
    return file_exists($mf) && in_array($name, json_decode(file_get_contents($mf), true) ?: []);
}

function markAgent(string $name): void {
    $mf = DATA_DIR . '/' . AGENT_MARKER;
    $list = file_exists($mf) ? json_decode(file_get_contents($mf), true) ?: [] : [];
    if (!in_array($name, $list)) {
        $list[] = $name;
        file_put_contents($mf, json_encode($list));
    }
}

function apiUpload(string $method): void {
    if ($method !== 'POST') jsonError('Use POST method', 405);
    
    $isAgent = isset($_POST['agent']) || isset($_GET['agent']);
    $filename = null;
    $content = null;
    
    if (!empty($_FILES['file']) && $_FILES['file']['error'] === UPLOAD_ERR_OK) {
        $filename = basename($_FILES['file']['name']);
        $content = file_get_contents($_FILES['file']['tmp_name']);
    } elseif (!empty($_POST['code']) || !empty($_POST['content'])) {
        $code = $_POST['code'] ?? $_POST['content'];
        $ext = $_POST['extension'] ?? $_POST['ext'] ?? 'lua';
        $filename = $_POST['filename'] ?? genName($ext);
        $content = $code;
    } else {
        $input = json_decode(file_get_contents('php://input'), true);
        if ($input && !empty($input['content'])) {
            $filename = $input['filename'] ?? genName($input['extension'] ?? 'lua');
            $content = $input['content'];
            $isAgent = $isAgent || ($input['agent'] ?? false);
        }
    }
    
    if (!$filename || !$content) jsonError('No file or content. Use file upload or code/content parameter', 400);
    
    $ext = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
    if (empty($ext)) {
        $ext = 'lua';
        $filename .= '.lua';
    }
    
    if (strlen($content) > MAX_FILE_SIZE) jsonError('File too large (max 10MB)', 400);
    
    // Sanitize filename
    $filename = preg_replace('/[^a-zA-Z0-9._-]/', '_', $filename);
    
    file_put_contents(DATA_DIR . '/' . $filename, $content);
    if ($isAgent) markAgent($filename);
    
    $slug = pathinfo($filename, PATHINFO_FILENAME);
    
    echo json_encode([
        'success' => true,
        'message' => 'Uploaded successfully',
        'filename' => $filename,
        'slug' => $slug,
        'size' => strlen($content),
        'extension' => $ext,
        'is_agent' => $isAgent,
        'url' => '/s/' . $slug,
        'raw_url' => '/?raw=' . urlencode($filename),
        'loadstring' => 'loadstring(game:HttpGet("' . getBaseUrl() . '/s/' . $slug . '"))()'
    ]);
}

function apiDelete(string $method): void {
    $input = json_decode(file_get_contents('php://input'), true);
    $filename = $input['filename'] ?? $_POST['filename'] ?? $_GET['filename'] ?? $_GET['file'] ?? null;
    if (!$filename) jsonError('Filename required. Use filename or file parameter', 400);
    
    $filepath = DATA_DIR . '/' . basename($filename);
    if (!file_exists($filepath)) jsonError('File not found: ' . $filename, 404);
    
    $mf = DATA_DIR . '/' . AGENT_MARKER;
    if (file_exists($mf)) {
        $list = array_filter(json_decode(file_get_contents($mf), true) ?: [], fn($f) => $f !== basename($filename));
        file_put_contents($mf, json_encode(array_values($list)));
    }
    
    unlink($filepath);
    echo json_encode(['success' => true, 'message' => 'Deleted', 'filename' => $filename]);
}

function serveRaw(string $filename): void {
    $filename = basename($filename);
    $filepath = DATA_DIR . '/' . $filename;
    
    if (!file_exists($filepath)) {
        http_response_code(404);
        echo '-- Script not found: ' . $filename;
        exit;
    }
    
    $ext = strtolower(pathinfo($filename, PATHINFO_EXTENSION));
    $mimes = [
        'lua' => 'text/plain', 'luau' => 'text/plain',
        'php' => 'text/plain', 'js' => 'text/plain', 'py' => 'text/plain'
    ];
    
    header('Content-Type: ' . ($mimes[$ext] ?? 'text/plain'));
    header('Access-Control-Allow-Origin: *');
    header('Cache-Control: no-cache');
    readfile($filepath);
    exit;
}

function serveRawBySlug(string $slug): void {
    // Find script by slug (filename without extension)
    foreach (glob(DATA_DIR . '/*.*') as $f) {
        if (basename($f) === AGENT_MARKER) continue;
        $name = pathinfo($f, PATHINFO_FILENAME);
        if (strtolower($name) === strtolower($slug)) {
            header('Content-Type: text/plain');
            header('Access-Control-Allow-Origin: *');
            header('Cache-Control: no-cache');
            readfile($f);
            exit;
        }
    }
    
    http_response_code(404);
    echo '-- Script not found: ' . $slug;
    exit;
}

function showLoadstringInfo(): void {
    $scripts = getScripts();
    $baseUrl = getBaseUrl();
    
    echo "<!DOCTYPE html>\n";
    echo "<html><head><title>Loadstring URLs</title>";
    echo "<style>
        body { font-family: 'IBM Plex Mono', monospace; background: #0f0f0f; color: #fff; padding: 20px; }
        h1 { color: #a855f7; }
        .script { background: #1a1a1a; padding: 15px; margin: 10px 0; border-radius: 8px; border-left: 3px solid #a855f7; }
        .name { color: #fbbf24; font-size: 16px; margin-bottom: 8px; }
        .ls { background: #0a0a0a; padding: 10px; border-radius: 4px; color: #4ade80; word-break: break-all; }
        .copy { cursor: pointer; color: #60a5fa; margin-left: 10px; }
        .copy:hover { color: #93c5fd; }
    </style></head><body>";
    echo "<h1>⚡ Vyve Loadstring URLs</h1>";
    echo "<p>Copy these URLs to use in your Roblox executor:</p>";
    
    foreach ($scripts as $s) {
        $ls = "loadstring(game:HttpGet(\"$baseUrl/s/{$s['slug}\"))()";
        echo "<div class='script'>";
        echo "<div class='name'>📄 {$s['name']}" . ($s['is_agent'] ? " 🤖" : "") . "</div>";
        echo "<div class='ls' id='ls-{$s['slug']}'>$ls</div>";
        echo "</div>";
    }
    
    if (empty($scripts)) {
        echo "<p>No scripts uploaded yet.</p>";
    }
    
    echo "</body></html>";
}

function getBaseUrl(): string {
    $proto = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https' : 'http';
    return $proto . '://' . ($_SERVER['HTTP_HOST'] ?? 'localhost');
}

function genName(string $ext): string {
    return 'script_' . date('Ymd_His') . '_' . substr(md5(uniqid()), 0, 6) . '.' . $ext;
}

function jsonError(string $msg, int $code): void {
    http_response_code($code);
    echo json_encode(['success' => false, 'error' => $msg, 'code' => $code]);
    exit;
}

function getDocsMd(): string {
    return <<<'MD'
# Vyve API - Roblox Loadstring Platform

> **Script Hosting for Roblox Executors**
> Base URL: `https://venxy.wasmer.app`

## Quick Start

### Loadstring Format
```lua
loadstring(game:HttpGet("https://venxy.wasmer.app/s/SCRIPT_NAME"))()
```

### Example
```lua
-- Load a script by slug (no extension needed)
loadstring(game:HttpGet("https://venxy.wasmer.app/s/myscript"))()

-- Or use query parameter
loadstring(game:HttpGet("https://venxy.wasmer.app/?raw=myscript.lua"))()
```

## API Endpoints

### List Scripts
`GET /api/list`

### Upload Script
`POST /api/upload`

Parameters:
- `file` - File upload (multipart/form-data)
- `filename` - Script name
- `code` or `content` - Script content
- `extension` or `ext` - File extension (default: lua)
- `agent` - Set to "1" to mark as AI-generated

### Delete Script
`POST /api/delete?filename=script.lua`

### Get Raw Script
- `GET /s/{slug}` - Get by slug (NO extension, NO dots!)
- `GET /?raw=script.lua` - Get by filename

## Supported Extensions
lua, luau, php, js, ts, py, json, yaml, yml, xml, toml, ini, txt, md, sh, bat, ps1, sql

## Important Notes

⚠️ **URL Format**: Use `/s/scriptname` (without extension) to avoid routing issues!

✅ Correct: `/s/myscript`
❌ Wrong: `/raw/myscript.lua` (may not work on some hosts)

## Upload via cURL
```bash
curl -X POST https://venxy.wasmer.app/api/upload \
  -F "file=@script.lua"
```

## Response Example
```json
{
  "success": true,
  "filename": "script.lua",
  "slug": "script",
  "loadstring": "loadstring(game:HttpGet(\"https://venxy.wasmer.app/s/script\"))()"
}
```
MD;
}

function renderUI(): void {
    $scriptsJson = json_encode(getScripts());
    $baseUrl = getBaseUrl();
    ?>
<!DOCTYPE html>
<html lang="en" class="scroll-smooth">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Vyve – Roblox Script Hosting</title>
<link rel="preconnect" href="https://fonts.gstatic.com">
<link href="https://fonts.googleapis.com/css2?family=Source+Sans+Pro:wght@400;600;700&family=IBM+Plex+Mono:wght@400;500;600&display=swap" rel="stylesheet">
<script src="https://cdn.tailwindcss.com"></script>
<script>
tailwind.config={darkMode:'class',theme:{extend:{fontFamily:{sans:['"Source Sans Pro"','system-ui','sans-serif'],mono:['"IBM Plex Mono"','monospace']}}}}
</script>
<style>
.grainy{background-image:url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.85' numOctaves='4' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E");opacity:.03}
@keyframes float{0%,100%{transform:translateY(0)}50%{transform:translateY(-10px)}}
@keyframes pulse-glow{0%,100%{box-shadow:0 0 10px rgba(168,85,247,.4)}50%{box-shadow:0 0 30px rgba(168,85,247,.8)}}
@keyframes gradient{0%{background-position:0% 50%}50%{background-position:100% 50%}100%{background-position:0% 50%}}
.animate-float{animation:float 3s ease-in-out infinite}
.animate-pulse-glow{animation:pulse-glow 2s ease-in-out infinite}
.animate-gradient{background-size:200% 200%;animation:gradient 3s ease infinite}
.glass{background:rgba(255,255,255,.4);backdrop-filter:blur(12px)}
.dark .glass{background:rgba(17,17,17,.4)}
.card-hover{transition:all .2s}
.card-hover:hover{transform:translateY(-2px);box-shadow:0 10px 40px -10px rgba(168,85,247,.3)}
.upload-zone{border:2px dashed rgba(168,85,247,.3);transition:all .3s}
.upload-zone:hover,.upload-zone.dragover{border-color:rgba(168,85,247,.8);background:rgba(168,85,247,.05)}
</style>
</head>
<body class="flex flex-col min-h-screen bg-white dark:bg-gray-950 text-black dark:text-white font-sans">

<!-- Header -->
<header class="sticky top-0 z-40 border-b border-gray-100 dark:border-gray-800 bg-white/80 dark:bg-gray-950/80 backdrop-blur-lg">
<div class="container mx-auto px-4 h-14 flex items-center">
<a href="/" class="flex items-center gap-2 mr-6">
<div class="w-7 h-7 rounded-lg bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center animate-pulse-glow">
<span class="text-white text-sm font-bold">V</span>
</div>
<span class="font-bold text-lg hidden sm:block">Vyve</span>
<span class="text-xs text-purple-500 hidden sm:block">Roblox Scripts</span>
</a>
<div class="flex-1 max-w-md relative">
<input type="text" id="searchInput" placeholder="Search scripts..." class="w-full h-9 pl-9 pr-3 rounded-lg bg-gray-100 dark:bg-gray-800 border-0 focus:ring-2 focus:ring-purple-500/30 text-sm">
<svg class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg>
</div>
<nav class="ml-auto flex items-center gap-2">
<a href="/ls" target="_blank" class="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-gray-600 dark:text-gray-300 hover:text-purple-500 hover:bg-purple-50 dark:hover:bg-purple-900/20 text-sm">
<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"/></svg>
<span class="hidden md:inline">Loadstring</span>
</a>
<a href="/docs" target="_blank" class="flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-gray-600 dark:text-gray-300 hover:text-yellow-600 hover:bg-yellow-50 dark:hover:bg-yellow-900/20 text-sm">
<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
<span class="hidden md:inline">Docs</span>
</a>
<button onclick="openUpload()" class="flex items-center gap-1.5 px-4 py-1.5 rounded-full bg-gradient-to-r from-purple-500 to-pink-500 text-white text-sm font-medium hover:opacity-90 transition-opacity">
<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
<span class="hidden sm:inline">Upload</span>
</button>
</nav>
</div>
</header>

<!-- Hero -->
<main class="flex-1">
<section class="container mx-auto px-4 pt-6 md:pt-12">
<div class="relative rounded-[2rem] bg-gray-950 dark:bg-gray-900 overflow-hidden">
<div class="grainy pointer-events-none absolute inset-0"></div>
<div class="relative p-8 md:p-12 lg:p-16 flex flex-col lg:flex-row items-center gap-8">
<div class="flex-1 text-center lg:text-left">
<h1 class="text-3xl md:text-4xl lg:text-5xl font-bold text-white mb-4 leading-tight">
Roblox Script Hosting<br/>
<span class="bg-gradient-to-r from-purple-400 via-pink-400 to-red-400 bg-clip-text text-transparent">with Loadstring</span>
</h1>
<p class="text-lg text-gray-400 mb-6 max-w-lg">
Upload your Lua scripts and get instant loadstring URLs for Roblox executors. Fast, free, and secure.
</p>
<div class="flex flex-wrap items-center gap-3 justify-center lg:justify-start">
<button onclick="openUpload()" class="group relative">
<span class="flex items-center gap-2 h-11 px-6 rounded-full border border-gray-600 bg-gradient-to-r from-transparent via-white/5 to-transparent text-white font-medium hover:via-white/10 transition-all">
<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"/></svg>
Upload Script
</span>
</button>
<a href="/ls" target="_blank" class="text-purple-300 underline decoration-purple-600 underline-offset-4 hover:decoration-purple-400 transition-colors">get loadstring URLs</a>
</div>
</div>
<div class="flex-1 w-full max-w-md">
<div class="bg-gray-900/50 rounded-xl overflow-hidden border border-gray-800 shadow-2xl">
<div class="flex items-center gap-2 px-4 py-3 bg-gray-800/50 border-b border-gray-700">
<div class="flex gap-1.5">
<div class="w-3 h-3 rounded-full bg-red-500/80"></div>
<div class="w-3 h-3 rounded-full bg-yellow-500/80"></div>
<div class="w-3 h-3 rounded-full bg-green-500/80"></div>
</div>
<span class="text-xs text-gray-500 font-mono ml-2">loadstring.lua</span>
</div>
<div class="p-4 font-mono text-sm leading-relaxed text-gray-300">
<div><span class="text-gray-600 mr-4">1</span><span class="text-gray-500">-- Load any script instantly</span></div>
<div><span class="text-gray-600 mr-4">2</span></div>
<div><span class="text-gray-600 mr-4">3</span><span class="text-pink-400">loadstring</span>(<span class="text-blue-400">game</span>:<span class="text-yellow-400">HttpGet</span>(</div>
<div><span class="text-gray-600 mr-4">4</span>  <span class="text-green-400">"https://venxy.wasmer.app/s/script"</span></div>
<div><span class="text-gray-600 mr-4">5</span>))()</div>
</div>
</div>
</div>
</div>
<div class="absolute -bottom-3 left-0 right-0 h-6 bg-white dark:bg-gray-950 rounded-[50%]"></div>
</div>
</section>

<!-- Scripts Section -->
<section id="scripts" class="container mx-auto px-4 py-12">
<div class="flex items-center justify-center gap-4 mb-8">
<div class="h-px flex-1 bg-gradient-to-r from-transparent to-gray-200 dark:to-gray-800"></div>
<h2 class="flex items-center gap-2 text-lg font-semibold">
Scripts
<div class="w-6 h-6 rounded bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center">
<span class="text-white text-xs font-bold">V</span>
</div>
</h2>
<div class="h-px flex-1 bg-gradient-to-l from-transparent to-gray-200 dark:to-gray-800"></div>
</div>
<div class="relative">
<div class="absolute inset-0 bg-gradient-to-br from-purple-500/10 via-pink-500/5 to-red-500/10 blur-3xl -z-10 rounded-full"></div>
<div id="scriptsGrid" class="glass rounded-xl p-4 md:p-6 grid gap-3">
<div class="text-center py-12 text-gray-400">
<svg class="w-10 h-10 mx-auto mb-3 animate-spin text-gray-300" fill="none" viewBox="0 0 24 24"><circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle><path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path></svg>
Loading...
</div>
</div>
</div>
</section>
</main>

<!-- Footer -->
<footer class="border-t border-gray-100 dark:border-gray-800 py-6">
<div class="container mx-auto px-4 flex flex-col md:flex-row items-center justify-between gap-3 text-sm text-gray-500">
<div class="flex items-center gap-2">
<div class="w-5 h-5 rounded bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center">
<span class="text-white text-xs font-bold">V</span>
</div>
<span>Vyve v<?php echo VYVE_VERSION; ?> - Roblox Script Hosting</span>
</div>
<div class="flex items-center gap-4">
<a href="/docs" target="_blank" class="hover:text-purple-500">Docs</a>
<a href="/ls" target="_blank" class="hover:text-purple-500">Loadstring</a>
<a href="/debug" target="_blank" class="hover:text-purple-500">Debug</a>
</div>
</div>
</footer>

<!-- Upload Modal -->
<div id="uploadModal" class="fixed inset-0 z-50 hidden">
<div class="absolute inset-0 bg-black/50 backdrop-blur-sm" onclick="closeUpload()"></div>
<div class="relative z-10 w-full max-w-lg mx-4 my-8 bg-white dark:bg-gray-900 rounded-xl shadow-2xl overflow-hidden">
<div class="flex items-center justify-between p-4 border-b dark:border-gray-800">
<h3 class="font-semibold">Upload Script</h3>
<button onclick="closeUpload()" class="p-1.5 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800">
<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
</button>
</div>
<div class="p-4">
<div id="uploadZone" class="upload-zone rounded-xl p-6 text-center cursor-pointer mb-4">
<input type="file" id="fileInput" class="hidden" accept=".lua,.luau,.php,.js,.py,.txt,.json">
<svg class="w-10 h-10 mx-auto mb-2 text-purple-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"/></svg>
<p class="text-sm text-gray-600 dark:text-gray-300">Drop .lua file or click to upload</p>
<p class="text-xs text-gray-400 mt-1">Supports: lua, luau, php, js, py, json, txt</p>
</div>
<div class="flex items-center gap-4 mb-4">
<div class="h-px flex-1 bg-gray-200 dark:bg-gray-700"></div>
<span class="text-xs text-gray-500">or paste code</span>
<div class="h-px flex-1 bg-gray-200 dark:bg-gray-700"></div>
</div>
<div class="mb-4">
<div class="flex gap-2 mb-2">
<input type="text" id="filenameInput" placeholder="script.lua" class="flex-1 px-3 py-2 rounded-lg bg-gray-100 dark:bg-gray-800 border-0 text-sm font-mono focus:ring-2 focus:ring-purple-500/30">
<select id="extSelect" class="px-3 py-2 rounded-lg bg-gray-100 dark:bg-gray-800 border-0 text-sm">
<option value="lua">.lua</option>
<option value="luau">.luau</option>
<option value="txt">.txt</option>
</select>
<label class="flex items-center gap-2 px-3 py-2 rounded-lg bg-gray-100 dark:bg-gray-800 cursor-pointer">
<input type="checkbox" id="agentCheck" class="rounded border-gray-300 text-purple-500 focus:ring-purple-500">
<span class="text-sm">🤖</span>
</label>
</div>
<textarea id="codeInput" rows="8" placeholder="-- Paste your Lua code here..." class="w-full px-3 py-2 rounded-lg bg-gray-100 dark:bg-gray-800 border-0 font-mono text-sm focus:ring-2 focus:ring-purple-500/30 resize-none"></textarea>
</div>
<button id="uploadBtn" onclick="doUpload()" class="w-full py-2.5 rounded-lg bg-gradient-to-r from-purple-500 to-pink-500 text-white font-medium hover:opacity-90 transition-opacity">Upload & Get Loadstring</button>
</div>
</div>
</div>

<!-- Toast -->
<div id="toast" class="fixed bottom-4 right-4 z-50 hidden">
<div class="px-4 py-3 rounded-lg shadow-lg text-white text-sm" id="toastContent"></div>
</div>

<script>
const BASE_URL='<?php echo $baseUrl; ?>';
let scripts=<?php echo $scriptsJson; ?>;

document.addEventListener('DOMContentLoaded',loadScripts);

function openUpload(){document.getElementById('uploadModal').classList.remove('hidden')}
function closeUpload(){
document.getElementById('uploadModal').classList.add('hidden');
document.getElementById('fileInput').value='';
document.getElementById('filenameInput').value='';
document.getElementById('codeInput').value='';
document.getElementById('agentCheck').checked=false;
}

const zone=document.getElementById('uploadZone');
const fileInput=document.getElementById('fileInput');
zone.onclick=()=>fileInput.click();
zone.ondragover=e=>{e.preventDefault();zone.classList.add('dragover')};
zone.ondragleave=()=>zone.classList.remove('dragover');
zone.ondrop=e=>{e.preventDefault();zone.classList.remove('dragover');if(e.dataTransfer.files[0])handleFile(e.dataTransfer.files[0])};
fileInput.onchange=e=>{if(e.target.files[0])handleFile(e.target.files[0])};

function handleFile(f){
document.getElementById('filenameInput').value=f.name.replace(/\.[^.]+$/,'');
const r=new FileReader();
r.onload=e=>document.getElementById('codeInput').value=e.target.result;
r.readAsText(f);
}

async function doUpload(){
const name=document.getElementById('filenameInput').value.trim();
const code=document.getElementById('codeInput').value.trim();
const ext=document.getElementById('extSelect').value;
const agent=document.getElementById('agentCheck').checked;
if(!code){toast('Please provide code','error');return}
const btn=document.getElementById('uploadBtn');
btn.disabled=true;btn.textContent='Uploading...';
try{
const fd=new FormData();
fd.append('filename',name||'script_'+Date.now());
fd.append('code',code);
fd.append('extension',ext);
if(agent)fd.append('agent','1');
const res=await fetch('/api/upload',{method:'POST',body:fd});
const d=await res.json();
if(d.success){
toast('Uploaded! Loadstring copied.','success');
closeUpload();
loadScripts();
if(d.loadstring){navigator.clipboard?.writeText(d.loadstring);}
}else toast(d.error||'Upload failed','error')
}catch(e){toast('Error: '+e.message,'error')}
btn.disabled=false;btn.textContent='Upload & Get Loadstring';
}

async function loadScripts(){
try{
const res=await fetch('/api/list');
const d=await res.json();
if(d.success){scripts=d.scripts;renderScripts(scripts)}
}catch(e){}
}

function renderScripts(s){
const g=document.getElementById('scriptsGrid');
if(!s.length){
g.innerHTML='<div class="col-span-full text-center py-12 text-gray-400"><svg class="w-12 h-12 mx-auto mb-3 text-gray-300 dark:text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M9 13h6m-3-3v6m5 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg><p class="font-medium mb-1">No scripts yet</p><p class="text-sm">Upload your first Lua script</p></div>';
return;
}
g.innerHTML=s.map(x=>{
const ls=`loadstring(game:HttpGet("${BASE_URL}/s/${x.slug}"))()`;
return`<div class="card-hover group p-3 rounded-lg bg-white dark:bg-gray-800/50 flex items-center gap-3">
<div class="w-9 h-9 rounded-lg bg-gradient-to-br from-purple-500 to-pink-500 flex items-center justify-center flex-shrink-0">
<span class="text-white text-xs font-bold">LUA</span>
</div>
<div class="flex-1 min-w-0">
<div class="flex items-center gap-2">
<span class="font-mono text-sm font-medium truncate">${esc(x.name)}</span>
${x.is_agent?'<span class="px-1.5 py-0.5 text-xs font-bold rounded-full bg-gradient-to-r from-purple-500 to-pink-500 text-white">🤖</span>':''}
</div>
<span class="text-xs text-gray-500">${fmtSize(x.size)} • ${fmtDate(x.modified)}</span>
</div>
<div class="flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
<button onclick="copyLs('${esc(ls)}')" class="p-1.5 rounded hover:bg-purple-100 dark:hover:bg-purple-900/30 text-purple-500" title="Copy Loadstring">
<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 5H6a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2v-1M8 5a2 2 0 002 2h2a2 2 0 002-2M8 5a2 2 0 012-2h2a2 2 0 012 2m0 0h2a2 2 0 012 2v3m2 4H10m0 0l3-3m-3 3l3 3"/></svg>
</button>
<a href="/s/${x.slug}" target="_blank" class="p-1.5 rounded hover:bg-gray-100 dark:hover:bg-gray-700" title="View Raw">
<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/></svg>
</a>
<button onclick="delScript('${esc(x.name)}')" class="p-1.5 rounded hover:bg-red-100 dark:hover:bg-red-900/30 text-red-500" title="Delete">
<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/></svg>
</button>
</div>
</div>`;
}).join('');
}

function copyLs(ls){navigator.clipboard?.writeText(ls);toast('Loadstring copied!','success')}

async function delScript(n){
if(!confirm('Delete '+n+'?'))return;
try{
const res=await fetch('/api/delete?filename='+encodeURIComponent(n));
const d=await res.json();
if(d.success){toast('Deleted','success');loadScripts()}
else toast(d.error||'Delete failed','error')
}catch(e){toast('Error: '+e.message,'error')}
}

function toast(msg,type){
const t=document.getElementById('toast'),c=document.getElementById('toastContent');
c.textContent=msg;
c.className='px-4 py-3 rounded-lg shadow-lg text-white text-sm '+(type==='error'?'bg-red-500':'bg-green-500');
t.classList.remove('hidden');
setTimeout(()=>t.classList.add('hidden'),3000);
}

function esc(s){return String(s).replace(/[&<>"']/g,function(m){return{'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m];})}
function fmtSize(b){if(b<1024)return b+' B';if(b<1048576)return(b/1024).toFixed(1)+' KB';return(b/1048576).toFixed(1)+' MB'}
function fmtDate(t){const d=new Date(t*1000),n=new Date(),diff=Math.floor((n-d)/1000);if(diff<60)return'just now';if(diff<3600)return Math.floor(diff/60)+'m ago';if(diff<86400)return Math.floor(diff/3600)+'h ago';return d.toLocaleDateString()}

document.getElementById('searchInput').addEventListener('input',function(e){
const q=e.target.value.toLowerCase();
renderScripts(scripts.filter(s=>s.name.toLowerCase().includes(q)));
});
</script>
</body>
</html>
<?php
}
?>