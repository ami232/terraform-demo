from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def hello():
    env_value = os.environ.get('ENVIRONMENT', 'production')
    # Use an f-string and escape literal braces in CSS with double braces
    return f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Terraform Demo</title>
        <style>
            body {{
                font-family: Arial, sans-serif;
                max-width: 800px;
                margin: 50px auto;
                padding: 20px;
                background-color: #f5f5f5;
            }}
            .container {{
                background-color: white;
                padding: 30px;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }}
            h1 {{
                color: #2c3e50;
            }}
            .info {{
                background-color: #e8f4f8;
                padding: 15px;
                border-radius: 5px;
                margin-top: 20px;
            }}
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 Hello from Terraform!</h1>
            <p>This Flask application was deployed using Terraform Infrastructure as Code.</p>
            <div class="info">
                <strong>Environment:</strong> {env_value}<br>
                <strong>Status:</strong> ✅ Running
            </div>
        </div>
    </body>
    </html>
    """

@app.route('/health')
def health():
    """Health check endpoint for monitoring"""
    return jsonify({
        'status': 'healthy',
        'service': 'terraform-demo-app',
        'environment': os.environ.get('ENVIRONMENT', 'production')
    }), 200

@app.route('/api/info')
def info():
    """API endpoint with deployment information"""
    return jsonify({
        'message': 'Hello from Terraform Demo',
        'version': '1.0.0',
        'environment': os.environ.get('ENVIRONMENT', 'production'),
        'python_version': os.environ.get('PYTHON_VERSION', 'unknown')
    })

if __name__ == '__main__':
    # This is used when running locally only
    # Azure App Service uses port 8000 by default
    port = int(os.environ.get('PORT', 8000))
    app.run(debug=False, host='0.0.0.0', port=port)
