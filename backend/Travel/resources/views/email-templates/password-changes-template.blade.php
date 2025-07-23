<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Password Changed Notification</title>
    <style>
        /* Base styles */
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
            margin: 0;
            padding: 0;
            background-color: #f5f5f5;
        }
        
        /* Container */
        .container {
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
            background-color: #ffffff;
        }
        
        /* Header */
        .header {
            text-align: center;
            padding: 20px 0;
            border-bottom: 1px solid #eeeeee;
        }
        
        /* Content */
        .content {
            padding: 20px 0;
        }
        
        /* Footer */
        .footer {
            text-align: center;
            padding: 20px 0;
            border-top: 1px solid #eeeeee;
            font-size: 12px;
            color: #999999;
        }
        
        /* Button */
        .button {
            display: inline-block;
            padding: 10px 20px;
            background-color: #3490dc;
            color: #ffffff;
            text-decoration: none;
            border-radius: 4px;
            margin: 10px 0;
        }
        
        /* Responsive adjustments */
        @media only screen and (max-width: 600px) {
            .container {
                width: 100%;
                padding: 10px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Your Password Has Been Changed</h1>
        </div>
        
        <div class="content">
            <p>Hello {{ $user->name }},</p>
            
            <p>This is a confirmation that the password for your account has been successfully changed.</p>
            
            <div style="background-color: #f9f9f9; padding: 15px; border-radius: 4px; margin: 20px 0;">
                <p><strong>Account Details:</strong></p>
                <p>Username/Email: {{ $user->email }}</p>
                <p>Password Changed At: {{ now()->format('F j, Y \a\t g:i a') }}</p>
            </div>
            
            <p>If you did not request this change, please contact our support team immediately.</p>
            
            <p style="text-align: center;">
                <a href="{{ route('contact') }}" class="button">Contact Support</a>
            </p>
        </div>
        
        <div class="footer">
            <p>&copy; {{ date('Y') }} {{ config('app.name') }}. All rights reserved.</p>
            <p>If you're having trouble with the button above, copy and paste the URL below into your web browser:</p>
            <p>{{ route('contact') }}</p>
        </div>
    </div>
</body>
</html>