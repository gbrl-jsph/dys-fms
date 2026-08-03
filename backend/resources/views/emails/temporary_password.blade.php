<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Your DYS Financial Management System Account</title>
    <style>
        body { font-family: Arial, Helvetica, sans-serif; color: #1C1B22; background-color: #F7F7FA; margin: 0; padding: 24px; }
        .card { max-width: 480px; margin: 0 auto; background: #FFFFFF; border: 1px solid #E4E4EA; border-radius: 12px; padding: 24px; }
        h1 { font-size: 18px; margin: 0 0 12px; }
        p { font-size: 14px; line-height: 1.6; margin: 0 0 12px; }
        ul { font-size: 14px; line-height: 1.7; margin: 0 0 12px; padding-left: 20px; }
        .password { display: inline-block; font-family: monospace; font-size: 16px; font-weight: bold; color: #4338CA; background: #EEEDFC; border-radius: 8px; padding: 8px 12px; margin: 4px 0 12px; }
        .note { font-size: 12px; color: #8B8C97; margin-top: 12px; }
    </style>
</head>
<body>
    <div class="card">
        <h1>Welcome to the DYS Financial Management System</h1>
        <p>Dear {{ $userName }},</p>
        <p>An account has been created for you. Your account details are:</p>
        <ul>
            <li><strong>Role:</strong> {{ $userRole }}</li>
            @if ($sectorName)
                <li><strong>Business sector:</strong> {{ $sectorName }}</li>
            @endif
        </ul>
        <p>Your one-time temporary password is:</p>
        <span class="password">{{ $temporaryPassword }}</span>
        <p>Sign in to the DYS Financial Management System using this password. You must change your password after your first login to keep your account secure &mdash; this security step will be enforced in a future update.</p>
        <p>Regards,<br>The DYS Financial Management System Team</p>
        <p class="note">If you did not expect this email, you can ignore it or contact your Business Owner.</p>
    </div>
</body>
</html>
