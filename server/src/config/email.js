const nodemailer = require('nodemailer');

// Get configuration from environment variables
const emailConfig = {
  host: process.env.EMAIL_HOST || 'smtp.gmail.com',
  port: parseInt(process.env.SMTP_PORT || '587'),
  secure: process.env.EMAIL_SECURE === 'true', // true for 465, false for other ports
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
  // Connection timeout settings (longer defaults for deployed servers)
  connectionTimeout: parseInt(process.env.EMAIL_CONNECTION_TIMEOUT || '30000'), // 30 seconds (increased for deployed servers)
  socketTimeout: parseInt(process.env.EMAIL_SOCKET_TIMEOUT || '30000'), // 30 seconds
  greetingTimeout: parseInt(process.env.EMAIL_GREETING_TIMEOUT || '10000'), // 10 seconds
  // Connection pool settings
  pool: process.env.EMAIL_POOL === 'true', // Use connection pooling
  maxConnections: parseInt(process.env.EMAIL_MAX_CONNECTIONS || '5'),
  maxMessages: parseInt(process.env.EMAIL_MAX_MESSAGES || '100'),
  // Retry settings
  retry: {
    attempts: parseInt(process.env.EMAIL_RETRY_ATTEMPTS || '3'),
    delay: parseInt(process.env.EMAIL_RETRY_DELAY || '2000'), // 2 seconds
  },
  // TLS options for better compatibility
  tls: {
    rejectUnauthorized: process.env.EMAIL_TLS_REJECT_UNAUTHORIZED !== 'false',
    // Remove outdated cipher specification - let Node.js use secure defaults
  },
  // Debug mode (set EMAIL_DEBUG=true to enable)
  debug: process.env.EMAIL_DEBUG === 'true',
  logger: process.env.EMAIL_DEBUG === 'true',
};

// Create transporter
const transporter = nodemailer.createTransport(emailConfig);

// Verify transporter configuration with better error handling
const verifyEmailConnection = async () => {
  // Skip verification if disabled via environment variable
  if (process.env.SKIP_EMAIL_VERIFICATION === 'true') {
    console.log('⚠️  Email verification skipped (SKIP_EMAIL_VERIFICATION=true)');
    console.log('📧 Email will be attempted when needed, but connection is not verified');
    return false;
  }

  // Check if email credentials are provided
  if (!emailConfig.auth.user || !emailConfig.auth.pass) {
    console.warn('⚠️  Email credentials not configured. Email functionality will be disabled.');
    console.warn('   Set SMTP_USER and SMTP_PASS environment variables to enable email.');
    return false;
  }

  try {
    console.log(`🔍 Verifying email connection to ${emailConfig.host}:${emailConfig.port}...`);
    
    // Set a timeout for the verification
    const verifyPromise = new Promise((resolve, reject) => {
      transporter.verify((error, success) => {
        if (error) {
          reject(error);
        } else {
          resolve(success);
        }
      });
    });

    // Add overall timeout
    const timeoutPromise = new Promise((_, reject) => {
      setTimeout(() => {
        reject(new Error('Email verification timeout - server may be unreachable or firewall blocking connection'));
      }, emailConfig.connectionTimeout + 5000);
    });

    await Promise.race([verifyPromise, timeoutPromise]);
    console.log('✅ Email server is ready to send messages');
    console.log(`📧 SMTP Host: ${emailConfig.host}:${emailConfig.port}`);
    return true;
  } catch (error) {
    console.error('❌ Email configuration error:', error.message);
    console.error('📋 Connection details:', {
      host: emailConfig.host,
      port: emailConfig.port,
      secure: emailConfig.secure,
      user: emailConfig.auth.user ? `${emailConfig.auth.user.substring(0, 3)}***` : 'not set',
    });
    
    console.warn('⚠️  App will continue running, but email functionality may not work.');
    console.warn('   Email sending will be attempted when needed, but may fail.');
    
    // Provide helpful troubleshooting information
    if (error.code === 'ETIMEDOUT' || error.message.includes('timeout')) {
      console.error('\n💡 Troubleshooting tips:');
      console.error('   1. Check if the SMTP host and port are correct');
      console.error('   2. Verify firewall rules allow outbound connections on port', emailConfig.port);
      console.error('   3. Test connectivity: telnet', emailConfig.host, emailConfig.port);
      console.error('   4. For Gmail: Use App Password (not regular password)');
      console.error('   5. Try port 465 with EMAIL_SECURE=true');
      console.error('   6. Consider alternative SMTP services:');
      console.error('      - SendGrid (port 587)');
      console.error('      - Mailgun (port 587)');
      console.error('      - AWS SES (port 587)');
      console.error('      - Mailtrap (for testing)');
      console.error('\n   To skip verification on startup, set: SKIP_EMAIL_VERIFICATION=true');
    }
    
    // Don't throw error - allow app to continue but email won't work
    return false;
  }
};

// Verify connection on startup (non-blocking)
// Only verify if credentials are provided and verification is not skipped
if (emailConfig.auth.user && emailConfig.auth.pass && process.env.SKIP_EMAIL_VERIFICATION !== 'true') {
  verifyEmailConnection().catch(() => {
    // Error already logged
  });
} else if (!emailConfig.auth.user || !emailConfig.auth.pass) {
  console.warn('⚠️  Email credentials not configured. Set SMTP_USER and SMTP_PASS to enable email.');
}

// Email templates
const emailTemplates = {
  verification: (name, verificationLink) => `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body {
          font-family: 'Arial', sans-serif;
          line-height: 1.6;
          color: #333;
          background-color: #f4f4f4;
          margin: 0;
          padding: 0;
        }
        .container {
          max-width: 600px;
          margin: 20px auto;
          background: #ffffff;
          border-radius: 10px;
          overflow: hidden;
          box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .header {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          padding: 30px;
          text-align: center;
          color: white;
        }
        .header h1 {
          margin: 0;
          font-size: 28px;
        }
        .content {
          padding: 40px 30px;
        }
        .content h2 {
          color: #333;
          font-size: 22px;
          margin-bottom: 20px;
        }
        .content p {
          color: #666;
          font-size: 16px;
          margin-bottom: 20px;
        }
        .button {
          display: inline-block;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: #ffffff !important;
          padding: 14px 35px;
          text-decoration: none;
          border-radius: 6px;
          font-weight: bold;
          margin: 20px 0;
          text-align: center;
        }
        .footer {
          background: #f8f9fa;
          padding: 20px 30px;
          text-align: center;
          font-size: 14px;
          color: #999;
        }
        .divider {
          height: 1px;
          background: #e0e0e0;
          margin: 30px 0;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>🏪 Classifieds Marketplace</h1>
        </div>
        <div class="content">
          <h2>Welcome, ${name}! 👋</h2>
          <p>Thank you for signing up with Classifieds Marketplace! We're excited to have you on board.</p>
          <p>To start posting ads and connecting with buyers and sellers in your area, please verify your email address by clicking the button below:</p>
          <div style="text-align: center;">
            <a href="${verificationLink}" class="button">Verify Email Address</a>
          </div>
          <div class="divider"></div>
          <p style="font-size: 14px; color: #999;">If the button doesn't work, copy and paste this link into your browser:</p>
          <p style="font-size: 14px; color: #667eea; word-break: break-all;">${verificationLink}</p>
          <p style="font-size: 14px; color: #999; margin-top: 30px;">This verification link will expire in 24 hours.</p>
        </div>
        <div class="footer">
          <p>If you didn't create this account, please ignore this email.</p>
          <p>&copy; 2025 Classifieds Marketplace. All rights reserved.</p>
        </div>
      </div>
    </body>
    </html>
  `,

  passwordReset: (name, resetLink) => `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body {
          font-family: 'Arial', sans-serif;
          line-height: 1.6;
          color: #333;
          background-color: #f4f4f4;
          margin: 0;
          padding: 0;
        }
        .container {
          max-width: 600px;
          margin: 20px auto;
          background: #ffffff;
          border-radius: 10px;
          overflow: hidden;
          box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        .header {
          background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
          padding: 30px;
          text-align: center;
          color: white;
        }
        .header h1 {
          margin: 0;
          font-size: 28px;
        }
        .content {
          padding: 40px 30px;
        }
        .content h2 {
          color: #333;
          font-size: 22px;
          margin-bottom: 20px;
        }
        .content p {
          color: #666;
          font-size: 16px;
          margin-bottom: 20px;
        }
        .button {
          display: inline-block;
          background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
          color: #ffffff !important;
          padding: 14px 35px;
          text-decoration: none;
          border-radius: 6px;
          font-weight: bold;
          margin: 20px 0;
        }
        .footer {
          background: #f8f9fa;
          padding: 20px 30px;
          text-align: center;
          font-size: 14px;
          color: #999;
        }
        .warning {
          background: #fff3cd;
          border-left: 4px solid #ffc107;
          padding: 15px;
          margin: 20px 0;
          border-radius: 4px;
        }
        .divider {
          height: 1px;
          background: #e0e0e0;
          margin: 30px 0;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>🔒 Password Reset</h1>
        </div>
        <div class="content">
          <h2>Hello, ${name}</h2>
          <p>We received a request to reset your password for your Classifieds Marketplace account.</p>
          <p>Click the button below to create a new password:</p>
          <div style="text-align: center;">
            <a href="${resetLink}" class="button">Reset Password</a>
          </div>
          <div class="divider"></div>
          <p style="font-size: 14px; color: #999;">If the button doesn't work, copy and paste this link into your browser:</p>
          <p style="font-size: 14px; color: #f5576c; word-break: break-all;">${resetLink}</p>
          <div class="warning">
            <p style="margin: 0; color: #856404;">⚠️ This password reset link will expire in 1 hour.</p>
          </div>
          <p style="font-size: 14px; color: #999; margin-top: 20px;">If you didn't request this password reset, please ignore this email and your password will remain unchanged.</p>
        </div>
        <div class="footer">
          <p>For security reasons, never share this link with anyone.</p>
          <p>&copy; 2025 Classifieds Marketplace. All rights reserved.</p>
        </div>
      </div>
    </body>
    </html>
  `,
};

// Send email function with retry logic
const sendEmail = async ({ to, subject, html }, retryCount = 0) => {
  try {
    const mailOptions = {
      from: process.env.EMAIL_FROM || 'noreply@classifieds.com',
      to,
      subject,
      html,
    };

    // Add timeout wrapper for sendMail
    const sendPromise = transporter.sendMail(mailOptions);
    const timeoutPromise = new Promise((_, reject) => {
      setTimeout(() => {
        reject(new Error(`Email send timeout after ${emailConfig.socketTimeout}ms`));
      }, emailConfig.socketTimeout + 5000);
    });

    const info = await Promise.race([sendPromise, timeoutPromise]);
    console.log('✅ Email sent:', info.messageId);
    return { success: true, messageId: info.messageId };
  } catch (error) {
    const maxRetries = emailConfig.retry.attempts;
    
    // Retry on timeout or connection errors
    if (
      retryCount < maxRetries &&
      (error.code === 'ETIMEDOUT' || 
       error.code === 'ECONNRESET' || 
       error.code === 'ECONNREFUSED' ||
       error.message.includes('timeout'))
    ) {
      const delay = emailConfig.retry.delay * (retryCount + 1); // Exponential backoff
      console.warn(`⚠️ Email send failed (attempt ${retryCount + 1}/${maxRetries}), retrying in ${delay}ms...`, error.message);
      
      await new Promise(resolve => setTimeout(resolve, delay));
      return sendEmail({ to, subject, html }, retryCount + 1);
    }

    // Log detailed error information
    console.error('❌ Error sending email:', {
      error: error.message,
      code: error.code,
      command: error.command,
      to,
      subject,
      attempts: retryCount + 1,
    });

    // Throw error for backward compatibility with existing try-catch blocks
    const emailError = new Error(`Failed to send email: ${error.message}`);
    emailError.code = error.code;
    emailError.originalError = error;
    throw emailError;
  }
};

module.exports = { 
  sendEmail, 
  emailTemplates,
  verifyEmailConnection,
  transporter,
};

