<!DOCTYPE html>
<html>
<head>
    <title>Password Reset - TRAVELIN</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            font-family: 'Arial', sans-serif;
            background-color: #f5f7fa;
            margin: 0;
            padding: 0;
            color: #333;
        }
        .email-container {
            max-width: 600px;
            margin: 30px auto;
            background: #ffffff;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        }
        .email-header {
            background: linear-gradient(135deg, #506dab 0%, #4CAF50 100%);
            padding: 30px 20px;
            text-align: center;
            color: white;
        }
        .email-header img {
            max-width: 180px;
            margin-bottom: 15px;
        }
        .email-header h2 {
            margin: 0;
            font-size: 24px;
            font-weight: 700;
            letter-spacing: 0.5px;
        }
        .email-body {
            padding: 40px;
        }
        .email-body h1 {
            font-size: 22px;
            color: #2c3e50;
            margin-top: 0;
            margin-bottom: 25px;
            font-weight: 600;
        }
        .email-body p {
            font-size: 16px;
            line-height: 1.6;
            margin-bottom: 25px;
            color: #555;
        }
        .btn-reset {
            display: inline-block;
            padding: 12px 30px;
            background: linear-gradient(135deg, #506dab 0%, #4CAF50 100%);
            color: white !important;
            text-decoration: none;
            border-radius: 50px;
            font-weight: 600;
            font-size: 16px;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(80, 109, 171, 0.3);
            margin: 15px 0;
        }
        .btn-reset:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(80, 109, 171, 0.4);
        }
        .divider {
            height: 1px;
            background: #eaeaea;
            margin: 30px 0;
        }
        .email-footer {
            text-align: center;
            padding: 20px;
            background: #f8f9fa;
            font-size: 14px;
            color: #777;
        }
        .social-icons {
            margin: 20px 0;
        }
        .social-icons a {
            display: inline-block;
            margin: 0 10px;
            color: #506dab;
            font-size: 20px;
        }
        .travel-tip {
            background: #f8f9fa;
            border-left: 4px solid #506dab;
            padding: 15px;
            margin: 25px 0;
            font-style: italic;
            color: #555;
        }
    </style>
</head>
<body>
    <div class="email-container">
        <div class="email-header">
            <!-- Replace with your logo -->
            <h2>TRAVELIN</h2>
            <h2>Password Reset Request</h2>
        </div>
        <div class="email-body">
            <h1>Hello {{ $user->name }},</h1>
            <p>We received a request to reset the password for your TRAVELIN account. Click the button below to set a new password:</p>
            
            <div style="text-align: center;">
                <a href="{{ $actionlink }}" class="btn-reset">Reset My Password</a>
            </div>
            
            <p>If you didn't request this password reset, please disregard this email - your account remains secure.</p>
            
            <div class="divider"></div>
            
            <div class="travel-tip">
                <strong>Traveler's Tip:</strong> Unlock exclusive deals for your next adventure! Log in to discover special discounts on our featured destinations.
            </div>
        </div>
        <div class="email-footer">
            <div class="social-icons">
                <a href="#">📱</a>
                <a href="#">📘</a>
                <a href="#">📸</a>
                <a href="#">🐦</a>
            </div>
            <p>&copy; {{ date('Y') }} TRAVELIN. All rights reserved.</p>
            <p style="font-size: 12px; margin-top: 10px;">
                Need help? Contact us at <a href="mailto:support@travelin.com" style="color: #506dab;">support@travelin.com</a>
            </p>
        </div>
    </div>
</body>
</html>