<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Réinitialisation du mot de passe | Voyage</title>
    <style>
        :root {
            --primary: #2d91f2; /* Bleu voyage */
            --secondary: #f39c12; /* Orange soleil */
            --light: #f8f9fa;
            --dark: #2c3e50;
            --border: #e0e6ed;
        }
        
        body {
            font-family: 'Segoe UI', Roboto, sans-serif;
            background-color: #f5f7fa;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            background-image: linear-gradient(rgba(255,255,255,0.9), rgba(255,255,255,0.9)), 
                              url('https://images.unsplash.com/photo-1506929562872-bb421503ef21?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80');
            background-size: cover;
            background-position: center;
        }
        
        .container {
            width: 100%;
            max-width: 450px;
            padding: 0 20px;
        }
        
        .card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(41, 128, 185, 0.1);
            padding: 40px;
            text-align: center;
            border: 1px solid var(--border);
        }
        
        h2 {
            color: var(--dark);
            margin-bottom: 30px;
            font-weight: 600;
            position: relative;
        }
        
        h2:after {
            content: "";
            position: absolute;
            bottom: -10px;
            left: 50%;
            transform: translateX(-50%);
            width: 50px;
            height: 3px;
            background: var(--secondary);
        }
        
        .form-group {
            margin-bottom: 20px;
            text-align: left;
        }
        
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: var(--dark);
            font-size: 14px;
        }
        
        input {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid var(--border);
            border-radius: 6px;
            font-size: 15px;
            transition: all 0.3s;
            box-sizing: border-box;
        }
        
        input:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(45, 145, 242, 0.1);
            outline: none;
        }
        
        button {
            width: 100%;
            background-color: var(--primary);
            color: white;
            border: none;
            padding: 12px;
            font-size: 16px;
            font-weight: 600;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s;
            margin-top: 10px;
        }
        
        button:hover {
            background-color: #2681d8;
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <h2>Réinitialiser votre mot de passe</h2>
            
            <form method="POST" action="{{ route('password.update') }}">
                @csrf
                <input type="hidden" name="token" value="{{ $token }}">
                
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" name="email" value="{{ $email }}" required>
                </div>
                
                <div class="form-group">
                    <label>Nouveau mot de passe</label>
                    <input type="password" name="password" required>
                </div>
                
                <div class="form-group">
                    <label>Confirmer le mot de passe</label>
                    <input type="password" name="password_confirmation" required>
                </div>
                
                <button type="submit">Réinitialiser</button>
            </form>
        </div>
    </div>
</body>
</html>