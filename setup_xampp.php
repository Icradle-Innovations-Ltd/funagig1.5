<?php
// XAMPP Setup Helper Script
// Run this in your browser to configure FunaGig for XAMPP

echo "<h1>FunaGig XAMPP Setup</h1>";

// Common XAMPP htdocs paths
$possiblePaths = [
    'C:\\xampp\\htdocs',
    'C:\\Program Files\\XAMPP\\htdocs',
    'D:\\xampp\\htdocs',
    'E:\\xampp\\htdocs',
    getenv('DOCUMENT_ROOT') ?: null
];

$htdocsPath = null;
foreach ($possiblePaths as $path) {
    if ($path && is_dir($path)) {
        $htdocsPath = $path;
        break;
    }
}

if (!$htdocsPath) {
    echo "<h2>⚠️ XAMPP htdocs not found automatically</h2>";
    echo "<p>Please manually enter your XAMPP htdocs path:</p>";
    echo "<form method='POST'>";
    echo "<input type='text' name='htdocs_path' placeholder='C:\\xampp\\htdocs' size='50' required>";
    echo "<button type='submit'>Use This Path</button>";
    echo "</form>";
    
    if (isset($_POST['htdocs_path'])) {
        $htdocsPath = $_POST['htdocs_path'];
        if (!is_dir($htdocsPath)) {
            die("<p style='color:red;'>❌ Path does not exist: $htdocsPath</p>");
        }
    } else {
        exit;
    }
}

echo "<p>✅ Found XAMPP htdocs: <strong>$htdocsPath</strong></p>";

$projectName = 'funagig';
$targetPath = $htdocsPath . DIRECTORY_SEPARATOR . $projectName;
$sourcePath = __DIR__;

echo "<h2>Setup Steps:</h2>";

// Step 1: Create directory if needed
if (!is_dir($targetPath)) {
    echo "<p>📁 Creating directory: $targetPath</p>";
    if (!mkdir($targetPath, 0755, true)) {
        die("<p style='color:red;'>❌ Failed to create directory. Check permissions.</p>");
    }
}

// Step 2: Copy files (or create symlink suggestion)
echo "<h3>Option 1: Copy Files (Recommended)</h3>";
echo "<p>Would you like to copy files from:</p>";
echo "<pre>Source: $sourcePath\nTarget: $targetPath</pre>";
echo "<form method='POST'>";
echo "<input type='hidden' name='copy_files' value='1'>";
echo "<input type='hidden' name='htdocs_path' value='$htdocsPath'>";
echo "<button type='submit'>Copy Project Files to XAMPP</button>";
echo "</form>";

if (isset($_POST['copy_files'])) {
    echo "<h3>Copying files...</h3>";
    
    function copyDirectory($src, $dst) {
        $dir = opendir($src);
        @mkdir($dst);
        while (($file = readdir($dir)) !== false) {
            if ($file != '.' && $file != '..') {
                if (is_dir($src . '/' . $file)) {
                    copyDirectory($src . '/' . $file, $dst . '/' . $file);
                } else {
                    copy($src . '/' . $file, $dst . '/' . $file);
                }
            }
        }
        closedir($dir);
    }
    
    // Exclude certain directories
    $exclude = ['.git', 'node_modules', '.vscode'];
    
    $items = scandir($sourcePath);
    $copied = 0;
    foreach ($items as $item) {
        if ($item == '.' || $item == '..' || in_array($item, $exclude)) continue;
        
        $src = $sourcePath . DIRECTORY_SEPARATOR . $item;
        $dst = $targetPath . DIRECTORY_SEPARATOR . $item;
        
        if (is_dir($src)) {
            if (!is_dir($dst)) {
                mkdir($dst, 0755, true);
            }
            copyDirectory($src, $dst);
            echo "<p>✅ Copied directory: $item</p>";
        } else {
            copy($src, $dst);
            echo "<p>✅ Copied file: $item</p>";
        }
        $copied++;
    }
    
    echo "<h3>✅ Copy Complete! ($copied items)</h3>";
}

// Step 3: Update config
echo "<h3>Configuration Update:</h3>";
$configPath = $targetPath . DIRECTORY_SEPARATOR . 'php' . DIRECTORY_SEPARATOR . 'config.php';
if (file_exists($configPath)) {
    $config = file_get_contents($configPath);
    $newUrl = "http://localhost/$projectName";
    $config = preg_replace("/define\('APP_URL',\s*'[^']*'\);/", "define('APP_URL', '$newUrl');", $config);
    file_put_contents($configPath, $config);
    echo "<p>✅ Updated APP_URL in config.php to: $newUrl</p>";
}

// Step 4: Update app.js
echo "<h3>Frontend Configuration:</h3>";
$appJsPath = $targetPath . DIRECTORY_SEPARATOR . 'js' . DIRECTORY_SEPARATOR . 'app.js';
if (file_exists($appJsPath)) {
    $appJs = file_get_contents($appJsPath);
    $newApiUrl = "$newUrl/php/api.php";
    $appJs = preg_replace(
        "/const BACKEND_SERVER_IP = '[^']*';/",
        "const BACKEND_SERVER_IP = 'localhost';",
        $appJs
    );
    $appJs = preg_replace(
        "/: `http:\/\/\$\{BACKEND_SERVER_IP\}:\$\{BACKEND_PORT\}\/[^`]*`;/",
        ": `$newApiUrl`;",
        $appJs
    );
    file_put_contents($appJsPath, $appJs);
    echo "<p>✅ Updated API base URL in app.js to: $newApiUrl</p>";
}

echo "<h2>✅ Setup Complete!</h2>";
echo "<p><strong>Your FunaGig is now configured for XAMPP.</strong></p>";
echo "<p>Access your application at:</p>";
echo "<ul>";
echo "<li>Home: <a href='http://localhost/$projectName/index.html' target='_blank'>http://localhost/$projectName/index.html</a></li>";
echo "<li>API: <a href='http://localhost/$projectName/php/api.php' target='_blank'>http://localhost/$projectName/php/api.php</a></li>";
echo "</ul>";
echo "<p><strong>Next Steps:</strong></p>";
echo "<ol>";
echo "<li>Make sure XAMPP Apache and MySQL are running</li>";
echo "<li>Run <a href='http://localhost/$projectName/setup_database.php' target='_blank'>setup_database.php</a> to initialize the database</li>";
echo "<li>Start using the application!</li>";
echo "</ol>";
?>

