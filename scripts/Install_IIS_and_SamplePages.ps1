# Install IIS with all subfeatures
Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature

# Create directory structure for websites
$websiteRoot = "C:\inetpub\wwwroot"
$subpages = @("connection-info", "about", "contact")

foreach ($page in $subpages) {
    New-Item -ItemType Directory -Path "$websiteRoot\$page" -Force
}

# Create connection info page content
$connectionInfoContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>Connection Information</title>
    <style>
        :root {
            --primary-color: #2c3e50;
            --secondary-color: #34495e;
            --background-color: #ecf0f1;
            --text-color: #333;
            --border-color: #bdc3c7;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            line-height: 1.6;
            color: var(--text-color);
            background-color: var(--background-color);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }

        .nav {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            background-color: #2c3e50;
            padding: 15px;
            text-align: center;
        }

        .nav a {
            color: white;
            text-decoration: none;
            margin: 0 15px;
        }

        .nav a:hover {
            text-decoration: underline;
        }

        .container {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 700px;
            overflow: hidden;
            margin-top: 60px;
        }

        .header {
            background-color: var(--primary-color);
            color: white;
            text-align: center;
            padding: 15px;
            font-weight: 300;
        }

        .header h1 {
            font-size: 1.5rem;
            letter-spacing: 1px;
        }

        .info-table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
        }

        .info-table tr {
            transition: background-color 0.3s ease;
        }

        .info-table tr:nth-child(even) {
            background-color: #f8f9fa;
        }

        .info-table tr:hover {
            background-color: #f1f3f4;
        }

        .info-table td {
            padding: 12px 15px;
            border-bottom: 1px solid var(--border-color);
        }

        .info-table td:first-child {
            font-weight: 600;
            color: var(--secondary-color);
            width: 40%;
        }

        .info-table td:last-child {
            text-align: right;
            color: #555;
        }

        .speed-test-row {
            background-color: #f0f0f0;
            font-weight: bold;
        }

        @media (max-width: 600px) {
            .container {
                margin: 60px 10px 0;
            }
        }
    </style>
</head>
<body>
    <div class="nav">
        <a href="/">Home</a>
        <a href="/about/">About</a>
        <a href="/contact/">Contact</a>
    </div>

    <script type="text/javascript">
        var timerStart = Date.now();
    </script>

    <div class="nav">
        <a href="/">Home</a>
        <a href="/connection-info/">Connection Information</a>
        <a href="/about/">About</a>
        <a href="/contact/">Contact</a>
    </div>

    <div class="container">
        <div class="header">
            <h1>Connection Information</h1>
        </div>
        <table class="info-table">
            <tr>
                <td>Current Time</td>
                <td id="current-time"></td>
            </tr>
            <tr>
                <td>Timestamp (Unix)</td>
                <td id="timestamp"></td>
            </tr>
            <tr>
                <td>Hostname</td>
                <td id="hostname"></td>
            </tr>
            <tr>
                <td>Host</td>
                <td id="host"></td>
            </tr>
            <tr>
                <td>Invoked Host</td>
                <td id="invoked-host"></td>
            </tr>
            <tr>
                <td>Server Protocol</td>
                <td id="server-protocol"></td>
            </tr>
            <tr>
                <td>Time to DOM Ready</td>
                <td id="dom-ready-time">Calculating...</td>
            </tr>
            <tr>
                <td>Time to Full Page Load</td>
                <td id="full-page-load-time">Calculating...</td>
            </tr>
            <tr class="speed-test-row">
                <td>Speed Test (bps)</td>
                <td id="speed-bps">Running test...</td>
            </tr>
            <tr class="speed-test-row">
                <td>Speed Test (kbps)</td>
                <td id="speed-kbps">Running test...</td>
            </tr>
            <tr class="speed-test-row">
                <td>Speed Test (Mbps)</td>
                <td id="speed-mbps">Running test...</td>
            </tr>
        </table>
    </div>

    <script>
        // Configuration for speed test
        var imageAddr = "https://upload.wikimedia.org/wikipedia/commons/2/2d/Snake_River_%285mb%29.jpg"; 
        var downloadSize = 7300000; // bytes

        function updateDateTime() {
            const now = new Date();
            
            const formattedTime = now.toLocaleString("en-US", {
                year: "numeric",
                month: "long",
                day: "numeric",
                hour: "2-digit",
                minute: "2-digit",
                second: "2-digit",
                hour12: true
            });
            
            const unixTimestamp = Math.floor(now.getTime() / 1000);
            
            document.getElementById("current-time").textContent = formattedTime;
            document.getElementById("timestamp").textContent = unixTimestamp;
        }

        function updateConnectionInfo() {
            document.getElementById("hostname").textContent = window.location.hostname || "Unknown";
            document.getElementById("host").textContent = window.location.host || "Unknown";
            document.getElementById("invoked-host").textContent = window.location.origin || "Unknown";
            document.getElementById("server-protocol").textContent = window.location.protocol.replace(":", "");
        }

        function MeasureConnectionSpeed() {
            var startTime, endTime;
            var download = new Image();
            
            download.onload = function () {
                endTime = (new Date()).getTime();
                showResults();
            }
            
            download.onerror = function (err, msg) {
                document.getElementById("speed-bps").textContent = "Test failed";
                document.getElementById("speed-kbps").textContent = "Test failed";
                document.getElementById("speed-mbps").textContent = "Test failed";
            }
            
            startTime = (new Date()).getTime();
            var cacheBuster = "?nnn=" + startTime;
            download.src = imageAddr + cacheBuster;
            
            function showResults() {
                var duration = (endTime - startTime) / 1000;
                var bitsLoaded = downloadSize * 8;
                var speedBps = (bitsLoaded / duration).toFixed(2);
                var speedKbps = (speedBps / 1024).toFixed(2);
                var speedMbps = (speedKbps / 1024).toFixed(2);

                document.getElementById("speed-bps").textContent = speedBps + " bps";
                document.getElementById("speed-kbps").textContent = speedKbps + " kbps";
                document.getElementById("speed-mbps").textContent = speedMbps + " Mbps";
            }
        }

        // Update time every second
        updateDateTime();
        setInterval(updateDateTime, 1000);

        // Other calculations
        updateConnectionInfo();

        // DOM Ready and Full Page Load timing
        document.addEventListener("DOMContentLoaded", function() {
            const domReadyTime = Date.now() - timerStart;
            document.getElementById("dom-ready-time").textContent = `${domReadyTime} ms`;
        });

        window.addEventListener("load", function() {
            const fullPageLoadTime = Date.now() - timerStart;
            document.getElementById("full-page-load-time").textContent = `${fullPageLoadTime} ms`;
            
            // Start speed test automatically
            MeasureConnectionSpeed();
        });
    </script>
</body>
</html>
'@

# Create main page with links to subpages
$mainPageContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>Welcome to IIS Demo</title>
    <style>
        :root {
            --primary-color: #2c3e50;
            --secondary-color: #34495e;
            --background-color: #ecf0f1;
            --text-color: #333;
            --border-color: #bdc3c7;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            line-height: 1.6;
            color: var(--text-color);
            background-color: var(--background-color);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }

        .nav {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            background-color: var(--primary-color);
            padding: 15px;
            text-align: center;
            z-index: 1000;
        }

        .nav a {
            color: white;
            text-decoration: none;
            margin: 0 15px;
            transition: opacity 0.3s ease;
        }

        .nav a:hover {
            opacity: 0.8;
        }

        .container {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 700px;
            overflow: hidden;
            margin-top: 60px;
            padding: 30px;
        }

        .header {
            background-color: var(--primary-color);
            color: white;
            text-align: center;
            padding: 15px;
            margin: -30px -30px 30px -30px;
        }

        .header h1 {
            font-size: 1.5rem;
            letter-spacing: 1px;
        }

        p {
            margin-bottom: 15px;
            color: var(--text-color);
        }

        @media (max-width: 600px) {
            .container {
                margin: 60px 10px 0;
            }
        }
    </style>
</head>
<body>
    <div class="nav">
        <a href="/">Home</a>
        <a href="/connection-info/">Connection Information</a>
        <a href="/about/">About</a>
        <a href="/contact/">Contact</a>
    </div>

    <div class="container">
        <div class="header">
            <h1>Welcome to IIS Demo Site</h1>
        </div>
        <p>Welcome to our IIS demonstration website. This site showcases various features and capabilities of Internet Information Services (IIS).</p>
        <p>Feel free to explore different sections using the navigation menu above. Each page demonstrates different aspects of web hosting and server capabilities.</p>
    </div>
</body>
</html>
'@

# Create about page
$aboutContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>About - IIS Demo</title>
    <style>
        :root {
            --primary-color: #2c3e50;
            --secondary-color: #34495e;
            --background-color: #ecf0f1;
            --text-color: #333;
            --border-color: #bdc3c7;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            line-height: 1.6;
            color: var(--text-color);
            background-color: var(--background-color);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }

        .nav {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            background-color: var(--primary-color);
            padding: 15px;
            text-align: center;
            z-index: 1000;
        }

        .nav a {
            color: white;
            text-decoration: none;
            margin: 0 15px;
            transition: opacity 0.3s ease;
        }

        .nav a:hover {
            opacity: 0.8;
        }

        .container {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 700px;
            overflow: hidden;
            margin-top: 60px;
            padding: 30px;
        }

        .header {
            background-color: var(--primary-color);
            color: white;
            text-align: center;
            padding: 15px;
            margin: -30px -30px 30px -30px;
        }

        .header h1 {
            font-size: 1.5rem;
            letter-spacing: 1px;
        }

        p {
            margin-bottom: 15px;
            color: var(--text-color);
        }

        @media (max-width: 600px) {
            .container {
                margin: 60px 10px 0;
            }
        }
    </style>
</head>
<body>
    <div class="nav">
        <a href="/">Home</a>
        <a href="/connection-info/">Connection Information</a>
        <a href="/about/">About</a>
        <a href="/contact/">Contact</a>
    </div>

    <div class="container">
        <div class="header">
            <h1>About Us</h1>
        </div>
        <p>This is a demonstration website showcasing the capabilities of Internet Information Services (IIS), Microsoft's powerful web server software.</p>
        <p>Our site features multiple pages demonstrating different aspects of web hosting, including:</p>
        <p>• A connection information page showing real-time server and network statistics<br>
           • Multiple page templates with consistent styling<br>
           • Clean and responsive design that works on all devices</p>
        <p>This demo site is perfect for learning about web hosting and server management with IIS.</p>
    </div>
</body>
</html>
'@

# Create contact page
$contactContent = @'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>Contact - IIS Demo</title>
    <style>
        :root {
            --primary-color: #2c3e50;
            --secondary-color: #34495e;
            --background-color: #ecf0f1;
            --text-color: #333;
            --border-color: #bdc3c7;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            line-height: 1.6;
            color: var(--text-color);
            background-color: var(--background-color);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }

        .nav {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            background-color: var(--primary-color);
            padding: 15px;
            text-align: center;
            z-index: 1000;
        }

        .nav a {
            color: white;
            text-decoration: none;
            margin: 0 15px;
            transition: opacity 0.3s ease;
        }

        .nav a:hover {
            opacity: 0.8;
        }

        .container {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 700px;
            overflow: hidden;
            margin-top: 60px;
            padding: 30px;
        }

        .header {
            background-color: var(--primary-color);
            color: white;
            text-align: center;
            padding: 15px;
            margin: -30px -30px 30px -30px;
        }

        .header h1 {
            font-size: 1.5rem;
            letter-spacing: 1px;
        }

        p {
            margin-bottom: 15px;
            color: var(--text-color);
        }

        .contact-info {
            background-color: var(--background-color);
            padding: 20px;
            border-radius: 4px;
            margin-top: 20px;
        }

        @media (max-width: 600px) {
            .container {
                margin: 60px 10px 0;
            }
        }
    </style>
</head>
<body>
    <div class="nav">
        <a href="/">Home</a>
        <a href="/connection-info/">Connection Information</a>
        <a href="/about/">About</a>
        <a href="/contact/">Contact</a>
    </div>

    <div class="container">
        <div class="header">
            <h1>Contact Us</h1>
        </div>
        <p>Welcome to our contact page. This is a demo page showcasing how a contact section might look in a professional IIS-hosted website.</p>
        <p>In a real-world scenario, this page would contain contact forms, business hours, and various ways to get in touch with the organization.</p>
        <div class="contact-info">
            <p><strong>Demo Contact Information:</strong></p>
            <p>• Email: demo@example.com<br>
               • Phone: (555) 123-4567<br>
               • Address: 123 Demo Street, Sample City</p>
        </div>
    </div>
</body>
</html>
'@

# Save all pages
Set-Content -Path "$websiteRoot\index.html" -Value $mainPageContent
Set-Content -Path "$websiteRoot\about\index.html" -Value $aboutContent
Set-Content -Path "$websiteRoot\contact\index.html" -Value $contactContent
Set-Content -Path "$websiteRoot\connection-info\index.html" -Value $connectionInfoContent

# Configure IIS website settings
Import-Module WebAdministration

# Check if index.html is already in default documents
$defaultDocs = Get-WebConfiguration //defaultDocument/files/* | Select-Object -ExpandProperty value
if ($defaultDocs -notcontains "index.html") {
    # Add index.html only if it doesn't exist
    Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter "//defaultDocument/files" -Name "." -Value @{value='index.html'}
}

# Set directory browsing
Set-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Filter "//directoryBrowse" -Name "enabled" -Value "True"

# Add cache control headers
$webConfigContent = @'
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <staticContent>
            <clientCache cacheControlMode="DisableCache" />
        </staticContent>
        <httpProtocol>
            <customHeaders>
                <add name="Cache-Control" value="no-cache, no-store, must-revalidate" />
                <add name="Pragma" value="no-cache" />
                <add name="Expires" value="0" />
            </customHeaders>
        </httpProtocol>
    </system.webServer>
</configuration>
'@

Set-Content -Path "$websiteRoot\web.config" -Value $webConfigContent

Write-Host "IIS installation and website setup completed successfully!"
Write-Host "You can access the website at http://localhost/"
